function MenuManager:show_warning_nojammod()
	local dialog_data = {}
	dialog_data.title = "/// ATTENTION ///"
	dialog_data.text = " You're activating 'Drills Unable To Jam' MOD. \n No public lobby allowed."
	local ok_button = {}
	ok_button.text = managers.localization:text("dialog_ok")
	dialog_data.button_list = {ok_button}
	managers.system_menu:show(dialog_data)
end