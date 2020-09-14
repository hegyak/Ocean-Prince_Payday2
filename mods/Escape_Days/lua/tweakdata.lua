Hooks:Add("LocalizationManagerPostInit", "EscapeDaysLocalization", function(loc)
	LocalizationManager:add_localized_strings({
	["heist_contact_escape_days"] = "Escape Days",
	["heist_contact_escape_days_description"] = "",
	})
end)

if not tweak_data then return end

if not tweak_data.narrative.contacts.escape_days then
tweak_data.narrative.contacts.escape_days = {}
tweak_data.narrative.contacts.escape_days.name_id = "heist_contact_escape_days"
tweak_data.narrative.contacts.escape_days.descriptions_id = "heist_contact_escape_days_description"
tweak_data.narrative.contacts.escape_days.package = "packages/contact_bain"
tweak_data.narrative.contacts.escape_days.assets_gui = Idstring("guis/mission_briefing/preload_contact_bain")
end

tweak_data.narrative.jobs.escape_street = deep_clone(tweak_data.narrative.jobs.rat)
tweak_data.narrative.jobs.escape_street.name_id = "heist_escape_street_hl"
tweak_data.narrative.jobs.escape_street.briefing_id = "heist_escape_street_briefing"
tweak_data.narrative.jobs.escape_street.contact = "escape_days"
tweak_data.narrative.jobs.escape_street.region = "street"
tweak_data.narrative.jobs.escape_street.chain = {
		{
			level_id = "escape_street",
			type_id = "heist_type_assault",
			type = "d",
		}
	}

tweak_data.narrative.jobs.escape_park_day = deep_clone(tweak_data.narrative.jobs.escape_street)
tweak_data.narrative.jobs.escape_park_day.name_id = "heist_escape_park_day_hl"
tweak_data.narrative.jobs.escape_park_day.briefing_id = "heist_escape_park_briefing"
tweak_data.narrative.jobs.escape_park_day.contact = "escape_days"
tweak_data.narrative.jobs.escape_park_day.region = "street"
tweak_data.narrative.jobs.escape_park_day.chain = {
		{
			level_id = "escape_park_day",
			type_id = "heist_type_assault",
			type = "d",
		}
	}

tweak_data.narrative.jobs.escape_park = deep_clone(tweak_data.narrative.jobs.escape_street)
tweak_data.narrative.jobs.escape_park.name_id = "heist_escape_park_hl"
tweak_data.narrative.jobs.escape_park.briefing_id = "heist_escape_park_briefing"
tweak_data.narrative.jobs.escape_park.contact = "escape_days"
tweak_data.narrative.jobs.escape_park.region = "street"
tweak_data.narrative.jobs.escape_park.chain = {
		{
			level_id = "escape_park",
			type_id = "heist_type_assault",
			type = "d",
		}
	}

tweak_data.narrative.jobs.escape_overpass = deep_clone(tweak_data.narrative.jobs.escape_street)
tweak_data.narrative.jobs.escape_overpass.name_id = "heist_escape_overpass_hl"
tweak_data.narrative.jobs.escape_overpass.briefing_id = "heist_escape_overpass_briefing"
tweak_data.narrative.jobs.escape_overpass.contact = "escape_days"
tweak_data.narrative.jobs.escape_overpass.region = "street"
tweak_data.narrative.jobs.escape_overpass.chain = {
		{
			level_id = "escape_overpass",
			type_id = "heist_type_assault",
			type = "d",
		}
	}

tweak_data.narrative.jobs.escape_garage = deep_clone(tweak_data.narrative.jobs.escape_street)
tweak_data.narrative.jobs.escape_garage.name_id = "heist_escape_garage_hl"
tweak_data.narrative.jobs.escape_garage.briefing_id = "heist_escape_garage_briefing"
tweak_data.narrative.jobs.escape_garage.contact = "escape_days"
tweak_data.narrative.jobs.escape_garage.region = "street"
tweak_data.narrative.jobs.escape_garage.chain = {
		{
			level_id = "escape_garage",
			type_id = "heist_type_assault",
			type = "d",
		}
	}

tweak_data.narrative.jobs.escape_cafe_day = deep_clone(tweak_data.narrative.jobs.escape_street)
tweak_data.narrative.jobs.escape_cafe_day.name_id = "heist_escape_cafe_day_hl"
tweak_data.narrative.jobs.escape_cafe_day.briefing_id = "heist_escape_cafe_briefing"
tweak_data.narrative.jobs.escape_cafe_day.contact = "escape_days"
tweak_data.narrative.jobs.escape_cafe_day.region = "street"
tweak_data.narrative.jobs.escape_cafe_day.chain = {
		{
			level_id = "escape_cafe_day",
			type_id = "heist_type_assault",
			type = "d",
		}
	}

tweak_data.narrative.jobs.escape_cafe = deep_clone(tweak_data.narrative.jobs.escape_street)
tweak_data.narrative.jobs.escape_cafe.name_id = "heist_escape_cafe_hl"
tweak_data.narrative.jobs.escape_cafe.briefing_id = "heist_escape_cafe_briefing"
tweak_data.narrative.jobs.escape_cafe.contact = "escape_days"
tweak_data.narrative.jobs.escape_cafe.region = "street"
tweak_data.narrative.jobs.escape_cafe.chain = {
		{
			level_id = "escape_cafe",
			type_id = "heist_type_assault",
			type = "d",
		}
	}

table.insert(tweak_data.narrative._jobs_index, "escape_street")
table.insert(tweak_data.narrative._jobs_index, "escape_park_day")
table.insert(tweak_data.narrative._jobs_index, "escape_park")
table.insert(tweak_data.narrative._jobs_index, "escape_overpass")
table.insert(tweak_data.narrative._jobs_index, "escape_cafe_day")
table.insert(tweak_data.narrative._jobs_index, "escape_cafe")
table.insert(tweak_data.narrative._jobs_index, "escape_garage")