function set_static(){
	PS1_STATIC="%F{blue}%n%f@%F{cyan}%m%f#"
	if [[ $TTY == /dev/pts/* ]]; then
		local TTY_COLOR='%F{blue}'
	elif [[ $TTY == /dev/tty* ]]; then
		local TTY_COLOR='%F{green}'
	else
		local TTY_COLOR='%F{white}'
	fi
	PS1_STATIC+=$TTY_COLOR"%l%f&"
	if [ -d /proc/$PPID ]; then
		local SH_PARENT="$(</proc/$PPID/comm)"
	fi
	case $SH_PARENT in
		"xterm") local SH_COLOR="%F{cyan}";; # common
		"foot") local SH_COLOR="%F{cyan}";;
		"sshd") local SH_COLOR="%F{green}";; # remote
		"mosh-server") local SH_COLOR="%F{green}";;
		"screen") local SH_COLOR="%F{blue}";; # detachable
		"tmux") local SH_COLOR="%F{blue}";;
		*) local SH_COLOR="%F{white}";; # others
	esac
	PS1_STATIC+=$SH_COLOR"$SH_PARENT%f"
}

function set_prompt(){
	PS1=$'%(?..%1F%?<%f)'
	PS1+=$PS1_STATIC
	PS1+=":%6F%d%f"$'\n%k'
	if [ -w $PWD ]; then
		PS1+='%F{cyan}'
	elif [ -x $PWD ]; then
		PS1+='%F{red}'
	else
		PS1+='%F{white}'
	fi
	PS1+="${(l:$SHLVL::>:)}%f"
}

function zle-line-init {
	set_prompt
	zle reset-prompt
	zle-keymap-select
}

function zle-keymap-select {
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

rtlv_prompt_precmd() {
	set_prompt
	echo -ne '\e[5 q'
}

rtlv_prompt_setup() {
	autoload -U add-zsh-hook
	add-zsh-hook precmd rtlv_prompt_precmd
	set_static

	zle -N zle-line-init
	zle -N zle-keymap-select
}
