#!/usr/bin/env bash
# Backup dotfiles and state

set -euo pipefail

BACKUP_DIR="${DOTFILES_BACKUP_DIR:-$HOME/.dotfiles_backups}"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_NAME="dotfiles_backup_$TIMESTAMP"
BACKUP_PATH="$BACKUP_DIR/$BACKUP_NAME"

CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}"

echo "Dotfiles Backup Utility"
echo "======================="
echo ""

# Create backup directory
mkdir -p "$BACKUP_PATH"

echo "Backing up to: $BACKUP_PATH"
echo ""

# Backup configurations
echo "📦 Backing up configurations..."
for dir in sway waybar eww rofi mako swaylock neofetch; do
  if [[ -d "$CONFIG_DIR/$dir" ]]; then
    echo "  → $dir"
    cp -r "$CONFIG_DIR/$dir" "$BACKUP_PATH/"
  fi
done

# Backup scripts
if [[ -d "$CONFIG_DIR/scripts" ]]; then
  echo "  → scripts"
  cp -r "$CONFIG_DIR/scripts" "$BACKUP_PATH/"
fi

# Backup shell configs
echo ""
echo "🐚 Backing up shell configs..."
for file in .zshrc .bashrc .profile; do
  if [[ -f "$HOME/$file" ]]; then
    echo "  → $file"
    cp "$HOME/$file" "$BACKUP_PATH/"
  fi
done

# Backup Spotify credentials (if exists)
if [[ -f "$CONFIG_DIR/eww/spotify.env" ]]; then
  echo ""
  echo "🔑 Backing up Spotify credentials..."
  cp "$CONFIG_DIR/eww/spotify.env" "$BACKUP_PATH/"
fi

# Create manifest
echo ""
echo "📝 Creating manifest..."
cat > "$BACKUP_PATH/MANIFEST.txt" <<EOF
Dotfiles Backup
===============
Created: $(date)
Hostname: $(hostname)
User: $USER

Contents:
$(find "$BACKUP_PATH" -type f -o -type d | sed "s|$BACKUP_PATH/||" | sort)

Restore:
  ~/.config/scripts/restore.sh $BACKUP_NAME
EOF

# Create archive
echo ""
echo "🗜️  Creating archive..."
cd "$BACKUP_DIR"
tar -czf "${BACKUP_NAME}.tar.gz" "$BACKUP_NAME"
ARCHIVE_SIZE=$(du -h "${BACKUP_NAME}.tar.gz" | cut -f1)

# Cleanup uncompressed backup
rm -rf "$BACKUP_NAME"

echo ""
echo "✅ Backup complete!"
echo ""
echo "Archive: $BACKUP_DIR/${BACKUP_NAME}.tar.gz"
echo "Size: $ARCHIVE_SIZE"
echo ""
echo "To restore:"
echo "  ~/.config/scripts/restore.sh ${BACKUP_NAME}.tar.gz"
echo ""

# List recent backups
echo "Recent backups:"
ls -lht "$BACKUP_DIR"/*.tar.gz 2>/dev/null | head -5 | awk '{print "  " $9 " (" $5 ")"}'

# Cleanup old backups (keep last 10)
BACKUP_COUNT=$(ls -1 "$BACKUP_DIR"/*.tar.gz 2>/dev/null | wc -l)
if [[ $BACKUP_COUNT -gt 10 ]]; then
  echo ""
  echo "🧹 Cleaning up old backups (keeping last 10)..."
  ls -t "$BACKUP_DIR"/*.tar.gz | tail -n +11 | xargs rm -f
fi
