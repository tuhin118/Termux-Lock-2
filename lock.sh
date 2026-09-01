#!/data/data/com.termux/files/usr/bin/bash
set -u

BASE="$HOME/.termux-lock"
CFG="$BASE/config"
HASH="$CFG/password.sha256"
SALT="$CFG/salt"
RHASH="$CFG/recovery.sha256"
RSALT="$CFG/recovery.salt"

[ -f "$BASE/ui.sh" ] && . "$BASE/ui.sh"

hashpw(){
  printf '%s%s' "$2" "$1" | sha256sum | awk '{print $1}'
}

new_salt(){
  od -An -N16 -tx1 /dev/urandom | tr -d ' \n'
}

setup(){
  mkdir -p "$CFG"
  local a b s r rs

  while :; do
    printf 'New password: '
    IFS= read -r -s a || exit 1
    printf '\n'

    printf 'Confirm password: '
    IFS= read -r -s b || exit 1
    printf '\n'

    [ -n "$a" ] || {
      echo 'Password cannot be empty.'
      continue
    }

    [ "$a" = "$b" ] || {
      echo 'Passwords do not match.'
      continue
    }

    s="$(new_salt)"

    # Generate a random 5-character recovery code.
    r="$(tr -dc 'A-Za-z0-9' < /dev/urandom | head -c 5)"

    rs="$(new_salt)"

    printf '%s' "$s" > "$SALT"
    hashpw "$a" "$s" > "$HASH"

    printf '%s' "$rs" > "$RSALT"
    hashpw "$r" "$rs" > "$RHASH"

    chmod 600 "$SALT" "$HASH" "$RSALT" "$RHASH"

    clear

    echo '========================================'
    echo ' PASSWORD SETUP COMPLETE'
    echo '========================================'
    echo "Recovery Code: $r"
    echo
    echo 'IMPORTANT: Save this Recovery Code somewhere safe.'
    echo 'It is the only built-in way to reset a forgotten password.'
    echo 'The old password cannot be displayed/recovered.'
    echo '========================================'

    unset a b s r rs
    return
  done
}

verify(){
  local a s e

  s="$(cat "$SALT")"
  e="$(cat "$HASH")"

  printf 'Password: '
  IFS= read -r -s a || return 1
  printf '\n'

  [ "$(hashpw "$a" "$s")" = "$e" ]
}

verify_recovery(){
  local r s e

  s="$(cat "$RSALT")"
  e="$(cat "$RHASH")"

  printf 'Recovery Code: '
  IFS= read -r r || return 1
  printf '\n'

  [ "$(hashpw "$r" "$s")" = "$e" ]
}

reset_password(){
  local a b s

  if ! verify_recovery; then
    echo 'Recovery Code incorrect.'
    return 1
  fi

  while :; do
    printf 'New password: '
    IFS= read -r -s a || return 1
    printf '\n'

    printf 'Confirm password: '
    IFS= read -r -s b || return 1
    printf '\n'

    [ -n "$a" ] || {
      echo 'Password cannot be empty.'
      continue
    }

    [ "$a" = "$b" ] || {
      echo 'Passwords do not match.'
      continue
    }

    s="$(new_salt)"

    printf '%s' "$s" > "$SALT"
    hashpw "$a" "$s" > "$HASH"

    chmod 600 "$SALT" "$HASH"

    unset a b s

    echo 'Password reset successfully. Access granted.'
    return 0
  done
}

lock(){
  trap 'echo; echo "Locked. Enter password or use the Recovery Code."' INT TSTP QUIT

  local n=0 choice

  while :; do
    ui_lock 2>/dev/null || clear

    echo '1) Password'
    echo '2) Recovery Code (reset password)'

    printf 'Choose [1/2]: '
    IFS= read -r choice || exit 1
    printf '\n'

    case "$choice" in
      1)
        if verify; then
          trap - INT TSTP QUIT
          clear
          echo 'Access granted.'
          return
        fi

        n=$((n+1))

        ui_error "$n" 2>/dev/null || {
          clear
          echo "ACCESS DENIED — attempt $n"
        }
        ;;

      2)
        if reset_password; then
          trap - INT TSTP QUIT
          clear
          echo 'Access granted.'
          return
        fi
        ;;

      *)
        echo 'Invalid choice.'
        sleep 1
        ;;
    esac
  done
}

case "${1:-lock}" in

  passwd|password|set-password)
    setup
    ;;

  recover|reset)
    reset_password
    ;;

  lock)
    [ -f "$HASH" ] || setup
    [ -f "$RHASH" ] || setup
    lock
    ;;

  status)
    [ -f "$HASH" ] && [ -f "$RHASH" ] &&
      echo 'Termux Lock: configured (recovery enabled)' ||
      echo 'Termux Lock: not configured'
    ;;

  uninstall)
    exec "$BASE/uninstall.sh"
    ;;

  help|-h|--help)
    echo 'Usage: termux-lock [lock|passwd|recover|status|uninstall]'
    ;;

  *)
    echo 'Unknown command'
    exit 2
    ;;

esac
