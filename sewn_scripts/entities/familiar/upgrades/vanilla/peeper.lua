local FindCloserNpc = require("sewn_scripts.helpers.find_closer_npc")
local Delay = require("sewn_scripts.helpers.delay")
local ShootTearsCircular = require("sewn_scripts.helpers.shoot_tears_circular")
local Globals = require("sewn_scripts.core.globals")
local CColor = require("sewn_scripts.helpers.ccolor")

local Peeper = { }

Sewn_API:MakeFamiliarAvailable(FamiliarVariant.PEEPER, CollectibleType.COLLECTIBLE_PEEPER)


Peeper.Stats = {
    AmountTears = 5,
    TearDamage = 5,
    TearCooldownMax = 200,
    TearCooldownMin = 60,
}

Sewn_API:AddFamiliarDescription(
    FamiliarVariant.PEEPER,
    "Fire ".. Peeper.Stats.AmountTears .." tears in random directions every few seconds#Tries to home onto close enemies",
    "Spawn an additional Peeper Eye {{Collectible".. CollectibleType.COLLECTIBLE_PEEPER .."}}#The new Peeper Eye is upgraded as well#With Inner Eye {{Collectible".. CollectibleType.COLLECTIBLE_INNER_EYE .."}} spawns an additional Peeper Eye", nil, "The Peeper"
)
Sewn_API:AddFamiliarDescription(
    FamiliarVariant.PEEPER,
    "每隔一段时间向不同的方向发射".. Peeper.Stats.AmountTears .."5颗眼泪 #在接近敌人时有短距离的跟踪效果",
    "额外生成一个 {{Collectible".. CollectibleType.COLLECTIBLE_PEEPER .."}} 窥眼 #新的窥眼同样具有超级形态的效果 #如果持有 {{Collectible".. CollectibleType.COLLECTIBLE_INNER_EYE .."}} 内眼，则再额外生成一个窥眼", nil, "窥眼","zh_cn"
)
Sewn_API:AddFamiliarDescription(
    FamiliarVariant.PEEPER,
    "Стреляет ".. Peeper.Stats.AmountTears .." слёз в каждом направлении каждые несколько секунд#Старается наводиться на врагов",
    "Спавнит дополнительное Моргало {{Collectible".. CollectibleType.COLLECTIBLE_PEEPER .."}}#Новое Моргало также улучшено#С Внутренним Глазом {{Collectible".. CollectibleType.COLLECTIBLE_INNER_EYE .."}} спавнит также третье Моргало", nil, "Моргало", "ru"
)
Sewn_API:AddFamiliarDescription(
    FamiliarVariant.PEEPER,
    "Tire parfois ".. Peeper.Stats.AmountTears .." larmes en cercle#Il est légerement attiré par les ennemis a proximité",
    "Invoque un deuxième Œil Baladeur {{Collectible".. CollectibleType.COLLECTIBLE_PEEPER .."}} amélioré#Invoque un Œil Baladeur supplémentaire si Isaac a \"Le Troisième Œeil\" {{Collectible".. CollectibleType.COLLECTIBLE_INNER_EYE .."}}", nil, "Œil Baladeur", "fr"
)
Sewn_API:AddFamiliarDescription(
    FamiliarVariant.PEEPER,
    "Dispara ".. Peeper.Stats.AmountTears .." lágrimas en diferentes direcciones cada varios segundos.#Intenta acercarse a los enemigos",
    "Spawnea un Ojo de Meador adicional{{Collectible".. CollectibleType.COLLECTIBLE_PEEPER .."}}#El nuevo Ojo de Meador también se mejora.#Con el Ojo Interior {{Collectible".. CollectibleType.COLLECTIBLE_INNER_EYE .."}}, spawnea dos Ojos de Meador", nil, "Meador", "spa"
)

function Peeper:OnFamiliarUpgraded(familiar, isPermanentUpgrade)
    local fData = familiar:GetData()
    fData.Sewn_peeper_tearCooldown = familiar:GetDropRNG():RandomInt(Peeper.Stats.TearCooldownMax - Peeper.Stats.TearCooldownMin) + Peeper.Stats.TearCooldownMin
    Sewn_API:AddCrownOffset(familiar, Vector(0, 5))
end

function Peeper:OnFamiliarUpdate(familiar)
    local fData = familiar:GetData()

    local center = familiar.Position + familiar.Velocity * 10
    local closerNpc = FindCloserNpc(center, 50)

    if closerNpc ~= nil then
        local velocityMagnitude = familiar.Velocity:Length()
        familiar.Velocity = (familiar.Velocity:Normalized() + (closerNpc.Position - familiar.Position):Normalized() * 0.2):Normalized() * velocityMagnitude
    end

    if Globals.Room:IsClear() then
        return
    end

    if fData.Sewn_peeper_tearCooldown == 0 then
        ShootTearsCircular(familiar, Peeper.Stats.AmountTears, TearVariant.BLOOD, nil, nil, Peeper.Stats.TearDamage, TearFlags.TEAR_SPECTRAL)
        fData.Sewn_peeper_tearCooldown = familiar:GetDropRNG():RandomInt(Peeper.Stats.TearCooldownMax - Peeper.Stats.TearCooldownMin) + Peeper.Stats.TearCooldownMin
    elseif fData.Sewn_peeper_tearCooldown > 0 then
        fData.Sewn_peeper_tearCooldown = fData.Sewn_peeper_tearCooldown - 1
    end
end

function Peeper:OnFamiliarUpgraded_Ultra(familiar, isPermanentUpgrade)
    local fData = familiar:GetData()
    fData.Sewn_peeper_additionalEyes = { }
    fData.Sewn_peeper_hasInnerEye = familiar.Player:HasCollectible(CollectibleType.COLLECTIBLE_INNER_EYE)
    
    Delay:DelayFunction(function()
        familiar.Player:AddCacheFlags(CacheFlag.CACHE_FAMILIARS)
        familiar.Player:EvaluateItems()
    end, 1)
end

function Peeper:OnFamiliarUpdate_Ultra(familiar)
    local fData = familiar:GetData()
    local hasInnerEye = familiar.Player:HasCollectible(CollectibleType.COLLECTIBLE_INNER_EYE)
    if fData.Sewn_peeper_hasInnerEye ~= hasInnerEye then
        fData.Sewn_peeper_hasInnerEye = hasInnerEye
        
        familiar.Player:AddCacheFlags(CacheFlag.CACHE_FAMILIARS)
        familiar.Player:EvaluateItems()
    end
end

function Peeper:EvaluateFamiliarCache(familiar, player)
    local fData = familiar:GetData()
    
    local countPeeper = familiar.Player:GetCollectibleNum(CollectibleType.COLLECTIBLE_PEEPER)
    local amountOfAdditionalEyes = fData.Sewn_peeper_hasInnerEye and 2 or 1
    
    local peeperEyesCopies = Isaac.FindByType(familiar.Type, familiar.Variant, 1, false, false)
    for i, additionalEye in ipairs(peeperEyesCopies) do
        additionalEye:Remove()
    end

    familiar.Player:CheckFamiliar(familiar.Variant, countPeeper, familiar:GetDropRNG())

    Delay:DelayFunction(function(_)
        for i = 1, amountOfAdditionalEyes do
            local newPeeper = Isaac.Spawn(familiar.Type, familiar.Variant, 1, familiar.Position, Globals.V0, familiar.Player)
            local newFData = newPeeper:GetData()
            newFData.Sewn_peeper_isAddtionalPeeperEye = true
            newFData.Sewn_noUpgrade = Sewn_API.Enums.NoUpgrade.ANY
            
            Sewn_API:UpFamiliar(newPeeper, Sewn_API.Enums.FamiliarLevel.SUPER)

            --sewnFamiliars:upPeeper(newPeeper)
            Sewn_API:HideCrown(newPeeper, true)
            newPeeper:SetColor(CColor(1,0.6,0.6,0.9), -1, 2, false, false)
            
            table.insert(fData.Sewn_peeper_additionalEyes, newPeeper)
        end
    end)
end
function Peeper:LoseUpgrade(familiar, losePermanentUpgrade)
    familiar.Player:AddCacheFlags(CacheFlag.CACHE_FAMILIARS)
    familiar.Player:EvaluateItems()
end

Sewn_API:AddCallback(Sewn_API.Enums.ModCallbacks.ON_FAMILIAR_UPGRADED, Peeper.OnFamiliarUpgraded, FamiliarVariant.PEEPER)
Sewn_API:AddCallback(Sewn_API.Enums.ModCallbacks.FAMILIAR_UPDATE, Peeper.OnFamiliarUpdate, FamiliarVariant.PEEPER)

Sewn_API:AddCallback(Sewn_API.Enums.ModCallbacks.ON_FAMILIAR_LOSE_UPGRADE, Peeper.LoseUpgrade, FamiliarVariant.PEEPER)
Sewn_API:AddCallback(Sewn_API.Enums.ModCallbacks.ON_FAMILIAR_UPGRADED, Peeper.OnFamiliarUpgraded_Ultra, FamiliarVariant.PEEPER, Sewn_API.Enums.FamiliarLevelFlag.FLAG_ULTRA)
Sewn_API:AddCallback(Sewn_API.Enums.ModCallbacks.FAMILIAR_UPDATE, Peeper.OnFamiliarUpdate_Ultra, FamiliarVariant.PEEPER, Sewn_API.Enums.FamiliarLevelFlag.FLAG_ULTRA)
Sewn_API:AddCallback(Sewn_API.Enums.ModCallbacks.FAMILIAR_EVALUATE_CACHE, Peeper.EvaluateFamiliarCache, FamiliarVariant.PEEPER, Sewn_API.Enums.FamiliarLevelFlag.FLAG_ULTRA, CacheFlag.CACHE_FAMILIARS)