using Pkg

get_global_env() = string("v", VERSION.major, ".", VERSION.minor)
get_global_env_folder() = joinpath(DEPOT_PATH[1], "environments", get_global_env())
get_active_env() = Base.active_project() |> dirname |> basename

# Check version
if get_global_env() != "v1.7"
    @info "Warning: This script is intended to be used with Julia v1.7. You are using " * get_global_env() * "."
end

# activate global environment (if not already active)
function activate_global_env()
    if get_active_env() != get_global_env()
        Pkg.REPLMode.pkgstr("activate --shared $(get_global_env())")
    end 
    nothing
end

function rm_global_env()
    if isdir(get_global_env_folder())
        cd(get_global_env_folder()) do
            isfile("Project.toml") && rm("Project.toml")
            isfile("Manifest.toml") && rm("Manifest.toml")
        end
    end
    nothing
end

function install_packages()
    Pkg.add(name="BenchmarkTools", version="1.3.1")
    Pkg.add(name="CSV", version="0.10.4")
    Pkg.add(name="CSVFiles", version="1.0.1")
    Pkg.add(name="ColorTypes", version="0.11.0")
    Pkg.add(name="Cubature", version="1.5.1")
    Pkg.add(name="DataFrames", version="1.3.2")
    Pkg.add(name="DifferentialEquations", version="7.1.0")
    Pkg.add(name="Distributions", version="0.25.53")
    Pkg.add(name="FFTW", version="1.4.6")
    Pkg.add(name="Flux", version="0.12.4")
    Pkg.add(name="Formatting", version="0.4.2")
    Pkg.add(name="HDF5", version="0.16.5")
    Pkg.add(name="JLD", version="0.13.1")
    Pkg.add(name="LaTeXStrings", version="1.3.0")
    Pkg.add(name="LsqFit", version="0.12.1")
    Pkg.add(name="Measurements", version="2.7.1")
    Pkg.add(name="Polynomials", version="3.0.0")
    Pkg.add(name="ProgressMeter", version="1.7.2")
    Pkg.add(name="PyCall", version="1.93.1")
    Pkg.add(name="PlotlyJS", version="0.18.8")
    Pkg.add(name="Plots", version="1.27.4")
    Pkg.add(name="Traceur", version="0.3.1")
    Pkg.add(name="Zygote", version="0.6.37")
end

# Installs all correct versions of our package dependencies.
function install()
    activate_global_env()

    # add all pkgs with specific versions (not pinned)
    @info "Installiere alle Pakete..."
    install_packages()

    # precompile
    @info "Bereite alle Pakete vor...."
    pkg"precompile"
end


# Installs all correct versions of our package dependencies
# by overwriting(!) the existing global environment.
function install_overwrite()
    rm_global_env()
    activate_global_env()

    # install IJulia
    @info "Installiere IJulia"
    Pkg.add(name="IJulia")

    # add all pkgs with specific versions (not pinned)
    @info "Installiere alle Pakete..."
    install_packages()

    # precompile
    @info "Bereite alle Pakete vor...."
    pkg"precompile"
end

nothing
