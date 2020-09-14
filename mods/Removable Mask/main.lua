local localization_path = ModPath..'loc/'

local M_groupai
local M_hud
local M_localization
local M_player

local PlayerDamage = PlayerDamage
local PlayerStandard = PlayerStandard

local Hooks = Hooks

Hooks:PreHook(PlayerStandard, 'init', 'RemovableMask_PlayerStandard_init', function()
	LocalizationManager:load_localization_file(localization_path..BLT.Localization:get_language().language)
	LocalizationManager:load_localization_file(localization_path..'en', false)

	M_groupai = managers.groupai
	M_hud = managers.hud
	M_localization = managers.localization
	M_player = managers.player

	Hooks:RemovePreHook('RemovableMask_PlayerStandard_init')
end)

local pull_off_mask_time = tweak_data.player.put_on_mask_time * 2

local mask_removal_enabled

local function disable_removable_mask()
	mask_removal_enabled = nil
	Hooks:RemovePreHook('RemovableMask_PlayerDamage__calc_armor_damage')
	Hooks:RemovePreHook('RemovableMask_PlayerDamage__calc_health_damage')
	Hooks:RemovePreHook('RemovableMask_PlayerDamage_set_health')
	Hooks:RemovePostHook('RemovableMask_PlayerMaskOff__enter')
end

Hooks:PreHook(PlayerDamage, '_calc_armor_damage', 'RemovableMask_PlayerDamage__calc_armor_damage', function(_, attack_data)
	if attack_data.damage >= 0.6 then
		disable_removable_mask()
	end
end)

Hooks:PreHook(PlayerDamage, '_calc_health_damage', 'RemovableMask_PlayerDamage__calc_health_damage', function(_, attack_data)
	if attack_data.damage > 0 then
		disable_removable_mask()
	end
end)

Hooks:PreHook(PlayerDamage, 'set_health', 'RemovableMask_PlayerDamage_set_health', function(_, health)
	if health == 0 then
		disable_removable_mask()
	end
end)

Hooks:PostHook(PlayerMaskOff, '_enter', 'RemovableMask_PlayerMaskOff__enter', function(self)
	if mask_removal_enabled then
		self._show_casing_t = nil
	end
	mask_removal_enabled = M_groupai:state():whisper_mode()
end)

local orig_PlayerStandard__check_use_item = PlayerStandard._check_use_item
function PlayerStandard:_check_use_item(t, input)
	local new_action = nil
	if mask_removal_enabled then
		local action_wanted = input.btn_use_item_press
		if action_wanted then
			local action_forbidden = self._use_item_expire_t or self:_interacting() or self:_changing_weapon() or self:_is_throwing_projectile() or self:_is_meleeing() or M_player:is_carrying() or self:_on_zipline()
			if not action_forbidden and not M_player:check_selected_equipment_placement_valid(self._unit) then
				mask_removal_enabled = M_groupai:state():whisper_mode()
				if mask_removal_enabled then
					self._use_item_maskoff = true
					self:_start_action_use_item(t)
					new_action = true
				end
			end
		end
		if input.btn_use_item_release then
			self:_interupt_action_use_item()
		end
	end
	return new_action or orig_PlayerStandard__check_use_item(self, t, input)
end

local orig_PlayerStandard__update_use_item_timers = PlayerStandard._update_use_item_timers
function PlayerStandard:_update_use_item_timers(t, input)
	if self._use_item_maskoff then
		if self._use_item_expire_t then
			M_hud:set_progress_timer_bar_width(pull_off_mask_time - (self._use_item_expire_t - t), pull_off_mask_time)
			if self._use_item_expire_t <= t then
				self:_end_action_use_item(M_groupai:state():whisper_mode())
				self._use_item_expire_t = nil
			end
		end
	else
		orig_PlayerStandard__update_use_item_timers(self, t, input)
	end
end

local orig_PlayerStandard__does_deploying_limit_movement = PlayerStandard._does_deploying_limit_movement
function PlayerStandard:_does_deploying_limit_movement()
	return self._use_item_maskoff or orig_PlayerStandard__does_deploying_limit_movement(self)
end

local orig_PlayerStandard__start_action_use_item = PlayerStandard._start_action_use_item
function PlayerStandard:_start_action_use_item(t)
	if self._use_item_maskoff then
		self:_interupt_action_reload(t)
		self:_interupt_action_steelsight(t)
		self:_interupt_action_running(t)
		self:_interupt_action_charging_weapon(t)
		self._use_item_expire_t = t + pull_off_mask_time
		self:_play_unequip_animation()
		M_hud:show_progress_timer_bar(0, pull_off_mask_time)
		M_hud:show_progress_timer({text = M_localization:text('RemovableMask_removing')})
	else
		orig_PlayerStandard__start_action_use_item(self, t)
	end
end

local orig_PlayerStandard__interupt_action_use_item = PlayerStandard._interupt_action_use_item
function PlayerStandard:_interupt_action_use_item(t, input, complete)
	if self._use_item_maskoff then
		if self._use_item_expire_t then
			self._use_item_expire_t = nil
			if not complete then
				self:_play_equip_animation()
			end
			M_hud:hide_progress_timer_bar(complete)
			M_hud:remove_progress_timer()
			self._use_item_maskoff = nil
		end
	else
		orig_PlayerStandard__interupt_action_use_item(self, t, input, complete)
	end
end

local orig_PlayerStandard__end_action_use_item = PlayerStandard._end_action_use_item
function PlayerStandard:_end_action_use_item(valid)
	if self._use_item_maskoff then
		self:_interupt_action_use_item(nil, nil, valid)
		if valid and mask_removal_enabled then
			M_player:set_player_state('mask_off')
		end
	else
		orig_PlayerStandard__end_action_use_item(self, valid)
	end
end