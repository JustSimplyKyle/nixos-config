{ pkgs }:

pkgs.writeShellApplication {
  name = "mv-merge";

  runtimeInputs = with pkgs; [
    yt-dlp
    ffmpeg
    fzf
    coreutils
    gnused
    gawk
    jq
    kitty
    wget
    bc
  ];

  text = ''
    # Default settings
    DET_NOISE="-40dB"
    DET_DURATION="0.5"
    KEEP_TEMP=false
    FF_LOG="quiet"
    YTP_LOG="" 
    MANUAL_OFFSET=""
    MV_START_HINT=""
    AUDIO_START_HINT=""
    AUDIO_IN=""

    usage() {
      echo "Usage: mv-merge [options] <audio_file>"
      echo ""
      echo "Sync Options:"
      echo "  -o, --offset <val>       Set final offset directly"
      echo "  --mv-start <val>         Set MV start time (HH:MM:SS or seconds)"
      echo "  --audio-start <val>      Set local audio start time (HH:MM:SS or seconds)"
      echo ""
      echo "General Options:"
      echo "  -q, --quiet              Hide all progress"
      echo "  -v, --verbose            Show full ffmpeg logs"
      echo "  -k, --keep               Keep hash-based temp dir (enables caching)"
      echo "  -s, --sensitivity [1|2]  Presets (1: -50dB/0.2s, 2: -60dB/0.1s)"
      echo "  -h, --help               Show this help"
      exit 1
    }

    # Helper: Convert HH:MM:SS or MM:SS to seconds so bc can handle it
    to_seconds() {
      local IN="''${1:-0}"
      echo "$IN" | gawk -F: '{
        if (NF == 3) print ($1 * 3600) + ($2 * 60) + $3
        else if (NF == 2) print ($1 * 60) + $2
        else print $1
      }'
    }

    while [[ $# -gt 0 ]]; do
      case $1 in
        -o|--offset) MANUAL_OFFSET="$2"; shift 2 ;;
        --mv-start)  MV_START_HINT="$2"; shift 2 ;;
        --audio-start) AUDIO_START_HINT="$2"; shift 2 ;;
        -q|--quiet)   YTP_LOG="--quiet"; FF_LOG="quiet"; shift ;;
        -v|--verbose) FF_LOG="info"; YTP_LOG=""; shift ;;
        -k|--keep)    KEEP_TEMP=true; shift ;;
        -s|--sensitivity)
          if [ "$2" = "1" ]; then DET_NOISE="-50dB"; DET_DURATION="0.2"
          elif [ "$2" = "2" ]; then DET_NOISE="-60dB"; DET_DURATION="0.1"
          fi
          shift 2 ;;
        -h|--help)     usage ;;
        -*) echo "Unknown option $1"; usage ;;
        *) AUDIO_IN="$1"; shift ;;
      esac
    done

    if [ ! -f "$AUDIO_IN" ]; then usage; fi

    # 1. Prepare Metadata
    BASENAME=$(basename "$AUDIO_IN" | sed 's/\.[^.]*$//')
    [ "$YTP_LOG" != "--quiet" ] && echo "🔍 Reading metadata..."
    
    META_ARTIST=$(ffprobe -loglevel quiet -show_entries format_tags=artist -of default=noprint_wrappers=1:nokey=1 "$AUDIO_IN" || echo "")
    META_TITLE=$(ffprobe -loglevel quiet -show_entries format_tags=title -of default=noprint_wrappers=1:nokey=1 "$AUDIO_IN" || echo "")

    if [ -n "$META_TITLE" ]; then SEARCH_TERM="$META_TITLE"
    else SEARCH_TERM=$(echo "$BASENAME" | sed -E 's/^[0-9]+[\.\s-]*//'); fi
    [ -n "$META_ARTIST" ] && SEARCH_TERM="$SEARCH_TERM $META_ARTIST"
    SEARCH_QUERY="$SEARCH_TERM official music video"

    # 2. Search and Select
    SELECTED=$(yt-dlp $YTP_LOG "ytsearch20:$SEARCH_QUERY" --extractor-arg "youtube:skip=hls,dash" --ignore-no-formats \
      -j --flat-playlist | \
      jq -r '[
        (.title // "No Title" | gsub("[\t\n\r\"]"; "")), 
        (.id // "NoID" | gsub("[\t\n\r\"\u0027 ]"; "")), 
        (.uploader // "Unknown" | gsub("[\t\n\r\"]"; "")), 
        (.duration_string // "??:??"),
        (.thumbnails[-1].url // .thumbnail // "")
      ] | @tsv' | \
      fzf --ansi --delimiter '\t' --with-nth "1,3,4" --header "Select MV" \
          --preview-window="right:60%" \
          --preview "
              kitty +kitten icat --clear --stdin=no --silent --transfer-mode=file > /dev/tty < /dev/null 2>&1
              VIDEO_ID=\"{2}\"
              THUMB_URL={5}
              [[ \"\$THUMB_URL\" == *\"webp\"* ]] && EXT=\"webp\" || EXT=\"jpg\"
              THUMB_FILE=\"/tmp/mv-thumb-\''${VIDEO_ID}.\''${EXT}\"
              if [ ! -f \"\$THUMB_FILE\" ] && [ -n \"\$THUMB_URL\" ]; then wget -q \"\$THUMB_URL\" -O \"\$THUMB_FILE\"; fi
              kitty +kitten icat --silent --stdin=no --transfer-mode=file --place \"\''${FZF_PREVIEW_COLUMNS}x\''${FZF_PREVIEW_LINES}@0x0\" \"\$THUMB_FILE\" 2>/dev/null
          ")

    [ -z "$SELECTED" ] && exit 0
    VIDEO_ID=$(echo "$SELECTED" | cut -f2)

    # 3. Deterministic Path
    [ "$YTP_LOG" != "--quiet" ] && printf "calc hash... "
    FILE_HASH=$(sha256sum "$AUDIO_IN" | cut -d' ' -f1)
    TMP_DIR="/tmp/mv-merge-''${FILE_HASH:0:12}-$VIDEO_ID"
    mkdir -p "$TMP_DIR"
    DOWNLOADED_VIDEO="$TMP_DIR/video.mkv"

    # 4. Download
    [ "$YTP_LOG" != "--quiet" ] && echo "📥 Working in: $TMP_DIR"
    yt-dlp $YTP_LOG -f "bestvideo+bestaudio/best" \
      --embed-subs --sub-langs "zh-TW,zh-Hant,zh-HK,en,ja" \
      --remux-video mkv \
      --output "$DOWNLOADED_VIDEO" \
      "https://youtu.be/$VIDEO_ID"

    if [ -f "$DOWNLOADED_VIDEO" ]; then
      # --- SYNC LOGIC ---
      # Crucial: all descriptive echo/printf commands here must use >&2
      # so they don't get captured into variables during $(get_start_time)
      get_start_time() {
        local FILE="$1" HINT="$2" LABEL="$3"
        if [ -n "$HINT" ]; then
            local CLEAN_HINT
            CLEAN_HINT=$(to_seconds "$HINT")
            [ "$YTP_LOG" != "--quiet" ] && echo "   $LABEL Start:    ''${CLEAN_HINT}s (Hint)" >&2
            echo "$CLEAN_HINT"
        else
            [ "$YTP_LOG" != "--quiet" ] && printf "   Detecting %s... " "$LABEL" >&2
            local RAW_VAL
            RAW_VAL=$(ffmpeg -loglevel info -i "$FILE" -af "silencedetect=n=$DET_NOISE:d=$DET_DURATION" -f null - 2>&1 | \
                  sed -n 's/.*silence_end: \([0-9.:]*\).*/\1/p' | head -n 1)
            local VAL
            VAL=$(to_seconds "''${RAW_VAL:-0}")
            [ "$YTP_LOG" != "--quiet" ] && echo "''${VAL}s" >&2
            echo "$VAL"
        fi
      }

      if [ -n "$MANUAL_OFFSET" ]; then
          OFFSET=$(to_seconds "$MANUAL_OFFSET")
          OFFSET=$(printf "%.6f" "$OFFSET")
          [ "$YTP_LOG" != "--quiet" ] && echo "⏱️  Using Manual Offset: ''${OFFSET}s"
      else
          [ "$YTP_LOG" != "--quiet" ] && echo "⏱️  Syncing..."
          AUDIO_START=$(get_start_time "$AUDIO_IN" "$AUDIO_START_HINT" "Local")
          VIDEO_START=$(get_start_time "$DOWNLOADED_VIDEO" "$MV_START_HINT" "MV")
          
          RAW_OFFSET=$(echo "$VIDEO_START - $AUDIO_START" | bc -l)
          OFFSET=$(printf "%.6f" "$RAW_OFFSET")
          [ "$YTP_LOG" != "--quiet" ] && echo "   Final Offset:    ''${OFFSET}s"
      fi

      OUT_FILE="''${BASENAME}_merged.mkv"
      [ "$YTP_LOG" != "--quiet" ] && echo "🔄 Merging..."
      
      if (( $(echo "$OFFSET >= 0" | bc -l) )); then
          ffmpeg -loglevel "$FF_LOG" -i "$DOWNLOADED_VIDEO" -itsoffset "$OFFSET" -i "$AUDIO_IN" \
            -map 0:v -map 1:a -map 0:s? -c copy -map_metadata 1 "$OUT_FILE" -y
      else
          ABS_OFFSET=''${OFFSET#-}; ABS_OFFSET=$(printf "%.6f" "$ABS_OFFSET")
          ffmpeg -loglevel "$FF_LOG" -itsoffset "$ABS_OFFSET" -i "$DOWNLOADED_VIDEO" -i "$AUDIO_IN" \
            -map 0:v -map 1:a -map 0:s? -c copy -map_metadata 1 "$OUT_FILE" -y
      fi
      [ "$YTP_LOG" != "--quiet" ] && echo "🚀 Done: $OUT_FILE"
    else
      echo "❌ Download failed."; [ "$KEEP_TEMP" = false ] && rm -rf "$TMP_DIR"; exit 1
    fi

    if [ "$KEEP_TEMP" = false ]; then
        rm -rf "$TMP_DIR" "/tmp/mv-thumb-$VIDEO_ID"*
    fi
  '';
}
