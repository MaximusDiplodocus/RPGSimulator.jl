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
@testset "combat" begin
    gandalf = Mage()
    arthur = Chevalier()
    winner = combat(gandalf, arthur; max_rounds=10)
    @test winner in [gandalf.nom, arthur.nom]
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