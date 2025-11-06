# ======================================
# Example/test.jl — Script de démonstration du moteur RPG
# ======================================

# Active le module principal du jeu
push!(LOAD_PATH, joinpath(@__DIR__, "..", "src"))
using RPGSimulator

# Création de deux personnages pour le test
mage = Mage(nom="Jed")
mage.stats = Stats(PV=100, PM=20, ATK=30, VITESSE=40, DEFENSE=10)

chevalier = Chevalier(nom="Hussin")
chevalier.stats = Stats(PV=120, PM=20, ATK=40, VITESSE=30, DEFENSE=15)

println("=== Début du test de combat ===")
println("Personnages en présence :")
show(mage)
show(chevalier)

simulate_many!(mage, chevalier)
