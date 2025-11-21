# Structure pour stocker les informations d'une action pendant le combat
struct AttackLog
    round::Int
    actor::String
    action::String
    target::String
    damage::Int
    actor_PV::Int
    target_PV::Int
end

# Fonction pour afficher les stats d'un personnage
function afficher_stats(c::Role)
    s = c.stats
    println("$(c.nom): PV=$(s.PV), PM=$(s.PM), ATK=$(s.ATK), VIT=$(s.VITESSE), DEF=$(s.DEFENSE)")
end

# Fonction par défaut pour choisir l'action d'un personnage générique : attaque normale
choose_action(actor::Role, defender::Role) = (:attack, nothing)

# Choix d'action spécifique pour le Mage : lance Fireball si PM suffisant, sinon attaque
choose_action(actor::Mage, defender::Role) = actor.stats.PM ≥ 10 ? (:skill, Fireball(10, 30)) : (:attack, nothing)

# Choix d'action spécifique pour le Chevalier : 20% de chance de lancer PowerStrike si PM suffisant
choose_action(actor::Chevalier, defender::Role) = (actor.stats.PM ≥ 8 && rand() < 0.2) ? (:skill, PowerStrike(8, 20)) : (:attack, nothing)

# Fonction principale de combat entre deux personnages
function combat(j1::Role, j2::Role; max_rounds=100, dmg_mat=Dict(), skill_usage=Dict())
    
    # Tableau pour stocker les logs d'action
    logs = AttackLog[]
    
    # Compteur de tours
    round = 1

    # Boucle de combat : continue tant que les deux personnages sont en vie et max_rounds non atteint
    while j1.stats.PV>0 && j2.stats.PV>0 && round ≤ max_rounds
        println("\n=== Tour $round ===")

        # Applique les effets de statut en début de tour (shield, stun, regen, poison, etc.)
        shield1, stunned1, _, _ = apply_effects_round!(j1)
        shield2, stunned2, _, _ = apply_effects_round!(j2)

        # Détermine l'ordre des actions selon la vitesse
        order = (j1.stats.VITESSE >= j2.stats.VITESSE) ? (j1, j2) : (j2, j1)

        # Boucle sur chaque personnage dans l'ordre de vitesse
        for actor in order

            # Si un personnage est mort, on arrête la boucle
            if j1.stats.PV <= 0 || j2.stats.PV <= 0
                break
            end

            # Détermine la cible de l'acteur
            defender = actor === j1 ? j2 : j1

            # Récupère le bouclier actif du défenseur
            def_shield = defender === j1 ? shield1 : shield2

            # Vérifie si l'acteur est étourdi
            is_stunned = actor === j1 ? stunned1 : stunned2

            # Le personnage étourdi perd simplement son tour
            if is_stunned
                println("$(actor.nom) est étourdi et rate son tour.")
                push!(logs, AttackLog(round, actor.nom, "Stunned", "", 0, actor.stats.PV, defender.stats.PV))
                continue
            end

            # Choix de l’action : attaque ou compétence
            action, payload = choose_action(actor, defender)

            # PV du défenseur avant l’action (pour calculer les dégâts réels)
            before = defender.stats.PV

            if action == :skill
                # Utilisation d’une compétence
                use_skill(actor, payload, defender; dmg_mat=dmg_mat, skill_usage=skill_usage)
            else
                # Attaque normale
                attaquer(actor, defender; shield=def_shield, dmg_mat=dmg_mat, skill_usage=skill_usage)
            end

            # Calcul des dégâts infligés
            dmg = before - defender.stats.PV

            # Log de l’action
            push!(logs, AttackLog(
                round,
                actor.nom,
                string(action),
                defender.nom,
                dmg,
                actor.stats.PV,
                defender.stats.PV
            ))

            # Affichage des stats actuelles
            afficher_stats(j1)
            afficher_stats(j2)
        end

        # Passe au tour suivant
        round += 1
    end

    # Détermine le gagnant final
    winner = j1.stats.PV > 0 ? j1.nom : j2.nom

    return winner, logs
end