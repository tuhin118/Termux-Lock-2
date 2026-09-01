ui_lock(){ printf '\033[2J\033[H'; cat <<'EOT'
╔════════════════════════════════════════════════════╗
║                                                    ║
║              T E R M U X   L O C K                 ║
║                                                    ║
║          🔐  SECURE SESSION REQUIRED               ║
║                                                    ║
║     Enter your password to continue.               ║
║                                                    ║
╚════════════════════════════════════════════════════╝
EOT
}
ui_error(){ local n="${1:-1}"; printf '\033[2J\033[H'; cat <<EOT
╔════════════════════════════════════════════════════╗
║                                                    ║
║                 ⚠  ACCESS DENIED                  ║
║                                                    ║
║             AUTHENTICATION FAILED                  ║
║                                                    ║
║       The password entered was incorrect.          ║
║                                                    ║
║       Attempt: $n                                  ║
║                                                    ║
║       SYSTEM STATUS: LOCKED                        ║
║                                                    ║
║       Press ENTER to try again...                  ║
║                                                    ║
╚════════════════════════════════════════════════════╝
EOT
read -r; }
