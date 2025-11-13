# RPGSimulator

Règles du Jeu — RPG Simulator

## Présentation du Jeu:

RPGSimulator est un moteur de simulation de combats tour par tour entre différents rôles de personnages (héros et monstres).
Chaque combat se déroule selon des règles précises de statistiques, d’effets, de compétences et de probabilités critiques.
L’objectif est d’évaluer les performances des rôles, d’équilibrer le système de jeu et de visualiser les résultats à travers des simulations massives.


## Statistiques de base

Chaque personnage dispose de plusieurs statistiques influençant le combat :
- PV (Points de Vie) : santé du personnage. Le combat se termine à 0 PV.
- PM (Points de Magie) : ressource utilisée pour les compétences spéciales.
- ATK (Attaque) : force d’attaque physique de base.
- VITESSE : détermine l’ordre d’action à chaque tour.
- DEFENSE : réduit les dégâts physiques subis.


## Rôles disponibles

Chaque personnage appartient à un rôle avec des caractéristiques propres, qui sont modifiables dans le fichier `test.jl` :

Archer : rapide et précis, inflige des dégâts physiques constants.
- PV : 90
- PM : 30
- ATK : 15
- VITESSE : 20
- DEFENSE : 8

Mage : puissant magicien, fort potentiel offensif mais fragile.
- PV : 70
- PM : 100
- ATK : 25
- VITESSE : 12
- DEFENSE : 6

Chevalier : résistant et fiable, parfait pour encaisser les coups.
- PV : 120
- PM : 20
- ATK : 18
- VITESSE : 10
- DEFENSE : 20

Gobelin : créature agile mais peu résistante, utilisée comme adversaire de test.
- PV : 60
- PM : 10
- ATK : 12
- VITESSE : 14
- DEFENSE : 5


## Attaques physiques

Les attaques normales utilisent la formule suivante :
"dégâts = (ATK ± aléa) - DEF"

Un aléa (variation) est appliqué selon une distribution normale centrée sur l’attaque, avec un écart-type de 12 %.
Les dégâts sont arrondis à l’entier et ne peuvent pas être négatifs.
Chaque attaque a une chance de coup critique de 10 %, infligeant 1,6 fois les dégâts normaux.


## Compétences spéciales

Certaines classes peuvent utiliser des compétences qui consomment des PM.

Fireball (Mage) :
- Coût : 10 PM
- Effet : attaque magique puissante.
- Ignore 30 % de la défense adverse.
- Chance de critique : 22 %. Multiplicateur : 2.2x.

PowerStrike (Chevalier) :
- Coût : 8 PM
- Effet : coup puissant basé sur 70 % de l’attaque du chevalier.
- Chance de critique : 18 %. Multiplicateur : 1.8x.

Quand un personnage n’a pas assez de PM, il effectue une attaque normale.


## Effets de statut

Certains effets influencent les tours de combat et ont une durée limitée.
- Poison : inflige des dégâts fixes chaque tour.
- Bleed : inflige des dégâts continus de saignement.
- Regen : soigne un montant fixe de PV chaque tour.
- Shield : bloque une partie des dégâts subis.
- Stun : empêche le personnage d’agir pendant un tour.

Les effets se cumulent et disparaissent automatiquement quand leur durée expire.


## Déroulement d’un combat

Un combat se déroule en plusieurs tours successifs :
1/ Initialisation des deux combattants avec leurs PV et PM.
2/ Application des effets en cours (poison, régénération, etc.).
3/ Détermination de l’ordre d’action selon la vitesse.
4/ Chaque combattant agit à son tour :
- Si le personnage est étourdi (stun), il passe son tour.
- Sinon, il attaque ou utilise une compétence.
- Les dégâts sont calculés et appliqués à la cible.
5/ Fin du tour :
- Les effets sont mis à jour (durée diminuée).
- Si un combattant tombe à 0 PV, le combat se termine.
6/ Le vainqueur est celui dont les PV sont supérieurs à 0 à la fin du combat.


## Simulation multiple

La simulation permet d’exécuter plusieurs combats pour obtenir des statistiques globales :

Exemple :
"simulate_many!(Mage(), Gobelin(); N=100)"

N : nombre de combats à simuler.

Les résultats sont enregistrés dans deux fichiers :
- data/combat_results.csv : journal complet des tours.
- data/combat_summary.csv : vainqueur de chaque combat.

Ces données peuvent ensuite être utilisées pour calculer les taux de victoire, les dégâts moyens ou l’équilibrage général.
