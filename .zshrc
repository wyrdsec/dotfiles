#          _              
#  _______| |__  _ __ ___ 
# |_  / __| '_ \| '__/ __|
#  / /\__ \ | | | | | (__ 
# /___|___/_| |_|_|  \___|
                        
## Options section
setopt extendedglob                                             # Extended globbing. Allows using regular expressions with *
setopt nocaseglob                                               # Case insensitive globbing
setopt rcexpandparam                                            # Array expension with parameters
setopt nocheckjobs                                              # Don't warn about running processes when exiting
setopt numericglobsort                                          # Sort filenames numerically when it makes sense
setopt nobeep                                                   # No beep
setopt appendhistory                                            # Immediately append history instead of overwriting
setopt histignorealldups                                        # If a new command is a duplicate, remove the older one

zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'       # Case insensitive tab completion
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"         # Colored completion (different colors for dirs/files/etc)
zstyle ':completion:*' rehash true                              # automatically find new executables in path 
# Speed up completions
zstyle ':completion:*' accept-exact '*(N)'
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path ~/.zsh/cache

# History Settings
HISTFILE=~/.zhistory
HISTSIZE=1000
SAVEHIST=500

export SHELL=$(which zsh)

# Set editor
export EDITOR=$(which vim)										# Use vim because it's better
export VISUAL=$(which vim)										# Use vim because it's better

# Set up extra paths if needed
SOURCES=(
	"$HOME/.cargo/bin"
	"$HOME/.nimble/bin"
	"/usr/local/sbin"
	"$HOME/bin"
)

for f in "${SOURCES[@]}"; do
	if [ -d $f ]; then
		export PATH=$PATH:$f
	fi
done

unset SOURCES

WORDCHARS=${WORDCHARS//\/[&.;]}                                 # Don't consider certain characters part of the word

## Keybindings section
bindkey -e
bindkey '^[[7~' beginning-of-line                               # Home key
bindkey '^[[H' beginning-of-line                                # Home key
if [[ "${terminfo[khome]}" != "" ]]; then
  bindkey "${terminfo[khome]}" beginning-of-line                # [Home] - Go to beginning of line
fi
bindkey '^[[8~' end-of-line                                     # End key
bindkey '^[[F' end-of-line                                      # End key
if [[ "${terminfo[kend]}" != "" ]]; then
  bindkey "${terminfo[kend]}" end-of-line                       # [End] - Go to end of line
fi
bindkey '^[[3~' delete-char                                     # Delete key
bindkey '^[[C'  forward-char                                    # Right key
bindkey '^[[D'  backward-char                                   # Left key
bindkey '^[[5~' history-beginning-search-backward               # Page up key
bindkey '^[[6~' history-beginning-search-forward                # Page down key

# Navigate words with ctrl+arrow keys
bindkey '^[Oc' forward-word                                     #
bindkey '^[Od' backward-word                                    #
bindkey '^[[1;5D' backward-word                                 #
bindkey '^[[1;5C' forward-word                                  #
bindkey '^H' backward-kill-word                                 # delete previous word with ctrl+backspace
bindkey '^[[Z' undo                                             # Shift+tab undo last action


# Theming section  
autoload -U colors
colors

# Completion section
autoload bashcompinit && bashcompinit
autoload -U compinit && compinit -d

if command -v 'aws_completer'; then
	complete -C $(which aws_completer) aws
fi

# enable substitution for prompt
setopt prompt_subst

# Prompt (on left side) similar to default bash prompt, or redhat zsh prompt with colors
#PROMPT="%(!.%{$fg[red]%}[%n@%m %1~]%{$reset_color%}# .%{$fg[green]%}[%n@%m %1~]%{$reset_color%}$ "
# Maia prompt
PROMPT="%{$fg[green]%}%m%{$reset_color%} | %B%{$fg[cyan]%}%(4~|%-1~/.../%2~|%~)%u%b >%{$fg[cyan]%}>%B%(?.%{$fg[cyan]%}.%{$fg[red]%})>%{$reset_color%}%b " # Print some system information when the shell is first started

# Right prompt with exit status of previous command if not successful
#RPROMPT="%{$fg[red]%} %(?..[%?])" 
# Right prompt with exit status of previous command marked with ✓ or ✗
RPROMPT="%(?.%{$fg[green]%}✓%{$reset_color%}.%{$fg[red]%}%? ✗%{$reset_color%})"


# Color man pages
export LESS_TERMCAP_mb=$'\E[01;32m'
export LESS_TERMCAP_md=$'\E[01;32m'
export LESS_TERMCAP_me=$'\E[0m'
export LESS_TERMCAP_se=$'\E[0m'
export LESS_TERMCAP_so=$'\E[01;47;34m'
export LESS_TERMCAP_ue=$'\E[0m'
export LESS_TERMCAP_us=$'\E[01;36m'
export LESS=-r

## Alias section 
alias cp="cp -i"                                                # Confirm before overwriting something
alias df='df -h'                                                # Human-readable sizes
alias free='free -m'                                            # Show sizes in MB
alias grep='grep --color=always'
alias ll='ls -lh'
alias la='ls -lah'
alias pvim='vim -n -i NONE'

if [[ -d "$HOME/.ssh/config.d" ]]; then
	alias ssh='ssh -F =(for f in ~/.ssh/config.d/*config; do cat $f; echo; done)'
	alias scp='scp -F =(for f in ~/.ssh/config.d/*config; do cat $f; echo; done)'
fi

# Print SSH config hosts entries in a /etc/hosts friendly output
function lssh {
	if [[ -d "$HOME/.ssh/config.d" ]]; then
		for ssh_host in `cat ~/.ssh/config.d/*config | egrep '^\s*Host\s+' | sed 's/^\s*Host \(\w*\)/\1/g'`; do
			ssh_host_address=`ssh -G $ssh_host | grep "^hostname " | sed "s/^hostname \(.*\)/\1/"`
			printf "%-60s\t%-s\n" $ssh_host_address $ssh_host
		done
	fi
}

# Swap prompt to a smaller one with no hostname included
CURRENT_PROMPT=0
function pswap {
	if (( CURRENT_PROMPT == 0 )); then
		PROMPT="%B%{$fg[cyan]%}%(4~|%-1~/.../%2~|%~)%u%b >%{$fg[cyan]%}>%B%(?.%{$fg[cyan]%}.%{$fg[red]%})>%{$reset_color%}%b "
		CURRENT_PROMPT=1
	else
		PROMPT="%{$fg[green]%}%m%{$reset_color%} | %B%{$fg[cyan]%}%(4~|%-1~/.../%2~|%~)%u%b >%{$fg[cyan]%}>%B%(?.%{$fg[cyan]%}.%{$fg[red]%})>%{$reset_color%}%b "
		CURRENT_PROMPT=0
	fi
}

case `uname -s` in
	# OSX
	Darwin*)
		alias ls="ls -G"
		if [[ -f "/opt/homebrew/bin/vim" ]]; then
			alias vim="/opt/homebrew/bin/vim"
		fi
		export PATH="$PATH:/opt/homebrew/bin"
	;;
	Linux*)
		alias ls="ls --color=always"

		# Apply different settigns for different terminals
		case $(basename "$(cat "/proc/$PPID/comm")") in
			login)
				# Type name of desired desktop after x, xinitrc is configured for it
				alias x='startx ~/.xinitrc'
			;;
		  'tmux: server')

		     ;;
			*)

			;;
		esac

	;;
	FreeBSD*)
	;;
esac

# Print a greeting message when shell is started
echo $USER@$HOST  $(uname -srm)
