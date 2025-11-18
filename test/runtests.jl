using Test
using RPGSimulator
using Random

println("=== DÉBUT DES TESTS UNITAIRES RPGSimulator ===")

# On fixe la seed pour reproductibilité
Random.seed!(1234)

# === TEST 1 : compute_damage ===
@testset "compute_damage" begin
    dmg, crit = compute_damage(50, 10)
    @test dmg ≥ 0
    @test crit isa Bool
end

# === TEST 2 : attaquer ===
@testset "attaquer" begin
    robin = Archer()
    gobelin = Gobelin()
    dmg = attaquer(robin, gobelin)
    @test dmg ≥ 0
    @test gobelin.stats.PV ≤ 60
end

# === TEST 3 : combat simple ===
@testset "combat simple" begin
    gandalf = RPGSimulator.Mage()
    arthur = RPGSimulator.Chevalier()
    # On fixe les champs VITESSE si nécessaire
    gandalf.stats.VITESSE = 10
    arthur.stats.VITESSE = 8
    winner, logs = RPGSimulator.combat(gandalf, arthur; max_rounds=10)
    @test winner in [gandalf.nom, arthur.nom]
    @test length(logs) ≥ 1    # au moins un tour effectué
    @test all(log -> log.damage ≥ 0, logs)  # pas de dégâts négatifs
end

# === TEST 4 : use_skill Mage Fireball ===
@testset "use_skill Mage" begin
    mage = Mage()
    target = Chevalier()
    fireball = Fireball(10, 30)  # positionnel
    before_PV = target.stats.PV
    before_PM = mage.stats.PM
    dmg = use_skill(mage, fireball, target)
    @test dmg ≥ 0
    @test target.stats.PV == before_PV - dmg
    @test mage.stats.PM == before_PM - fireball.cost_pm
end

# === TEST 5 : use_skill Chevalier PowerStrike ===
@testset "use_skill Chevalier" begin
    chevalier = Chevalier()
    target = Gobelin()
    power_strike = PowerStrike(8, 20)  # positionnel
    before_PV = target.stats.PV
    before_PM = chevalier.stats.PM
    dmg = use_skill(chevalier, power_strike, target)
    @test dmg ≥ 0
    @test target.stats.PV == before_PV - dmg
    @test chevalier.stats.PM == before_PM - power_strike.cost_pm
end

# === TEST 6 : use_skill générique ===
@testset "use_skill générique" begin
    archer = Archer()
    target = Gobelin()
    dummy_skill = AOE(5, 10, 2)
    dmg = use_skill(archer, dummy_skill, target)
    @test dmg == 0
end

# ------------------------------------------------------
# Structures factices pour les tests de "effets"
# ------------------------------------------------------
mutable struct DummyStats
    PV::Int
    ATK::Int
    DEFENSE::Int
    PM::Int
end

mutable struct DummyRole <: RPGSimulator.Role
    nom::String
    stats::DummyStats
    effects::Vector{RPGSimulator.StatusEffect}
end

# Helper pour créer un rôle factice
function make_dummy_role(pv=100; name="Testeur", effects=RPGSimulator.StatusEffect[])
    return DummyRole(name, DummyStats(pv, 10, 5, 20), effects)
end

# === TEST 7 : Poison ===
@testset "Poison" begin
    c = make_dummy_role(100, effects=[RPGSimulator.Poison(2,8)])
    shield, stunned, regen, dmg = RPGSimulator.apply_effects_round!(c)
    @test dmg == 8
    @test c.stats.PV == 92
    @test length(c.effects) == 1  
end

# === TEST 8 : Bleed ===
@testset "Bleed" begin
    c = make_dummy_role(100, effects=[RPGSimulator.Bleed(3,5)])
    shield, stunned, regen, dmg = RPGSimulator.apply_effects_round!(c)
    @test dmg == 5
    @test c.stats.PV == 95
    @test length(c.effects) == 1  
end

# === TEST 9 : Regen ===
@testset "Regen" begin
    c = make_dummy_role(50, effects=[RPGSimulator.Regen(2,10)])
    shield, stunned, regen, dmg = RPGSimulator.apply_effects_round!(c)
    @test regen == 10
    @test dmg == 0
    @test c.stats.PV == 60
    @test length(c.effects) == 1  
end

# === TEST 10 : Shield ===
@testset "Shield" begin
    c = make_dummy_role(100, effects=[RPGSimulator.Shield(2,15)])
    shield, stunned, regen, dmg = RPGSimulator.apply_effects_round!(c)
    @test shield == 15
    @test dmg == 0
    @test c.stats.PV == 100
    @test length(c.effects) == 1 
end

# === TEST 11 : Stun ===
@testset "Stun" begin
    c = make_dummy_role(100, effects=[RPGSimulator.Stun(1)])
    shield, stunned, regen, dmg = RPGSimulator.apply_effects_round!(c)
    @test stunned == true
    @test dmg == 0
    @test length(c.effects) == 0  
end

# === TEST 12 : Stack d'effects ===
@testset "Stack d’effets" begin
    c = make_dummy_role(100, effects=[
        RPGSimulator.Poison(2,5),
        RPGSimulator.Bleed(2,3),
        RPGSimulator.Regen(2,4),
        RPGSimulator.Shield(2,10)
    ])
    shield, stunned, regen, dmg = RPGSimulator.apply_effects_round!(c)
    @test shield == 10
    @test regen == 4
    @test dmg == 8     # 5 poison + 3 bleed
    @test c.stats.PV == 100 + 4 - 8
    @test length(c.effects) == 4 
end

# === TEST 13 : Aucun effet ===
@testset "Aucun effet" begin
    c = make_dummy_role(100, effects=RPGSimulator.StatusEffect[])
    shield, stunned, regen, dmg = RPGSimulator.apply_effects_round!(c)
    @test shield == 0
    @test stunned == false
    @test regen == 0
    @test dmg == 0
    @test isempty(c.effects)
end