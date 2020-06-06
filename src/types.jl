#### Constants
const MODEL_FILENAME = "pls_model.jld" # jld filename for storing the model
const MODEL_ID       = "pls_model"     # if od the model in the filesystem jld data

#### An abstract pls model
abstract type PLSModel{T} end


#export Model,PLS1Model,PLS2Model, KPLSModel

#### PLS1 type
mutable struct PLS1Model{T<:AbstractFloat} <:PLSModel{T}
    W::Matrix{T}           # a set of vectors representing correlation weights of input data (X) with the target (Y)
    b::Matrix{T}           # a set of scalar values representing a latent value for dependent variables or target (Y)
    P::Matrix{T}           # a set of latent vetors for the input data (X)
    nfactors::Int          # a scalar value representing the number of latent variables
    mx::Matrix{T}          # mean stat after for z-scoring input data (X)
    my::T                  # mean stat after for z-scoring target data (Y)
    sx::Matrix{T}          # standard deviation stat after z-scoring input data (X)
    sy::T                  # standard deviation stat after z-scoring target data (X)
    nfeatures::Int         # number of input (X) features columns
    standardize::Bool       # store information of centralization of data. if true, tehn it is passed to transform function
end



## PLS1: constructor
function PLSModel(X::Matrix{T},
               Y::Vector{T},
               nfactors::Int,
               standardize::Bool) where T<:AbstractFloat
    (nrows,ncols) = size(X)
    ## Allocation
    return PLS1Model(zeros(T,ncols,nfactors), ## W
            zeros(T,1,nfactors),       ## b
            zeros(T,ncols,nfactors), ## P
            nfactors,
            mean(X,dims=1),
            mean(Y),
            std(X,dims=1),
            std(Y),
            ncols,
            standardize)
end

########################################################################################
#### PLS2 type
mutable struct PLS2Model{T<:AbstractFloat} <:PLSModel{T}
    W::Matrix{T}           # a set of vectors representing correlation weights of input data (X) with the target (Y)
    Q::Matrix{T}           #
    b::Matrix{T}           # a set of scalar values representing a latent value for dependent variables or target (Y)
    P::Matrix{T}           # a set of latent vetors for the input data (X)
    nfactors::Int          # a scalar value representing the number of latent variables
    mx::Matrix{T}          # mean stat after for z-scoring input data (X)
    my::Matrix{T}          # mean stat after for z-scoring target data (Y)
    sx::Matrix{T}          # standard deviation stat after z-scoring input data (X)
    sy::Matrix{T}          # standard deviation stat after z-scoring target data (X)
    nfeatures::Int         # number of input (X) features columns
    ntargetcols::Int       # number of target (Y) columns
    standardize::Bool       # store information of centralization of data. if true, tehn it is passed to transform function
end


## PLS2: constructor
function PLSModel(X::Matrix{T},
        Y::Matrix{T}, # this is the diference from PLS1 param constructor!
        nfactors::Int,
        standardize::Bool) where T<:AbstractFloat
    (nrows,ncols) = size(X)
    (n,m)         = size(Y)
    ## Allocation
    return PLS2Model(zeros(T,ncols,nfactors), ## W
            zeros(T,m,nfactors),       ## Q
            zeros(T,n,nfactors),       ## b
            zeros(T,ncols,nfactors),   ## P
            nfactors,
            mean(X,dims=1),
            mean(Y,dims=1),
            std(X,dims=1),
            std(Y,dims=1),
            ncols,
            m,
            standardize)
end

################################################################################
#### KPLS type
mutable struct KPLSModel{T<:AbstractFloat} <:PLSModel{T}
    X::Matrix{T}           # Training set
    K::Matrix{T}           # Kernel matrix
    B::Matrix{T}           # Regression matrix
    nfactors::Int          # a scalar value representing the number of latent variables
    mx::Matrix{T}          # mean stat after for z-scoring input data (X)
    my::AbstractArray{T}   # mean stat after for z-scoring target data (Y)
    sx::Matrix{T}          # standard deviation stat after z-scoring input data (X)
    sy::AbstractArray{T}   # standard deviation stat after z-scoring target data (X)
    nfeatures::Int         # number of input (X) features columns
    ntargetcols::Int       # number of target (Y) columns
    standardize::Bool       # store information of centralization of data. if true, tehn it is passed to transform function
    kernel::AbstractString
    width::Float64
end


## KPLS: constructor
function PLSModel(X::Matrix{T},
            Y::AbstractArray{T}, # this is the diference from PLS1 param constructor!
            nfactors::Int,
            standardize::Bool,
            kernel::String,
            width::Float64) where T<:AbstractFloat
    (nrows,ncols) = size(X)
    (n,m)         = size(Y[:,:])
    ## Allocation
    return KPLSModel(zeros(T,nrows,ncols), ## X
            zeros(T,nrows,nrows),          ## K
            zeros(T,ncols,m),              ## B
            nfactors,
            mean(X,dims=1),
            mean(Y,dims=1),
            std(X,dims=1),
            std(Y,dims=1),
            ncols,
            m,
            standardize,
            kernel,
            width)
end


######################################################################################################
## Load and Store models (good for production)
function load(; filename::AbstractString = MODEL_FILENAME, modelname::AbstractString = MODEL_ID)
    local M
    jldopen(filename, "r") do file
        M = read(file, modelname)
    end
    M
end

function save(M::PLSModel; filename::AbstractString = MODEL_FILENAME, modelname::AbstractString = MODEL_ID)
    jldopen(filename, "w") do file
        write(file, modelname, M)
    end
end
