
"""
In diesem Modul ist das Pohl'sche Rad als virtuelles Experiment implementiert.

Für Details siehe die Dokumentation der `run_experiment` Funktion.
"""
module PohlExperiment

	using DifferentialEquations
	using DataFrames
	using Measurements

	export run_experiment # Die Funktion run_experiment soll außerhalb des Moduls verwendet werden.


	# Physikalische Parameter des Pohl'schen Rades.
	Omega_0 = 1.0 + 0.3 * rand()
	F = 1.0 + 0.7 * rand()
	gamma = [0, 0.3 + 0.1 * rand(), 2 + 0.5 * rand()]
	Theta = measurement(13, 0.5)


	"""
		damped_oscillator!(du, u, p, t)

	In dieser Funktion ist die DGL des Pohl'schen Rades implementiert.
	"""
	function damped_oscillator!(du, u, p, t)
	    alpha, Omega0, A, OmegaE = p
	    phi, omega = u
	    du[1] = omega
	    du[2] = - alpha * omega - Omega0 * phi + A * sin(OmegaE*t)
	end


	"""
		run_experiment(t_max::Real, phi_init::Real; damping::Int64=0, driving::Bool=false, Omega_F::Real=0.0)

	Diese Funktion simuliert ein Experiment mit einem Pohl'schen Rad, das durch folgende DGL beschrieben
	wird:

	``
		φ''+γφ'+Ω_0φ=F sin(Ω_F t)
	``

	Die Dämpfung kann auf drei Stufen eingestellt werden. Der äußere Antrieb kann ein- oder ausgeschaltet 
	werden und die Frequenz des Antriebs kann frei gewählt werden.

	Die jeweiligen Parameter ``γ``, ``Ω_0`` und ``A`` werden zufällig gewählt.

	Als Ergebnis des Experiments gibt die Funktion die zeitabhängige Beobachtung der Amplitude ``φ`` zurück,
	die leicht fehlerbehaftet ist.

	## Arguments
	- `t_max::Real`: Laufzeit des Experiments. Start bei ``t=0``, Ende bei ``t=t_{max}``.
	- `phi_init::Real`: Anfangswert für die Auslenkung ``φ``.
	- `damping::Int64`: Einstellung der Dämpfung. `0`: keine Dämpfung, `1`: schwache Dämfpung, `2`: starke Dämpfung.
	- `driving::Bool`: Antrieb ein/aus.
	- `Omega_F::Real`: Antriebsfrequenz ``Ω_F``.

	## Returns
	Ein `DataFrame` mit zwei Spalten: eine für die Zeit ``t`` und eine für die Auslenkung ``φ(t)``
	"""
	function run_experiment(t_max::Real, phi_init::Real; 
							damping::Int64=0, driving::Bool=false, Omega_F::Real=0.0)

		global Omega_0
		global F

		# Stelle Parameter zum Lösen der DGL zusammen
		tspan = (0.0, t_max)
		u0 = [phi_init,0]
		p = [gamma[damping+1], Omega_0, 0.0, Omega_F]

		# Add driving if switched on.
		if driving
			p[3] = F
		end

		# Definiere ODEProblem
		prob = ODEProblem(PohlExperiment.damped_oscillator!, u0, tspan, p)

		# Löse ODEProblem
		data = solve(prob, saveat=0.1)

		# Verpacke die Lösung φ(t) in ein DataFrame
		data = DataFrame(
							t = data.t,
							phi = getindex.(data.u,1) + 0.01 * pi * rand(length(data.t))
						)

		return data
	end

end # module PohlExperiment