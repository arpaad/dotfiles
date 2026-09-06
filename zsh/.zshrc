# ~/.zshrc  ·  managed in ~/.dotfiles, symlinked by stow

# --- PATH: user-local bin must come first (the mise binary lives here) ---
export PATH="$HOME/.local/bin:$PATH"

# --- oh-my-zsh ---
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME=""
# Feature flags: comment out a line to disable that plugin.
plugins=(
  git                     # git aliases + completions
  zsh-completions         # extra completion definitions
  zsh-autosuggestions     # ghosted suggestions from history (unsure? comment this out)
  zsh-syntax-highlighting # colorize commands as you type — KEEP LAST
)
source $ZSH/oh-my-zsh.sh

# --- mise: put runtimes/tools on PATH ---
eval "$(mise activate zsh)"

# --- starship: the prompt ---
eval "$(starship init zsh)"

# --- zoxide: cd = smart cd, cdi = interactive jump ---
eval "$(zoxide init zsh --cmd cd)"

# --- fzf: Ctrl-R history, Ctrl-T files, completion ---
source <(fzf --zsh)

# --- aliases (interactive only; scripts unaffected) ---
alias ls='eza --icons --group-directories-first'
alias ll='eza -l --icons --group-directories-first --git'
alias la='eza -la --icons --group-directories-first --git'
alias lt='eza -T --icons --level=2 --group-directories-first'
alias lg='eza -l --icons --git --git-repos'   # shows repo status per folder

alias cat='bat'

export BAT_THEME="Catppuccin Frappe"
export MANPAGER="sh -c 'col -bx | bat -l man -p'"
# --- go ---
export GOPATH="$HOME/go"
export PATH="$GOPATH/bin:$PATH"
