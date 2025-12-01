# Déclare un type abstrait pour représenter une compétence
abstract type Skill end

# Déclaration de la compétence Fireball : coûte des PM et inflige des dégâts
struct Fireball <: Skill
    cost_pm::Int
    power::Int
end

# Déclaration de la compétence PowerStrike : coûte des PM et inflige des dégâts
struct PowerStrike <: Skill
    cost_pm::Int
    power::Int
end

# Méthode par défaut : utilise une compétence non-spécifiée pour une combinaison donnée
function use_skill(att::Role, skl::Skill, target; kwargs...)
    println("$(att.nom) utilise une compétence non spécifiée pour ce type.")
    return 0
end

# Spécialisation : Mage qui lance Fireball sur n'importe quel ennemi
function use_skill(att::Mage, skl::Fireball, def::Role; dmg_mat=Dict(), skill_usage=Dict())
    
    # Vérifie si le mage a assez de PM pour lancer la boule de feu
    if att.stats.PM < skl.cost_pm
        println("$(att.nom) n'a pas assez de PM pour Fireball.")
        return 0
    end

    # Enlève le coût en PM
    att.stats.PM -= skl.cost_pm

    # Défense réduite de la cible (exemple: l'armure protège moins contre le feu)
    effective_def = Int(round(def.stats.DEFENSE * 0.7))

    # Puissance = skill + moitié attaque du mage
    base_atk = skl.power + Int(round(att.stats.ATK*0.5))

    dmg, crit = compute_damage(base_atk, effective_def, sd_frac=0.05, crit_chance=0.22, crit_mult=2.2)

    # Met à jour les PV de la cible, jamais négatif
    def.stats.PV = max(def.stats.PV - dmg, 0)

    # Affiche le résultat et mentionne si critique
    println("$(att.nom) lance Fireball sur $(def.nom) => $dmg dégâts" * (crit ? " (CRIT!)" : ""))

    # Met à jour le suivi d'utilisation des skills
    skill_usage[string(typeof(skl))] = get(skill_usage,string(typeof(skl)),0) + 1

    return dmg
end

function use_skill(att::Chevalier, skl::PowerStrike, def::Role; dmg_mat=Dict(), skill_usage=Dict())
    
    if att.stats.PM < skl.cost_pm
        println("$(att.nom) n'a pas assez de PM pour PowerStrike.")
        return 0
    end

    # Consomme les PM
    att.stats.PM -= skl.cost_pm
    
    # Puissance = skill + grosse partie de l'attaque du perso
    base_atk = skl.power + Int(round(att.stats.ATK*0.7))

    dmg, crit = compute_damage(base_atk, def.stats.DEFENSE, sd_frac=0.03, crit_chance=0.18, crit_mult=1.8)

    # Met à jour les PV
    def.stats.PV = max(def.stats.PV - dmg, 0)

    println("$(att.nom) utilise PowerStrike sur $(def.nom) => $dmg dégâts" * (crit ? " (CRIT!)" : ""))

    # Met à jour la matrice de dégâts
    acls=string(typeof(att)); dcls=string(typeof(def))

    dmg_mat[(acls,dcls)] = get(dmg_mat,(acls,dcls),0) + dmg

    # Met à jour le suivi d'utilisation
    skill_usage[string(typeof(skl))] = get(skill_usage,string(typeof(skl)),0) + 1

    return dmg
end
