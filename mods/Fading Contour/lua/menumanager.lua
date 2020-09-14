local key = ModPath .. '	' .. RequiredScript
if _G[key] then return else _G[key] = true end

_G.FadingContour = _G.FadingContour or {}
FadingContour._path = ModPath
FadingContour._data_path = SavePath .. 'fading_contour.txt'
FadingContour.FadeModifier = FadingContour.FadeSquareRoot
FadingContour.sync_contour = 'medic_heal'
FadingContour.settings = {
	fade_from = 1,
	fade_method = 2
}

-- fade_level: float from 0 to 1
local sync_history = {}
function FadingContour.SynchronizeFadeLevel(unit, fade_level, forced)
	fade_level = math.ceil(fade_level * 8)

	local u_key = unit:key()
	if not forced and fade_level == sync_history[u_key] then
		return
	end
	sync_history[u_key] = fade_level

	local session = managers.network:session()
	if session then
		session:send_to_peers_synched('sync_contour_state', unit, unit:id(), FadingContour.sync_contour_index, false, fade_level)
	end
end

function FadingContour:FadeLinear(dt_end, dt_now, duration)
	return (dt_end - dt_now) / (duration * self.settings.fade_from)
end

function FadingContour:FadeSquareRoot(dt_end, dt_now, duration)
	return math.sqrt(self:FadeLinear(dt_end, dt_now, duration))
end

function FadingContour:SetModifier()
	if self.settings.fade_method == 1 then
		self.FadeModifier = self.FadeLinear
	else
		self.FadeModifier = self.FadeSquareRoot
	end
end

function FadingContour:Load()
	local file = io.open(self._data_path, 'r')
	if file then
		for k, v in pairs(json.decode(file:read('*all'))) do
			self.settings[k] = v
		end
		file:close()
	end
	self:SetModifier()
end

function FadingContour:Save()
	local file = io.open(self._data_path, 'w+')
	if file then
		file:write(json.encode(self.settings))
		file:close()
	end
end

function FadingContour:SetScene()
	if Application:file_streamer_workload() ~= 0 then
		DelayedCalls:Add('DelayedModFC_postponedsetscene', 1, function()
			FadingContour:SetScene()
		end)
		return
	end

	if managers.network:session() then
		return
	end

	if not CopBase then
		require('lib/units/enemies/cop/CopBase')
	end
	if not ContourExt or not ContourExt.add then
		require('lib/units/ContourExt')
	end

	if not managers.occlusion then
		self.dummy_occlusion_manager = true
		managers.occlusion = {
			add_occlusion = function() end,
			remove_occlusion = function() end
		}
	end

	local unit = World:spawn_unit(
		Idstring('units/payday2/characters/ene_fbi_2/ene_fbi_2'),
		Vector3(105, 200, -125),
		Rotation(130, 0, 0)
	)
	if alive(unit) then
		unit:interaction().refresh_material = function() end
		unit:play_redirect(Idstring('e_so_ntl_bored'), 0)
		self.dummy_cop = unit
	end
end

function FadingContour:ClearScene()
	DelayedCalls:Remove('DelayedModFC_postponedsetscene')

	if self.dummy_occlusion_manager then
		managers.occlusion = nil
		self.dummy_occlusion_manager = nil
	end

	if alive(self.dummy_cop) then
		World:delete_unit(self.dummy_cop)
		self.dummy_cop = nil
	end
end

Hooks:Add('LocalizationManagerPostInit', 'LocalizationManagerPostInit_FadingContour', function(loc)
	local language_filename

	local modname_to_language = {
		['PAYDAY 2 THAI LANGUAGE Mod'] = 'thai.txt',
	}
	for _, mod in pairs(BLT and BLT.Mods:Mods() or {}) do
		language_filename = mod:IsEnabled() and modname_to_language[mod:GetName()]
		if language_filename then
			break
		end
	end

	if not language_filename then
		for _, filename in pairs(file.GetFiles(FadingContour._path .. 'loc/')) do
			local str = filename:match('^(.*).txt$')
			if str and Idstring(str) and Idstring(str):key() == SystemInfo:language():key() then
				language_filename = filename
				break
			end
		end
	end

	if language_filename then
		loc:load_localization_file(FadingContour._path .. 'loc/' .. language_filename)
	end
	loc:load_localization_file(FadingContour._path .. 'loc/english.txt', false)
end)

Hooks:Add('MenuManagerInitialize', 'MenuManagerInitialize_FadingContour', function(menu_manager)
	MenuCallbackHandler.FadingContourFadeMethod = function(this, item)
		FadingContour.settings.fade_method = tonumber(item:value())
		FadingContour:SetModifier()
	end

	MenuCallbackHandler.FadingContourFadeFrom = function(self, item)
		FadingContour.settings.fade_from = item:value()
	end

	MenuCallbackHandler.FadingContourTestContour = function(self, item)
		if alive(FadingContour.dummy_cop) then
			FadingContour.dummy_cop:contour():add('mark_enemy')
		end
	end

	MenuCallbackHandler.FadingContourChangedFocus = function(node, focus)
		if focus then
			FadingContour:SetScene()
		else
			FadingContour:ClearScene()
			FadingContour:Save()
		end
	end

	FadingContour:Load()
	MenuHelper:LoadFromJsonFile(FadingContour._path .. 'menu/options.txt', FadingContour, FadingContour.settings)
end)
