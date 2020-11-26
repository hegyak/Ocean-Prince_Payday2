local origfunc = AchievementDetailGui.init
function AchievementDetailGui:init(parent, achievement_data_or_id, back_callback)
	local passondata = {}
	
	if type(achievement_data_or_id) == "table" then
		achievement_data_or_id = achievement_data_or_id.id
	end
	
	local detailed_desc = '\n\nID: '
	
------------------------------------
	local TableToString
	TableToString = function(tbl, recursive)
		recursive = recursive or 0
		if recursive > 10 then return '' end
		
		local str = recursive > 0 and '\n' or ''
		for k,v in pairs(tbl) do
			local vt = type(v)
			local v_str = vt == 'table' and TableToString(v, recursive + 1) or v
			v_str = vt == 'boolean' and (v and 'true' or 'false') or v_str
			v_str = vt == 'function' and k..'()' or v_str
			v_str = vt == 'string' and v or v_str
			
			--if type(v_str) == 'string' then
				if recursive > 0 then
					local i
					local tabs = ''
					for i = 1, recursive do
						tabs = tabs..'    '
					end
					str = str..tabs..k..' = '..v_str..'\n'
				else
					str = str..k..' = '..v_str..'\n'
				end
			--end
		end
		return str
	end
----------------------------------
	
	local found = false
	for k,v in pairs(tweak_data.achievement) do
		if type(v) == 'table'
			and k ~= 'visual'
		then
			if v[achievement_data_or_id] then
				detailed_desc = detailed_desc..achievement_data_or_id..'\n'
				detailed_desc = detailed_desc..'['..k..']\n'..TableToString(v[achievement_data_or_id])
				found = true
			elseif v.award and v.award == achievement_data_or_id then
				detailed_desc = detailed_desc..k..'\n'
				detailed_desc = detailed_desc..'['..k..']\n'..TableToString(v)
				found = true
			else
				for k2,v2 in pairs(v) do
					if type(v2) == 'table' and v2.award and v2.award == achievement_data_or_id then
						detailed_desc = detailed_desc..k2..'\n'
						detailed_desc = detailed_desc..'['..k..']\n'..TableToString(v2)
						found = true
					end
				end
			end
		end
	end
	
	if not found then
		detailed_desc = detailed_desc..achievement_data_or_id..'\n'
	end
	
	LocalizationManager:add_localized_strings({
		menu_achievements_detailedstr = detailed_desc,
		menu_achievements_detailedstr_mask = ''
	})

	local visdata = tweak_data.achievement.visual[achievement_data_or_id]
	passondata.id = achievement_data_or_id

	if not visdata.detailed_achievements_tag_added then
		table.insert(visdata.tags, #visdata.tags+1, 'detailedstr_mask')
		visdata.detailed_achievements_tag_added = true
	end
	passondata.visual = visdata
	
	return origfunc(self, parent, passondata, back_callback)
end