# ~/.bashrc: Radxa Cubie A7Z Development Environment
# Configurado por radxa-dotfiles

# Si no es interactivo, salir
case $- in
    *i*) ;;
      *) return;;
esac

# ═══════════════════════════════════════════════════════════════
# Historia
# ═══════════════════════════════════════════════════════════════
HISTCONTROL=ignoreboth:erasedups
HISTSIZE=10000
HISTFILESIZE=20000
shopt -s histappend
shopt -s checkwinsize

# ═══════════════════════════════════════════════════════════════
# Prompt personalizado
# ═══════════════════════════════════════════════════════════════
parse_git_branch() {
    git branch 2>/dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/ (\1)/'
}

# Prompt con colores y rama git
PS1='\[\033[01;32m\]\u@radxa\[\033[00m\]:\[\033[01;34m\]\w\[\033[33m\]$(parse_git_branch)\[\033[00m\]\$ '

# ═══════════════════════════════════════════════════════════════
# PATH
# ═══════════════════════════════════════════════════════════════
export PATH="$HOME/.local/bin:$PATH"
export PATH="$HOME/.opencode/bin:$PATH"
export PATH="$HOME/.bun/bin:$PATH"

# Bun
export BUN_INSTALL="$HOME/.bun"
[ -d "$BUN_INSTALL" ] && export PATH="$BUN_INSTALL/bin:$PATH"

# ═══════════════════════════════════════════════════════════════
# Aliases - Navegación
# ═══════════════════════════════════════════════════════════════
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias ~='cd ~'

# ═══════════════════════════════════════════════════════════════
# Aliases - Listado
# ═══════════════════════════════════════════════════════════════
alias ls='ls --color=auto'
alias ll='ls -alFh'
alias la='ls -A'
alias l='ls -CF'
alias lt='ls -ltrh'  # ordenado por tiempo

# ═══════════════════════════════════════════════════════════════
# Aliases - Git
# ═══════════════════════════════════════════════════════════════
alias g='git'
alias gs='git status'
alias ga='git add'
alias gaa='git add --all'
alias gc='git commit'
alias gcm='git commit -m'
alias gp='git push'
alias gpl='git pull'
alias gf='git fetch'
alias gb='git branch'
alias gco='git checkout'
alias gd='git diff'
alias gl='git log --oneline -20'
alias glog='git log --graph --oneline --decorate'
alias lg='lazygit'

# ═══════════════════════════════════════════════════════════════
# Aliases - Herramientas
# ═══════════════════════════════════════════════════════════════
alias v='nvim'
alias vim='nvim'
alias t='tmux'
alias ta='tmux attach -t'
alias tn='tmux new -s'
alias tl='tmux list-sessions'
alias oc='opencode'

# ═══════════════════════════════════════════════════════════════
# Aliases - Sistema
# ═══════════════════════════════════════════════════════════════
alias update='sudo apt update && sudo apt upgrade -y'
alias install='sudo apt install'
alias remove='sudo apt remove'
alias ports='sudo netstat -tulanp'
alias myip='curl -s ifconfig.me'
alias mem='free -h'
alias disk='df -h'
alias temp='cat /sys/class/thermal/thermal_zone0/temp 2>/dev/null | awk "{printf \"%.1f°C\n\", \$1/1000}"'

# ═══════════════════════════════════════════════════════════════
# Aliases - Android/ADB
# ═══════════════════════════════════════════════════════════════
alias adb-devices='adb devices -l'
alias adb-connect='~/.local/bin/android-ssh-setup.sh'
alias android-ssh='~/.local/bin/android-ssh-setup.sh'

# ═══════════════════════════════════════════════════════════════
# Aliases - Búsqueda
# ═══════════════════════════════════════════════════════════════
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'

# fd está instalado como fdfind en Debian
if command -v fdfind &> /dev/null; then
    alias fd='fdfind'
fi

# ═══════════════════════════════════════════════════════════════
# Funciones útiles
# ═══════════════════════════════════════════════════════════════

# Crear directorio y entrar
mkcd() {
    mkdir -p "$1" && cd "$1"
}

# Extraer archivos
extract() {
    if [ -f "$1" ]; then
        case "$1" in
            *.tar.bz2)   tar xjf "$1"   ;;
            *.tar.gz)    tar xzf "$1"   ;;
            *.tar.xz)    tar xJf "$1"   ;;
            *.bz2)       bunzip2 "$1"   ;;
            *.rar)       unrar x "$1"   ;;
            *.gz)        gunzip "$1"    ;;
            *.tar)       tar xf "$1"    ;;
            *.tbz2)      tar xjf "$1"   ;;
            *.tgz)       tar xzf "$1"   ;;
            *.zip)       unzip "$1"     ;;
            *.Z)         uncompress "$1";;
            *.7z)        7z x "$1"      ;;
            *)           echo "'$1' no se puede extraer" ;;
        esac
    else
        echo "'$1' no es un archivo válido"
    fi
}

# Buscar en historial
hg() {
    history | grep "$1"
}

# Información del sistema
sysinfo() {
    echo "═══════════════════════════════════════"
    echo "  Radxa Cubie A7Z - System Info"
    echo "═══════════════════════════════════════"
    echo "  Hostname: $(hostname)"
    echo "  Kernel:   $(uname -r)"
    echo "  Uptime:   $(uptime -p)"
    echo "  CPU Temp: $(cat /sys/class/thermal/thermal_zone0/temp 2>/dev/null | awk '{printf "%.1f°C", $1/1000}')"
    echo "  Memory:   $(free -h | awk '/^Mem:/ {print $3 "/" $2}')"
    echo "  Disk:     $(df -h / | awk 'NR==2 {print $3 "/" $2 " (" $5 ")"}')"
    echo "  IP:       $(hostname -I | awk '{print $1}')"
    echo "═══════════════════════════════════════"
}

# ═══════════════════════════════════════════════════════════════
# FZF (si está instalado)
# ═══════════════════════════════════════════════════════════════
[ -f ~/.fzf.bash ] && source ~/.fzf.bash

# ═══════════════════════════════════════════════════════════════
# Bash completion
# ═══════════════════════════════════════════════════════════════
if ! shopt -oq posix; then
    if [ -f /usr/share/bash-completion/bash_completion ]; then
        . /usr/share/bash-completion/bash_completion
    elif [ -f /etc/bash_completion ]; then
        . /etc/bash_completion
    fi
fi

# ═══════════════════════════════════════════════════════════════
# Mensaje de bienvenida
# ═══════════════════════════════════════════════════════════════
echo ""
echo "  Radxa Cubie A7Z ready!"
echo "  Tip: 'sysinfo' para ver estado del sistema"
echo ""
