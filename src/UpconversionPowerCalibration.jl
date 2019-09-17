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

# Generate Data Points for Calculated Values
L = 11
mcalc = range(12, 30, length=L)
vcalc = range(0, 30, length=L)
mvcalc = Array{Float64,2}(undef, 0, 2)
for mm in mcalc, vv in vcalc
    global mvcalc = vcat(mvcalc, [mm vv])
end
scalc = model(mvcalc, fit.param)
scalc[scalc .< 0] .= NaN

# Plot the data
println("Plotting data...")
pygui(true)
figure()
scatter3D(m,v,s, label="real Sample power", color="C1")
mesh(mcalc, vcalc, reshape(scalc, (L,L)))
# scatter3D(model(x,fit.param),m,v, label="calculated Sample Power")
xlabel("Max Power")
ylabel("Power Value")
zlabel("Sample Power")
legend()

println("...done!")

# Print calibration equation
param = round.(fit.param,digits=5)
println("------------------------------------------------------------------")
println("Equation to calculate Sample Power with Max Power and Power Value:")
println("s = $(param[1]) + ($(param[2]))*m + ($(param[3]))*m**2 + ($(param[4]))*v + ($(param[5]))*v**2;")
println("------------------------------------------------------------------")
