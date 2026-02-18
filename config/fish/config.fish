if status is-interactive
    # Commands to run in interactive sessions can go here
    # Install Fisher if not installed
    if not functions -q fisher
        curl -sL https://git.io/fisher | source
        fisher install jorgebucaran/fisher
    end
end

# Detect Termux or Radxa (ARM devices)
set -l IS_ARM_DEVICE 0
if test -n "$TERMUX_VERSION"; or test -d /data/data/com.termux
    set IS_ARM_DEVICE 1
else if test (uname -m) = "aarch64"; or test (uname -m) = "armv7l"
    set IS_ARM_DEVICE 1
end

# PATH configuration
if test $IS_ARM_DEVICE -eq 1
    # ARM device (Radxa, Raspberry Pi, etc.)
    set -x PATH $HOME/.local/bin $HOME/.cargo/bin $HOME/.volta/bin $HOME/.bun/bin $HOME/go/bin /usr/local/go/bin /usr/local/bin $PATH
else if test (uname) = Darwin
    # macOS - check for Apple Silicon vs Intel
    if test -f /opt/homebrew/bin/brew
        set BREW_BIN /opt/homebrew/bin/brew
    else if test -f /usr/local/bin/brew
        set BREW_BIN /usr/local/bin/brew
    end
    set -x PATH $HOME/.local/bin $HOME/.volta/bin $HOME/.bun/bin $HOME/.cargo/bin /usr/local/bin $PATH
else
    # Linux x86
    set BREW_BIN /home/linuxbrew/.linuxbrew/bin/brew
    set -x PATH $HOME/.local/bin $HOME/.volta/bin $HOME/.bun/bin $HOME/.cargo/bin /usr/local/bin $PATH
end

# Only eval brew shellenv if brew is installed
if set -q BREW_BIN; and test -f $BREW_BIN
    eval ($BREW_BIN shellenv)
end

# Start tmux automatically if not already in tmux
if not set -q TMUX
    if command -q tmux
        tmux
    end
end

# Initialize tools (only if they exist)
if command -q starship
    starship init fish | source
end

if command -q zoxide
    zoxide init fish | source
end

if command -q atuin
    atuin init fish | source
end

if command -q fzf
    # Check if fzf supports --fish flag (v0.48+)
    # Fallback to basic configuration for older versions
    set fzf_version (fzf --version 2>/dev/null | string match -r '^\d+\.\d+' | string replace '.' '')
    if test -n "$fzf_version"; and test $fzf_version -ge 048
        fzf --fish | source
    else
        # Fallback for fzf < 0.48
        set -gx FZF_DEFAULT_OPTS '--height 40% --layout=reverse --border'
    end
end

# Carapace completions (if installed)
# Note: Requires Fish 3.2.0+ and may have compatibility issues with some versions
if command -q carapace
    # Check Fish version for compatibility
    set fish_version (fish --version | string match -r '\d+\.\d+' | string replace '.' '')
    
    if test -n "$fish_version"; and test $fish_version -ge 32
        # Only initialize if not already done or if there's no syntax error
        set -l carapace_init_error 0
        
        # Create completions directory
        if not test -d ~/.config/fish/completions
            mkdir -p ~/.config/fish/completions
        end

        if not test -f ~/.config/fish/completions/.initialized
            carapace --list | awk '{print $1}' | xargs -I{} touch ~/.config/fish/completions/{}.fish 2>/dev/null
            touch ~/.config/fish/completions/.initialized
        end

        # Try to source carapace, suppress errors if incompatible
        set -Ux CARAPACE_BRIDGES 'zsh,fish,bash,inshellisense' 2>/dev/null
        carapace _carapace 2>/dev/null | source 2>/dev/null
        or set carapace_init_error 1
        
        # If there was an error, clean up and disable
        if test $carapace_init_error -eq 1
            set -e CARAPACE_BRIDGES 2>/dev/null
        end
    end
end

# Disable greeting
set -g fish_greeting ""

# Enable vi mode
fish_vi_key_bindings

# Set nvim as default editor
set -gx EDITOR nvim
set -gx VISUAL nvim

# Aliases
alias ls='ls --color=auto'
alias ll='ls -la'
alias la='ls -A'

# FZF with bat preview (if both exist)
if command -q fzf; and command -q bat
    alias fzfbat='fzf --preview="bat --theme=gruvbox-dark --color=always {}"'
    alias fzfnvim='nvim (fzf --preview="bat --theme=gruvbox-dark --color=always {}")'
end

# Lazygit alias
if command -q lazygit
    alias lg='lazygit'
end

# Color scheme (Gentleman theme)
set -l foreground F3F6F9 normal
set -l selection 263356 normal
set -l comment 8394A3 brblack
set -l red CB7C94 red
set -l orange DEBA87 orange
set -l yellow FFE066 yellow
set -l green B7CC85 green
set -l purple A3B5D6 purple
set -l cyan 7AA89F cyan
set -l pink FF8DD7 magenta

# Syntax Highlighting Colors
set -g fish_color_normal $foreground
set -g fish_color_command $cyan
set -g fish_color_keyword $pink
set -g fish_color_quote $yellow
set -g fish_color_redirection $foreground
set -g fish_color_end $orange
set -g fish_color_error $red
set -g fish_color_param $purple
set -g fish_color_comment $comment
set -g fish_color_selection --background=$selection
set -g fish_color_search_match --background=$selection
set -g fish_color_operator $green
set -g fish_color_escape $pink
set -g fish_color_autosuggestion $comment

# Completion Pager Colors
set -g fish_pager_color_progress $comment
set -g fish_pager_color_prefix $cyan
set -g fish_pager_color_completion $foreground
set -g fish_pager_color_description $comment

clear
