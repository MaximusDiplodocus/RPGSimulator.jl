using RPGSimulator

mage = Mage(nom="Jed")
mage.stats = Stats(PV=100, PM=20, ATK=30, VITESSE=40, DEFENSE=10)

chevalier = Chevalier(nom="Hussin")

chevalier.stats = Stats(PV=120, PM=20, ATK=40, VITESSE=30, DEFENSE=15)

println("=== Début du test de combat ===")
println("Personnages en présence :")
show(mage)
show(chevalier)

simulation(mage, chevalier)
