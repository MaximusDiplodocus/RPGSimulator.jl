using Test
using RPGSimulator
using Random

println("=== DÉBUT DES TESTS UNITAIRES RPGSimulator ===")

# On fixe la seed pour reproductibilité
Random.seed!(1234)

# Tableau pour stocker les résultats
results = Dict{String, Bool}()

# === TEST 1 : compute_damage ===
@testset "compute_damage" begin
    Random.seed!(1234)
    dmg, crit = compute_damage(50, 10)
    @test dmg ≥ 0
    @test isa(crit, Bool)
    results["compute_damage"] = true
    println("compute_damage fonctionne : dmg=$dmg, crit=$crit")
end

# === TEST 2 : attaquer ===
@testset "attaquer" begin
    robin = Archer()
    gobelin = Gobelin()
    dmg = attaquer(robin, gobelin)
    @test dmg ≥ 0
    @test gobelin.stats.PV ≤ 60
    results["attaquer"] = true
    println("attaquer fonctionne : dmg infligés=$dmg, PV gobelin=$(gobelin.stats.PV)")
end

# === TEST 3 : combat simple ===
@testset "combat" begin
    gandalf = Mage()
    arthur = Chevalier()
    winner = combat(gandalf, arthur; max_rounds=10)
    @test winner in [gandalf.nom, arthur.nom]
    results["combat"] = true
    println("combat simple terminé, gagnant : $winner")
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
    results["use_skill Mage Fireball"] = true
    println("use_skill Mage fonctionne : dmg=$dmg, PV cible=$(target.stats.PV), PM Mage=$(mage.stats.PM)")
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
    results["use_skill Chevalier PowerStrike"] = true
    println("use_skill Chevalier fonctionne : dmg=$dmg, PV cible=$(target.stats.PV), PM Chevalier=$(chevalier.stats.PM)")
end

# === TEST 6 : use_skill générique ===
@testset "use_skill générique" begin
    archer = Archer()
    target = Gobelin()
    dummy_skill = AOE(5, 10, 2)
    dmg = use_skill(archer, dummy_skill, target)
    @test dmg == 0
    results["use_skill générique"] = true
    println("use_skill générique fonctionne : dmg=$dmg")
end

# === RÉCAPITULATIF ===
println("\n=== RÉCAPITULATIF DES TESTS ===")
println("| Test                             | Statut |")
println("|----------------------------------|--------|")
for (k,v) in results
    println("| $(lpad(k,30))   | $(v ? "PASS" : "FAIL") |")
end

println("\n✅ Tous les tests se sont exécutés !")
