using RPGSimulator

#1/ - Tests manuel

#Initialisation de nos 2 opposants
mage = Mage(nom="Jed")
mage.stats = Stats(PV=100, PM=20, ATK=30, VITESSE=40, DEFENSE=10)

chevalier = Chevalier(nom="Hussin")
chevalier.stats = Stats(PV=120, PM=20, ATK=40, VITESSE=30, DEFENSE=15)

#Visualisation de nos opposants
println("=== Début du test de combat ===")
println("Personnages en présence :")
mage
chevalier

#Simulation d'un combat entre Jed le mage et Hussin le chevalier
combat(mage,chevalier)
#Simulation de 5 combats entre Jed le mage et Hussin le chevalier
rand(mage, chevalier, n_simulations=5)


#2/ Tests automatiques - stats par défaut
combat(Archer(), Gobelin())
rand(Archer(), Gobelin())
