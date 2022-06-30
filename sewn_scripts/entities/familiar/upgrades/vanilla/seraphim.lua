local Random = require("sewn_scripts.helpers.random")

local Seraphim = { }

Sewn_API:MakeFamiliarAvailable(FamiliarVariant.SERAPHIM, CollectibleType.COLLECTIBLE_SERAPHIM)

Sewn_API:AddFamiliarDescription(
    FamiliarVariant.SERAPHIM,
    "Has a chance to fire Holy Tears (from {{Collectible"..CollectibleType.COLLECTIBLE_HOLY_LIGHT.."}})",
    "{{ArrowUp}} Tears Up#{{ArrowUp}} Higher chance to fire Holy Tears", nil, "Seraphim"
)
Sewn_API:AddFamiliarDescription(
    FamiliarVariant.SERAPHIM,
    "概率发射圣光眼泪",
    "更高概率发射圣光眼泪 #{{ArrowUp}} 射速提升", nil, "撒拉弗","zh_cn"
)
Sewn_API:AddFamiliarDescription(
    FamiliarVariant.SACRIFICIAL_DAGGER,
    "{{ArrowUp}} Малый урон +#Наносит кровоток",
    "{{ArrowUp}} Урон +", nil, "Жертвенный Кинжал", "ru"
)
Sewn_API:AddFamiliarDescription(
    FamiliarVariant.SERAPHIM,
    "Peut tirer une larme sacrée (comme avec \"Saint Éclat\" {{Collectible"..CollectibleType.COLLECTIBLE_HOLY_LIGHT.."}})",
    "{{ArrowUp}} Débit#{{ArrowUp}} Augmente les chances de tirer une larme sacrée", nil, "Séraphin", "fr"
)
Sewn_API:AddFamiliarDescription(
    FamiliarVariant.SERAPHIM,
    "Tiene una probabilidad de disparar Lágrimas Sagradas",
    "Tiene una probabilidad más alta de disparar Lágrimas Sagradas#{{ArrowUp}} + Lágrimas", nil, "Serafín", "spa"
)

Sewn_API:AddEncyclopediaUpgrade(
    FamiliarVariant.SERAPHIM,
    "Have 10% chance to fire a Holy Tear#Holy Tear spawn a light beam on contact",
    "Have 15% chance to fire a Holy Tear#Tears Up (x1.24)"
)

Seraphim.Stats = {
    TearRateBonus = {
        [Sewn_API.Enums.FamiliarLevel.SUPER] = 0,
        [Sewn_API.Enums.FamiliarLevel.ULTRA] = 5
    },
    HolyLightChance = {
        [Sewn_API.Enums.FamiliarLevel.SUPER] = 10,
        [Sewn_API.Enums.FamiliarLevel.ULTRA] = 15
    }
}

function Seraphim:OnFireTear(familiar, tear)
    local fData = familiar:GetData()
    familiar.FireCooldown = familiar.FireCooldown - Seraphim.Stats.TearRateBonus[Sewn_API:GetLevel(fData)]

    if Random:CheckRoll(Seraphim.Stats.HolyLightChance[Sewn_API:GetLevel(fData)], familiar:GetDropRNG()) then
        tear.TearFlags = tear.TearFlags | TearFlags.TEAR_LIGHT_FROM_HEAVEN
    end
end

Sewn_API:AddCallback(Sewn_API.Enums.ModCallbacks.POST_FAMILIAR_FIRE_TEAR, Seraphim.OnFireTear, FamiliarVariant.SERAPHIM)