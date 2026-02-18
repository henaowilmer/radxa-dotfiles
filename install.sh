#!/bin/bash
#
# Radxa Dotfiles Installation Script
# Based on Gentleman.Dots - https://github.com/Gentleman-Programming/Gentleman.Dots
# Optimized for ARM devices (Radxa, Raspberry Pi, etc.)
#
# Tools: Fish, Tmux, Neovim, Starship, Oil, Volta, Carapace, Zoxide, Atuin,
#        jq, fzf, Bun, Cargo, Go, tree-sitter, gcc, fd, ripgrep, bat, lazygit,
#        Nerd Fonts (Iosevka Term)
#
# Usage: curl -fsSL https://raw.githubusercontent.com/YOUR_USER/radxa-dotfiles/main/install.sh | bash
#        or: ./install.sh
#

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

DOTFILES_DIR="$HOME/dotfiles"
DOTFILES_REPO="https://github.com/YOUR_USER/radxa-dotfiles.git"

log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[OK]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }
log_step() { echo -e "${CYAN}[STEP]${NC} $1"; }

header() {
    echo ""
    echo -e "${GREEN}╔═══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║     Radxa Dotfiles Installer                                  ║${NC}"
    echo -e "${GREEN}║     Based on Gentleman.Dots                                   ║${NC}"
    echo -e "${GREEN}╚═══════════════════════════════════════════════════════════════╝${NC}"
    echo ""
}

# Detect architecture
detect_arch() {
    ARCH=$(uname -m)
    case $ARCH in
        aarch64) ARCH="arm64" ;;
        x86_64) ARCH="amd64" ;;
        armv7l) ARCH="arm" ;;
    esac
    log_info "Architecture detected: $ARCH"
    
    # Detect OS
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        OS_ID=$ID
        OS_VERSION=$VERSION_CODENAME
        log_info "OS detected: $OS_ID $OS_VERSION"
    fi
}

# Setup backports for Debian
setup_backports() {
    if [ "$OS_ID" = "debian" ]; then
        log_info "Setting up Debian backports..."
        BACKPORTS_FILE="/etc/apt/sources.list.d/50-${OS_VERSION}-backports.list"
        
        if [ ! -f "$BACKPORTS_FILE" ]; then
            echo "deb http://deb.debian.org/debian ${OS_VERSION}-backports main contrib non-free" | sudo tee "$BACKPORTS_FILE" > /dev/null
            log_success "Backports configured for $OS_VERSION"
        fi
    fi
}

# Install base dependencies
install_base() {
    log_step "Installing base dependencies..."
    sudo apt-get update -qq
    
    setup_backports
    sudo apt-get update -qq
    
    sudo apt-get install -y -qq \
        curl \
        wget \
        unzip \
        git \
        build-essential \
        cmake \
        pkg-config \
        libssl-dev \
        libclang-dev \
        clang \
        openssh-server \
        htop \
        tree \
        xclip \
        jq
    
    log_success "Base dependencies installed"
}

# Install Fish shell
install_fish() {
    log_step "Installing Fish shell..."
    
    if command -v fish &> /dev/null; then
        CURRENT_FISH_VERSION=$(fish --version | grep -oP '\d+\.\d+' | head -1)
        log_warn "Fish already installed: $(fish --version)"
        
        # Check if we need to upgrade from backports
        if [ "$OS_ID" = "debian" ] && [ ! -z "$CURRENT_FISH_VERSION" ]; then
            FISH_MAJOR=$(echo $CURRENT_FISH_VERSION | cut -d. -f1)
            FISH_MINOR=$(echo $CURRENT_FISH_VERSION | cut -d. -f2)
            
            # If version is < 3.2, upgrade from backports
            if [ "$FISH_MAJOR" -lt 3 ] || ([ "$FISH_MAJOR" -eq 3 ] && [ "$FISH_MINOR" -lt 2 ]); then
                log_info "Upgrading Fish to newer version from backports..."
                sudo apt-get install -y -qq -t ${OS_VERSION}-backports fish
                log_success "Fish upgraded to $(fish --version)"
            fi
        fi
    else
        # Fresh installation
        if [ "$OS_ID" = "debian" ]; then
            # Install from backports to get Fish 3.6+
            log_info "Installing Fish from backports for better compatibility..."
            sudo apt-get install -y -qq -t ${OS_VERSION}-backports fish
        else
            sudo apt-get install -y -qq fish
        fi
        log_success "Fish installed: $(fish --version)"
    fi
    
    # Set Fish as default shell
    if [ "$SHELL" != "$(which fish)" ]; then
        log_info "Setting Fish as default shell..."
        sudo chsh -s $(which fish) $USER
        log_success "Fish set as default shell (restart required)"
    fi
}

# Install Starship prompt
install_starship() {
    log_step "Installing Starship prompt..."
    
    if command -v starship &> /dev/null; then
        log_warn "Starship already installed: $(starship --version)"
    else
        curl -sS https://starship.rs/install.sh | sh -s -- -y
        log_success "Starship installed"
    fi
}

# Install Zoxide (smart cd)
install_zoxide() {
    log_step "Installing Zoxide..."
    
    if command -v zoxide &> /dev/null; then
        log_warn "Zoxide already installed: $(zoxide --version)"
    else
        curl -sS https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | bash
        log_success "Zoxide installed"
    fi
}

# Install Atuin (shell history)
install_atuin() {
    log_step "Installing Atuin..."
    
    if command -v atuin &> /dev/null; then
        log_warn "Atuin already installed: $(atuin --version)"
    else
        curl -sSf https://setup.atuin.sh | bash
        log_success "Atuin installed"
    fi
}

# Install fzf (fuzzy finder)
install_fzf() {
    log_step "Installing fzf..."
    
    if command -v fzf &> /dev/null; then
        log_warn "fzf already installed: $(fzf --version)"
    else
        sudo apt-get install -y -qq fzf || {
            git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
            ~/.fzf/install --all
        }
        log_success "fzf installed"
    fi
}

# Install fd (better find)
install_fd() {
    log_step "Installing fd..."
    
    if command -v fd &> /dev/null || command -v fdfind &> /dev/null; then
        log_warn "fd already installed"
    else
        sudo apt-get install -y -qq fd-find
        # Create symlink for fd command
        mkdir -p ~/.local/bin
        ln -sf $(which fdfind) ~/.local/bin/fd 2>/dev/null || true
        log_success "fd installed"
    fi
}

# Install ripgrep (better grep)
install_ripgrep() {
    log_step "Installing ripgrep..."
    
    if command -v rg &> /dev/null; then
        log_warn "ripgrep already installed: $(rg --version | head -1)"
    else
        sudo apt-get install -y -qq ripgrep
        log_success "ripgrep installed"
    fi
}

# Install bat (better cat)
install_bat() {
    log_step "Installing bat..."
    
    if command -v bat &> /dev/null || command -v batcat &> /dev/null; then
        log_warn "bat already installed"
    else
        sudo apt-get install -y -qq bat
        # Create symlink for bat command
        mkdir -p ~/.local/bin
        ln -sf $(which batcat) ~/.local/bin/bat 2>/dev/null || true
        log_success "bat installed"
    fi
}

# Install Lazygit
install_lazygit() {
    log_step "Installing Lazygit..."
    
    if command -v lazygit &> /dev/null; then
        log_warn "Lazygit already installed: $(lazygit --version)"
    else
        LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep -Po '"tag_name": "v\K[^"]*')
        
        if [ "$ARCH" = "arm64" ]; then
            LAZYGIT_ARCH="arm64"
        elif [ "$ARCH" = "amd64" ]; then
            LAZYGIT_ARCH="x86_64"
        else
            LAZYGIT_ARCH="arm"
        fi
        
        curl -Lo /tmp/lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${LAZYGIT_VERSION}_Linux_${LAZYGIT_ARCH}.tar.gz"
        cd /tmp && tar xf lazygit.tar.gz lazygit
        sudo install lazygit /usr/local/bin
        rm -f /tmp/lazygit.tar.gz /tmp/lazygit
        log_success "Lazygit installed"
    fi
}

# Install Neovim
install_neovim() {
    log_step "Installing Neovim..."
    
    if command -v nvim &> /dev/null; then
        NVIM_VERSION=$(nvim --version | head -1)
        log_warn "Neovim already installed: $NVIM_VERSION"
    else
        # Try to install from repository first
        if sudo apt-get install -y -qq neovim 2>/dev/null; then
            # Check if version is recent enough (>= 0.9)
            NVIM_VERSION=$(nvim --version | head -1 | grep -oP '\d+\.\d+' | head -1)
            if [ "$(echo "$NVIM_VERSION >= 0.9" | bc -l)" = "1" ] 2>/dev/null; then
                log_success "Neovim installed from repository"
            else
                log_warn "Repository version too old, building from source..."
                sudo apt-get remove -y neovim 2>/dev/null || true
                build_neovim_from_source
            fi
        else
            build_neovim_from_source
        fi
    fi
}

build_neovim_from_source() {
    log_info "Building Neovim from source (this may take a while)..."
    
    sudo apt-get install -y -qq \
        ninja-build \
        gettext \
        cmake \
        unzip \
        curl
    
    cd /tmp
    rm -rf neovim
    git clone --depth 1 --branch stable https://github.com/neovim/neovim.git
    cd neovim
    make CMAKE_BUILD_TYPE=Release
    sudo make install
    cd ~
    rm -rf /tmp/neovim
    log_success "Neovim built and installed"
}

# Install tree-sitter CLI
install_treesitter() {
    log_step "Installing tree-sitter..."
    
    if command -v tree-sitter &> /dev/null; then
        log_warn "tree-sitter already installed"
    else
        # Install libclang (required for building tree-sitter-cli)
        log_info "Installing libclang dependencies..."
        sudo apt-get install -y -qq libclang-dev clang
        
        # tree-sitter CLI via npm (faster, no compilation) or cargo
        if command -v npm &> /dev/null; then
            npm install -g tree-sitter-cli
            log_success "tree-sitter installed via npm"
        elif command -v cargo &> /dev/null; then
            cargo install tree-sitter-cli
            log_success "tree-sitter installed via cargo"
        else
            log_warn "tree-sitter requires npm or cargo, skipping"
            return
        fi
    fi
}

# Install GCC (compiler)
install_gcc() {
    log_step "Installing GCC..."
    
    if command -v gcc &> /dev/null; then
        log_warn "GCC already installed: $(gcc --version | head -1)"
    else
        sudo apt-get install -y -qq gcc g++
        log_success "GCC installed"
    fi
}

# Install Tmux
install_tmux() {
    log_step "Installing Tmux..."
    
    if command -v tmux &> /dev/null; then
        log_warn "Tmux already installed: $(tmux -V)"
    else
        sudo apt-get install -y -qq tmux
        log_success "Tmux installed"
    fi
    
    # Install TPM (Tmux Plugin Manager)
    if [ ! -d "$HOME/.tmux/plugins/tpm" ]; then
        log_info "Installing TPM (Tmux Plugin Manager)..."
        git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
        log_success "TPM installed"
    fi
}

# Install Carapace (completions)
install_carapace() {
    log_step "Installing Carapace..."
    
    if command -v carapace &> /dev/null; then
        log_warn "Carapace already installed"
    else
        # Download binary from GitHub releases
        CARAPACE_VERSION=$(curl -sL "https://api.github.com/repos/carapace-sh/carapace-bin/releases/latest" | grep -oP '"tag_name": "v\K[^"]*' | head -1)
        
        if [ -z "$CARAPACE_VERSION" ]; then
            log_warn "Could not fetch Carapace version, using fallback"
            CARAPACE_VERSION="1.0.6"
        fi
        
        if [ "$ARCH" = "arm64" ]; then
            CARAPACE_ARCH="arm64"
        elif [ "$ARCH" = "amd64" ]; then
            CARAPACE_ARCH="amd64"
        else
            log_warn "Carapace not available for $ARCH"
            return
        fi
        
        log_info "Downloading Carapace v${CARAPACE_VERSION}..."
        curl -fsSL -o /tmp/carapace.tar.gz "https://github.com/carapace-sh/carapace-bin/releases/download/v${CARAPACE_VERSION}/carapace-bin_${CARAPACE_VERSION}_linux_${CARAPACE_ARCH}.tar.gz"
        
        if [ $? -ne 0 ]; then
            log_error "Failed to download Carapace"
            return
        fi
        
        cd /tmp && tar xzf carapace.tar.gz
        if [ -f /tmp/carapace ]; then
            sudo install carapace /usr/local/bin/
            rm -f /tmp/carapace.tar.gz /tmp/carapace
            log_success "Carapace installed"
        else
            log_error "Carapace binary not found after extraction"
            rm -f /tmp/carapace.tar.gz
        fi
    fi
}

# Install Volta (Node.js version manager)
install_volta() {
    log_step "Installing Volta..."
    
    if command -v volta &> /dev/null; then
        log_warn "Volta already installed: $(volta --version)"
    else
        curl https://get.volta.sh | bash -s -- --skip-setup
        export VOLTA_HOME="$HOME/.volta"
        export PATH="$VOLTA_HOME/bin:$PATH"
        
        # Install latest Node.js LTS
        log_info "Installing Node.js LTS via Volta..."
        volta install node@lts
        log_success "Volta and Node.js installed"
    fi
}

# Install Bun
install_bun() {
    log_step "Installing Bun..."
    
    if command -v bun &> /dev/null; then
        log_warn "Bun already installed: $(bun --version)"
    else
        curl -fsSL https://bun.sh/install | bash
        export BUN_INSTALL="$HOME/.bun"
        export PATH="$BUN_INSTALL/bin:$PATH"
        log_success "Bun installed"
    fi
}

# Install Rust and Cargo
install_rust() {
    log_step "Installing Rust and Cargo..."
    
    if command -v cargo &> /dev/null; then
        log_warn "Rust already installed: $(rustc --version)"
    else
        curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
        source "$HOME/.cargo/env"
        log_success "Rust and Cargo installed"
    fi
}

# Install Go
install_go() {
    log_step "Installing Go..."
    
    if command -v go &> /dev/null; then
        log_warn "Go already installed: $(go version)"
    else
        GO_VERSION="1.22.0"
        
        if [ "$ARCH" = "arm64" ]; then
            GO_ARCH="arm64"
        elif [ "$ARCH" = "amd64" ]; then
            GO_ARCH="amd64"
        else
            GO_ARCH="armv6l"
        fi
        
        curl -Lo /tmp/go.tar.gz "https://go.dev/dl/go${GO_VERSION}.linux-${GO_ARCH}.tar.gz"
        sudo rm -rf /usr/local/go
        sudo tar -C /usr/local -xzf /tmp/go.tar.gz
        rm /tmp/go.tar.gz
        
        # Add to PATH
        echo 'export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin' >> ~/.bashrc
        export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin
        log_success "Go installed"
    fi
}

# Install OpenCode (AI coding assistant)
install_opencode() {
    log_step "Installing OpenCode..."
    
    if command -v opencode &> /dev/null; then
        log_warn "OpenCode already installed: $(opencode --version 2>/dev/null || echo 'installed')"
    else
        # Prefer npm (via Volta) if available, otherwise use bun
        if command -v npm &> /dev/null; then
            npm install -g opencode-ai
            log_success "OpenCode installed via npm"
        elif command -v bun &> /dev/null; then
            bun install -g opencode-ai
            log_success "OpenCode installed via bun"
        else
            # Fallback to install script
            curl -fsSL https://opencode.ai/install | bash
            log_success "OpenCode installed via install script"
        fi
    fi
}

# Install Nerd Fonts (Iosevka Term)
install_nerd_fonts() {
    log_step "Installing Nerd Fonts (Iosevka Term)..."
    
    FONT_DIR="$HOME/.local/share/fonts"
    mkdir -p "$FONT_DIR"
    
    if ls "$FONT_DIR"/*Iosevka* &> /dev/null; then
        log_warn "Iosevka Nerd Font already installed"
    else
        log_info "Downloading Iosevka Term Nerd Font..."
        curl -Lo /tmp/IosevkaTerm.zip "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/IosevkaTerm.zip"
        unzip -o /tmp/IosevkaTerm.zip -d "$FONT_DIR"
        rm /tmp/IosevkaTerm.zip
        
        # Update font cache
        fc-cache -fv
        log_success "Iosevka Term Nerd Font installed"
    fi
}

# Configure Git
setup_git() {
    log_step "Configuring Git..."
    
    if [ ! -f "$HOME/.gitconfig" ] || ! grep -q "name" "$HOME/.gitconfig"; then
        read -p "Your name for Git: " GIT_NAME
        read -p "Your email for Git: " GIT_EMAIL
        
        git config --global user.name "$GIT_NAME"
        git config --global user.email "$GIT_EMAIL"
    fi
    
    git config --global init.defaultBranch main
    git config --global core.editor nvim
    git config --global pull.rebase false
    
    log_success "Git configured"
}

# Copy dotfiles configurations
setup_dotfiles() {
    log_step "Setting up dotfiles..."
    
    # Fish
    if [ -f "$DOTFILES_DIR/config/fish/config.fish" ]; then
        mkdir -p "$HOME/.config/fish"
        cp "$DOTFILES_DIR/config/fish/config.fish" "$HOME/.config/fish/config.fish"
        log_success "Fish config installed"
    fi
    
    # Starship
    if [ -f "$DOTFILES_DIR/config/starship/starship.toml" ]; then
        mkdir -p "$HOME/.config"
        cp "$DOTFILES_DIR/config/starship/starship.toml" "$HOME/.config/starship.toml"
        log_success "Starship config installed"
    fi
    
    # Tmux
    if [ -f "$DOTFILES_DIR/config/tmux/tmux.conf" ]; then
        mkdir -p "$HOME/.config/tmux"
        cp "$DOTFILES_DIR/config/tmux/tmux.conf" "$HOME/.config/tmux/tmux.conf"
        ln -sf "$HOME/.config/tmux/tmux.conf" "$HOME/.tmux.conf"
        log_success "Tmux config installed"
        
        # Install Tmux plugins
        if [ -d "$HOME/.tmux/plugins/tpm" ]; then
            log_info "Installing Tmux plugins..."
            ~/.tmux/plugins/tpm/bin/install_plugins || true
        fi
    fi
    
    # Neovim
    if [ -d "$DOTFILES_DIR/config/nvim" ]; then
        # Backup existing config
        if [ -d "$HOME/.config/nvim" ]; then
            mv "$HOME/.config/nvim" "$HOME/.config/nvim.backup.$(date +%s)"
            log_info "Existing Neovim config backed up"
        fi
        
        mkdir -p "$HOME/.config/nvim"
        cp -r "$DOTFILES_DIR/config/nvim/"* "$HOME/.config/nvim/"
        log_success "Neovim config installed"
    fi
    
    # Lazygit
    if [ -d "$DOTFILES_DIR/config/lazygit" ]; then
        mkdir -p "$HOME/.config/lazygit"
        cp -r "$DOTFILES_DIR/config/lazygit/"* "$HOME/.config/lazygit/"
        log_success "Lazygit config installed"
    fi
    
    # Scripts
    if [ -d "$DOTFILES_DIR/scripts" ]; then
        mkdir -p "$HOME/.local/bin"
        cp "$DOTFILES_DIR/scripts/"*.sh "$HOME/.local/bin/" 2>/dev/null || true
        chmod +x "$HOME/.local/bin/"*.sh 2>/dev/null || true
        log_success "Scripts installed in ~/.local/bin"
    fi
}

# Clone dotfiles repository
clone_dotfiles() {
    if [ ! -d "$DOTFILES_DIR" ]; then
        log_step "Cloning dotfiles repository..."
        git clone "$DOTFILES_REPO" "$DOTFILES_DIR"
        log_success "Dotfiles cloned to $DOTFILES_DIR"
    else
        log_info "Dotfiles directory already exists, pulling latest..."
        cd "$DOTFILES_DIR" && git pull
    fi
}

# Full installation
full_install() {
    install_base
    install_gcc
    install_fish
    install_tmux
    install_neovim
    install_starship
    install_zoxide
    install_atuin
    install_fzf
    install_fd
    install_ripgrep
    install_bat
    install_lazygit
    install_rust
    install_go
    install_volta
    install_bun
    install_carapace
    install_nerd_fonts
    install_opencode
    setup_git
    setup_dotfiles
    
    # Install tree-sitter after cargo is available
    install_treesitter
}

# Tools only installation
tools_only() {
    install_base
    install_gcc
    install_fish
    install_tmux
    install_neovim
    install_starship
    install_zoxide
    install_atuin
    install_fzf
    install_fd
    install_ripgrep
    install_bat
    install_lazygit
    install_rust
    install_go
    install_volta
    install_bun
    install_carapace
    install_nerd_fonts
    install_opencode
    install_treesitter
}

# Main menu
main() {
    header
    detect_arch
    
    # Check if running as part of the repo or standalone
    if [ -d "$(dirname "$0")/config" ]; then
        DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"
        log_info "Using local dotfiles: $DOTFILES_DIR"
    fi
    
    echo "Select an option:"
    echo ""
    echo "  1) Full installation (recommended)"
    echo "  2) Tools only (no dotfiles)"
    echo "  3) Dotfiles only"
    echo "  4) Install specific tool"
    echo "  5) Exit"
    echo ""
    read -p "Option [1]: " OPTION
    OPTION=${OPTION:-1}
    
    case $OPTION in
        1)
            full_install
            ;;
        2)
            tools_only
            ;;
        3)
            setup_dotfiles
            ;;
        4)
            echo ""
            echo "Available tools:"
            echo "  fish, tmux, neovim, starship, zoxide, atuin, fzf"
            echo "  fd, ripgrep, bat, lazygit, rust, go, volta, bun"
            echo "  carapace, gcc, treesitter, fonts, opencode"
            echo ""
            read -p "Tool to install: " TOOL
            case $TOOL in
                fish) install_fish ;;
                tmux) install_tmux ;;
                neovim|nvim) install_neovim ;;
                starship) install_starship ;;
                zoxide) install_zoxide ;;
                atuin) install_atuin ;;
                fzf) install_fzf ;;
                fd) install_fd ;;
                ripgrep|rg) install_ripgrep ;;
                bat) install_bat ;;
                lazygit) install_lazygit ;;
                rust|cargo) install_rust ;;
                go) install_go ;;
                volta) install_volta ;;
                bun) install_bun ;;
                carapace) install_carapace ;;
                gcc) install_gcc ;;
                treesitter|tree-sitter) install_treesitter ;;
                fonts|nerdfonts) install_nerd_fonts ;;
                opencode) install_opencode ;;
                *) log_error "Unknown tool: $TOOL" ;;
            esac
            ;;
        5)
            exit 0
            ;;
        *)
            log_error "Invalid option"
            exit 1
            ;;
    esac
    
    echo ""
    echo -e "${GREEN}╔═══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║     Installation complete!                                    ║${NC}"
    echo -e "${GREEN}╚═══════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo "Next steps:"
    echo "  1. Restart your terminal or run: exec fish"
    echo "  2. Start tmux and press prefix + I to install plugins"
    echo "  3. Open nvim to let LazyVim install plugins"
    echo ""
    
    # Kill tmux server if running to ensure it uses new Fish version
    if pgrep -x tmux > /dev/null; then
        log_info "Restarting tmux server to apply Fish updates..."
        tmux kill-server 2>/dev/null || true
        log_success "Tmux server restarted"
    fi
}

# Run if called directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
