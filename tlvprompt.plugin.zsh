source ${0:A:h}/tlvprompt.zsh
tlvprompt_plugin_dir=${0:A:h}
tlvprompt_setup

tlvtoggle() {
	tlvprompt_legacy="$(( 1 - tlvprompt_legacy ))"
	if [ "$tlvprompt_legacy" = 1 ]; then
		source ${tlvprompt_plugin_dir}/tlvprompt_legacy.zsh
		tlvprompt_setup
	else
		source ${tlvprompt_plugin_dir}/tlvprompt.zsh
		tlvprompt_setup
	fi
}

tlvprompt_legacy=0
