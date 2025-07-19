if status is-interactive
    # Commands to run in interactive sessions can go here
end
set fish_greeting # Disable greeting
function fish_prompt
	echo (set_color purple)(prompt_hostname) (set_color yellow)(prompt_pwd)(set_color normal)" > "
end
