function compute_damage(base_atk::Int, def::Int; sd_frac=0.12, crit_chance=0.10, crit_mult=1.6)
    sd = max(1.0, abs(base_atk)*sd_frac)
    d = rand(Normal(base_atk, sd))
    raw = Int(round(d)) - def
    raw = max(raw, 0)
    is_crit = (rand() < crit_chance) && raw > 0
    raw = is_crit ? Int(round(raw * crit_mult)) : raw
    return raw, is_crit
end

function attaquer(att::Role, def::Role; shield::Int=0, dmg_mat=Dict(), skill_usage=Dict())
    dmg, crit = compute_damage(att.stats.ATK, def.stats.DEFENSE - shield)
    def.stats.PV = max(def.stats.PV - dmg, 0)
    println("$(att.nom) attaque $(def.nom) et inflige $dmg dégâts" * (crit ? " (CRIT!)" : ""))
    acls, dcls = string(typeof(att)), string(typeof(def))
    dmg_mat[(acls,dcls)] = get(dmg_mat,(acls,dcls),0) + dmg
    return dmg
end
