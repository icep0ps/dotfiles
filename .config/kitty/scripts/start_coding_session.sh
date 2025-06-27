#!/bin/bash

# Define your base coding directory
CODING_DIR="$HOME/Documents/Coding/" # Adjust this to your actual coding directory

# Check if the coding directory exists
if [ ! -d "$CODING_DIR" ]; then
  echo "Error: Coding directory '$CODING_DIR' not found."
  exit 1
fi

# Use fzf to select a project directory
# -type d: only list directories
# -maxdepth 1: only search in the immediate subdirectories of CODING_DIR
# -mindepth 1: exclude the CODING_DIR itself from the list
# fzf: interactive fuzzy finder
# --prompt: custom prompt for fzf
# --cycle: allow cycling through the list
# --height 40%: set the height of the fzf window
# --border: add a border around the fzf window
# --info=inline: display info on the same line as the prompt
# --preview 'ls -F {}': show a preview of the directory contents
# --preview-window=right: show the preview on the right
SELECTED_PROJECT=$(find "$CODING_DIR" -maxdepth 1 -mindepth 1 -type d | fzf \
  --prompt="Select a project: " \
  --cycle \
  --height 40% \
  --border \
  --info=inline \
  --preview 'ls -F {}' \
  --preview-window=right)

# Check if a project was selected
if [ -z "$SELECTED_PROJECT" ]; then
  echo "No project selected. Exiting."
  exit 0
fi

echo "Opening Kitty session for project: $SELECTED_PROJECT"

# Now, launch kitty with your session file, passing the selected project
# as an environment variable
# checkout https://github.com/kovidgoyal/kitty/discussions/5917 on why im passing in directory
kitty --directory $SELECTED_PROJECT --session "$HOME/.config/kitty/coding.sh"
exit
