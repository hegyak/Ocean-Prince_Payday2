Hooks:PostHook( HUDManager , "_player_hud_layout" , "DCCPostHUDManagerPlayerInfoHUDLayout" , function( self )
	DCC.c_cross.offsetscale=(DCC._data.sl_cl/48)
	self._crosshair_main = managers.hud:script(PlayerBase.PLAYER_INFO_HUD_PD2).panel:panel({
		name 	= "crosshair_main",
		halign 	= "grow",
		valign 	= "grow"
	})

	local crosshair_panel = self._crosshair_main:panel({
		name = "crosshair_panel"
	})

	local crosshair_part_right = crosshair_panel:bitmap({
		name 			= "crosshair_part_right",
		texture 		= "guis/textures/hud_icons",
		texture_rect 	= {
							481,
							33,
							24,
							4
						},
		layer 			= 2,
		rotation 		= 0,
		valign 			= "center",
		halign 			= "center",
		w 				= DCC._data.sl_cl,
		h 				= DCC._data.sl_cw
	})

	local crosshair_part_bottom = crosshair_panel:bitmap({
		name 			= "crosshair_part_bottom",
		texture 		= "guis/textures/hud_icons",
		texture_rect 	= {
							481,
							33,
							24,
							4
						},
		layer 			= 2,
		rotation 		= 90,
		valign 			= "center",
		halign 			= "center",
		w = DCC._data.sl_cl,
		h = DCC._data.sl_cw
	})

	local crosshair_part_left = crosshair_panel:bitmap({
		name 			= "crosshair_part_left",
		texture 		= "guis/textures/hud_icons",
		texture_rect 	= {
							481,
							33,
							24,
							4
						},
		layer 			= 2,
		rotation 		= 180,
		valign 			= "center",
		halign 			= "center",
		w = DCC._data.sl_cl,
		h = DCC._data.sl_cw
	})

	local crosshair_part_top = crosshair_panel:bitmap({
		name 			= "crosshair_part_top",
		texture 		= "guis/textures/hud_icons",
		texture_rect 	= {
							481,
							33,
							24,
							4
						},
		rotation 		= 270,
		valign 			= "center",
		halign 			= "center",
		w = DCC._data.sl_cl,
		h = DCC._data.sl_cw
	})

	crosshair_panel:set_center( managers.hud:script(PlayerBase.PLAYER_INFO_HUD_PD2).panel:center() )

	self:set_crosshair_offset( 0 )
	self._ch_current_offset = self._ch_offset
	self:_layout_crosshair()

end )

Hooks:PostHook( HUDManager , "init" , "DCCPostHUDManagerInit" , function(self)
	if self._teammate_panels then
		for i,v in pairs(self._teammate_panels) do
			if not v.update then
				function v:update() return nil end
			end
		end
	end
end)

function HUDManager:set_crosshair_color( color )

	if not self._crosshair_main then return end

	self._crosshair_parts = self._crosshair_parts or {
		self._crosshair_main:child( "crosshair_panel" ):child( "crosshair_part_left" ),
		self._crosshair_main:child( "crosshair_panel" ):child( "crosshair_part_top" ),
		self._crosshair_main:child( "crosshair_panel" ):child( "crosshair_part_right" ),
		self._crosshair_main:child( "crosshair_panel" ):child( "crosshair_part_bottom" )
	}

	for _ , part in ipairs( self._crosshair_parts ) do
		part:set_color( color )
	end

end
function HUDManager:set_crosshair_part_color(part, color)
	if not self._crosshair_main then return end
	if part == "left" or part == "right" or part == "top" or part == "bottom" then
		self._crosshair_main:child( "crosshair_panel" ):child("crosshair_part_"..part):set_color(color)
	end
end

function HUDManager:show_crosshair_panel( visible )
	if not self._crosshair_main then return end
  if DCC and DCC._data.tg_crosshair_visible then
		self._crosshair_main:set_visible( visible )
	else
		self._crosshair_main:set_visible(false)
	end
end

function HUDManager:set_crosshair_offset( offset )

	self._ch_offset = math.lerp( ((tweak_data.weapon.crosshair.MIN_OFFSET+10)/2)+(tweak_data.weapon.crosshair.MIN_OFFSET+10)*(DCC.c_cross.offsetscale or 1) , tweak_data.weapon.crosshair.MAX_OFFSET , offset * DCC._data.sl_dynamic )

end

function HUDManager:set_crosshair_visible( visible )

	if not self._crosshair_main then return end

	self._crosshair_main:child( "crosshair_panel" ):set_visible( visible )

end

function HUDManager:set_crosshair_part_visible(part, visible )

	if not self._crosshair_main then return end

	if part == "left" or part == "right" or part == "top" or part == "bottom" then
		self._crosshair_main:child( "crosshair_panel" ):child("crosshair_part_"..part):set_visible( visible )
	end
end

function HUDManager:_update_crosshair_offset( t, dt )

	if self._ch_current_offset and self._ch_current_offset > self._ch_offset then
		self:_kick_crosshair_offset( -dt * 3 )
		if self._ch_current_offset < self._ch_offset then
			self._ch_current_offset = self._ch_offset
			self:_layout_crosshair()
		end

	elseif self._ch_current_offset and self._ch_current_offset < self._ch_offset then
		self:_kick_crosshair_offset( dt * 3 )
		if self._ch_current_offset > self._ch_offset then
			self._ch_current_offset = self._ch_offset
			self:_layout_crosshair()
		end

	end

end

function HUDManager:_kick_crosshair_offset( offset )

	self._ch_current_offset = self._ch_current_offset or 0
	if self._ch_current_offset > tweak_data.weapon.crosshair.MAX_OFFSET then
		self._ch_current_offset = tweak_data.weapon.crosshair.MAX_OFFSET
	end

	self._ch_current_offset = self._ch_current_offset + math.lerp( tweak_data.weapon.crosshair.MIN_KICK_OFFSET , tweak_data.weapon.crosshair.MAX_KICK_OFFSET , offset )
	self:_layout_crosshair()

end

function HUDManager:_layout_crosshair()

	if not self._crosshair_main then return end

	local hud = self._crosshair_main
	local x = self._crosshair_main:child( "crosshair_panel" ):center_x() - self._crosshair_main:child( "crosshair_panel" ):left()
	local y = self._crosshair_main:child( "crosshair_panel" ):center_y() - self._crosshair_main:child( "crosshair_panel" ):top()

	self._crosshair_parts = self._crosshair_parts or {
		self._crosshair_main:child( "crosshair_panel" ):child( "crosshair_part_left" ),
		self._crosshair_main:child( "crosshair_panel" ):child( "crosshair_part_top" ),
		self._crosshair_main:child( "crosshair_panel" ):child( "crosshair_part_right" ),
		self._crosshair_main:child( "crosshair_panel" ):child( "crosshair_part_bottom" )
	}

	for _ , part in ipairs( self._crosshair_parts ) do
		local rotation = part:rotation()
		part:set_center_x( x + math.cos( rotation ) * self._ch_current_offset * tweak_data.scale.hud_crosshair_offset_multiplier )
		part:set_center_y( y + math.sin( rotation ) * self._ch_current_offset * tweak_data.scale.hud_crosshair_offset_multiplier )
	end

end
CloneClass(HUDManager)
--[[function HUDManager:_create_teammates_panel(hud)
	hud = hud or managers.hud:script(PlayerBase.PLAYER_INFO_HUD_PD2)
	self._hud.teammate_panels_data = self._hud.teammate_panels_data or {}
	self._teammate_panels = {}
	if hud.panel:child("teammates_panel") then
		hud.panel:remove(hud.panel:child("teammates_panel"))
	end
	local h = self:teampanels_height()
	local teammates_panel = hud.panel:panel({
		name = "teammates_panel",
		h = h,
		y = hud.panel:h() - h,
		halign = "grow",
		valign = "bottom"
	})

	for i = 1, HUDManager.PLAYER_PANEL do
		local is_player = i == HUDManager.PLAYER_PANEL

		local teammate_w = is_player and 204 or 512
		self._hud.teammate_panels_data[i] = {
			taken = false,
			special_equipments = {}
		}
		local pw = teammate_w + (is_player and 128 or 64)
		local teammate = HUDTeammate:new(i, teammates_panel, is_player, pw)
		if is_player then
			teammate._panel:set_right(hud.panel:right())
		else
			local y = math.floor( 24 * (i - 1) + 14 )
			teammate._panel:set_y(y)
		end
		table.insert(self._teammate_panels, teammate)
		if is_player then
			teammate:add_panel()
		end
	end
end]]


--SECRET SPICY MAYMAYS BELOW
local Net = _G.LuaNetworking
local function isInGame()
	if not game_state_machine then
		return false
	end
	return string.find( game_state_machine:current_state_name(), "ingame" )
end
Hooks:Add("NetworkReceivedData", "NetworkReceivedData_DCC", function(sender, id, data)
    if id == "DCC_GET_USES_MOD" then
	Net:SendToPeers("DCC_USES_MOD", "DCC_RX_OFFICIAL")
    end
end)
