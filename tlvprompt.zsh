function set_static(){
	PS1_STATIC="%4F%n%f@%3F%m%f#"
	if [[ $TTY == /dev/pts/* ]]; then
		local TTY_COLOR='%F{blue}'
	elif [[ $TTY == /dev/tty/* ]]; then
		local TTY_COLOR='%F{green}'
	else
		local TTY_COLOR='%F{white}'
	fi
	PS1_STATIC+=$TTY_COLOR"%l%f&"
	if [ -d /proc/$PPID ]; then
		local SH_PARENT="$(ps -o comm= $PPID)"
	fi
	case $SH_PARENT in
		"xterm") local SH_COLOR="%F{cyan}";; # simple terminals
		"st") local SH_COLOR="%F{cyan}";;
		"sshd") local SH_COLOR="%F{green}";; # remote
		"mosh-server") local SH_COLOR="%F{green}";;
		"screen") local SH_COLOR="%F{blue}";; # nested
		"tmux") local SH_COLOR="%F{blue}";;
		"sakura") local SH_COLOR='%F{magenta}';; # vte based
		"termite") local SH_COLOR='%F{magenta}';;
		"kitty") local SH_COLOR="%F{yellow}";; # GPU accelarated
		"alacritty") local SH_COLOR="%F{yellow}";;
		*) local SH_COLOR="%F{white}";; # others
	esac
	PS1_STATIC+=$SH_COLOR"$SH_PARENT%f"
}

function set_prompt(){
	PS1=$'%(?..%11F%1F%?<%f)'
	PS1+=$PS1_STATIC
	PS1+=":%6F%d%f"$'\n%k'
	PS1+=$PS1_VISTATUS
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
	local PS1_VIINS_SYMBOL="%12FI%f"
	local PS1_VICMD_SYMBOL="%3FN%f"
	PS1_VISTATUS="${${KEYMAP/vicmd/$PS1_VICMD_SYMBOL}/(main|viins)/$PS1_VIINS_SYMBOL}"
	set_prompt
	zle reset-prompt
	if [[ $TERM != 'linux' ]]; then
		if [ "$KEYMAP" = "vicmd" ] ||
				[ "$1" = "block" ]; then
			echo -ne '\e[1 q'
		elif [ "$KEYMAP" = "main" ] ||
				[ "$KEYMAP" = "viins" ] ||
				[ "$KEYMAP" = "" ] ||
				[ $1 = 'beam' ]; then
			echo -ne '\e[5 q'
		fi
	fi
}

tlvprompt_precmd() {
	set_prompt
	echo -ne '\e[5 q'
}

tlvprompt_setup() {
	add-zsh-hook precmd tlvprompt_precmd
	set_static

	zle -N zle-line-init
	zle -N zle-keymap-select

	local PS1_VISTATUS=""
}
