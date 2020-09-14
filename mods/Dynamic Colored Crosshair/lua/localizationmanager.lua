local _modpath = ModPath
Hooks:Add("LocalizationManagerPostInit", "DCC_Localization", function(loc)
	if Idstring("german"):key() == SystemInfo:language():key() then
		LocalizationManager:load_localization_file(_modpath.."/loc/de.txt")
	else
		LocalizationManager:load_localization_file(_modpath.."/loc/en.txt")
	end
end)