Hooks:PreHook( AchievementListItem, "init", "ShowSecretAchievement", function( self, parent, data, owner )
	if Global and Global.custom_safehouse_manager and Global.custom_safehouse_manager.uno_achievements_challenge and Global.custom_safehouse_manager.uno_achievements_challenge.challenge then
		if table.contains( Global.custom_safehouse_manager.uno_achievements_challenge.challenge, data.key ) then
			self.ND_COLOR = Color.yellow
			self.NT_SD_COLOR = Color.yellow
			self.ST_COLOR = Color.yellow

			if data.data and data.data.tags then
				table.insert( data.data.tags, "progress_payday_secret" )
			end
		end
	end
end)