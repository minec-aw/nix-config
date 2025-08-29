ble-face auto_complete='fg=gray'
ble-face syntax_command='fg=green'
ble-face argument_error='fg=red'
ble-face syntax_comment='fg=gray'
ble-face syntax_delimiter='fg=green'
ble-face command_builtin='fg=green'
ble-face syntax_error='fg=brred'
ble-face syntax_escape='fg=brcyan'
ble-face syntax_expr='fg=brcyan'
ble-face command_function='fg=teal,bold'
ble-face syntax_param_expansion='fg=cyan'
ble-face syntax_quoted='fg=yellow'
ble-face syntax_brace='fg=cyan,bold'
ble-face syntax_default='none'
ble-face filename_directory='fg=green,underline'

ble-face region_match='fg=white,bg=brblack'
ble-face region='fg=white,bold,bg=brblack'
ble-face region_insert='bold'

ble-face prompt_status_line='fg=brgreen,bg=240'

ble-face overwrite_mode='fg=brwhite,bg=cyan'
ble-face region_target='reverse'

ble-face vbell='reverse'

if [[ $- == *i* ]]; then
	LIGHT_BLUE='\[\e[94m\]'
	PURPLE='\[\e[35m\]'
	YELLOW='\[\e[33m\]'
	NORMAL='\[\e[0m\]'

	# Function to build the prompt
	build_prompt() {
		local shell_prefix=""
		if [[ -n "$IN_NIX_SHELL" ]]; then
			shell_prefix="${LIGHT_BLUE}(nix-shell)${NORMAL} "
		fi

		PS1="${shell_prefix}${PURPLE}\h ${YELLOW}\w${NORMAL} > "
	}

	# Run on every prompt
	PROMPT_COMMAND=build_prompt
fi