using Pkg

Pkg.add("Distributions")
Pkg.add("Arpack")
Pkg.add("CausalInference")

# for LightGraphs
Pkg.add("FileIO")
Pkg.add("LightGraphs")

Pkg.add("GraphPlot")
# a compatibility bug with Cairo
# https://github.com/GiovineItalia/Compose.jl/pull/360
Pkg.add(PackageSpec(name="Compose", rev="master"))
Pkg.add("Cairo")
# Pkg.add("Fontconfig")
Pkg.add("MetaGraphs")

Pkg.add("Optim")
Pkg.add("NLopt")
Pkg.add("LineSearches")
Pkg.add("CSV")
Pkg.add("BSON")
Pkg.add("ForwardDiff")
Pkg.add("Tracker")

Pkg.add("Images")
Pkg.add("ProgressMeter")
Pkg.add("MLDatasets")
Pkg.add("ImageMagick")

Pkg.add("TensorBoardLogger")
Pkg.add("Plots")
Pkg.add("PyPlot")

Pkg.add("Interpolations")
Pkg.add("GaussianMixtures")
Pkg.add("StatsFuns")

# Flux
Pkg.add("CUDAnative")
Pkg.rm("CUDAnative")
Pkg.rm("CuArrays")
#!!!
Pkg.add("Distributions")


##############################
## Using Flux#master and Zygote

Pkg.add("Flux")
Pkg.rm("Flux")
Pkg.rm("Tracker")
Pkg.add(PackageSpec(name="Flux", rev="master"))
Pkg.free("Flux")
Pkg.add(Pkg.PackageSpec(name="Zygote", rev="master"))
# Pkg.rm("CuArrays")

##############################
## Or using Flux 0.9 and Tracker
Pkg.rm("Flux")
Pkg.rm("CuArrays")
Pkg.rm("GPUArrays")
Pkg.rm("Distributions")
Pkg.add(PackageSpec(name="Flux", version="0.9"))
Pkg.pin(PackageSpec(name="Flux", version="0.9"))
Pkg.add("Tracker")
Pkg.add("Distributions")


Pkg.instantiate()

Pkg.status()
Pkg.update()

# Pkg.build("Arpack")
