HISTFILE=~/.histfile
HISTSIZE=100000
SAVEHIST=10000
bindkey -e

setopt INC_APPEND_HISTORY SHARE_HISTORY
setopt APPEND_HISTORY
setopt HIST_IGNORE_ALL_DUPS

setopt autocd
setopt prompt_subst

# Delete key
bindkey    "^[[3~"          delete-char
bindkey    "^[3;5~"         delete-char

bindkey "\e[A" history-beginning-search-backward
bindkey "\e[B" history-beginning-search-forward

zstyle :compinstall filename '/home/yurin/.zshrc'

autoload -Uz compinit promptinit colors
colors
compinit
promptinit

zstyle ':completion::complete:*' use-cache on
zstyle ':completion::complete:*' cache-path .zcache
zstyle ':completion:*:cd:*' _complete _match ignore-parents parent pwd

[ -f /etc/DIR_COLORS ] && eval $(dircolors -b /etc/DIR_COLORS)
export ZLSCOLORS="${LS_COLORS}"

zmodload  zsh/complist
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#)*=0=01;31'

case `hostname` in
	hell)
		MY_HOST='%{$fg[yellow]%U%}%m%{%u${reset_color}'
		;;
	dev-mx)
		MY_HOST='%{$fg[green]%U%}%m%{%u${reset_color}'
		;;
	dev-webnode1)
		MY_HOST='%{$fg[blue]%U%}%m%{%u${reset_color}'
		;;
	*)
		MY_HOST='%{$fg[white]%U%}%m%{%u${reset_color}'
		;;
esac
USER='%{$fg[yellow]%U%}%n%{%u${reset_color}'
PROMPT="$USER@$MY_HOST:%{$fg[blue]%}%~%{$fg[red]%}\$ %{${reset_color}%}"

# enable color support of ls and also add handy aliases
alias ls='ls --color=auto'
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'

alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi
