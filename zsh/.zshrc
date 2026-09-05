# ~/.zshrc  ·  managed in ~/dev/dotfiles, symlinked by stow

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
alias ls='eza --group-directories-first'
alias ll='eza -l --git --group-directories-first'
alias la='eza -la --git --group-directories-first'
alias lt='eza --tree --level=2'
alias cat='bat'

# --- go ---
export GOPATH="$HOME/go"
export PATH="$GOPATH/bin:$PATH"
