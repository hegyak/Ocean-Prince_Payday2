function isHost()
	if not Network then return false end
	return not Network:is_client()
end
local green = 	Color( 200, 000, 255, 000 )	/255
local red 	= 	Color( 200, 255, 000, 000 )	/255
_toggleOverdrill = not _toggleOverdrill
if _toggleOverdrill then
	if managers.job:current_level_id() == "red2" and managers.groupai:state():whisper_mode() and isHost() then
		managers.chat:_receive_message(1, "Overdrill Activator", "Can not be activated during stealth!", Color.yellow)
	elseif managers.job:current_level_id() == "red2" and not managers.groupai:state():whisper_mode() and Global.game_settings.difficulty == "overkill_290" and isHost() then
		for _, script in pairs(managers.mission:scripts()) do
			for id, element in pairs(script:elements()) do
				for _, trigger in pairs(element:values().trigger_list or {}) do
					if trigger.notify_unit_sequence == "light_on" then
						element:on_executed()
						managers.chat:_receive_message(1, "Overdrill Activator", "Overdrill activated.", tweak_data.system_chat_color)
						RefreshTest()
					end
				end
			end
		end
	elseif managers.job:current_level_id() == "red2" and not managers.groupai:state():whisper_mode() and Global.game_settings.difficulty == "sm_wish" and isHost() then
		for _, script in pairs(managers.mission:scripts()) do
			for id, element in pairs(script:elements()) do
				for _, trigger in pairs(element:values().trigger_list or {}) do
					if trigger.notify_unit_sequence == "light_on" then
						element:on_executed()
						managers.chat:_receive_message(1, "Overdrill Activator", "Overdrill activated.", tweak_data.system_chat_color)
						RefreshTest()
					end
				end
			end
		end
	else
		managers.chat:_receive_message(1, "Overdrill Activator", "Play Deathwish or above", Color.red)
	end
else
	managers.chat:_receive_message(1, "Overdrill Activator", "Manual activation disabled", Color.red)
	RefreshTest()
end    