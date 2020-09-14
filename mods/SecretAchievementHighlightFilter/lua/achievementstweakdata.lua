Hooks:PostHook( AchievementsTweakData, "_init_visual", "ShowSecretAchievementTags", function( self, tweak_data )
	table.insert( self.tags.progress, "progress_payday_secret" )
end)