local ps_add = PlayerStandard._add_unit_to_char_table
function PlayerStandard:_add_unit_to_char_table(char_table, unit, unit_type, ...)
	if unit_type ~= 3 or unit:base()._detection_delay then
		ps_add(self, char_table, unit, unit_type, ...)
	end
end