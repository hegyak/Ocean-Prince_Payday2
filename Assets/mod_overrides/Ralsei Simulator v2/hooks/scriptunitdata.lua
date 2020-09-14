--[[
	UNIT ATTACHMENT DATA ( as long as you keep the top line you can change this between mods and it should merge properly and work fine! )
]]--

ScriptUnitData.unit_attachments = ScriptUnitData.unit_attachments or {}

-- Goat Normal Unit
ScriptUnitData.unit_attachments["units/pd2_dlc_peta/characters/wld_goat_1/wld_goat_1"] = {
	{ attach_point = "Head", unit_path = "units/pd2_dlc_peta/goater/realsi" }
}
-- Pickup Normal Unit
ScriptUnitData.unit_attachments["units/pd2_dlc_peta/pickups/pta_pku_goatbag/pta_pku_goatbag"] = {
	{ attach_point = "Head", unit_path = "units/pd2_dlc_peta/goater/realsi" }
}





--[[
	UNIT ATTACHMENT CODE ( copy this between mods and it should work fine. )
]]--

-- Pre-Convert them to Idstrings to save processing when ingame.
ScriptUnitData.hashed_unit_attachments = {}
for path, attachment_data in pairs(ScriptUnitData.unit_attachments) do
	ScriptUnitData.hashed_unit_attachments[tostring(Idstring(path))] = attachment_data
end

-- Loading function to check if an asset actually exists before trying to load it.
local function safe_load( path, ext )
	if managers.dyn_resource and DB:has( ext, path ) then
		managers.dyn_resource:load( Idstring(ext), Idstring(path), DynamicResourceManager.DYN_RESOURCES_PACKAGE, false )

		return true
	else
		return false
	end
end

-- Hook to check if we need to attach anything to your unit!
Hooks:PostHook( ScriptUnitData, "init", "AttachToUnit", function(self, unit)
	-- Get the path in Idstring form.
	local unit_id = tostring(unit:name())

	-- See if we have attachments for it.
	if unit_id and self.hashed_unit_attachments[unit_id] then
		local attachments = self.hashed_unit_attachments[unit_id]

		self._attachey_things = {}

		-- Go through every attachment.
		for index, value in ipairs(attachments) do
			-- A quick check for valid data.
			if value.attach_point and value.unit_path then
				-- Get some more data.
				local align_obj = unit:get_object(Idstring(value.attach_point))
				local unit_path = value.unit_path

				-- Double check that they also exist.
				if align_obj and unit_path then
					-- Load Unit In 
					local loaded = safe_load( unit_path, "unit" )
				
					-- If it loaded successfully...
					if loaded then
						-- ...get our start position and rotation...
						local spawn_pos = align_obj:position()
						local spawn_rot = align_obj:rotation()

						-- ...and spawn the unit.
						local spawn_unit = safe_spawn_unit(Idstring(unit_path), spawn_pos, spawn_rot)
						
						-- Finally we link the unit to the main unit.
						spawn_unit:unit_data().parent_unit = unit
						unit:link(Idstring(value.attach_point), spawn_unit, spawn_unit:orientation_object():name())

						table.insert(self._attachey_things, spawn_unit)
					end
				end
			end
		end
	end
end)

Hooks:PostHook( ScriptUnitData, "destroy", "DestroyUnits", function(self)
	if not self._attachey_things then return end

	for _, unit in ipairs(self._attachey_things) do
		unit:set_slot(0)
	end
end)