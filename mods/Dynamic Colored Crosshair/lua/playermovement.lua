Hooks:PostHook( PlayerMovement , "change_state" , "DynamicColoredCrosshairPostPlayerMovementChangeState" , function( self , name )

	if not self._current_state_name then return end

	if self._current_state_name == "standard" or self._current_state_name == "bleed_out" or self._current_state_name == "tased" or self._current_state_name == "carry" or self._current_state_name == "bipod" then
		if DCC and DCC._data.tg_coloring==false then
			managers.hud:set_crosshair_color(Color.white)
		end
		managers.hud:show_crosshair_panel( true )
	else
		managers.hud:show_crosshair_panel( false )
	end
end )
