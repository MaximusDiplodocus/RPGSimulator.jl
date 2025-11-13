module RPGSimulator

using Random, Dates, CSV, DataFrames, Distributions, StatsBase, Chain

include("roles.jl")
include("effets.jl")
include("attaques.jl")
include("skills.jl")
include("combat.jl")
include("simulation.jl")

export simulate, combat, attaquer, use_skill, afficher_stats,
       compute_damage,
       Stats, Role, Archer, Mage, Chevalier, Gobelin,
       Skill, Fireball, PowerStrike, Heal, AOE

end