global function AdrenalineShot_Init

void function AdrenalineShot_Init()
{
    AddCallback_OnNPCKilled( AdrenalineShot_OnNPCKilled );
}

void function AdrenalineShot_OnNPCKilled( entity npc, entity attacker, var damageInfo )
{
    if (!attacker.IsPlayer()) return
    if (attacker.IsTitan()) return
    
    if (Roguelike_GetItemCount(attacker, "adrenaline_shot") <= 0) return

    print("Applying speed boost for " + attacker.GetPlayerName())
    float duration = Roguelike_LinearChanceFunc(0.5, 0.25)(Roguelike_GetItemCount(attacker, "adrenaline_shot"))
    StatusEffect_AddTimed( attacker, eStatusEffect.speed_boost, 0.35, duration, 0.5 )
}