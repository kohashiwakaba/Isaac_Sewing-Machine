local UpgradeManager = require("sewn_scripts/core/upgrade_manager")
local MachineDataManager = require("sewn_scripts/core/machine_data_manager")
local SaveManager = require("sewn_scripts/core/save_manager")
local Delay = require("sewn_scripts/helpers/delay")

local function MC_POST_GAME_STARTED(_, isExistingRun)
    if not isExistingRun then
        UpgradeManager:ResetUpgrades()
        MachineDataManager:ResetMachinesData()
    else
        SaveManager:LoadSave()
    end
    Delay:OnGameStart(isExistingRun)
end

return MC_POST_GAME_STARTED