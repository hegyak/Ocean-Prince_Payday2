
CloneClass( BlackMarketGui )
CloneClass( BlackMarketGuiSlotItem )
CloneClass( BlackMarketGuiButtonItem )

local is_win32 = SystemInfo:platform() == Idstring("WIN32")
local NOT_WIN_32 = not is_win32
local WIDTH_MULTIPLIER = NOT_WIN_32 and 0.68 or 0.71
local BOX_GAP = 13.5
local GRID_H_MUL = (NOT_WIN_32 and 7 or 6.6) / 8
local massive_font = tweak_data.menu.pd2_massive_font
local large_font = tweak_data.menu.pd2_large_font
local medium_font = tweak_data.menu.pd2_medium_font
local small_font = tweak_data.menu.pd2_small_font
local massive_font_size = tweak_data.menu.pd2_massive_font_size
local large_font_size = tweak_data.menu.pd2_large_font_size
local medium_font_size = tweak_data.menu.pd2_medium_font_size
local small_font_size = tweak_data.menu.pd2_small_font_size
local tiny_font_size = tweak_data.menu.pd2_small_font_size * 0.75



Hooks:RegisterHook("BlackMarketGUIPreSetup")
Hooks:RegisterHook("BlackMarketGUIPostSetup")
function BlackMarketGui._setup(self, is_start_page, component_data)
	Hooks:Call("BlackMarketGUIPreSetup", self, is_start_page, component_data)
	self.orig._setup(self, is_start_page, component_data)
	Hooks:Call("BlackMarketGUIPostSetup", self, is_start_page, component_data)
end

function BlackMarketGuiButtonItem.init(self, main_panel, data, x)
	self.orig.init(self, main_panel, data, x)
	self._main_panel = main_panel
	self._initial_x = x
end

function BlackMarketGuiButtonItem:set_order( prio )

	BlackMarketGuiButtonItem._default_w = BlackMarketGuiButtonItem._default_w or self._panel:w()
	BlackMarketGuiButtonItem._highlight_w = BlackMarketGuiButtonItem._highlight_w or self._panel:w() / 2
	BlackMarketGuiButtonItem._padding = BlackMarketGuiButtonItem._padding or 8
	BlackMarketGuiButtonItem._max_btn_height = BlackMarketGuiButtonItem._max_btn_height or 5
	local btn_h = BlackMarketGuiButtonItem._max_btn_height
	local num = BlackMarketGui._instance and BlackMarketGui._instance._button_count or 0
	local overflowed = num and num > btn_h

	if overflowed then

		self:check_overflow_font_size()
		self._panel:set_w( BlackMarketGuiButtonItem._highlight_w )
		self._btn_text:set_font_size( small_font_size )

		if prio > btn_h then
			self._panel:set_y( (prio % btn_h - 1) * small_font_size )
			self._panel:set_left( self._main_panel:left() + BlackMarketGuiButtonItem._padding )
		else
			self._panel:set_y( (prio % btn_h) * small_font_size )
			self._panel:set_right( self._main_panel:right() - BlackMarketGuiButtonItem._padding )
		end

	else
		self._panel:set_w( BlackMarketGuiButtonItem._default_w )
		self._panel:set_y( (prio - 1) * small_font_size )
		self._panel:set_left( self._initial_x or 0 )
		self._btn_text:set_font_size( small_font_size )
	end

	self._btn_text:set_right( self._panel:w() )

end

Hooks:RegisterHook("BlackMarketGUIButtonPreSetTextParameters")
Hooks:RegisterHook("BlackMarketGUIButtonPostSetTextParameters")
function BlackMarketGuiButtonItem.set_text_params(self, params)
	Hooks:Call("BlackMarketGUIButtonPreSetTextParameters", self, params)
	self._btn_text:set_font_size(small_font_size)
	self.orig.set_text_params(self, params)
	Hooks:Call("BlackMarketGUIButtonPostSetTextParameters", self, params)
end

Hooks:Add("BlackMarketGUIButtonPostSetTextParameters", "BlackMarketGUIButtonPostSetTextParameters_GoonModBMGUI", function(self, params)

	local btn_h = BlackMarketGuiButtonItem._max_btn_height or 5
	local num = BlackMarketGui._instance and BlackMarketGui._instance._button_count or 0
	local overflowed = num and num > btn_h
	if overflowed then

		self:check_overflow_font_size()
		self._btn_text:set_font_size( small_font_size )
		BlackMarketGui.make_fine_text(self, self._btn_text)

		local _, _, w, h = self._btn_text:text_rect()
		self._btn_text:set_size(w, h)
		self._btn_text:set_right(self._panel:w())
		if overflow then
			self._btn_text:set_position( self._btn_text:x(), small_font_size / 4 - 1 )
		else
			self._btn_text:set_position( self._btn_text:x(), 0 )
		end

	else
		self._btn_text:set_position( 0, 0 )
	end

end)

function BlackMarketGuiButtonItem.check_overflow_font_size( self )
	if string.len(self._btn_text:text()) > 22 then
		self._btn_text:set_text( self._btn_text:text():lower():gsub("weapon ", ""):upper() )
	end
end

function BlackMarketGui._update_borders( self )

	local wh = self._weapon_info_panel:h()
	local dy = self._detection_panel:y()
	local dh = self._detection_panel:h()
	local by = self._btn_panel:y()
	local bh = self._btn_panel:h()
	local btn_h = 20

	self._btn_panel:set_visible(self._button_count > 0 and true or false)
	if self._btn_panel:visible() then
		local h = self._button_count % BlackMarketGuiButtonItem._max_btn_height
		h = self._button_count > BlackMarketGuiButtonItem._max_btn_height and self._button_count - h or self._button_count
		self._btn_panel:set_h(btn_h * h + 16)
	end

	local info_box_panel = self._panel:child("info_box_panel")
	local weapon_info_height = info_box_panel:h() - (self._button_count > 0 and self._btn_panel:h() + 8 or 0) - (self._detection_panel:visible() and self._detection_panel:h() + 8 or 0)
	self._weapon_info_panel:set_h(weapon_info_height)
	self._info_texts_panel:set_h(weapon_info_height - btn_h)
	if self._detection_panel:visible() then
		self._detection_panel:set_top(self._weapon_info_panel:bottom() + 8)
		if dh ~= self._detection_panel:h() or dy ~= self._detection_panel:y() then
			self._detection_border:create_sides(self._detection_panel, {
				sides = {
					1,
					1,
					1,
					1
				}
			})
		end
	end
	self._btn_panel:set_top((self._detection_panel:visible() and self._detection_panel:bottom() or self._weapon_info_panel:bottom()) + 8)
	if wh ~= self._weapon_info_panel:h() then
		self._weapon_info_border:create_sides(self._weapon_info_panel, {
			sides = {
				1,
				1,
				1,
				1
			}
		})
	end
	if bh ~= self._btn_panel:h() or by ~= self._btn_panel:y() then
		self._button_border:create_sides(self._btn_panel, {
			sides = {
				1,
				1,
				1,
				1
			}
		})
	end

	if self._info_text_first_set then
		self._info_text_scroll_offset = self._info_text_scroll_offset or 0
	end
	if self._info_text_scroll_offset ~= nil then

		if not self._info_texts_offsets then
			self._info_texts_offsets = {}
			for i = 1, #self._info_texts do
				self._info_texts_offsets[i] = self._info_texts[i]:y()
			end
		end

		local min_offset = -self:get_info_text_height() + self._info_texts_panel:h()
		if self._info_text_scroll_offset < min_offset then
			self._info_text_scroll_offset = min_offset
		end
		if self._info_text_scroll_offset > 0 then
			self._info_text_scroll_offset = 0
		end
		if min_offset < 0 then
			self:add_info_text_scroll_bar( min_offset, self:get_info_text_height(), self._info_text_scroll_offset )
		end

		for i = 1, #self._info_texts do
			self._info_texts[i]:set_y( self._info_texts_offsets[i] + self._info_text_scroll_offset )
		end

	end

end

function BlackMarketGui:get_info_text_height()
	local min_i = 1
	local max_i = #self._info_texts
	local height = self._info_texts_offsets[max_i] + self._info_texts[max_i]:h() - self._info_texts_offsets[min_i]
	return height
end

function BlackMarketGui:add_info_text_scroll_bar( min_offset, max_height, current_offset )
	
	local visible = min_offset < 0
	local scroll_up_indicator_arrow = self._info_texts_panel:child("scroll_up_indicator_arrow")
	local scroll_down_indicator_arrow = self._info_texts_panel:child("scroll_down_indicator_arrow")
	local scroll_bar = self._info_texts_panel:child("scroll_bar")
	local scroll_bar_box_panel = self._info_texts_panel:child("scroll_bar_box_panel")
	local scroll_width = 8
	local scroll_height, scroll_position

	if not scroll_up_indicator_arrow then

		local texture, rect = tweak_data.hud_icons:get_icon_data("scrollbar_arrow")
		scroll_up_indicator_arrow = self._info_texts_panel:bitmap({
			name = "scroll_up_indicator_arrow",
			texture = texture,
			texture_rect = rect,
			layer = 2,
			color = Color.white
		})
		scroll_up_indicator_arrow:set_top( 0 )
		scroll_up_indicator_arrow:set_right( self._info_texts_panel:w() )

	end

	if not scroll_down_indicator_arrow then

		local texture, rect = tweak_data.hud_icons:get_icon_data("scrollbar_arrow")
		scroll_down_indicator_arrow = self._info_texts_panel:bitmap({
			name = "scroll_down_indicator_arrow",
			texture = texture,
			texture_rect = rect,
			layer = 2,
			color = Color.white,
			rotation = 180
		})
		scroll_down_indicator_arrow:set_bottom( self._info_texts_panel:h() )
		scroll_down_indicator_arrow:set_right( self._info_texts_panel:w() )

	end

	if not scroll_bar then

		scroll_bar = self._info_texts_panel:panel({
			name = "scroll_bar",
			layer = 3,
			h = bar_h,
			w = self._info_texts_panel:w()
		})

	end

	if not scroll_bar_box_panel then

		scroll_bar_box_panel = scroll_bar:panel({
			name = "scroll_bar_box_panel",
			w = 4,
			halign = "scale",
			valign = "scale",
		})

	end

	if self._scroll_bar_box_class then
		self._scroll_bar_box_class:close()
	end

	scroll_height = ( scroll_down_indicator_arrow:bottom() - scroll_up_indicator_arrow:top() )
	scroll_height = scroll_height * self._info_texts_panel:h() / max_height
	if current_offset ~= 0 then
		scroll_position = -current_offset * self._info_texts_panel:h() / max_height
	else
		scroll_position = 0
	end

	scroll_bar_box_panel:set_center_x(scroll_bar:w() / 2)
	self._scroll_bar_box_class = BoxGuiObject:new(scroll_bar_box_panel, {
		sides = {
			2,
			2,
			0,
			0
		}
	})
	self._scroll_bar_box_class:set_aligns("scale", "scale")
	scroll_bar_box_panel:set_w( scroll_width )
	scroll_bar_box_panel:set_h( scroll_height )
	scroll_bar:set_top( scroll_up_indicator_arrow:top() + scroll_position )
	scroll_bar:set_center_x( scroll_up_indicator_arrow:center_x() - 2 )
	scroll_bar:set_h( scroll_height )

	scroll_up_indicator_arrow:set_visible( scroll_bar:top() > scroll_up_indicator_arrow:bottom() )
	scroll_down_indicator_arrow:set_visible( scroll_bar:bottom() < scroll_down_indicator_arrow:top() )

end

Hooks:RegisterHook("BlackMarketGUIOnPopulateMasks")
Hooks:RegisterHook("BlackMarketGUIOnPopulateMasksActionList")
function BlackMarketGui.populate_masks(self, data)

	Hooks:Call("BlackMarketGUIOnPopulateMasks", self, data)

	local NOT_WIN_32 = SystemInfo:platform() ~= Idstring("WIN32")
	local GRID_H_MUL = (NOT_WIN_32 and 7 or 6.6) / 8

	local new_data = {}
	local crafted_category = managers.blackmarket:get_crafted_category("masks") or {}
	local mini_icon_helper = math.round((self._panel:h() - (tweak_data.menu.pd2_medium_font_size + 10) - 60) * GRID_H_MUL / 3) - 16
	local max_items = data.override_slots and data.override_slots[1] * data.override_slots[2] or 9
	local start_crafted_item = data.start_crafted_item or 1
	local hold_crafted_item = managers.blackmarket:get_hold_crafted_item()
	local currently_holding = hold_crafted_item and hold_crafted_item.category == "masks"
	local max_rows = tweak_data.gui.MAX_MASK_ROWS or 5
	max_items = max_rows * (data.override_slots and data.override_slots[2] or 3)
	for i = 1, max_items do
		data[i] = nil
	end

	local guis_catalog = "guis/"
	local index = 0
	for i, crafted in pairs(crafted_category) do

		index = i - start_crafted_item + 1
		guis_catalog = "guis/"
		local bundle_folder = tweak_data.blackmarket.masks[crafted.mask_id] and tweak_data.blackmarket.masks[crafted.mask_id].texture_bundle_folder
		if bundle_folder then
			guis_catalog = guis_catalog .. "dlcs/" .. tostring(bundle_folder) .. "/"
		end

		new_data = {}
		new_data.name = crafted.mask_id
		new_data.name_localized = managers.blackmarket:get_mask_name_by_category_slot("masks", i)
		new_data.raw_name_localized = managers.localization:text(tweak_data.blackmarket.masks[new_data.name].name_id)
		new_data.custom_name_text = managers.blackmarket:get_crafted_custom_name("masks", i, true)
		new_data.custom_name_text_right = crafted.modded and -55 or -20
		new_data.custom_name_text_width = crafted.modded and 0.6
		new_data.category = "masks"
		new_data.global_value = crafted.global_value
		new_data.slot = i
		new_data.unlocked = true
		new_data.equipped = crafted.equipped
		new_data.bitmap_texture = guis_catalog .. "textures/pd2/blackmarket/icons/masks/" .. new_data.name
		new_data.stream = false
		new_data.holding = currently_holding and hold_crafted_item.slot == i
		local is_locked = tweak_data.lootdrop.global_values[new_data.global_value] and tweak_data.lootdrop.global_values[new_data.global_value].dlc and not managers.dlc:has_dlc(new_data.global_value)
		local locked_parts = {}
		if not is_locked then
			for part, type in pairs(crafted.blueprint) do
				if tweak_data.lootdrop.global_values[part.global_value] and tweak_data.lootdrop.global_values[part.global_value].dlc and not tweak_data.dlc[part.global_value].free and not managers.dlc:has_dlc(part.global_value) then
					locked_parts[type] = part.global_value
					is_locked = true
				end
			end
		end

		if is_locked then
			new_data.unlocked = false
			new_data.lock_texture = self:get_lock_icon(new_data, "guis/textures/pd2/lock_incompatible")
			new_data.dlc_locked = tweak_data.lootdrop.global_values[new_data.global_value].unlock_id or "bm_menu_dlc_locked"
		end

		if currently_holding then
			if i ~= 1 then
				new_data.selected_text = managers.localization:to_upper_text("bm_menu_btn_swap_mask")
			end

			if i ~= 1 and new_data.slot ~= hold_crafted_item.slot then
				table.insert(new_data, "m_swap")
			end

			table.insert(new_data, "i_stop_move")
		else
			if new_data.unlocked then
				if not new_data.equipped then
					table.insert(new_data, "m_equip")
				end

				if i ~= 1 and new_data.equipped then
					table.insert(new_data, "m_move")
				end

				if not crafted.modded and managers.blackmarket:can_modify_mask(i) and i ~= 1 then
					table.insert(new_data, "m_mod")
				end

				if i ~= 1 then
					table.insert(new_data, "m_preview")
				end

			end

			if i ~= 1 then
				Hooks:Call("BlackMarketGUIOnPopulateMasksActionList", self, new_data)
			end

			if i ~= 1 then
				if 0 < managers.money:get_mask_sell_value(new_data.name, new_data.global_value) then
					table.insert(new_data, "m_sell")
				else
					table.insert(new_data, "m_remove")
				end

			end

		end

		if crafted.modded then
			new_data.mini_icons = {}
			local color_1 = tweak_data.blackmarket.colors[crafted.blueprint.color.id].colors[1]
			local color_2 = tweak_data.blackmarket.colors[crafted.blueprint.color.id].colors[2]
			table.insert(new_data.mini_icons, {
				texture = false,
				w = 16,
				h = 16,
				right = 0,
				bottom = 0,
				layer = 1,
				color = color_2
			})
			table.insert(new_data.mini_icons, {
				texture = false,
				w = 16,
				h = 16,
				right = 18,
				bottom = 0,
				layer = 1,
				color = color_1
			})
			if locked_parts.color then
				local texture = self:get_lock_icon({
					global_value = locked_parts.color
				})
				table.insert(new_data.mini_icons, {
					texture = texture,
					w = 32,
					h = 32,
					right = 2,
					bottom = -5,
					layer = 2,
					color = tweak_data.screen_colors.important_1
				})
			end

			local pattern = crafted.blueprint.pattern.id
			if pattern == "solidfirst" or pattern == "solidsecond" then
			else
				local material_id = crafted.blueprint.material.id
				guis_catalog = "guis/"
				local bundle_folder = tweak_data.blackmarket.materials[material_id] and tweak_data.blackmarket.materials[material_id].texture_bundle_folder
				if bundle_folder then
					guis_catalog = guis_catalog .. "dlcs/" .. tostring(bundle_folder) .. "/"
				end

				local right = -3
				local bottom = 38 - (NOT_WIN_32 and 20 or 10)
				local w = 42
				local h = 42
				table.insert(new_data.mini_icons, {
					texture = guis_catalog .. "textures/pd2/blackmarket/icons/materials/" .. material_id,
					right = right,
					bottom = bottom,
					w = w,
					h = h,
					layer = 1,
					stream = true
				})
				if locked_parts.material then
					local texture = self:get_lock_icon({
						global_value = locked_parts.material
					})
					table.insert(new_data.mini_icons, {
						texture = texture,
						w = 32,
						h = 32,
						right = right + (w - 32) / 2,
						bottom = bottom + (h - 32) / 2,
						layer = 2,
						color = tweak_data.screen_colors.important_1
					})
				end

			end

			do
				local right = -3
				local bottom = math.round(mini_icon_helper - 6 - 6 - 42)
				local w = 42
				local h = 42
				table.insert(new_data.mini_icons, {
					texture = tweak_data.blackmarket.textures[pattern].texture,
					right = right,
					bottom = bottom,
					w = h,
					h = w,
					layer = 1,
					stream = true,
					render_template = Idstring("VertexColorTexturedPatterns")
				})
				if locked_parts.pattern then
					local texture = self:get_lock_icon({
						global_value = locked_parts.pattern
					})
					table.insert(new_data.mini_icons, {
						texture = texture,
						w = 32,
						h = 32,
						right = right + (w - 32) / 2,
						bottom = bottom + (h - 32) / 2,
						layer = 2,
						color = tweak_data.screen_colors.important_1
					})
				end

			end

			new_data.mini_icons.borders = true
		elseif i ~= 1 and managers.blackmarket:can_modify_mask(i) and managers.blackmarket:got_new_drop("normal", "mask_mods", crafted.mask_id) then
			new_data.mini_icons = new_data.mini_icons or {}
			table.insert(new_data.mini_icons, {
				name = "new_drop",
				texture = "guis/textures/pd2/blackmarket/inv_newdrop",
				right = 0,
				top = 0,
				layer = 1,
				w = 16,
				h = 16,
				stream = false,
				visible = true
			})
			new_data.new_drop_data = {}
		end

		data[index] = new_data

	end

	local can_buy_masks = true
	for i = 1, max_items do
		if not data[i] then
			index = i + start_crafted_item - 1
			can_buy_masks = managers.blackmarket:is_mask_slot_unlocked(i)
			new_data = {}
			if can_buy_masks then
				new_data.name = "bm_menu_btn_buy_new_mask"
				new_data.name_localized = managers.localization:text("bm_menu_empty_mask_slot")
				new_data.mid_text = {}
				new_data.mid_text.noselected_text = new_data.name_localized
				new_data.mid_text.noselected_color = tweak_data.screen_colors.button_stage_3
				if not currently_holding or not new_data.mid_text.noselected_text then
				end

				new_data.mid_text.selected_text = managers.localization:text("bm_menu_btn_buy_new_mask")
				new_data.mid_text.selected_color = currently_holding and new_data.mid_text.noselected_color or tweak_data.screen_colors.button_stage_2
				new_data.empty_slot = true
				new_data.category = "masks"
				new_data.slot = index
				new_data.unlocked = true
				new_data.equipped = false
				new_data.num_backs = 0
				new_data.cannot_buy = not can_buy_masks
				if currently_holding then
					if i ~= 1 then
						new_data.selected_text = managers.localization:to_upper_text("bm_menu_btn_place_mask")
					end

					if i ~= 1 then
						table.insert(new_data, "m_place")
					end

					table.insert(new_data, "i_stop_move")
				else
					table.insert(new_data, "em_buy")
				end

				if index ~= 1 and managers.blackmarket:got_new_drop(nil, "mask_buy", nil) then
					new_data.mini_icons = new_data.mini_icons or {}
					table.insert(new_data.mini_icons, {
						name = "new_drop",
						texture = "guis/textures/pd2/blackmarket/inv_newdrop",
						right = 0,
						top = 0,
						layer = 1,
						w = 16,
						h = 16,
						stream = false,
						visible = false
					})
					new_data.new_drop_data = {}
				end

			else
				new_data.name = "bm_menu_btn_buy_mask_slot"
				new_data.name_localized = managers.localization:text("bm_menu_locked_mask_slot")
				new_data.empty_slot = true
				new_data.category = "masks"
				new_data.slot = index
				new_data.unlocked = true
				new_data.equipped = false
				new_data.num_backs = 0
				new_data.lock_texture = "guis/textures/pd2/blackmarket/money_lock"
				new_data.lock_color = tweak_data.screen_colors.button_stage_3
				new_data.lock_shape = {
					w = 32,
					h = 32,
					x = 0,
					y = -32
				}
				new_data.locked_slot = true
				new_data.dlc_locked = managers.experience:cash_string(managers.money:get_buy_mask_slot_price())
				new_data.mid_text = {}
				new_data.mid_text.noselected_text = new_data.name_localized
				new_data.mid_text.noselected_color = tweak_data.screen_colors.button_stage_3
				new_data.mid_text.is_lock_same_color = true
				if currently_holding then
					new_data.mid_text.selected_text = new_data.mid_text.noselected_text
					new_data.mid_text.selected_color = new_data.mid_text.noselected_color
					table.insert(new_data, "i_stop_move")
				elseif managers.money:can_afford_buy_mask_slot() then
					new_data.mid_text.selected_text = managers.localization:text("bm_menu_btn_buy_mask_slot")
					new_data.mid_text.selected_color = tweak_data.screen_colors.button_stage_2
					table.insert(new_data, "em_unlock")
				else
					new_data.mid_text.selected_text = managers.localization:text("bm_menu_cannot_buy_mask_slot")
					new_data.mid_text.selected_color = tweak_data.screen_colors.important_1
					new_data.dlc_locked = new_data.dlc_locked .. "  " .. managers.localization:to_upper_text("bm_menu_cannot_buy_mask_slot")
					new_data.mid_text.lock_noselected_color = tweak_data.screen_colors.important_1
					new_data.cannot_buy = true
				end

			end

			data[i] = new_data
		end

	end

end

Hooks:RegisterHook("BlackMarketGUIOnPopulateMods")
Hooks:RegisterHook("BlackMarketGUIOnPopulateModsActionList")

local populate_choose_mask_mod1 = BlackMarketGui.populate_choose_mask_mod
Hooks:RegisterHook("BlackMarketGUIOnPopulateMaskMods")
Hooks:RegisterHook("BlackMarketGUIOnPopulateMaskModsActionList")
function BlackMarketGui.populate_choose_mask_mod(self, data)
populate_choose_mask_mod1(self, data)
	Hooks:Call("BlackMarketGUIOnPopulateMaskMods", self, data)

	local new_data = {}
	local index = 1
	local equipped_mod = managers.blackmarket:customize_mask_category_id(data.category)
	local equipped_first, equipped_second = nil

	if data.category == "mask_colors" then
		equipped_first = data.is_first_color and managers.blackmarket:customize_mask_category_id("color_a")
		equipped_second = not data.is_first_color and managers.blackmarket:customize_mask_category_id("color_b")
	end
	local guis_catalog = "guis/"
	local type_func = type

	for k, mods in pairs(data.on_create_data) do

		guis_catalog = "guis/"
		local bundle_folder = tweak_data.blackmarket[data.category][mods.id] and tweak_data.blackmarket[data.category][mods.id].texture_bundle_folder
		if bundle_folder then
			guis_catalog = guis_catalog .. "dlcs/" .. tostring(bundle_folder) .. "/"
		end

		new_data = {}
		new_data.name = mods.id
		new_data.name_localized = managers.localization:text(tweak_data.blackmarket[data.category][new_data.name].name_id)
		new_data.category = data.category
		new_data.slot = index
		new_data.prev_slot = data.prev_node_data and data.prev_node_data.slot
		new_data.unlocked = mods.default or mods.amount
		new_data.amount = mods.amount or 0
		new_data.equipped = equipped_mod == mods.id
		new_data.equipped_text = managers.localization:text("bm_menu_chosen")
		new_data.mods = mods
		new_data.stream = data.category ~= "colors"
		new_data.global_value = mods.global_value
		local is_locked = false
		if new_data.amount < 1 and mods.id ~= "plastic" and mods.id ~= "no_color_full_material" and not mods.free_of_charge then
			if type(new_data.unlocked) == "number" then
				new_data.unlocked = -math.abs(new_data.unlocked)
			end
			new_data.lock_texture = true
			new_data.dlc_locked = "bm_menu_amount_locked"
			is_locked = true
		end
		if new_data.unlocked and type_func(new_data.unlocked) == "number" and tweak_data.lootdrop.global_values[new_data.global_value] and tweak_data.lootdrop.global_values[new_data.global_value].dlc and not managers.dlc:is_dlc_unlocked(new_data.global_value) then
			new_data.unlocked = -math.abs(new_data.unlocked)
			new_data.lock_texture = self:get_lock_icon(new_data)
			new_data.dlc_locked = tweak_data.lootdrop.global_values[new_data.global_value].unlock_id or "bm_menu_dlc_locked"
			is_locked = true
		elseif managers.dlc:is_content_achievement_locked(data.category, new_data.name) or managers.dlc:is_content_achievement_milestone_locked(data.category, new_data.name) then
			new_data.unlocked = -math.abs(new_data.unlocked)
			new_data.lock_texture = "guis/textures/pd2/lock_achievement"
		elseif managers.dlc:is_content_skirmish_locked(data.category, new_data.name) and (not new_data.unlocked or new_data.unlocked == 0) then
			new_data.lock_texture = "guis/textures/pd2/skilltree/padlock"
		elseif managers.dlc:is_content_crimespree_locked(data.category, new_data.name) and (not new_data.unlocked or new_data.unlocked == 0) then
			new_data.lock_texture = "guis/textures/pd2/skilltree/padlock"
		end
		if data.category == "mask_colors" then
			new_data.equipped = equipped_first == new_data.name or equipped_second == new_data.name
			new_data.bitmap_texture = "guis/dlcs/mcu/textures/pd2/blackmarket/icons/mask_color/mask_color_icon"
			new_data.bitmap_color = tweak_data.blackmarket.mask_colors[new_data.name].color
			new_data.is_first_color = data.is_first_color
		elseif data.category == "textures" then
			new_data.bitmap_texture = tweak_data.blackmarket[data.category][mods.id].texture
			new_data.render_template = Idstring("VertexColorTexturedPatterns")
		else
			new_data.bitmap_texture = guis_catalog .. "textures/pd2/blackmarket/icons/" .. tostring(data.category) .. "/" .. new_data.name
			if mods.bitmap_texture_override then
				new_data.bitmap_texture = guis_catalog .. "textures/pd2/blackmarket/icons/" .. tostring(data.category) .. "/" .. mods.bitmap_texture_override
			end
		end

		if managers.blackmarket:got_new_drop(new_data.global_value or "normal", new_data.category, new_data.name) then
			new_data.mini_icons = new_data.mini_icons or {}
			table.insert(new_data.mini_icons, {
				name = "new_drop",
				texture = "guis/textures/pd2/blackmarket/inv_newdrop",
				right = 0,
				top = 0,
				layer = 1,
				w = 16,
				h = 16,
				stream = false
			})
			new_data.new_drop_data = {
				new_data.global_value or "normal",
				new_data.category,
				new_data.name
			}
		end

		new_data.btn_text_params = {
			type = managers.localization:text("bm_menu_" .. data.category)
		}
		if not is_locked then

			if data.category == "mask_colors" then
				if data.is_first_color then
					table.insert(new_data, "mp_choose_first")
				else
					table.insert(new_data, "mp_choose_second")
				end
			else
				table.insert(new_data, "mp_choose")
			end
			table.insert(new_data, "mp_preview")

		end

		if managers.blackmarket:can_finish_customize_mask() and managers.blackmarket:can_afford_customize_mask() then
			table.insert(new_data, "mm_buy")
		end

		Hooks:Call("BlackMarketGUIOnPopulateMaskModsActionList", self, new_data)

		data[index] = new_data
		index = index + 1

	end

	if #data == 0 then
		new_data = {}
		new_data.name = "bm_menu_nothing"
		new_data.empty_slot = true
		new_data.category = data.category
		new_data.slot = 1
		new_data.unlocked = true
		new_data.can_afford = true
		new_data.equipped = false
		data[1] = new_data
	end

	local max_mask_mods = #data.on_create_data
	for i = 1, math.ceil(max_mask_mods / data.override_slots[1]) * data.override_slots[1] do
		if not data[i] then
			new_data = {}
			new_data.name = "empty"
			new_data.name_localized = ""
			new_data.category = data.category
			new_data.slot = i
			new_data.unlocked = true
			new_data.equipped = false
			data[i] = new_data
		end

	end

end

Hooks:RegisterHook("BlackMarketGUIStartPageData")
function BlackMarketGui._start_page_data(self)

	local data = {}
	data.topic_id = "menu_steam_inventory"
	data.init_callback_name = "create_steam_inventory"
	data.init_callback_params = data
	data.allow_tradable_reload = true
	data.create_steam_inventory_extra = true
	data.add_market_panel = true

	Hooks:Call("BlackMarketGUIStartPageData", self, data)

	return data

end

Hooks:RegisterHook("BlackMarketGUIOnMouseMoved")
function BlackMarketGui.mouse_moved(self, o, x, y)
	local r = self.orig.mouse_moved(self, o, x, y)
	if not self._enabled then
		return r
	end
	Hooks:Call("BlackMarketGUIOnMouseMoved", self, o, x, y)
	return r
end

Hooks:RegisterHook("BlackMarketGUIUpdateInfoText")
function BlackMarketGui.update_info_text(self)
	self.orig.update_info_text(self)
	Hooks:Call("BlackMarketGUIUpdateInfoText", self)
end

function BlackMarketGui._update_info_text(self, slot_data, updated_texts, data, scale_override)

	self._info_text_first_set = true

	local ignore_lock = false
	local is_renaming_this = false
	if data ~= nil then
		ignore_lock = data.ignore_lock or ignore_lock
		is_renaming_this = data.is_renaming_this or is_renaming_this
	end

	if self._desc_mini_icons then
		for _, gui_object in pairs(self._desc_mini_icons) do
			self._panel:remove(gui_object[1])
		end
	end
	self._desc_mini_icons = {}
	local desc_mini_icons = self._slot_data.desc_mini_icons
	local info_box_panel = self._panel:child("info_box_panel")
	if desc_mini_icons and 0 < table.size(desc_mini_icons) then
		for _, mini_icon in pairs(desc_mini_icons) do
			local new_icon = self._panel:bitmap({
				texture = mini_icon.texture,
				x = info_box_panel:left() + 10 + mini_icon.right,
				w = mini_icon.w or 32,
				h = mini_icon.h or 32
			})
			table.insert(self._desc_mini_icons, {new_icon, 1})
		end
		updated_texts[2].text = string.rep("     ", table.size(desc_mini_icons)) .. updated_texts[2].text
	else
	end
	if not ignore_lock and slot_data.lock_texture and slot_data.lock_texture ~= true then
		local new_icon = self._panel:bitmap({
			texture = slot_data.lock_texture,
			x = info_box_panel:left() + 10,
			w = 20,
			h = 20,
			color = self._info_texts[3]:color(),
			blend_mode = "add"
		})
		updated_texts[3].text = "     " .. updated_texts[3].text
		table.insert(self._desc_mini_icons, {new_icon, 2})
	else
	end
	if is_renaming_this and self._rename_info_text then
		local text = self._renaming_item.custom_name ~= "" and self._renaming_item.custom_name or "##" .. tostring(slot_data.raw_name_localized) .. "##"
		updated_texts[self._rename_info_text].text = text
		updated_texts[self._rename_info_text].resource_color = tweak_data.screen_colors.text:with_alpha(0.35)
	end
	for id, _ in ipairs(self._info_texts) do
		self:set_info_text(id, updated_texts[id].text, updated_texts[id].resource_color)
	end
	local _, _, _, th = self._info_texts[1]:text_rect()
	self._info_texts[1]:set_h(th)
	local y = self._info_texts[1]:bottom()
	local title_offset = y
	local bg = self._info_texts_bg[1]
	if alive(bg) then
		bg:set_shape(self._info_texts[1]:shape())
	end
	local below_y
	for i = 2, #self._info_texts do
		local info_text = self._info_texts[i]
		info_text:set_font_size(small_font_size)
		_, _, _, th = info_text:text_rect()
		info_text:set_y(y)
		info_text:set_h(th)
		if updated_texts[i].below_stats then
			if slot_data.comparision_data and alive(self._stats_text_modslist) then
				info_text:set_world_y(below_y or self._stats_text_modslist:world_top())
				below_y = (below_y or info_text:world_y()) + th
			else
				info_text:set_top((below_y or info_text:top()) + 20)
				below_y = (below_y or info_text:top()) + th
			end
		end
		local scale = 1
		if info_text:bottom() > self._info_texts_panel:h() then
			scale = self._info_texts_panel:h() / info_text:bottom()
		end

		if scale_override then
			if type(scale_override) == "number" then
				scale = scale_override
			end
			if type(scale_override) == "table" then
				scale = scale_override[i]
			end
		end

		info_text:set_font_size(small_font_size * scale)
		_, _, _, th = info_text:text_rect()
		info_text:set_h(th)
		local bg = self._info_texts_bg[i]
		if alive(bg) then
			bg:set_shape(info_text:shape())
		end
		y = info_text:bottom()
	end
	for _, desc_mini_icon in ipairs(self._desc_mini_icons) do
		desc_mini_icon[1]:set_y(title_offset)
		desc_mini_icon[1]:set_world_top(self._info_texts[ desc_mini_icon[2] ]:world_bottom() + (2 - (desc_mini_icon[2] - 1) * 3))
	end
	if is_renaming_this and self._rename_info_text and self._rename_caret then
		local info_text = self._info_texts[self._rename_info_text]
		local x, y, w, h = info_text:text_rect()
		if self._renaming_item.custom_name == "" then
			w = 0
		end
		self._rename_caret:set_w(2)
		self._rename_caret:set_h(h)
		self._rename_caret:set_world_position(x + w, y)
	end

end

Hooks:RegisterHook("BlackMarketGUIOnMousePressed")
function BlackMarketGui:mouse_pressed(button, x, y)
	if self:check_mouse_pressed(button, x, y) then
		Hooks:Call("BlackMarketGUIOnMousePressed", self, button, x, y)
		self.orig.mouse_pressed(self, button, x, y)
	end
end

function BlackMarketGui:check_mouse_pressed(button, x, y)
	if managers.menu_scene and managers.menu_scene:input_focus() then
		return false
	end
	if not self._enabled then
		return false
	end
	if self._renaming_item then
		self:_stop_rename_item()
		return false
	end
	if self._no_input then
		return false
	end
	return true
end

Hooks:RegisterHook("BlackMarketGUIOnPopulateBuyMasks")
Hooks:RegisterHook("BlackMarketGUIOnPopulateBuyMasksActionList")
function BlackMarketGui.populate_buy_mask(self, data)

	Hooks:Call("BlackMarketGUIOnPopulateBuyMasks", self, data)

	local new_data = {}
	local guis_catalog = "guis/"
	local max_masks = #data.on_create_data

	for i = 1, max_masks do
		data[i] = nil
	end

	for i = 1, #data.on_create_data do

		guis_catalog = "guis/"

		local bundle_folder = tweak_data.blackmarket.masks[data.on_create_data[i].mask_id] and tweak_data.blackmarket.masks[data.on_create_data[i].mask_id].texture_bundle_folder
		if bundle_folder then
			guis_catalog = guis_catalog .. "dlcs/" .. tostring(bundle_folder) .. "/"
		end

		new_data = {}
		new_data.name = data.on_create_data[i].mask_id
		new_data.name_localized = managers.localization:text(tweak_data.blackmarket.masks[new_data.name].name_id)
		new_data.category = data.category
		new_data.slot = data.prev_node_data and data.prev_node_data.slot
		new_data.global_value = data.on_create_data[i].global_value
		new_data.unlocked = managers.blackmarket:get_item_amount(new_data.global_value, "masks", new_data.name, true) or 0
		new_data.equipped = false
		new_data.num_backs = data.prev_node_data.num_backs + 1
		new_data.bitmap_texture = guis_catalog .. "textures/pd2/blackmarket/icons/masks/" .. new_data.name
		new_data.stream = false

		if not new_data.global_value then
			Application:debug("BlackMarketGui:populate_buy_mask( data ) Missing global value on mask", new_data.name)
		end

		if tweak_data.lootdrop.global_values[new_data.global_value] and tweak_data.lootdrop.global_values[new_data.global_value].dlc and not managers.dlc:is_dlc_unlocked(new_data.global_value) then
			new_data.unlocked = -math.abs(new_data.unlocked)
			new_data.lock_texture = self:get_lock_icon(new_data)
			new_data.dlc_locked = tweak_data.lootdrop.global_values[new_data.global_value].unlock_id or "bm_menu_dlc_locked"
		elseif managers.dlc:is_content_achievement_locked(data.category, new_data.name) or managers.dlc:is_content_achievement_milestone_locked(data.category, new_data.name) then
			new_data.unlocked = -math.abs(new_data.unlocked)
			new_data.lock_texture = "guis/textures/pd2/lock_achievement"
		elseif managers.dlc:is_content_skirmish_locked(data.category, new_data.name) and (not new_data.unlocked or new_data.unlocked == 0) then
			new_data.lock_texture = "guis/textures/pd2/skilltree/padlock"
		end

		if tweak_data.blackmarket.masks[new_data.name].infamy_lock then

			local infamy_lock = tweak_data.blackmarket.masks[new_data.name].infamy_lock
			local is_unlocked = managers.infamy:owned(infamy_lock)
			if not is_unlocked then
				if type(new_data.unlocked) == "number" then
					new_data.unlocked = -math.abs(new_data.unlocked)
				end
				new_data.lock_texture = "guis/textures/pd2/lock_infamy"
				new_data.infamy_lock = infamy_lock
			end

		end

		if new_data.unlocked and new_data.unlocked > 0 then

			table.insert(new_data, "bm_buy")
			table.insert(new_data, "bm_preview")
			if 0 < managers.money:get_mask_sell_value(new_data.name, new_data.global_value) then
				table.insert(new_data, "bm_sell")
			end

		else
			table.insert(new_data, "bm_preview")
			new_data.mid_text = ""
			new_data.lock_texture = new_data.lock_texture or true

		end

		Hooks:Call("BlackMarketGUIOnPopulateBuyMasksActionList", self, new_data)

		if managers.blackmarket:got_new_drop(new_data.global_value or "normal", "masks", new_data.name) then

			new_data.mini_icons = new_data.mini_icons or {}
			table.insert(new_data.mini_icons, {
				name = "new_drop",
				texture = "guis/textures/pd2/blackmarket/inv_newdrop",
				right = 0,
				top = 0,
				layer = 1,
				w = 16,
				h = 16,
				stream = false
			})
			new_data.new_drop_data = {
				new_data.global_value or "normal",
				"masks",
				new_data.name
			}

		end

		data[i] = new_data

	end

	local max_page = data.override_slots[1] * data.override_slots[2]
	for i = 1, math.max(math.ceil(max_masks / data.override_slots[1]) * data.override_slots[1], max_page) do

		if not data[i] then
			new_data = {}
			new_data.name = "empty"
			new_data.name_localized = ""
			new_data.category = data.category
			new_data.slot = i
			new_data.unlocked = true
			new_data.equipped = false
			data[i] = new_data
		end

	end

end

Hooks:RegisterHook("BlackMarketGUIChooseMaskPartCallback")
function BlackMarketGui.choose_mask_part_callback(self, data)
	local r = Hooks:ReturnCall("BlackMarketGUIChooseMaskPartCallback", self, data)
	if r then
		return
	end
	return self.orig.choose_mask_part_callback(self, data)
end

Hooks:RegisterHook("BlackMarketGUIMouseReleased")
function BlackMarketGui.mouse_released(self, o, button, x, y)
	if not self._enabled then
		return
	end
	self.orig.mouse_released(self, o, button, x, y)
	Hooks:Call("BlackMarketGUIMouseReleased", self, o, button, x, y)
end

function BlackMarketGui._choose_weapon_mods_callback(self, data)
	BlackMarketGui.choose_weapon_mods_callback(self, data)
	Hooks:Call("BlackMarketGUIOnStartCraftingWeapon", self, data, {})
end

Hooks:RegisterHook("BlackMarketGUIOnStartCraftingWeapon")
function BlackMarketGui._start_crafting_weapon(self, data, new_node_data)
	Hooks:Call("BlackMarketGUIOnStartCraftingWeapon", self, data, new_node_data)
	self.orig._start_crafting_weapon(self, data, new_node_data)
end

Hooks:RegisterHook("BlackMarketGUIOnPreviewWeapon")
function BlackMarketGui._preview_weapon(self, data)
	self.orig._preview_weapon(self, data)
	Hooks:Call("BlackMarketGUIOnPreviewWeapon", self, data)
end

Hooks:RegisterHook("BlackMarketGUISlotItemOnRefresh")
function BlackMarketGuiSlotItem.refresh(self)
	self.orig.refresh(self)
	Hooks:Call("BlackMarketGUISlotItemOnRefresh", self)
end

Hooks:RegisterHook("BlackMarketGUIOnPressFirstButton")
function BlackMarketGui.press_first_btn(self, button)
	local r = Hooks:ReturnCall("BlackMarketGUIOnPressFirstButton", self, button)
	if r ~= nil then return r end
	return self.orig.press_first_btn(self, button)
end

Hooks:RegisterHook("BlackMarketGUIOnMoveUp")
function BlackMarketGui.move_up(self)
	local r = Hooks:ReturnCall("BlackMarketGUIOnMoveUp", self)
	if r ~= nil then return r end
	return self.orig.move_up(self)
end

Hooks:RegisterHook("BlackMarketGUIOnMoveDown")
function BlackMarketGui.move_down(self)
	local r = Hooks:ReturnCall("BlackMarketGUIOnMoveDown", self)
	if r ~= nil then return r end
	return self.orig.move_down(self)
end

Hooks:RegisterHook("BlackMarketGUIOnMoveLeft")
function BlackMarketGui.move_left(self)
	local r = Hooks:ReturnCall("BlackMarketGUIOnMoveLeft", self)
	if r ~= nil then return r end
	return self.orig.move_left(self)
end

Hooks:RegisterHook("BlackMarketGUIOnMoveRight")
function BlackMarketGui.move_right(self)
	local r = Hooks:ReturnCall("BlackMarketGUIOnMoveRight", self)
	if r ~= nil then return r end
	return self.orig.move_right(self)
end

Hooks:RegisterHook("BlackMarketGUIOnNextPage")
function BlackMarketGui.next_page(self, no_sound)
	local r = Hooks:ReturnCall("BlackMarketGUIOnNextPage", self, no_sound)
	if r ~= nil then return r end
	return self.orig.next_page(self, no_sound)
end

Hooks:RegisterHook("BlackMarketGUIOnPreviousPage")
function BlackMarketGui.previous_page(self, no_sound)
	local r = Hooks:ReturnCall("BlackMarketGUIOnPreviousPage", self, no_sound)
	if r ~= nil then return r end
	return self.orig.previous_page(self, no_sound)
end

Hooks:RegisterHook("BlackMarketGUIOnPressButton")
function BlackMarketGui.press_button(self, button)
	local r = Hooks:ReturnCall("BlackMarketGUIOnPressButton", self, button)
	if r ~= nil then return r end
	return self.orig.press_button(self, button)
end

Hooks:RegisterHook("BlackMarketGUIOnPressedSpecialButton")
function BlackMarketGui.special_btn_pressed(self, button)
	local r = Hooks:ReturnCall("BlackMarketGUIOnPressedSpecialButton", self, button)
	if r ~= nil then return r end
	return self.orig.special_btn_pressed(self, button)
end

Hooks:RegisterHook("BlackMarketGUIOnConfirmPressed")
function BlackMarketGui.confirm_pressed(self)
	local r = Hooks:ReturnCall("BlackMarketGUIOnConfirmPressed", self)
	if r ~= nil then return r end
	return self.orig.confirm_pressed(self, button)
end

Hooks:RegisterHook("BlackMarketGUIPrePopulateInventoryTradables")
function BlackMarketGui.populate_inventory_tradable(self, data)
	Hooks:Call("BlackMarketGUIPrePopulateInventoryTradables", self, data)
	self.orig.populate_inventory_tradable(self, data)
end
