# Définition d'une structure Stats avec des champs modifiables
mutable struct Stats
    PV::Int
    PM::Int
    ATK::Int
    VITESSE::Int
    DEFENSE::Int
end

# Constructeur secondaire pour définir des valeurs par défault pour Stats
Stats(; PV=100, PM=50, ATK=10, VITESSE=10, DEFENSE=10) = Stats(PV, PM, ATK, VITESSE, DEFENSE)

# Définition d'un type abstrait pour la hiérarchie des rôles
abstract type Role end

# Déclaration du rôle Archer, qui hérite de Role
mutable struct Archer <: Role
    nom::String
    stats::Stats
    effects::Vector{Any}
end
# Constructeur secondaire pour définir des valeurs par défaut pour Archer
Archer(; nom="Robin") = Archer(nom, Stats(PV=90, PM=30, ATK=15, VITESSE=20, DEFENSE=8), [])

# Déclaration du rôle Mage
mutable struct Mage <: Role
    nom::String
    stats::Stats
    effects::Vector{Any}
end
Mage(; nom="Gandalf") = Mage(nom, Stats(PV=70, PM=100, ATK=25, VITESSE=12, DEFENSE=6), [])

# Déclaration du rôle Chevalier
mutable struct Chevalier <: Role
    nom::String
    stats::Stats
    effects::Vector{Any}
end
Chevalier(; nom="Arthur") = Chevalier(nom, Stats(PV=120, PM=20, ATK=18, VITESSE=10, DEFENSE=20), [])

# Déclaration du rôle Gobelin
mutable struct Gobelin <: Role
    nom::String
    stats::Stats
    effects::Vector{Any}
end
Gobelin(; nom="Gabimarou") = Gobelin(nom, Stats(PV=60, PM=10, ATK=12, VITESSE=14, DEFENSE=5), [])

# Affichage spécifique pour Role
function Base.show(io::IO, perso::Role)
    rl = typeof(perso).name.name
    st = perso.stats
    println(io, "$(perso.nom) le $rl")
    println(io, "  PV: $(st.PV) | PM: $(st.PM) | ATK: $(st.ATK) | VIT: $(st.VITESSE) | DEF: $(st.DEFENSE)")
end
