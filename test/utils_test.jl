@testset "Auxiliary Functions Test" begin
    @testset "check constant columns" begin
		@test_throws Exception PLSRegressor.check_constant_cols([1.0 1;1 2;1 3])
		@test_throws Exception PLSRegressor.check_constant_cols([1.0;1;1][:,:])
		@test_throws Exception PLSRegressor.check_constant_cols([1.0 2 3])
		@test_throws Exception PLSRegressor.check_constant_cols([1.0; 1; 1][:,:])

		@test PLSRegressor.check_constant_cols([1.0 1;2 2;3 3])
		@test PLSRegressor.check_constant_cols([1.0;2;3][:,:])
	end

	@testset "standardize" begin
		X        = [1; 2; 3.0][:,:]
		X        = PLSRegressor.standardize_data(X,mean(X,dims=1),std(X,dims=1))

		@test all(X .== [-1;0;1.0])
	end

	@testset "destandardize" begin
		Xo        = [1; 2; 3.0][:,:]
		Xn        = [-1;0;1.0][:,:]
		Xn        = PLSRegressor.destandardize_data(Xn,mean(Xo,dims=1),std(Xo,dims=1))

		@test all(Xn .== [1; 2; 3.0])
	end

	@testset "checkparams" begin
	     #@test_logs PLSRegressor.check_params(2,1,"linear")
		 @test_throws Exception PLSRegressor.check_params(-1,2,"linear")
		 @test_throws Exception PLSRegressor.check_params(1,2,"x")

		 @test PLSRegressor.check_params(1,2,"linear")
	end

	@testset "checkdata" begin
		 @test_throws Exception PLSRegressor.check_data(zeros(0,0), 0)
		 @test_throws Exception PLSRegressor.check_data(zeros(1,1), 10)
		 @test PLSRegressor.check_data(zeros(1,1), 1)
	end
end
