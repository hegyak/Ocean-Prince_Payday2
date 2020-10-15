
if not _G.GageModShop then
	_G.GageModShop = {}
	GageModShop.mod_path = ModPath
end

Hooks:Add("LocalizationManagerPostInit", "LocalizationManagerPostInit_GageModShop", function( loc )
	loc:load_localization_file( GageModShop.mod_path .. "loc/en.txt")
end)

GageModShop.dofiles = {
	"mod_shop.lua"
}

GageModShop.hook_files = {
	["lib/managers/menu/blackmarketgui"] = "lua/BlackMarketGUI.lua",
	["lib/managers/blackmarketmanager"] = "lua/BlackMarketManager.lua"
}

if not GageModShop.setup then

	for p, d in pairs(GageModShop.dofiles) do
		dofile(ModPath .. d)
	end
	GageModShop.setup = true
	log("[GageModShop] Loaded options")
end



if RequiredScript then
	local requiredScript = RequiredScript:lower()
	if GageModShop.hook_files[requiredScript] then
		dofile( ModPath .. GageModShop.hook_files[requiredScript] )
	end
end


