    # Inserted inside upstream tryDownload(), leaving mirrors and hooks intact.
    # Preserve arbitrary curl options and authentication by using upstream curl.
    if [[ "$url" == http://* || "$url" == https://* ]] &&
       [[ -z "${curlOpts-}${NIX_CURL_FLAGS-}${netrcPhase-}" ]] &&
       [[ "${#curlOptsList[@]}" -eq 0 ]]; then
        local aria2Target="$TMPDIR/aria2-download"
        local aria2TLS=(--check-certificate=false)
        if [[ -f "$SSL_CERT_FILE" ]]; then
            aria2TLS=(--check-certificate=true "--ca-certificate=$SSL_CERT_FILE")
        fi
        # A separate directory keeps aria2 control files out of $out, including
        # recursive fetches. Never resume a partial file from another mirror.
        rm -rf "$aria2Target"
        mkdir -p "$aria2Target"
        echo "downloading with aria2 (up to 16 connections)"
        if aria2c --no-conf --no-netrc --enable-rpc=false \
            --split=16 --max-connection-per-server=16 --min-split-size=1M \
            --file-allocation=none --auto-file-renaming=false \
            --allow-overwrite=true --max-tries=3 --retry-wait=1 \
            --connect-timeout=15 --timeout=60 --summary-interval=1 \
            --enable-color=false --stderr=true \
            --console-log-level=warn --download-result=hide \
            --follow-metalink=false --follow-torrent=false \
            --user-agent="curl/$curlVersion Nixpkgs/$nixpkgsVersion" \
            "${aria2TLS[@]}" --dir="$aria2Target" --out=download -- "$url"; then
            mv "$aria2Target/download" "$target"
            success=1
            return
        fi
        echo "aria2 failed; falling back to curl" >&2
    fi
