function simulation(j1::Role, j2::Role; n_simulations=10, max_rounds=100, dmg_mat=Dict(), skill_usage=Dict())
    results = Dict(j1.nom => 0, j2.nom => 0)
    
    # Sauvegarder les PV initiaux
    pv_init_j1 = j1.stats.PV
    pv_init_j2 = j2.stats.PV
    
    for i in 1:n_simulations
        println("\n" * "="^60)
        println("SIMULATION $i / $n_simulations")
        println("="^60)
        
        # Créer des copies fraîches
        fighter1 = deepcopy(j1)
        fighter2 = deepcopy(j2)
        
        # Réinitialiser les PV avec les valeurs initiales
        fighter1.stats.PV = pv_init_j1
        fighter2.stats.PV = pv_init_j2
        
        # Lancer le combat
        winner_msg = combat(fighter1, fighter2; max_rounds=max_rounds, dmg_mat=dmg_mat, skill_usage=skill_usage)
        
        println("\n" * winner_msg)
        
        # Déterminer le gagnant
        if fighter1.stats.PV > 0
            results[fighter1.nom] += 1
        else
            results[fighter2.nom] += 1
        end
    end
    
    # Afficher les résultats finaux
    println("\n" * "="^60)
    println("RÉSULTATS FINAUX")
    println("="^60)
    println("$(j1.nom): $(results[j1.nom]) victoires ($(round(results[j1.nom]/n_simulations*100, digits=1))%)")
    println("$(j2.nom): $(results[j2.nom]) victoires ($(round(results[j2.nom]/n_simulations*100, digits=1))%)")
    
    return
end