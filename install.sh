#!/bin/bash
#
# Radxa Cubie A7Z - Dotfiles Installation Script
# Restaura todo el entorno de desarrollo con un solo comando
#
# Uso: curl -fsSL https://raw.githubusercontent.com/TU_USUARIO/radxa-dotfiles/main/install.sh | bash
#      o: ./install.sh
#

set -e

# Colores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

DOTFILES_DIR="$HOME/dotfiles"
DOTFILES_REPO="https://github.com/TU_USUARIO/radxa-dotfiles.git"

log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[OK]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

header() {
    echo ""
    echo -e "${GREEN}╔═══════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║     Radxa Cubie A7Z - Dotfiles Installer              ║${NC}"
    echo -e "${GREEN}╚═══════════════════════════════════════════════════════╝${NC}"
    echo ""
}

# Detectar arquitectura
detect_arch() {
    ARCH=$(uname -m)
    case $ARCH in
        aarch64) ARCH="arm64" ;;
        x86_64) ARCH="amd64" ;;
        armv7l) ARCH="arm" ;;
    esac
    log_info "Arquitectura detectada: $ARCH"
}

# Configurar repositorio backports para Debian
setup_backports() {
    log_info "Configurando repositorio backports..."
    
    # Detectar versión de Debian
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        if [ "$ID" = "debian" ]; then
            CODENAME=$VERSION_CODENAME
            BACKPORTS_FILE="/etc/apt/sources.list.d/50-${CODENAME}-backports.list"
            
            if [ ! -f "$BACKPORTS_FILE" ]; then
                echo "deb http://deb.debian.org/debian ${CODENAME}-backports main contrib non-free" | sudo tee "$BACKPORTS_FILE" > /dev/null
                log_success "Backports configurado para $CODENAME"
            else
                log_warn "Backports ya configurado"
            fi
        fi
    fi
}

# Instalar Git desde backports (requerido >= 2.32 para lazygit)
install_git() {
    log_info "Instalando Git desde backports (>= 2.32 requerido para lazygit)..."
    
    # Detectar versión de Debian
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        if [ "$ID" = "debian" ]; then
            CODENAME=$VERSION_CODENAME
            # Intentar instalar desde backports
            if sudo apt-get install -y -qq git/${CODENAME}-backports 2>/dev/null; then
                log_success "Git instalado desde backports: $(git --version)"
            else
                # Fallback a versión normal si backports no está disponible
                sudo apt-get install -y -qq git
                log_warn "Git instalado desde repositorio principal: $(git --version)"
            fi
        else
            sudo apt-get install -y -qq git
        fi
    else
        sudo apt-get install -y -qq git
    fi
}

# Actualizar sistema e instalar dependencias básicas
install_base() {
    log_info "Actualizando sistema e instalando dependencias..."
    sudo apt-get update -qq
    
    # Configurar backports primero
    setup_backports
    sudo apt-get update -qq
    
    # Instalar Git desde backports (lazygit requiere >= 2.32)
    install_git
    
    # Instalar resto de dependencias
    sudo apt-get install -y -qq \
        curl \
        wget \
        unzip \
        build-essential \
        openssh-server \
        tmux \
        htop \
        tree \
        ripgrep \
        fd-find \
        fzf \
        jq \
        adb
    log_success "Dependencias base instaladas"
}

# Instalar Neovim
install_nvim() {
    log_info "Instalando Neovim..."
    
    if command -v nvim &> /dev/null; then
        log_warn "Neovim ya está instalado: $(nvim --version | head -1)"
    else
        # Para ARM64 usamos el AppImage o compilamos
        NVIM_VERSION="v0.10.0"
        
        # Intentar con el paquete de Debian si está disponible
        if sudo apt-get install -y -qq neovim 2>/dev/null; then
            log_success "Neovim instalado desde repositorio"
        else
            # Compilar desde source para ARM
            log_info "Compilando Neovim desde source (esto puede tomar tiempo)..."
            sudo apt-get install -y -qq ninja-build gettext cmake
            
            cd /tmp
            git clone --depth 1 --branch $NVIM_VERSION https://github.com/neovim/neovim.git
            cd neovim
            make CMAKE_BUILD_TYPE=Release
            sudo make install
            cd ~
            rm -rf /tmp/neovim
            log_success "Neovim compilado e instalado"
        fi
    fi
}

# Instalar Lazygit
install_lazygit() {
    log_info "Instalando Lazygit..."
    
    if command -v lazygit &> /dev/null; then
        log_warn "Lazygit ya está instalado: $(lazygit --version)"
    else
        LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep -Po '"tag_name": "v\K[^"]*')
        curl -Lo /tmp/lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${LAZYGIT_VERSION}_Linux_arm64.tar.gz"
        cd /tmp && tar xf lazygit.tar.gz lazygit
        sudo install lazygit /usr/local/bin
        rm -f /tmp/lazygit.tar.gz /tmp/lazygit
        log_success "Lazygit instalado"
    fi
}

# Instalar Bun
install_bun() {
    log_info "Instalando Bun..."
    
    if command -v bun &> /dev/null; then
        log_warn "Bun ya está instalado: $(bun --version)"
    else
        curl -fsSL https://bun.sh/install | bash
        export BUN_INSTALL="$HOME/.bun"
        export PATH="$BUN_INSTALL/bin:$PATH"
        log_success "Bun instalado"
    fi
}

# Instalar OpenCode
install_opencode() {
    log_info "Instalando OpenCode..."
    
    if command -v opencode &> /dev/null; then
        log_warn "OpenCode ya está instalado"
    else
        # Instalar via bun
        if command -v bun &> /dev/null; then
            bun install -g opencode
        else
            # Instalación alternativa
            curl -fsSL https://opencode.ai/install | bash
        fi
        log_success "OpenCode instalado"
    fi
}

# Configurar Git
setup_git() {
    log_info "Configurando Git..."
    
    if [ ! -f "$HOME/.gitconfig" ]; then
        read -p "Tu nombre para Git: " GIT_NAME
        read -p "Tu email para Git: " GIT_EMAIL
        
        git config --global user.name "$GIT_NAME"
        git config --global user.email "$GIT_EMAIL"
    fi
    
    git config --global init.defaultBranch main
    git config --global core.editor nvim
    git config --global pull.rebase false
    
    log_success "Git configurado"
}

# Copiar configuraciones (dotfiles)
setup_dotfiles() {
    log_info "Configurando dotfiles..."
    
    # Bashrc
    if [ -f "$DOTFILES_DIR/bashrc" ]; then
        cp "$DOTFILES_DIR/bashrc" "$HOME/.bashrc"
        log_success "bashrc configurado"
    fi
    
    # Tmux
    if [ -f "$DOTFILES_DIR/config/tmux/tmux.conf" ]; then
        mkdir -p "$HOME/.config/tmux"
        cp "$DOTFILES_DIR/config/tmux/tmux.conf" "$HOME/.config/tmux/tmux.conf"
        # También crear symlink en home para compatibilidad
        ln -sf "$HOME/.config/tmux/tmux.conf" "$HOME/.tmux.conf"
        log_success "tmux configurado"
    fi
    
    # Neovim
    if [ -d "$DOTFILES_DIR/config/nvim" ]; then
        mkdir -p "$HOME/.config/nvim"
        cp -r "$DOTFILES_DIR/config/nvim/"* "$HOME/.config/nvim/"
        log_success "nvim configurado"
    fi
    
    # Lazygit
    if [ -d "$DOTFILES_DIR/config/lazygit" ]; then
        mkdir -p "$HOME/.config/lazygit"
        cp -r "$DOTFILES_DIR/config/lazygit/"* "$HOME/.config/lazygit/"
        log_success "lazygit configurado"
    fi
    
    # Scripts
    if [ -d "$DOTFILES_DIR/scripts" ]; then
        mkdir -p "$HOME/.local/bin"
        cp "$DOTFILES_DIR/scripts/"* "$HOME/.local/bin/"
        chmod +x "$HOME/.local/bin/"*
        log_success "scripts instalados en ~/.local/bin"
    fi
}

# Configurar SSH para Android por USB
setup_android_ssh() {
    log_info "Configurando SSH para Android por USB..."
    
    # Asegurar que SSH server está corriendo
    sudo systemctl enable ssh
    sudo systemctl start ssh
    
    # Copiar script y servicio
    if [ -f "$DOTFILES_DIR/scripts/android-ssh-setup.sh" ]; then
        sudo cp "$DOTFILES_DIR/scripts/android-ssh.service" /etc/systemd/system/
        sudo systemctl daemon-reload
        sudo systemctl enable android-ssh.service
        sudo systemctl start android-ssh.service
        log_success "Servicio android-ssh configurado"
    fi
    
    log_success "SSH para Android configurado"
}

# Menú principal
main() {
    header
    detect_arch
    
    echo "Selecciona una opción:"
    echo ""
    echo "  1) Instalación completa (recomendado)"
    echo "  2) Solo instalar herramientas"
    echo "  3) Solo configurar dotfiles"
    echo "  4) Solo configurar Android SSH"
    echo "  5) Salir"
    echo ""
    read -p "Opción [1]: " OPTION
    OPTION=${OPTION:-1}
    
    case $OPTION in
        1)
            install_base
            install_nvim
            install_lazygit
            install_bun
            install_opencode
            setup_git
            setup_dotfiles
            setup_android_ssh
            ;;
        2)
            install_base
            install_nvim
            install_lazygit
            install_bun
            install_opencode
            ;;
        3)
            setup_dotfiles
            ;;
        4)
            setup_android_ssh
            ;;
        5)
            exit 0
            ;;
        *)
            log_error "Opción no válida"
            exit 1
            ;;
    esac
    
    echo ""
    echo -e "${GREEN}╔═══════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║     Instalación completada!                           ║${NC}"
    echo -e "${GREEN}╚═══════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo "Reinicia tu terminal o ejecuta: source ~/.bashrc"
    echo ""
}

# Ejecutar si se llama directamente
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
