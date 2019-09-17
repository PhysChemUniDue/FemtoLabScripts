using PyPlot
using LsqFit
using DelimitedFiles

# Load Config File in /FemtoLabScripts/Data
up_power = readdlm(joinpath(@__DIR__,"../Data/uc_power.config"), header=true)

# Load Values for max_power, power_value and sample_power
m = up_power[1][:,1]
v = up_power[1][:,2]
s = up_power[1][:,3]

# Define 2D-Model s = p1 + p2*m + p3*m^2 + p4*v + p5*v^2
x = [m v]
@. model(x,p) = p[1] + p[2]*x[:,1] + p[3]*x[:,1]^2 + p[4]*x[:,2] + p[5]*x[:,2]^2

# Set Starting Values
p0 = ones(5)

# Fit the data
fit = curve_fit(model, x, s, p0)

# Plot the data
pygui(true)
scatter3D(s,m,v, label="real Sample power")
scatter3D(model(x,fit.param),m,v, label="calculated Sample Power")
xlabel("Sample Power")
ylabel("Max Power")
zlabel("Power Value")
legend()

# Print calibration equation
param = round.(fit.param,digits=3)
println("------------------------------------------------------------------")
println("Equation to calculate Sample Power with Max Power and Power Value:")
println("s = $(param[1]) + ($(param[2]))*m + ($(param[3]))*m^2 + ($(param[4]))*v + ($(param[5]))*v^2")
println("------------------------------------------------------------------")
