local AvailableFamiliarManager = { }

-- Store familiars which can be upgraded in the Sewing Machine
local availableFamiliars = { }

local function GetSpriteFromCollectibleId(collectibleId)
    local collectible = Isaac.GetItemConfig():GetCollectible(collectibleId)
    if collectible ~= nil then
        return collectible.GfxFileName
    end
end

function AvailableFamiliarManager:IterateOverAvailableFamiliars(_function)
    for familiarID, data in pairs(availableFamiliars) do
        _function(familiarID, data)
    end
end

function AvailableFamiliarManager:TryMakeFamiliarAvailable(familiarVariant, collectibleID)
    if familiarVariant == nil then
        error("Can't make this familiar available for Sewing Machine")
        return
    end
    --[[
    if type(collectibleID_or_spritePath) == "string" then
        availableFamiliars[familiarVariant] = { Sprite = collectibleID_or_spritePath}
    elseif type(collectibleID_or_spritePath) == "number" then
        availableFamiliars[familiarVariant] = { Sprite = GetSpriteFromCollectibleId(collectibleID_or_spritePath)}
    end
    --]]
    availableFamiliars[familiarVariant] = { CollectibleID = collectibleID, Sprite = GetSpriteFromCollectibleId(collectibleID)}
end
function AvailableFamiliarManager:IsFamiliarAvailable(familiarVariant)
    return availableFamiliars[familiarVariant] ~= nil
end
function AvailableFamiliarManager:GetFamiliarSprite(familiarVariant)
    local default = "gfx.items.collectibles.questionmark.png"
    if availableFamiliars[familiarVariant] ~= nil then
        return availableFamiliars[familiarVariant].Sprite or default
    end
    return default
end
function AvailableFamiliarManager:GetFamiliarName(familiarVariant)
    local collectible = Isaac.GetItemConfig():GetCollectible(availableFamiliars[familiarVariant].CollectibleID)
    if collectible ~= nil then
        return collectible.Name
    end
    return "???"
end

return AvailableFamiliarManager