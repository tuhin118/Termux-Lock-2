#!/data/data/com.termux/files/usr/bin/bash
B="$HOME/.bashrc"; S='# >>> TERMUX-LOCK START >>>'; E='# <<< TERMUX-LOCK END <<<'; T="$(mktemp)"
awk -v s="$S" -v e="$E" '$0==s{skip=1;next}$0==e{skip=0;next}!skip{print}' "$B" > "$T" && cp "$T" "$B"; rm -f "$T" "$PREFIX/bin/termux-lock"; rm -rf "$HOME/.termux-lock"; echo 'Termux Lock uninstalled. Restart Termux.'
