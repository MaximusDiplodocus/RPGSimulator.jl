# Calcule les dégâts infligés par un attaquant à un défenseur
function compute_damage(base_atk::Int, def::Int; sd_frac=0.12, crit_chance=0.10, crit_mult=1.6)

    # Calcule l’écart type des dégâts (pour ajouter de l’aléatoire)
    sd = max(1.0, abs(base_atk)*sd_frac)

    # Tire un montant de dégâts selon une loi normale centrée en base_atk
    d = rand(Normal(base_atk, sd))

    # Arrondit les dégâts puis enlève la défense du défenseur
    raw = Int(round(d)) - def

    # S’assure que l’on n’ait pas de dégâts négatifs
    raw = max(raw, 0)

    # Détermine si l’attaque est un coup critique, seulement si dégâts > 0
    is_crit = (rand() < crit_chance) && raw > 0

    # Si coup critique, applique le multiplicateur
    raw = is_crit ? Int(round(raw * crit_mult)) : raw

    # Retourne les dégâts finaux et si c’est un crit
    return raw, is_crit
end

# Simule une attaque entre deux personnages
function attaquer(att::Role, def::Role; shield::Int=0, dmg_mat=Dict(), skill_usage=Dict())

    # Calcule les dégâts infligés en tenant compte du bouclier
    dmg, crit = compute_damage(att.stats.ATK, def.stats.DEFENSE - shield)

    # Met à jour les PV du défenseur
    def.stats.PV = max(def.stats.PV - dmg, 0)

    # Affiche un message résumant l’attaque et un avertissement en cas de crit
    println("$(att.nom) attaque $(def.nom) et inflige $dmg dégâts" * (crit ? " (CRIT!)" : ""))

    # Détermine les types (rôles) de l’attaquant et du défenseur
    acls, dcls = string(typeof(att)), string(typeof(def))

    # Enregistre les dégâts dans une matrice de suivi en fonction des types des rôles
    dmg_mat[(acls,dcls)] = get(dmg_mat,(acls,dcls),0) + dmg
    
    # Retourne le nombre de dégâts infligés
    return dmg
end
