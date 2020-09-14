Hooks:Add("LocalizationManagerPostInit", "ShowSecretAchievementLang", function()
	LocalizationManager:add_localized_strings({
		menu_achievements_progress_payday_secret = "The Payday Secret"
	})
end)