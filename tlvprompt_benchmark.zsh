source tlvprompt.zsh
test_static() {
	for ((ii = 0; ii < 1024; ii++)); do
		set_static
	done
}
test_hook() {
	for ((ii = 0; ii < 4096; ii++)); do
		tlvprompt_precmd
	done
}
echo "set_static * 1024"
time (test_static)
echo "(precmd) * 4096"
time (test_hook)
