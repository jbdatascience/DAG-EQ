include("exp.jl")

import Printf

function test_size()
    # model size
    @info "FC model"
    for d in [7, 10,15,20,25,30]
        Printf.@printf "%.2f\n" param_count(fc_model_fn(d)) / 1e6
    end
    @info "FC deep model"
    for d in [7, 10,15,20,25,30]
        Printf.@printf "%.2f\n" param_count(deep_fc_model_fn(d)) / 1e6
    end
    # EQ models is independent of input size
    @info "EQ model"
    Printf.@printf "%.2f\n" param_count(eq_model_fn(10)) / 1e6
    Printf.@printf "%.2f\n" param_count(deep_eq_model_fn(10)) / 1e6
end

function test()
    create_sup_data(DataSpec(d=10, k=1, gtype=:SF, noise=:Gaussian))
    load_sup_ds(DataSpec(d=10, k=1, gtype=:SF, noise=:Gaussian), 100)
end

function main_gen_data()
    # Create data to use. I must create this beforehand (not online during
    # training), so that I can completely separate training and testing
    # data. Probably also validation data.

    # TODO create data with different W range
    # TODO create graphs of different types
    for d in [10,15,20]
        # TODO [1,2,4]
        for k in [1]
            for gtype in [:ER, :SF]
                for noise in [:Gaussian, :Poisson]
                    create_sup_data(DataSpec(d=d, k=k, gtype=gtype, noise=noise))
                end
            end
        end
    end
end

function main_train_EQ()
    # I'll be training just one EQ model on SF graph with d=10,15,20
    specs = for d in [10, 15, 20]
        DataSpec(d=d, k=1, gtype=:ER, noise=:Gaussian)
    end
    exp_train(()->mixed_ds_fn(specs),
              deep_eq_model_fn,
              expID="deep-EQ", suffix="NIPS", train_steps=3e4)
end

function main_test_EQ()
    # load the trained model
    #
    # test on different types of data
    exp_test("deep-EQ-NIPS",
             ()->spec_ds_fn(DataSpec(d=25, k=1, gtype=:ER, noise=:Gaussian)))
    exp_test("deep-EQ-NIPS",
             ()->spec_ds_fn(DataSpec(d=18, k=1, gtype=:SF, noise=:Poisson)))
end

function main_train_FC()
    # train for d = 10
    for d in [10, 15, 20]
        spec = DataSpec(d=d, k=1, gtype=:ER, noise=:Gaussian)
        exp_train(()->spec_ds_fn(spec),
                  ()->deep_fc_model_fn(d),
                  expID="deep-FC-$d", suffix="NIPS", train_steps=1e5)
    end
end

function main_test_FC()
    for d in [10, 15, 20]
        exp_test("deep-FC-$d-NIPS",
                 ()->spec_ds_fn(DataSpec(d=d, k=1, gtype=:SF, noise=:Poisson)))
    end
end

main_gen_data()
main_train_EQ()
main_test_EQ()
