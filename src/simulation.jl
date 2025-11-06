module Simulation

using ..Classes
using ..Combat
using CSV, DataFrames, Dates

export simulate_many!

function simulate_many!(c1::Classes.Classe, c2::Classes.Classe; N=50, out_dir="data")
    mkpath(out_dir)
    all_logs = DataFrame(combat=Int[], time=DateTime[], round=Int[], actor=String[],
                         action=String[], target=String[], damage=Int[], actor_PV=Int[], target_PV=Int[])
    summary = DataFrame(Combat=Int[], Winner=String[])

    for i in 1:N
        j1 = deepcopy(c1)
        j2 = deepcopy(c2)
        logs, winner = combat(j1, j2)
        for l in logs
            push!(all_logs, (i, l.time, l.round, l.actor, l.action, l.target, l.damage, l.actor_PV, l.target_PV))
        end
        push!(summary, (i, winner))
    end

    CSV.write(joinpath(out_dir, "combat_results.csv"), all_logs)
    CSV.write(joinpath(out_dir, "combat_summary.csv"), summary)
    println("Résultats enregistrés dans $out_dir")
end

end # module Simulation
