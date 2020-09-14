local _f_text_original = LocalizationManager.text

function LocalizationManager:text(string_id, ...)
	if string_id == "heist_escape_park_day_hl" then
		return self:text("heist_escape_park_hl") .. " [DAY]"
	elseif string_id == "heist_escape_cafe_day_hl" then
		return self:text("heist_escape_cafe_hl") .. " [DAY]"
	else
		return _f_text_original(self, string_id, ...)
	end
end