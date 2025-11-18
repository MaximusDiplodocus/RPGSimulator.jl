require(Rulia)
library(shiny)
library(ggplot2)

jlrun('import Pkg; Pkg.activate("C:/Users/dufau/Documents/GitHub/RPGSimulator.jl")')

jlrun('using RPGSimulator')

#Test d'un combat
jl(`# Création des personnages
mage = Mage(nom="Jed")
mage.stats = Stats(PV=100, PM=20, ATK=30, VITESSE=40, DEFENSE=10)

chevalier = Chevalier(nom="Hussin")
chevalier.stats = Stats(PV=120, PM=20, ATK=40, VITESSE=30, DEFENSE=15)

# Vainqueur pour un combat
all_logs, summary = combat(mage,chevalier)`)