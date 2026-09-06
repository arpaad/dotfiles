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

# --- theme: ONE palette for bat, delta, fzf, eza, yazi, tmux, lazygit, nvim ---
# See theme/.config/theme/palette.env and docs/theme/README.md. Regenerate with 04-theme.sh.
source ~/.config/theme/palette.env
source ~/.config/theme/fzf.sh          # fzf colours (appends to FZF_DEFAULT_OPTS)
export BAT_THEME="$THEME_BAT"          # bat, and delta — which follows BAT_THEME

# --- aliases (interactive only; scripts unaffected) ---
alias ls='eza --icons --group-directories-first'
alias ll='eza -l --icons --group-directories-first --git'
alias la='eza -la --icons --group-directories-first --git'
alias lt='eza -T --icons --level=2 --group-directories-first'
alias lg='eza -l --icons --git --git-repos'   # shows repo status per folder

alias cat='bat'          # source, syntax-highlighted
alias md='glow -p'       # markdown, rendered  (cat shows source, md shows result)
alias cat='bat'          # source, syntax-highlighted
alias md='glow -p'       # markdown, rendered  (cat shows source, md shows result)

export MANPAGER="sh -c 'col -bx | bat -l man -p'"

# --- editor: what yazi, git, and friends open files with ---
export EDITOR=nvim
export VISUAL=nvim
alias v='nvim'

# --- yazi ---
# `y` opens yazi and, on quit, drops the shell in whatever directory you ended
# up in. Plain `yazi` works too — it just leaves the shell where it started.
y() {
  local tmp="$(mktemp -t yazi-cwd.XXXXXX)" cwd
  yazi "$@" --cwd-file="$tmp"
  IFS= read -r -d '' cwd < "$tmp"
  [ -n "$cwd" ] && [ "$cwd" != "$PWD" ] && cd "$cwd"
  rm -f -- "$tmp"
}


# --- editor: what yazi, git, and friends open files with ---
export EDITOR=nvim
export VISUAL=nvim
alias v='nvim'

# --- yazi ---
# `y` opens yazi and, on quit, drops the shell in whatever directory you ended
# up in. Plain `yazi` works too — it just leaves the shell where it started.
y() {
  local tmp="$(mktemp -t yazi-cwd.XXXXXX)" cwd
  yazi "$@" --cwd-file="$tmp"
  IFS= read -r -d '' cwd < "$tmp"
  [ -n "$cwd" ] && [ "$cwd" != "$PWD" ] && cd "$cwd"
  rm -f -- "$tmp"
}

# --- go ---
export GOPATH="$HOME/go"
export PATH="$GOPATH/bin:$PATH"
