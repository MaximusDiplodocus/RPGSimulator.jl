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

#Simulation d'un combat entre Jed le mage et Hussin le chevalier (renvoie le vainqueur)
combat(mage,chevalier)
#Simulation de 10 combats (n_simulations = 10) entre Jed le mage et Hussin le chevalier
rand(mage, chevalier)


#2/ Tests automatiques - stats par défaut
combat(Archer(), Gobelin())
rand(Archer(), Gobelin())


#3/ Test l'utilisation d'une compétence
mage = Mage(nom="Jed")
mage.stats = Stats(PV=100, PM=20, ATK=30, VITESSE=40, DEFENSE=10)

chevalier = Chevalier(nom="Hussin")
chevalier.stats = Stats(PV=120, PM=20, ATK=40, VITESSE=30, DEFENSE=15)

use_skill(mage, Fireball(10, 30), chevalier)
println("PV d'Hussin après la Fireball de Jed : ", mage.stats.PV)
