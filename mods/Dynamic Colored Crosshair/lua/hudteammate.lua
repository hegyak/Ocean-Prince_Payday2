log("Setting up DCC")
DelayedCalls:Add("DCCInitDelay", 1, function()
CloneClass(HUDTeammate)
DCC.c_cross.max_pri_clip=1
DCC.c_cross.max_sec_clip=1
DCC.c_cross.cur_pri_clip=1
DCC.c_cross.cur_sec_clip=1
DCC.c_cross.cur_pri_ttl=1
DCC.c_cross.cur_sec_ttl=1
DCC.c_cross.max_pri_ttl=1
DCC.c_cross.max_sec_ttl=1
DCC.c_cross.drawcount=0
DCC.c_cross.is_primary=false

	local hudtm_object=HUDTeammate
	local str_set_weapon_selected="_set_weapon_selected"
	local str_main_player="_main_player"
	local str_type_primary="primary"
	local str_type_secondary="secondary"

	if _G.WolfHUD and WolfHUD:getSetting("use_customhud", "boolean") then
		if not HUDTeammateCustom then
			log("ERROR HUDTeammateCustom is nil")
		end
		hudtm_object=HUDTeammateCustom
		log("[DCC] Using WolfHUD")
		str_main_player="_is_player"
		str_set_weapon_selected="set_weapon_selected"
	elseif MUIMenu and MUIMenu:ClassEnabled("MUITeammate") then
		if not MUITeammate then
			log("ERROR MUITeammate is nil")
		end
		hudtm_object=MUITeammate
		log("[DCC] Using MUI")
		str_set_weapon_selected="set_weapon_selected"
		str_type_primary="2"
		str_type_secondary="1"
	else
		log("[DCC] Using Stock HUD")
	end

Hooks:PostHook(hudtm_object, "set_ammo_amount_by_type", "PostHUDTeammateDCCsetAmmoAmountByType", function(self,type, max_clip, current_clip, current_left, max)
	if not managers.hud then log("[DCC] ERROR: managers.hud has not been initialized yet - set_ammo_amount_by_type") return end
	type=tostring(type) -- fuck you MUI and your weird numeric weapon types

	if self[str_main_player] then
		if type == str_type_primary then
			DCC.c_cross.cur_pri_clip=current_clip
			DCC.c_cross.max_pri_clip=max_clip
			DCC.c_cross.cur_pri_ttl=current_left
			if max then
				DCC.c_cross.max_pri_ttl=max
			elseif (current_left>DCC.c_cross.max_pri_ttl) then
				DCC.c_cross.max_pri_ttl=current_left
			end
		elseif type == str_type_secondary then
			DCC.c_cross.cur_sec_clip=current_clip
			DCC.c_cross.max_sec_clip=max_clip
			DCC.c_cross.cur_sec_ttl=current_left
			if max then
				DCC.c_cross.max_sec_ttl=max
			elseif (current_left>DCC.c_cross.max_sec_ttl) then
				DCC.c_cross.max_sec_ttl=current_left
			end
		end
		if type==str_type_primary and DCC.c_cross.is_primary==false then DCC.c_cross.drawcount=DCC.c_cross.drawcount+1 return end
		if type==str_type_secondary and DCC.c_cross.is_primary==true then DCC.c_cross.drawcount=DCC.c_cross.drawcount+1 return end
		if not current_clip then log("FATAL ERROR current_clip is "..tostring(weapon_panel)..", called with type="..tostring(type).."_panel") return end
		if managers.hud and DCC._data.tg_crosshair_visible and DCC.c_cross.drawcount>1 and DCC._data.tg_coloring then
			local Value = current_clip / max_clip
			if current_clip == 0 then
				DCC:set_crosshair_colors("current clip",DCC:ToColor(DCC._data.color_ammo_reload))
			elseif Value > 0.66 then
				DCC:set_crosshair_colors("current clip",DCC:ToColor(DCC._data.color_ammo_full))
			elseif Value > 0.33 then
				DCC:set_crosshair_colors("current clip",DCC:ToColor(DCC._data.color_ammo_half))
			elseif Value < 0.331 then
				DCC:set_crosshair_colors("current clip",DCC:ToColor(DCC._data.color_ammo_empty))
			end
		elseif not DCC._data.tg_coloring then
			managers.hud:set_crosshair_color(Color.white)
		end
		if managers.hud and DCC._data.tg_crosshair_visible and DCC.c_cross.drawcount>1 and DCC._data.tg_coloring then
			local current_clip = current_left
			local dccmaxttl
			if type == str_type_primary then
				dccmaxttl = DCC.c_cross.max_pri_ttl or 999
			elseif type == str_type_secondary then
				dccmaxttl = DCC.c_cross.max_sec_ttl or 999
			end
			local max_clip = max or dccmaxttl
			local Value = current_clip / max_clip
			if current_clip == 0  then -- <- remove this for default
				DCC:set_crosshair_colors("total ammo",DCC:ToColor(DCC._data.color_ammo_reload))
			elseif Value > 0.66  then
				DCC:set_crosshair_colors("total ammo",DCC:ToColor(DCC._data.color_ammo_full))
			elseif Value > 0.33  then
				DCC:set_crosshair_colors("total ammo",DCC:ToColor(DCC._data.color_ammo_half))
			elseif Value < 0.331  then
				DCC:set_crosshair_colors("total ammo",DCC:ToColor(DCC._data.color_ammo_empty))
			end
		end
		if not (DCC.c_cross.drawcount>1) then
			DCC.c_cross.drawcount=DCC.c_cross.drawcount+1
		end
	else
	end
end)

Hooks:PostHook(hudtm_object, str_set_weapon_selected, "PostHUDTeammateDCCsetWeaponSelected", function(self, id, hud_icon)
	if not self[str_main_player] then return end
	if not managers.hud then log("[DCC] ERROR: managers.hud has not been initialized yet - _set_weapon_selected") return end
	local is_secondary = id == 1
	DCC.c_cross.is_primary = not is_secondary
	local current_clip = is_secondary and DCC.c_cross.cur_sec_clip or DCC.c_cross.cur_pri_clip
	local offcurrent_clip = is_secondary and DCC.c_cross.cur_pri_clip or DCC.c_cross.cur_sec_clip
	local totalcurr = is_secondary and DCC.c_cross.cur_sec_ttl or DCC.c_cross.cur_pri_ttl
	if not offcurrent_clip then offcurrent_clip=999 end
	local max_clip=1
	local offmax_clip=1
	local totalmax=1
	if not is_secondary then
		if current_clip > DCC.c_cross.max_pri_clip then
			DCC.c_cross.max_pri_clip=current_clip
			DCC.c_cross.max_sec_clip=offcurrent_clip
		end
		if totalcurr > DCC.c_cross.max_pri_ttl then
			DCC.c_cross.max_pri_ttl=totalcurr
		end
		totalcurr=DCC.c_cross.max_pri_ttl
		max_clip=DCC.c_cross.max_pri_clip
		offmax_clip=DCC.c_cross.max_sec_clip
	elseif is_secondary then
		if current_clip > DCC.c_cross.max_sec_clip then
			DCC.c_cross.max_sec_clip=current_clip
			DCC.c_cross.max_pri_clip=offcurrent_clip
		end
		if totalcurr > DCC.c_cross.max_sec_ttl then
			DCC.c_cross.max_sec_ttl=totalcurr
		end
		totalcurr=DCC.c_cross.max_sec_ttl
		max_clip=DCC.c_cross.max_sec_clip
		offmax_clip=DCC.c_cross.max_pri_clip
	end
	if managers.hud and DCC._data.tg_crosshair_visible and DCC._data.tg_coloring then
		local Value = current_clip / max_clip
		local offValue = offcurrent_clip / offmax_clip
		local totalValue = totalcurr / totalmax
		if current_clip == 0 then
			DCC:set_crosshair_colors("current clip",DCC:ToColor(DCC._data.color_ammo_reload))
		elseif Value > 0.66 then
			DCC:set_crosshair_colors("current clip",DCC:ToColor(DCC._data.color_ammo_full))
		elseif Value > 0.33 then
			DCC:set_crosshair_colors("current clip",DCC:ToColor(DCC._data.color_ammo_half))
		elseif Value < 0.331 then
			DCC:set_crosshair_colors("current clip",DCC:ToColor(DCC._data.color_ammo_empty))
		end
		if offcurrent_clip == 0  then
			DCC:set_crosshair_colors("offhand clip",DCC:ToColor(DCC._data.color_ammo_reload))
		elseif offValue > 0.66  then
			DCC:set_crosshair_colors("offhand clip",DCC:ToColor(DCC._data.color_ammo_full))
		elseif offValue > 0.33  then
			DCC:set_crosshair_colors("offhand clip",DCC:ToColor(DCC._data.color_ammo_half))
		elseif offValue < 0.331  then
			DCC:set_crosshair_colors("offhand clip",DCC:ToColor(DCC._data.color_ammo_empty))
		end
		if totalcurr == 0  then
			DCC:set_crosshair_colors("total ammo",DCC:ToColor(DCC._data.color_ammo_reload))
		elseif totalValue > 0.66  then
			DCC:set_crosshair_colors("total ammo",DCC:ToColor(DCC._data.color_ammo_full))
		elseif totalValue > 0.33  then
			DCC:set_crosshair_colors("total ammo",DCC:ToColor(DCC._data.color_ammo_half))
		elseif totalValue < 0.331  then
			DCC:set_crosshair_colors("total ammo",DCC:ToColor(DCC._data.color_ammo_empty))
		end
	elseif not DCC._data.tg_coloring then
		managers.hud:set_crosshair_color(Color.white)
	end

	DCC.c_cross.drawcount=0
end)

Hooks:PostHook(hudtm_object, "set_health", "PostHUDTeammateDCCsetHealth", function(self, data, ...)
	if not managers.hud then log("[DCC] ERROR: managers.hud has not been initialized yet - set_health") return end
	local Value = data.current / data.total * 100
	if math.floor(Value) > 0 then
		if self[str_main_player] then
			if managers.hud and DCC._data.tg_crosshair_visible and DCC._data.tg_coloring then
				DCC:set_crosshair_colors("health",DCC:ToColor(DCC._data.color_health_full) * (math.round(Value) / 100) + DCC:ToColor(DCC._data.color_health_empty) * (1 - math.round(Value) / 100))
			elseif not DCC._data.tg_coloring then
				managers.hud:set_crosshair_color(Color.white)
			end
		end
	end
end)

Hooks:PostHook(hudtm_object, "set_armor", "PostHUDTeammateDCCsetArmor", function(self, data, ...)
	if not managers.hud then log("[DCC] ERROR: managers.hud has not been initialized yet - set_armor") return end
	local Value = data.current / data.total
	if self[str_main_player] then
		if managers.hud and DCC._data.tg_crosshair_visible and DCC._data.tg_coloring then
			DCC:set_crosshair_colors("armor",DCC:ToColor(DCC._data.color_armor_full) * (math.round(Value * 100) / 100) + DCC:ToColor(DCC._data.color_armor_empty) * (1 - math.round(Value * 100) / 100))
		elseif not DCC._data.tg_coloring then
			managers.hud:set_crosshair_color(Color.white)
		end
 	end
end)
end)
