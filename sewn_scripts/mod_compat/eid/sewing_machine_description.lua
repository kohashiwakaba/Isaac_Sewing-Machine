local FamiliarDescription = require("sewn_scripts.mod_compat.eid.familiar_description")
local MachineDataManager = require("sewn_scripts.core.machine_data_manager")
local Enums = require("sewn_scripts.core.enums")
local EIDManager = require("sewn_scripts.mod_compat.eid.eid_manager")

local SewingMachineDescription = { }

function SewingMachineDescription:SetMachineDescription(machine)
    local mData = MachineDataManager:GetMachineData(machine)
    local decription = SewingMachineDescription:GetMachineDescription(machine)
    EIDManager:SetEIDFor(machine, decription.Name, decription.Description)
    
    mData.EID_Description = decription
end
function SewingMachineDescription:ResetMachineDescription(machine)
    EIDManager:ResetEIDFor(machine)
end

function SewingMachineDescription:GetMachineDescription(machine)
    local mData = MachineDataManager:GetMachineData(machine)

    if mData.Sewn_currentFamiliarVariant == nil then
        return
    end

    local info = FamiliarDescription:GetInfoForFamiliar(mData.Sewn_currentFamiliarVariant)

    -- No description for the familiar
    if info == nil then return end

    local upgradeDescription = mData.Sewn_currentFamiliarLevel == Enums.FamiliarLevel.NORMAL and info.SuperUpgrade or info.UltraUpgrade
    local levelCrown = mData.Sewn_currentFamiliarLevek == Enums.FamiliarLevel.NORMAL and "Super" or "Ultra"

    return {
        Name = "{{SewnCrown" .. levelCrown .. "}}" .. info.Name .." {{SewnSewingMachine}}",
        Description = upgradeDescription
    }
end

return SewingMachineDescription