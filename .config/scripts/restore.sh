#!/usr/bin/env bash
# Restore dotfiles from backup

set -euo pipefail

BACKUP_DIR="${DOTFILES_BACKUP_DIR:-$HOME/.dotfiles_backups}"
CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}"

echo "Dotfiles Restore Utility"
echo "========================"
echo ""

# Check if backup file provided
if [[ $# -eq 0 ]]; then
  echo "Available backups:"
  ls -lht "$BACKUP_DIR"/*.tar.gz 2>/dev/null | awk '{print "  " $9 " (" $5 ", " $6 " " $7 ")"}'
  echo ""
  echo "Usage: $0 <backup-file.tar.gz>"
  exit 1
fi

BACKUP_FILE="$1"

# Handle relative/absolute paths
if [[ ! "$BACKUP_FILE" =~ ^/ ]]; then
  BACKUP_FILE="$BACKUP_DIR/$BACKUP_FILE"
fi

if [[ ! -f "$BACKUP_FILE" ]]; then
  echo "❌ Backup file not found: $BACKUP_FILE"
  exit 1
fi

echo "Restoring from: $BACKUP_FILE"
echo ""

# Extract to temp directory
TEMP_DIR=$(mktemp -d)
trap "rm -rf $TEMP_DIR" EXIT

echo "📦 Extracting backup..."
tar -xzf "$BACKUP_FILE" -C "$TEMP_DIR"

# Find the extracted directory
EXTRACTED_DIR=$(find "$TEMP_DIR" -maxdepth 1 -type d -name "dotfiles_backup_*" | head -1)

if [[ -z "$EXTRACTED_DIR" ]]; then
  echo "❌ Invalid backup archive"
  exit 1
fi

# Show manifest
if [[ -f "$EXTRACTED_DIR/MANIFEST.txt" ]]; then
  echo ""
  echo "📝 Backup info:"
  head -6 "$EXTRACTED_DIR/MANIFEST.txt" | sed 's/^/  /'
  echo ""
fi

# Confirm restore
read -p "⚠️  This will overwrite existing configs. Continue? (y/N) " -n 1 -r
echo ""
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
  echo "Restore cancelled."
  exit 0
fi

# Create backup of current state before restoring
echo ""
echo "🔄 Creating backup of current state..."
SAFETY_BACKUP="$BACKUP_DIR/pre_restore_$(date +%Y%m%d_%H%M%S).tar.gz"
tar -czf "$SAFETY_BACKUP" -C "$CONFIG_DIR" \
  sway waybar eww rofi mako swaylock scripts 2>/dev/null || true
echo "  → Saved to: $SAFETY_BACKUP"

# Restore configurations
echo ""
echo "📥 Restoring configurations..."
for dir in sway waybar eww rofi mako swaylock neofetch scripts; do
  if [[ -d "$EXTRACTED_DIR/$dir" ]]; then
    echo "  → $dir"
    rm -rf "$CONFIG_DIR/$dir"
    cp -r "$EXTRACTED_DIR/$dir" "$CONFIG_DIR/"
  fi
done

# Restore shell configs
echo ""
echo "🐚 Restoring shell configs..."
for file in .zshrc .bashrc .profile; do
  if [[ -f "$EXTRACTED_DIR/$file" ]]; then
    echo "  → $file"
    cp "$EXTRACTED_DIR/$file" "$HOME/"
  fi
done

# Restore Spotify credentials
if [[ -f "$EXTRACTED_DIR/spotify.env" ]]; then
  echo ""
  echo "🔑 Restoring Spotify credentials..."
  cp "$EXTRACTED_DIR/spotify.env" "$CONFIG_DIR/eww/"
fi

# Set permissions
echo ""
echo "🔒 Setting permissions..."
find "$CONFIG_DIR/scripts" -type f -name "*.sh" -exec chmod +x {} \; 2>/dev/null || true
find "$CONFIG_DIR/eww/scripts" -type f -name "*.sh" -exec chmod +x {} \; 2>/dev/null || true
find "$CONFIG_DIR/waybar/scripts" -type f -name "*.sh" -exec chmod +x {} \; 2>/dev/null || true
find "$CONFIG_DIR/sway" -type f -name "*.sh" -exec chmod +x {} \; 2>/dev/null || true

echo ""
echo "✅ Restore complete!"
echo ""
echo "Next steps:"
echo "  1. Reload Sway: Mod+Shift+c"
echo "  2. Restart Waybar: ~/.config/waybar/scripts/restart-waybar.sh"
echo "  3. Restart Eww: eww reload"
echo ""
echo "If something went wrong, restore from:"
echo "  $SAFETY_BACKUP"
