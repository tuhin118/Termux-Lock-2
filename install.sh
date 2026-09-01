#!/data/data/com.termux/files/usr/bin/bash
set -e
BASE="$HOME/.termux-lock"
BIN="$PREFIX/bin"
SRC="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
mkdir -p "$BASE/config" "$BASE/backups"
cp "$SRC/lock.sh" "$BASE/lock.sh"
cp "$SRC/lib/ui.sh" "$BASE/ui.sh"
cp "$SRC/uninstall.sh" "$BASE/uninstall.sh"
chmod 700 "$BASE"/*.sh "$BASE/ui.sh"
[ -f "$HOME/.bashrc" ] && cp "$HOME/.bashrc" "$BASE/backups/bashrc.$(date +%Y%m%d%H%M%S)" || : > "$HOME/.bashrc"
if ! grep -Fq '# >>> TERMUX-LOCK START >>>' "$HOME/.bashrc"; then
cat >> "$HOME/.bashrc" <<'BLOCK'

# >>> TERMUX-LOCK START >>>
if [ -t 0 ] && [ -x "$HOME/.termux-lock/lock.sh" ]; then
  "$HOME/.termux-lock/lock.sh"
fi
# <<< TERMUX-LOCK END <<<
BLOCK
fi
cat > "$BIN/termux-lock" <<'EOF2'
#!/data/data/com.termux/files/usr/bin/bash
exec "$HOME/.termux-lock/lock.sh" "$@"
EOF2
chmod 755 "$BIN/termux-lock"
echo 'TERMUX LOCK INSTALLED'
echo 'Set your password now:'
"$BASE/lock.sh" passwd
echo 'Restart Termux to test the lock.'
