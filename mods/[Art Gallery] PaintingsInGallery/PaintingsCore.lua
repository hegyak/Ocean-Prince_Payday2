--Replaces the sequence manager with the modified one.

Hooks:Add("BeardLibCreateScriptDataMods", "MorePaintingsCallBeardLibSequenceFuncs", function()
BeardLib:ReplaceScriptData(Path:Combine(self.ModPath, "paint.custom_xml", "custom_xml", "units/payday2/architecture/com_int_gallery/com_int_gallery_wall_painting_bars", "sequence_manager", true)
end)
