function set_static(){
	PS1_STATIC=""
	if [ "$EUID" = "0" ]; then
		PS1_STATIC+=("R")
	fi
	if [ -n "$SSH_CONNECTION" ]; then
		PS1_STATIC+=("SSH:$HOST")
	fi
}

function set_prompt(){
	PS1=$'%(?..%F{red}%?%f)'
	if [ -n "$PS1_STATIC" ] || \
		[ $(( $#PS1_STATIC + $#PWD )) -gt $(( $COLUMNS - 16 )) ]; then
		if [ -n "$PS1_STATIC" ]; then
			PS1+="($PS1_STATIC)"
		fi
		PS1+="%F{cyan}%d%f"$'\n%k'
	else
		RPS1="%F{cyan}%d%f"
	fi
	if [ -w $PWD ]; then
		PS1+='%F{cyan}'
	elif [ -x $PWD ]; then
		PS1+='%F{red}'
	else
		PS1+='%F{white}'
	fi
	for ((i=0;i<$SHLVL;i++)) {
		PS1+='>'
	}
	PS1+="%f"
}

function zle-line-init zle-keymap-select {
	set_prompt
	zle reset-prompt
	if [[ $TERM != 'linux' ]]; then
		if [ "$KEYMAP" = "vicmd" ]; then
			echo -ne '\e[1 q'
		elif [ "$KEYMAP" = "main" ] ||
				[ "$KEYMAP" = "viins" ] ||
				[ "$KEYMAP" = "" ]; then
			echo -ne '\e[5 q'
		fi
	fi
}

tlvprompt_precmd() {
	set_prompt
}

tlvprompt_preexec() {
	RPS1=""
	zle reset-prompt
	zle accept-line
}

tlvprompt_setup() {
	autoload -U add-zsh-hook
	add-zsh-hook precmd tlvprompt_precmd
	set_static
	# call precmd or RPS wont appear in first prompt
	tlvprompt_precmd

	zle -N tlvprompt_preexec
	bindkey "" tlvprompt_preexec
	zle -N zle-line-init
	zle -N zle-keymap-select

	local PS1_VISTATUS=""
}
