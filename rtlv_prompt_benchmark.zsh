source rtlv_prompt.zsh
test_static() {
	for ((ii = 0; ii < 256; ii++)); do
		set_static
	done
}
test_hook() {
	for ((ii = 0; ii < 65536; ii++)); do
		rtlv_prompt_precmd
	done
}
echo "set_static * 256"
time (test_static)
echo "(precmd) * 65536"
time (test_hook)
