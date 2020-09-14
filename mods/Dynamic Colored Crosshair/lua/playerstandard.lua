Hooks:PostHook( PlayerStandard , "update" , "DynamicColoredCrosshairPostPlayerStandardUpdate" , function( self , t , dt )

	if self._camera_unit:base()._melee_item_units and not self._crosshair_melee then
		self._crosshair_melee = true
		managers.hud:set_crosshair_visible( true )
		managers.hud:set_crosshair_offset( 0 )
	elseif not self._camera_unit:base()._melee_item_units and self._crosshair_melee then
		self._crosshair_melee = nil
		self:_update_crosshair_offset( t )
	end
	if self._fwd_ray and self._fwd_ray.unit then

		local unit = self._fwd_ray.unit

		local function is_teammate( unit )
			for _ , u_data in pairs( managers.groupai:state():all_criminals() ) do
				if u_data.unit == unit then return true end
			end
		end

		if managers.enemy:is_civilian( unit ) then

			DCC:set_crosshair_colors("scanner", Color( 194 / 255 , 252 / 255 , 151 / 255 ) )
		elseif managers.enemy:is_enemy( unit ) then

			DCC:set_crosshair_colors("scanner", Color( 1 , 1 , 0.2 , 0 ) )
		elseif is_teammate( unit ) then

			DCC:set_crosshair_colors("scanner", Color( 0.2 , 0.8 , 1 ) )
		else

			DCC:set_crosshair_colors("scanner", Color.white )
		end

	else

		DCC:set_crosshair_colors("scanner", Color.white )

	end
end )

function PlayerStandard:_update_crosshair_offset( t )

	if not alive( self._equipped_unit ) then
		return
	end

	if self._camera_unit:base()._melee_item_units and self._crosshair_melee then
		managers.hud:set_crosshair_offset( 0 )
		return
	end

	local name_id = self._equipped_unit:base():get_name_id()
	tweak_data.weapon[ name_id ].crosshair = deep_clone( tweak_data.weapon.glock_17.crosshair )
	--return
	managers.hud:set_crosshair_part_visible("top",true)
	managers.hud:set_crosshair_part_visible("bottom",true)
	managers.hud:set_crosshair_part_visible("left",true)
	managers.hud:set_crosshair_part_visible("right",true)
	if self._state_data.in_steelsight then
		if DCC._data.tg_adscross_lmg_only then
			local no_sight_weapons = {"mg42", "x_1911", "x_b92fs", "x_deagle", "saw", "hk21", "m249", "rpk", "m134", "x_g17", "x_usp", "flamethrower_mk2", "par", "x_sr2", "x_mp5", "x_akmsu", "arblast", "frankish", "long", "plainsrider"}
			local weaponname="ERR_NULLNAME"
			local current_state = managers.player:get_current_state()
			if current_state then
				local equipped_unit = current_state._equipped_unit
				if equipped_unit then
					weaponname=equipped_unit:base():weapon_tweak_data().name_id
				end
			end
			local has_sight=true
			for i,v in pairs(no_sight_weapons) do
				if weaponname=="bm_w_"..v then has_sight=false end
			end
			if has_sight then
				managers.hud:set_crosshair_part_visible("left",false)
				managers.hud:set_crosshair_part_visible("right",false)
				managers.hud:set_crosshair_part_visible("top",false)
				managers.hud:set_crosshair_part_visible("bottom",false)
			end
		end
		if DCC._data.mode_ironsights_str=="off" then
			managers.hud:set_crosshair_part_visible("left",false)
			managers.hud:set_crosshair_part_visible("right",false)
			managers.hud:set_crosshair_part_visible("top",false)
			managers.hud:set_crosshair_part_visible("bottom",false)
		elseif DCC._data.mode_ironsights_str=="classic" then
			managers.hud:set_crosshair_part_visible("top",false)
			managers.hud:set_crosshair_part_visible("bottom",false)
		elseif DCC._data.mode_ironsights_str=="leftonly" then
			managers.hud:set_crosshair_part_visible("right",false)
			managers.hud:set_crosshair_part_visible("top",false)
			managers.hud:set_crosshair_part_visible("bottom",false)
		elseif DCC._data.mode_ironsights_str=="rightonly" then
			managers.hud:set_crosshair_part_visible("left",false)
			managers.hud:set_crosshair_part_visible("top",false)
			managers.hud:set_crosshair_part_visible("bottom",false)
		elseif DCC._data.mode_ironsights_str=="toponly" then
			managers.hud:set_crosshair_part_visible("left",false)
			managers.hud:set_crosshair_part_visible("right",false)
			managers.hud:set_crosshair_part_visible("bottom",false)
		elseif DCC._data.mode_ironsights_str=="bottomonly" then
			managers.hud:set_crosshair_part_visible("left",false)
			managers.hud:set_crosshair_part_visible("right",false)
			managers.hud:set_crosshair_part_visible("top",false)
		elseif DCC._data.mode_ironsights_str=="full" then
			--nothing because everything visible
		end


		managers.hud:set_crosshair_offset( tweak_data.weapon[ name_id ].crosshair.steelsight.offset )
		return
	end

	local spread_multiplier = self._equipped_unit:base():spread_multiplier()
	managers.hud:set_crosshair_visible( not tweak_data.weapon[ name_id ].crosshair[ self._state_data.ducking and "crouching" or "standing" ].hidden )

	if self._moving then
		managers.hud:set_crosshair_offset( tweak_data.weapon[ name_id ].crosshair[ self._state_data.ducking and "crouching" or "standing" ].moving_offset * spread_multiplier )
		return
	else
		managers.hud:set_crosshair_offset( tweak_data.weapon[ name_id ].crosshair[ self._state_data.ducking and "crouching" or "standing" ].offset * spread_multiplier )
	end

end
