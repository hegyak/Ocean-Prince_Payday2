_G.DCC = _G.DCC or {}
DCC._path = ModPath
DCC._data_path = ModPath .. "save/dcc_options.txt"
DCC._data = {}
DCC.c_cross={}
function DCC:ToColor(dcc_color)
	local dcc_colorstring = dcc_color == 1 and "cyan"
	or dcc_color == 2 and "purple"
	or dcc_color == 3 and "red"
	or dcc_color == 4 and "black"
	or dcc_color == 5 and "yellow"
	or dcc_color == 6 and "white"
	or dcc_color == 7 and "blue"
	or dcc_color == 8 and "green"
	or dcc_color == 9  and "orange"
	or dcc_color == 10 and "darkred"
	or dcc_color == 11 and "darkblue"
	or dcc_color == 12 and "darkgreen"
	or dcc_color == 13 and "grey"
	if dcc_colorstring=="darkred" then
		return Color(0.5,0,0)
	elseif dcc_colorstring=="orange" then
		return Color(1,0.5,0)
	elseif dcc_colorstring=="darkblue" then
		return Color(0,0,0.5)
	elseif dcc_colorstring=="darkgreen" then
		return Color(0,0.5,0)
	elseif dcc_colorstring=="grey" then
		return Color(0.5,0.5,0.5)
	elseif dcc_colorstring then
		return Color[tostring(dcc_colorstring)] or Color.white
	end
end

function DCC:Save()
	local file = io.open( self._data_path, "w" )
	if file then
		file:write( json.encode( self._data ) )
		file:close()
	end
end
function DCC:Load()
	local file = io.open( self._data_path, "r" )
	if file then
		self._data = json.decode( file:read("*all") )
		file:close()
	end
end

Hooks:Add("MenuManagerInitialize", "MenuManagerInitialize_DCC", function(menu_manager)
	MenuCallbackHandler.dcc_save = function(self, item)
		DCC:Save()
	end
	MenuCallbackHandler.callbackdcc_toggle_cvis = function(self, item)
		DCC._data.tg_crosshair_visible = (item:value() == "on" and true or false)
	end
	MenuCallbackHandler.callbackdcc_toggle_colr = function(self, item)
		DCC._data.tg_coloring = (item:value() == "on" and true or false)
	end
	MenuCallbackHandler.callbackdcc_item_top = function(self, item)
		local _translates={"none", "current clip", "offhand clip", "total ammo", "armor", "health", "scanner"}
		DCC._data.item_top_str=_translates[item:value()]
		DCC._data.item_top=item:value()
	end
	MenuCallbackHandler.callbackdcc_item_left = function(self, item)
		local _translates={"none", "current clip", "offhand clip", "total ammo", "armor", "health", "scanner"}
		DCC._data.item_left_str=_translates[item:value()]
		DCC._data.item_left=item:value()
	end
	MenuCallbackHandler.callbackdcc_item_right = function(self, item)
		local _translates={"none", "current clip", "offhand clip", "total ammo", "armor", "health", "scanner"}
		DCC._data.item_right_str=_translates[item:value()]
		DCC._data.item_right=item:value()
	end
	MenuCallbackHandler.callbackdcc_item_bottom = function(self, item)
		local _translates={"none", "current clip", "offhand clip", "total ammo", "armor", "health", "scanner"}
		DCC._data.item_bottom_str=_translates[item:value()]
		DCC._data.item_bottom=item:value()
	end
	MenuCallbackHandler.callbackdcc_mode_irns = function(self, item)
		local _translates={"off","classic","toponly","rightonly","leftonly","bottomonly","full"}
		DCC._data.mode_ironsights_str = _translates[item:value()]
		DCC._data.mode_ironsights=item:value()
	end
	MenuCallbackHandler.callbackdcc_toggle_iclo = function(self, item)
		DCC._data.tg_adscross_lmg_only = (item:value() == "on" and true or false)
	end
	MenuCallbackHandler.callbackdcc_value_sldn = function(self, item)
		DCC._data.sl_dynamic = item:value() or 0.5
	end
	MenuCallbackHandler.callbackdcc_color_hf = function(self, item)
		DCC._data.color_health_full = item:value() or "white"
	end
	MenuCallbackHandler.callbackdcc_color_he = function(self, item)
		DCC._data.color_health_empty = item:value() or "white"
	end
	MenuCallbackHandler.callbackdcc_color_af = function(self, item)
		DCC._data.color_armor_full = item:value() or "white"
	end
	MenuCallbackHandler.callbackdcc_color_ae = function(self, item)
		DCC._data.color_armor_empty = item:value() or "white"
	end
	MenuCallbackHandler.callbackdcc_color_mf = function(self, item)
		DCC._data.color_ammo_full = item:value() or "white"
	end
	MenuCallbackHandler.callbackdcc_color_me = function(self, item)
		DCC._data.color_ammo_empty = item:value() or "white"
	end
	MenuCallbackHandler.callbackdcc_color_mh = function(self, item)
		DCC._data.color_ammo_half = item:value() or "white"
	end
	MenuCallbackHandler.callbackdcc_color_mr = function(self, item)
		DCC._data.color_ammo_reload = item:value() or "white"
	end
	MenuCallbackHandler.callbackdcc_value_sl_l = function(self, item)
		DCC._data.sl_cl = item:value() or 23
	end
	MenuCallbackHandler.callbackdcc_value_sl_w = function(self, item)
		DCC._data.sl_cw = item:value() or 4
	end
	DCC:Load()
	MenuHelper:LoadFromJsonFile(DCC._path .. "menu/options.txt", DCC, DCC._data)
end )

function DCC:set_crosshair_colors(itemtype, color)
	if not managers.hud then return end
	if not managers.hud._crosshair_main then return end
	for i,v in pairs(DCC._data) do
		if string.find(i,"item_") then
			if itemtype==v then
				managers.hud:set_crosshair_part_color(string.sub(i,6,i:find("_str")-1), color)
			end
		end
	end
end
