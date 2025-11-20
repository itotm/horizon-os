
#!/bin/bash
set -ouex pipefail

echo 'set completion-ignore-case On' | sudo tee -a /etc/inputrc

{
    echo "# HorizonOS aliases and shell enhancements"
    echo "alias bat='batcat'"
    echo "alias fd='fdfind'"
    echo "alias ls='lsd'"
    echo "alias du='dust'"
    echo "alias ps='procs'"
    echo "alias grep='rg'"
    echo "alias tldr='tldr --color'"
    echo "if command -v zoxide &>/dev/null; then"
    echo "    eval \"\$(zoxide init bash)\""
    echo "fi"
    echo "if [ -f /usr/share/fzf/shell/key-bindings.bash ]; then"
    echo "    source /usr/share/fzf/shell/key-bindings.bash"
    echo "fi"
    echo "if [ -f /usr/share/fzf/shell/completion.bash ]; then"
    echo "    source /usr/share/fzf/shell/completion.bash"
    echo "fi"
} | sudo tee -a /etc/bashrc

./setup-flatpak.sh
