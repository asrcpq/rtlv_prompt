function set_permcolor(){
	if [ -w "$(readlink -f "$PWD")" ]; then
		PERMCOLOR='%F{cyan}'
	elif [ -x "$(readlink -f "$PWD")" ]; then
		PERMCOLOR='%F{red}'
	else
		PERMCOLOR='%F{white}'
	fi
}

function set_static(){
	COLS=$(tput cols)
	PS1_STATIC="%4F%n%f@%3F%m%f#"
	if [ -n "$(echo $TTY | grep "^/dev/pts")" ]; then
		TTY_COLOR='%F{blue}'
	elif [ -n "$(echo $TTY | grep "^/dev/tty")" ]; then
		TTY_COLOR='%F{green}'
	else
		TTY_COLOR='%F{white}'
	fi	
	PS1_STATIC+=$TTY_COLOR"%l%f&"
	if [ -d /proc/$PPID ]; then
		SH_PARENT=$(cat /proc/$PPID/status | head -1 | awk '{print $2}' | grep -o "^[a-zA-Z0-9\-_]*")
	fi
	case $SH_PARENT in
		"sakura")
			SH_COLOR='%F{magenta}' # vte based
			;;
		"termite")
			SH_COLOR='%F{magenta}'
			;;
		"sshd")
			SH_COLOR="%F{green}" # remote
			;;
		"mosh-server")
			SH_COLOR="%F{green}"
			;;
		"kitty")
			SH_COLOR="%F{yellow}" # GPU accelarated
			;;
		"alacritty")
			SH_COLOR_"%F{yellow}"
			;;
		"screen")
			SH_COLOR="%F{blue}" # nested terminal
			;;
		"tmux") 
			SH_COLOR="%F{blue}"
			;;
		"xterm")
			SH_COLOR="%F{cyan}" # xterm, rxvt, st
			;;
		"st")
			SH_COLOR="%F{cyan}"
			;;
		*)
			SH_COLOR="%F{white}"
			;;
	esac
	PS1_STATIC+=$SH_COLOR"$SH_PARENT%f"
}

function set_ps(){
	PS1=$'%(?..%11F%1F%?<%f)'
	PS1+=$PS1_STATIC
	PS1+=":%6F%d%f"$'\n%k'
	PS1+=$PS1_VISTATUS
	PS1+=$PERMCOLOR
	for ((i=0;i<$SHLVL;i++)) {
		PS1+='>'
	}
	PS1+="%f"
}

function set_prompt(){
	set_permcolor
	set_ps
#	set_rps
}

function zle-line-init zle-keymap-select {
	PS1_VIINS_SYMBOL="%12FI%f"
	PS1_VICMD_SYMBOL="%3FN%f"
	PS1_VISTATUS="${${KEYMAP/vicmd/$PS1_VICMD_SYMBOL}/(main|viins)/$PS1_VIINS_SYMBOL}"
	set_prompt
	zle reset-prompt
	if [[ $TERM != 'linux' ]]; then
		if [[ ${KEYMAP} == vicmd ]] ||
				[[ $1 = 'block' ]]; then
			echo -ne '\e[1 q'
		elif [[ ${KEYMAP} == main ]] ||
				[[ ${KEYMAP} == viins ]] ||
				[[ ${KEYMAP} = '' ]] ||
				[[ $1 = 'beam' ]]; then
			echo -ne '\e[5 q'
		fi
	fi
}

tlvprompt_preexec() {}

tlvprompt_precmd() {
	set_prompt
	echo -ne '\e[5 q'
}

tlvprompt_setup() {
	add-zsh-hook precmd tlvprompt_precmd
	add-zsh-hook preexec tlvprompt_preexec
	set_static

	zle -N zle-line-init
	zle -N zle-keymap-select

	PS1_VISTATUS=""
}

tlvprompt_setup
