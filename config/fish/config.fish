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
    set -x PATH $HOME/.local/bin $HOME/.cargo/bin $HOME/.volta/bin $HOME/.bun/bin /usr/local/bin $PATH
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
    fzf --fish | source
end

# Carapace completions (if installed)
if command -q carapace
    set -Ux CARAPACE_BRIDGES 'zsh,fish,bash,inshellisense'

    if not test -d ~/.config/fish/completions
        mkdir -p ~/.config/fish/completions
    end

    if not test -f ~/.config/fish/completions/.initialized
        carapace --list | awk '{print $1}' | xargs -I{} touch ~/.config/fish/completions/{}.fish
        touch ~/.config/fish/completions/.initialized
    end

    carapace _carapace | source
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
