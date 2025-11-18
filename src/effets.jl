# Déclare un type abstrait pour représenter les effets de statut
abstract type StatusEffect end

# Déclaration de l'effet Poison : inflige des dégâts à chaque tour
mutable struct Poison <: StatusEffect
    remaining::Int
    dmg_per_turn::Int
end

# Déclaration de l'effet Shield : bloque une quantité fixe de dégâts à chaque tour
mutable struct Shield <: StatusEffect
    remaining::Int
    flat_block::Int
end

# Déclaration de l'effet Stun : bloque les actions du personnage pendant quelques tours
mutable struct Stun <: StatusEffect
    remaining::Int
end

# Déclaration de l'effet Regen : soigne le personnage à chaque tour
mutable struct Regen <: StatusEffect
    remaining::Int
    heal_per_turn::Int
end

# Déclaration de l'effet Bleed : inflige des dégâts à chaque tour (comme le poison)
mutable struct Bleed <: StatusEffect
    remaining::Int
    dmg_per_turn::Int
end

# Fonction pour appliquer les effets de statut à chaque tour pour un personnage
function apply_effects_round!(c::Role)
    new_effects = Any[]
    total_shield = 0
    total_poison = 0
    total_bleed = 0
    regen_amount = 0
    stunned = false

    # Parcourt chaque effet de statut actif sur le personnage
    for e in c.effects
        if e isa Poison
            total_poison += e.dmg_per_turn
            e.remaining -= 1
        elseif e isa Shield
            total_shield += e.flat_block
            e.remaining -= 1
        elseif e isa Bleed
            total_bleed += e.dmg_per_turn
            e.remaining -= 1
        elseif e isa Stun
            stunned = true
            e.remaining -= 1
        elseif e isa Regen
            regen_amount += e.heal_per_turn
            e.remaining -= 1
        end
        # Si l’effet existe encore, on le garde pour le prochain tour
        if e.remaining > 0
            push!(new_effects, e)
        end
    end

    # Met à jour la liste des effets actifs du personnage
    c.effects = new_effects

    # Applique la régénération si présente
    if regen_amount > 0
        c.stats.PV += regen_amount
        println("$(c.nom) regenère $regen_amount PV.")
    end

    # Inflige les dégâts de poison et de saignement si présents
    total_damage = total_poison + total_bleed
    if total_damage > 0
        c.stats.PV = max(c.stats.PV - total_damage, 0)
        println("$(c.nom) subit $total_damage dégâts (poison/bleed).")
    end

    # Retourne : bouclier total, état étourdi, régénération, dégâts subis
    return (total_shield, stunned, regen_amount, total_damage)
end

apply_effect!(c::Role) = apply_effects_round!(c)[1]
