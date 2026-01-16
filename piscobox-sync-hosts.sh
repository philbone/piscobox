#!/usr/bin/env bash
#
# ============================================================
#  Piscobox Host Sync Utility
#  Safely synchronizes local /etc/hosts with VM site entries
# ============================================================

PISTAG_START="# >>> piscobox hosts start"
PISTAG_END="# <<< piscobox hosts end"
HOSTS_FILE="/etc/hosts"
BACKUP_FILE="/etc/hosts.bak.piscobox"
PISCOBOX_FILE=".piscobox-hosts"

set -e

echo ""
echo "=========================================="
echo "      PISCOBOX HOSTS SYNC UTILITY"
echo "=========================================="
echo ""

# Ensure .piscobox-hosts exists
if [[ ! -f "$PISCOBOX_FILE" ]]; then
  echo "❌ Error: No $PISCOBOX_FILE found in current directory."
  echo "Please run this script from the same folder as your Vagrantfile."
  echo ""
  exit 1
fi

# Check permission to edit /etc/hosts
if [[ ! -w "$HOSTS_FILE" ]]; then
  if [[ $EUID -ne 0 ]]; then
    echo "🔐 Root privileges required to modify $HOSTS_FILE."
    echo "Re-running with sudo..."
    echo ""
    exec sudo "$0" "$@"
  fi
fi

# Backup original hosts file
echo "📦 Creating backup at $BACKUP_FILE..."
cp "$HOSTS_FILE" "$BACKUP_FILE"

# Remove any previous Piscobox block
echo "🧹 Cleaning old Piscobox entries..."
tmpfile=$(mktemp)
awk -v start="$PISTAG_START" -v end="$PISTAG_END" '
  $0 == start {inblock=1; next}
  $0 == end {inblock=0; next}
  !inblock {print}
' "$HOSTS_FILE" > "$tmpfile"

# Add new Piscobox block
{
  echo "$PISTAG_START"
  cat "$PISCOBOX_FILE"
  echo "$PISTAG_END"
} >> "$tmpfile"

# Replace /etc/hosts safely
echo "📝 Updating $HOSTS_FILE..."
mv "$tmpfile" "$HOSTS_FILE"

sudo chmod 644 /etc/hosts

echo ""
echo "✅ Successfully synchronized Piscobox hosts!"
echo "   Entries from $PISCOBOX_FILE have been merged into $HOSTS_FILE."
echo ""
echo "You can now access your sites locally:"
awk '{print "   → http://" $2}' "$PISCOBOX_FILE"
echo ""
