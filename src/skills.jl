module Skills

using ..Classes
using ..Attaques

export Skill, Fireball, PowerStrike, Heal, AOE, use_skill

abstract type Skill end
struct Fireball <: Skill; cost_pm::Int; power::Int; end
struct PowerStrike <: Skill; cost_pm::Int; power::Int; end
struct Heal <: Skill; cost_pm::Int; amount::Int; end
struct AOE <: Skill; cost_pm::Int; power::Int; radius::Int; end

function use_skill(att::Classe, skl::Skill, target; kwargs...)
    println("$(att.nom) utilise une compétence non spécifiée pour ce type.")
    return 0
end

# Exemple : Fireball (Mage)
function use_skill(att::Mage, skl::Fireball, def::Classe; dmg_mat=Dict(), skill_usage=Dict(), kwargs...)
    if att.stats.PM < skl.cost_pm
        println("$(att.nom) n'a pas assez de PM pour Fireball.")
        return 0
    end
    att.stats.PM -= skl.cost_pm
    effective_def = Int(round(def.stats.DEFENSE * 0.7))
    base_atk = skl.power + Int(round(att.stats.ATK*0.5))
    dmg, crit = compute_damage(base_atk, effective_def, sd_frac=0.05, crit_chance=0.22, crit_mult=2.2)
    def.stats.PV = max(def.stats.PV - dmg, 0)
    println("$(att.nom) lance Fireball sur $(def.nom) => $dmg dégâts" * (crit ? " (CRIT!)" : ""))
    skill_usage[string(typeof(skl))] = get(skill_usage,string(typeof(skl)),0) + 1
    return dmg
end

function use_skill(att::Chevalier, skl::PowerStrike, def::Classe; dmg_mat::Dict=Dict{Tuple{String,String},Int}(), skill_usage::Dict=Dict{String,Int}(), allies=nothing, enemies=nothing)
    if att.stats.PM < skl.cost_pm
        println("$(att.nom) n'a pas assez de PM pour PowerStrike.")
        return 0
    end
    att.stats.PM -= skl.cost_pm
    base_atk = skl.power + Int(round(att.stats.ATK*0.7))
    dmg, crit = compute_damage(base_atk, def.stats.DEFENSE, sd_frac=0.03, crit_chance=0.18, crit_mult=1.7)
    def.stats.PV = max(def.stats.PV - dmg, 0)
    println("$(att.nom) utilise PowerStrike sur $(def.nom) => $dmg dégâts" * (crit ? " (CRIT!)" : ""))
    acls=string(typeof(att)); dcls=string(typeof(def))
    dmg_mat[(acls,dcls)] = get(dmg_mat,(acls,dcls),0) + dmg
    skill_usage[string(typeof(skl))] = get(skill_usage,string(typeof(skl)),0) + 1
    return dmg
end

end # module Skills
