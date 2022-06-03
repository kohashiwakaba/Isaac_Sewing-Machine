local Debug = require("sewn_scripts.debug.debug")
local Globals = require("sewn_scripts.core.globals")
local ShootTearsCircular = require("sewn_scripts.helpers.shoot_tears_circular")

local Hushy = { }

Hushy.Stats = {
    AmountCircleTears = {
        [Sewn_API.Enums.FamiliarLevel.SUPER] = 15,
        [Sewn_API.Enums.FamiliarLevel.ULTRA] = 15
    },
    CircleTearsDamage = {
        [Sewn_API.Enums.FamiliarLevel.SUPER] = 2.5,
        [Sewn_API.Enums.FamiliarLevel.ULTRA] = 2.5
    },
    AttackCircleCooldown = {
        [Sewn_API.Enums.FamiliarLevel.SUPER] = 50,
        [Sewn_API.Enums.FamiliarLevel.ULTRA] = 50
    },
    CollisionDamageBonusMultiplier = {
        [Sewn_API.Enums.FamiliarLevel.SUPER] = 1.5,
        [Sewn_API.Enums.FamiliarLevel.ULTRA] = 1.5
    },
    MinisaacCooldown = function(familiar, amountSpawnMinisaac)
        return 300
    end,
}

Sewn_API:MakeFamiliarAvailable(FamiliarVariant.HUSHY, CollectibleType.COLLECTIBLE_HUSHY)

Sewn_API:AddFamiliarDescription(
    FamiliarVariant.HUSHY,
    "{{ArrowUp}} Damage Up",
    "{{ArrowUp}} Damage Up", nil, "Hushy"
)

local function HandleAttackCircleTears(familiar)
    local fData = familiar:GetData()
    local level = Sewn_API:GetLevel(fData)
    
    if fData.Sewn_hushy_circleAttackCooldown > 0 then
        fData.Sewn_hushy_circleAttackCooldown = fData.Sewn_hushy_circleAttackCooldown - 1
        return
    end

    --[[
    local amountTears = Hushy.Stats.AmountCircleTears[level]
    local tearsDamage = Hushy.Stats.CircleTearsDamage[level]
    ShootTearsCircular(familiar, amountTears, TearVariant.BLUE, nil, tearsDamage, nil, TearFlags.TEAR_SPECTRAL | TearFlags.TEAR_CONTINUUM)
    --]]

    local amountTears = Hushy.Stats.AmountCircleTears[level]
    local tearsDamage = Hushy.Stats.CircleTearsDamage[level]
    local attackCooldown = Hushy.Stats.AttackCircleCooldown[level]

    if fData.Sewn_hushy_circleAttackFiredTears < amountTears then
        local normalizedDirection = Vector(
            math.cos((math.pi * 2) / amountTears * fData.Sewn_hushy_circleAttackFiredTears),
            math.sin((math.pi * 2) / amountTears * fData.Sewn_hushy_circleAttackFiredTears)
        ):Normalized()

        Debug:RenderVector(normalizedDirection * 7, "normalizedDirection")

        local bullet = Isaac.Spawn(EntityType.ENTITY_PROJECTILE, ProjectileVariant.PROJECTILE_TEAR, 0, familiar.Position, normalizedDirection * 5, familiar):ToProjectile()
        bullet:AddProjectileFlags(ProjectileFlags.HIT_ENEMIES | ProjectileFlags.NO_WALL_COLLIDE | ProjectileFlags.SINE_VELOCITY | ProjectileFlags.CONTINUUM | ProjectileFlags.CANT_HIT_PLAYER)
        bullet.CollisionDamage = tearsDamage
        bullet.FallingAccel = -0.075
        
        fData.Sewn_hushy_circleAttackFiredTears = fData.Sewn_hushy_circleAttackFiredTears + 1
    else
        fData.Sewn_hushy_circleAttackCooldown = attackCooldown
        fData.Sewn_hushy_circleAttackFiredTears = 0
    end
end

local function SpawnMinisaac(familiar)
    local fData = familiar:GetData()
    
    if REPENTANCE == false then
        familiar.Player:AddMinisaac(familiar.Position, true)
    else
        local blueBoil = Isaac.Spawn(EntityType.ENTITY_HUSH_BOIL, 0, 0, familiar.Position, Globals.V0, familiar)
        blueBoil:AddEntityFlags(EntityFlag.FLAG_APPEAR | EntityFlag.FLAG_CHARM | EntityFlag.FLAG_NO_TARGET | EntityFlag.FLAG_FRIENDLY)
    end

    fData.Sewn_hushy_roomMinisaacSpawned = fData.Sewn_hushy_roomMinisaacSpawned + 1
end

function Hushy:FamiliarInit(familiar)
    local fData = familiar:GetData()
    local level = Sewn_API:GetLevel(fData)
    fData.Sewn_hushy_circleAttackCooldown = Hushy.Stats.AttackCircleCooldown[level]
    fData.Sewn_hushy_circleAttackFiredTears = 0
    fData.Sewn_hushy_roomMinisaacSpawned = 0
    fData.Sewn_hushy_minisaacCooldown = Hushy.Stats.MinisaacCooldown(familiar, fData.Sewn_hushy_roomMinisaacSpawned)
end

function Hushy:OnFamiliarUpdate(familiar)
    local player = familiar.Player

    if player:GetShootingInput():LengthSquared() > 0 then
        local fData = familiar:GetData()
        HandleAttackCircleTears(familiar)

        if Sewn_API:IsUltra(fData) then
            if Globals.Room:GetAliveEnemiesCount() > 0 then
                if fData.Sewn_hushy_minisaacCooldown <= 0 then
                    SpawnMinisaac(familiar)
                    fData.Sewn_hushy_minisaacCooldown = Hushy.Stats.MinisaacCooldown(familiar, fData.Sewn_hushy_roomMinisaacSpawned)
                else
                    fData.Sewn_hushy_minisaacCooldown = fData.Sewn_hushy_minisaacCooldown - 1
                end
            else
                fData.Sewn_hushy_minisaacCooldown = Hushy.Stats.MinisaacCooldown(familiar, fData.Sewn_hushy_roomMinisaacSpawned)
            end
        end
    end
end

function Hushy:OnFamiliarHitNPC(familiar, npc, damageAmount, damageFlags, entityRef, damageCountdown)
    if entityRef.Type == familiar then
        local fData = familiar:GetData()
        local level = Sewn_API:GetLevel(fData)
        local damageMultiplier = Hushy.Stats.CollisionDamageBonusMultiplier[level]

        npc:TakeDamage(familiar.CollisionDamage * damageMultiplier, DamageFlag.DAMAGE_CLONES, EntityRef(familiar), damageCountdown)
    end
end

function Hushy:OnFamiliarNewRoom(familiar)
    local fData = familiar:GetData()
    fData.Sewn_hushy_roomMinisaacSpawned = 0
end


Sewn_API:AddCallback(Sewn_API.Enums.ModCallbacks.ON_FAMILIAR_UPGRADED, Hushy.FamiliarInit, FamiliarVariant.HUSHY)
Sewn_API:AddCallback(Sewn_API.Enums.ModCallbacks.POST_FAMILIAR_INIT, Hushy.FamiliarInit, FamiliarVariant.HUSHY)
Sewn_API:AddCallback(Sewn_API.Enums.ModCallbacks.FAMILIAR_UPDATE, Hushy.OnFamiliarUpdate, FamiliarVariant.HUSHY)
Sewn_API:AddCallback(Sewn_API.Enums.ModCallbacks.FAMILIAR_HIT_NPC, Hushy.OnFamiliarHitNPC, FamiliarVariant.HUSHY)
Sewn_API:AddCallback(Sewn_API.Enums.ModCallbacks.POST_FAMILIAR_NEW_ROOM, Hushy.OnFamiliarNewRoom, FamiliarVariant.HUSHY)