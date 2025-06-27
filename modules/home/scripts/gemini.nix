{pkgs}:
pkgs.writeShellScriptBin "gemini-install" ''

  #!/usr/bin/env bash

  # Define the destination directory
  DEST_DIR="$HOME/.npm-global"
  LOG_FILE="$HOME/gemini_cli_install.log"

  # Function to print a formatted message
  print_message() {
      echo "----------------------------------------"
      echo "$1"
      echo "----------------------------------------"
  }

  # Check if Gemini CLI is already installed
  if [ -f "$DEST_DIR/bin/gemini" ]; then
      print_message "Gemini CLI is already installed."
      exit 0
  fi

  # Prompt the user for confirmation
  read -p "This script will install @google/gemini-cli globally. Do you want to continue? (y/n): " -n 1 -r
  echo
  if [[ ! $REPLY =~ ^[Yy]$ ]]; then
      print_message "Installation cancelled."
      exit 1
  fi

  # Install the package and log the output
  print_message "Installing @google/gemini-cli..."
  npm install --prefix "$DEST_DIR" @google/gemini-cli > "$LOG_FILE" 2>&1

  # Check if the installation was successful
  if [ $? -eq 0 ]; then
      print_message "Installation successful!"
      echo "Adding $DEST_DIR/bin to your PATH."
      export PATH="$DEST_DIR/bin:$PATH"
      echo "You can now run the tool by typing 'gemini'."
  else
      print_message "Installation failed. See $LOG_FILE for details."
  fi

''
