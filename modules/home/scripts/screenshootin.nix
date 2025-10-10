{ pkgs }:

pkgs.writeShellScriptBin "screenshootin" ''
  # Create screenshots directory if it doesn't exist
  mkdir -p /home/don/Pictures/Screenshots

  # Generate filename with timestamp
  filename="/home/don/Pictures/Screenshots/screenshot_$(date +%Y%m%d_%H%M%S).png"

  # Take screenshot, save to file, and copy to clipboard
  grim -g "$(slurp)" "$filename" && wl-copy < "$filename"
''
