# Termux Lock v2 — Recovery PIN

A Bash startup lock for Termux with salted SHA-256 password verification and a separate Recovery PIN.

## What the Recovery PIN does

When a password is forgotten, the **Recovery PIN can reset the password and grant access**. The old password is **not stored in plaintext and cannot be displayed by the tool**.

A new random 12-digit Recovery PIN is generated during setup. Save it somewhere safe. If the Recovery PIN is lost too, this project intentionally has no second built-in recovery method.

## Install
```bash
pkg install git -y
git clone https://github.com/tuhin118/Termux-Lock-2
cd termux-lock
bash install.sh
```

During setup you will receive a Recovery PIN immediately after setting the password.

## Commands
```bash
termux-lock
termux-lock passwd
termux-lock recover
termux-lock status
termux-lock uninstall
```

## Security note
This is a shell startup lock, not an Android system-level App Lock. Someone with sufficient access to the device, Termux app data, root access, or a modified environment may be able to remove or bypass a shell startup script. Use Android's built-in App Lock/device security as an additional layer.

The Recovery PIN is stored only as a salted SHA-256 hash, not as plaintext. Because it is the sole built-in recovery method, losing it means the tool cannot recover the forgotten password.
