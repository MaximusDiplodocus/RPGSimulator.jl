struct AttackLog
    time::DateTime
    round::Int
    actor::String
    action::String
    target::String
    damage::Int
    actor_PV::Int
    target_PV::Int
end

function afficher_stats(c::Role)
    s = c.stats
    println("$(c.nom): PV=$(s.PV), PM=$(s.PM), ATK=$(s.ATK), VIT=$(s.VITESSE), DEF=$(s.DEFENSE)")
end

function choose_action(actor::Role, defender::Role)
    if actor isa Mage && actor.stats.PM ≥ 10
        return (:skill, Fireball(10, 30))
    elseif actor isa Chevalier && actor.stats.PM ≥ 8 && rand() < 0.2
        return (:skill, PowerStrike(8, 20))
    else
        return (:attack, nothing)
    end
end

function combat(j1::Role, j2::Role; max_rounds=100, dmg_mat=Dict(), skill_usage=Dict())
    logs = AttackLog[]
    round = 1
    while j1.stats.PV>0 && j2.stats.PV>0 && round ≤ max_rounds
        println("\n=== Tour $round ===")
        shield1, stunned1, _, _ = apply_effects_round!(j1)
        shield2, stunned2, _, _ = apply_effects_round!(j2)

        order = (j1.stats.VITESSE >= j2.stats.VITESSE) ? (j1, j2) : (j2, j1)
        for actor in order
            if j1.stats.PV <= 0 || j2.stats.PV <= 0
                break
            end
            defender = actor === j1 ? j2 : j1
            def_shield = defender === j1 ? shield1 : shield2
            is_stunned = actor === j1 ? stunned1 : stunned2

            if is_stunned
                println("$(actor.nom) est étourdi et rate son tour.")
                push!(logs, AttackLog(now(), round, actor.nom, "Stunned", "", 0, actor.stats.PV, defender.stats.PV))
                continue
            end

            action, payload = choose_action(actor, defender)
            before = defender.stats.PV
            if action == :skill
                use_skill(actor, payload, defender; dmg_mat=dmg_mat, skill_usage=skill_usage)
            else
                attaquer(actor, defender; shield=def_shield, dmg_mat=dmg_mat, skill_usage=skill_usage)
            end
            dmg = before - defender.stats.PV
            push!(logs, AttackLog(now(), round, actor.nom, string(action), defender.nom, dmg, actor.stats.PV, defender.stats.PV))

            afficher_stats(j1)
            afficher_stats(j2)
        end
        round += 1
    end
    winner = j1.stats.PV > 0 ? j1.nom : j2.nom
    return "Le winner est : $winner"
end
