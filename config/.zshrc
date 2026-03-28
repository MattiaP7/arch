# Powerlevel10k Instant Prompt
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Esportazioni Ambiente
export ZSH="$HOME/.oh-my-zsh"
export TERMINAL=kitty
export EDITOR='nvim' # o vim
export GTK_THEME=Tokyo-Night # Se hai installato il tema Tokyo Night GTK
export ADW_DISABLE_PORTAL=1  # Forza Libadwaita a ignorare il portale e usare il dark

# Plugin Oh My Zsh
plugins=(
  git
  zsh-autosuggestions 
  zsh-syntax-highlighting 
  fast-syntax-highlighting
  colored-man-pages
  z
)

source $ZSH/oh-my-zsh.sh

# Integrazione Powerlevel10k
source ~/powerlevel10k/powerlevel10k.zsh-theme
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh


# Keybindings
.zle_select-all (){
  ((CURSOR=0))
  ((MARK=$#BUFFER))
  ((REGION_ACTIVE=1))
}
zle -N .zle_select-all
bindkey '^A' .zle_select-all

# Aliases
alias ls="eza --color=always --icons"
alias ll="eza -lah --color=always --icons"
alias lr="eza -lahR --color=always --icons"
alias cls="clear"

export PATH="$HOME/.local/bin:$PATH"
