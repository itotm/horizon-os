
#!/bin/bash
set -ouex pipefail

USER_HOME="/root"
if [ "$SUDO_USER" ]; then
    USER_HOME="$(getent passwd "$SUDO_USER" | cut -d: -f6)"
fi
BASHRC="$USER_HOME/.bashrc"
MARKER="$USER_HOME/.horizon_user_setup_done"

if [ -f "$MARKER" ]; then
    exit 0
fi

cat >> "$BASHRC" <<'EOF'
# HorizonOS aliases and shell enhancements
alias bat='batcat'
alias fd='fdfind'
alias ls='lsd'
alias du='dust'
alias ps='procs'
alias grep='rg'
alias tldr='tldr --color'
if command -v zoxide &>/dev/null; then
    eval "$(zoxide init bash)"
fi
if [ -f /usr/share/fzf/shell/key-bindings.bash ]; then
    source /usr/share/fzf/shell/key-bindings.bash
fi
if [ -f /usr/share/fzf/shell/completion.bash ]; then
    source /usr/share/fzf/shell/completion.bash
fi
EOF

cat > "$USER_HOME/.inputrc" <<EOF
set completion-ignore-case On
EOF

touch "$MARKER"
