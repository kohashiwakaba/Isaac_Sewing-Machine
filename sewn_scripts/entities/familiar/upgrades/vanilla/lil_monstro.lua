local Random = require("sewn_scripts.helpers.random")

local LilMonstro = { }

Sewn_API:MakeFamiliarAvailable(FamiliarVariant.LIL_MONSTRO, CollectibleType.COLLECTIBLE_LIL_MONSTRO)

Sewn_API:AddFamiliarDescription(
    FamiliarVariant.LIL_MONSTRO,
    "Has a chance to fire a tooth (from Tough Love {{Collectible"..CollectibleType.COLLECTIBLE_TOUGH_LOVE.."}}",
    "Fires way more tears", nil, "Lil Monstro"
)
Sewn_API:AddFamiliarDescription(
    FamiliarVariant.LIL_MONSTRO,
    "每颗发射的眼泪有概率替换成牙齿 #牙齿造成 x3.2 伤害",
    "发射更多眼泪", nil, "萌死戳宝宝","zh_cn"
)
Sewn_API:AddFamiliarDescription(
    FamiliarVariant.LIL_MONSTRO,
    "Имеет шанс стрельнуть зубом (как от Жёсткой Любви {{Collectible"..CollectibleType.COLLECTIBLE_TOUGH_LOVE.."}}",
    "Стреляет гораздо больше слёз", nil, "Маленький Монстро", "ru"
)
Sewn_API:AddFamiliarDescription(
    FamiliarVariant.LIL_MONSTRO,
    "Peut lancer des dents (comme le \"Poing Américain\" {{Collectible"..CollectibleType.COLLECTIBLE_TOUGH_LOVE.."}}",
    "Tire beaucoup plus de larmes", nil, "P'tit Monstro", "fr"
)
Sewn_API:AddFamiliarDescription(
    FamiliarVariant.LIL_MONSTRO,
    "Hay una probabilidad de disparar un diente#El diente hara x3.2 más daño que de normal",
    "Dispara más lágrimas", nil, "Pequeño Monstro", "spa"
)

LilMonstro.Stats = {
    ToothChance = 15,
    AdditionalTearChance = 25,
}

function LilMonstro:OnFamiliarFireTear_Ultra(familiar, tear)
    if Random:CheckRoll(LilMonstro.Stats.AdditionalTearChance, familiar:GetDropRNG()) then
        local velocity = Vector(math.random() - 0.5, math.random() - 0.5) + tear.Velocity
        
        local newTear = Isaac.Spawn(EntityType.ENTITY_TEAR, tear.Variant, tear.SubType, familiar.Position, velocity, familiar):ToTear()
        --sewnFamiliars:toBabyBenderTear(familiar, newTear)
        
        newTear.FallingSpeed = tear.FallingSpeed
        newTear.FallingAcceleration = tear.FallingAcceleration
        newTear.CollisionDamage = tear.CollisionDamage
        newTear.Parent = tear.Parent
    end
end
function LilMonstro:OnFamiliarFireTear(familiar, tear)
    if Random:CheckRoll(LilMonstro.Stats.ToothChance, familiar:GetDropRNG()) then
        if tear.Variant ~= TearVariant.TOOTH then
            tear:ChangeVariant(TearVariant.TOOTH)
        end
        tear.CollisionDamage = tear.CollisionDamage * 3.2
    end
end

Sewn_API:AddCallback(Sewn_API.Enums.ModCallbacks.POST_FAMILIAR_FIRE_TEAR, LilMonstro.OnFamiliarFireTear_Ultra, FamiliarVariant.LIL_MONSTRO, Sewn_API.Enums.FamiliarLevelFlag.FLAG_ULTRA)
Sewn_API:AddCallback(Sewn_API.Enums.ModCallbacks.POST_FAMILIAR_FIRE_TEAR, LilMonstro.OnFamiliarFireTear, FamiliarVariant.LIL_MONSTRO)
