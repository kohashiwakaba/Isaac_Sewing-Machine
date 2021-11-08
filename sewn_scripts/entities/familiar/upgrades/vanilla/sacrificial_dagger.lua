local SacrificialDagger = { }

Sewn_API:MakeFamiliarAvailable(FamiliarVariant.SACRIFICIAL_DAGGER, CollectibleType.COLLECTIBLE_SACRIFICIAL_DAGGER)

Sewn_API:AddFamiliarDescription(
    FamiliarVariant.SACRIFICIAL_DAGGER,
    "Apply bleed effect#{{ArrowUp}} Small damage up",
    "{{ArrowUp}} Damage Up"
)

SacrificialDagger.Stats = {
    DamageBonus = {
        [Sewn_API.Enums.FamiliarLevel.SUPER] = 1,
        [Sewn_API.Enums.FamiliarLevel.ULTRA] = 4
    }
}

function SacrificialDagger:OnFamiliarHitNpc(familiar, npc, amount, flags, source, countdown)
    if npc:IsVulnerableEnemy() then
        if not npc:IsBoss() then
            npc:AddEntityFlags(EntityFlag.FLAG_BLEED_OUT)
        end
        if not (flags & DamageFlag.DAMAGE_CLONES > 0) then
            npc:TakeDamage(SacrificialDagger.Stats.DamageBonus[Sewn_API:GetLevel(familiar:GetData())], DamageFlag.DAMAGE_CLONES, EntityRef(familiar), countdown)
        end
    end
end

Sewn_API:AddCallback(Sewn_API.Enums.ModCallbacks.FAMILIAR_HIT_NPC, SacrificialDagger.OnFamiliarHitNpc, FamiliarVariant.SACRIFICIAL_DAGGER)