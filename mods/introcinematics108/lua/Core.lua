function _include(file)
    dofile(VisualOverhaulCore.PATHS.lua .. file)
end

if not Log then
    function Log(...) end
end


if not VisualOverhaulCore then
    VisualOverhaulCore = {}

    VisualOverhaulCore.PATHS = {
        assets = ModPath .. "assets/",
        lua = ModPath .. "lua/",
        locales = ModPath .. "locales/"
    }

    VisualOverhaulCore.HOOKS = {
        ["lib/setups/setup"] = {
            "managers/HologramManager.lua",
            "managers/IntroCinematicManager.lua",
        },
        ["lib/states/ingamewaitingforplayers"] = "managers/IntroCinematicManager.lua",
        ["lib/managers/hud/hudmissionbriefing"] = "managers/IntroCinematicManager.lua",
        ["lib/managers/hud/hudblackscreen"] = "managers/IntroCinematicManager.lua",
        ["lib/managers/voicebriefingmanager"] = "managers/IntroCinematicManager.lua",
        ["lib/tweak_data/levelstweakdata"] = "tweak_data/LevelsTweakData.lua"
    }

    VisualOverhaulCore.managers = {}

    VisualOverhaulCore.global = {}

    function VisualOverhaulCore:process_requires()
        _include("tweak_data/Globals.lua")

        if RequiredScript then
            local hook_list = VisualOverhaulCore.HOOKS[RequiredScript:lower()]
            if hook_list then
                if type(hook_list) == "string" then
                    hook_list = {hook_list}
                end
                for _, file_name in pairs(hook_list) do
                    dofile(VisualOverhaulCore.PATHS.lua .. file_name)
                end
            end
        end
    end   
end

VisualOverhaulCore:process_requires()

if RequiredScript:lower() == "core/lib/setups/coresetup" then

    -- Global updater

    Hooks:PostHook(CoreSetup, "__update", "F_"..Idstring("PostHook:CoreSetup:__update"):key(), function(self,t,dt)
        if VisualOverhaulCore.managers.holograms then
            VisualOverhaulCore.managers.holograms:update(t,dt)
        end
    end)
end