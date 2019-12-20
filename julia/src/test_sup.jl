using Statistics
using Dates: now

include("data_graph.jl")
include("model.jl")
include("train.jl")


# TODO time to test the model!!
function inf()
end


function exp_sup(d; ng=10000, N=10, train_steps=1e5)
    # for scitific notation
    ng = convert(Int, ng)
    # TODO test on different type of graph

    ds, test_ds = gen_sup_ds_cached(ng=ng, N=N, d=d, batch_size=100)
    # ds, test_ds = gen_sup_ds_cached_diff(ng=ng, N=N, d=d, batch_size=100)
    x, y = next_batch!(test_ds)

    # FIXME parameterize the model
    model = sup_model(d) |> gpu
    # TODO lr decay
    opt = ADAM(1e-4)

    expID = "d=$d-ng=$ng-N=$N"

    logger = TBLogger("tensorboard_logs/train-$expID-$(now())", tb_append, min_level=Logging.Info)
    test_logger = TBLogger("tensorboard_logs/test-$expID-$(now())", tb_append, min_level=Logging.Info)

    print_cb = Flux.throttle(sup_create_print_cb(logger), 1)
    test_cb = Flux.throttle(sup_create_test_cb(model, test_ds, "test_ds", logger=test_logger), 10)

    sup_train!(model, opt, ds, test_ds,
               print_cb=print_cb,
               test_cb=test_cb,
               train_steps=train_steps)

    # TODO enforcing sparsity, and increase the loss weight of 1 edges, because
    # there are much more 0s, and they can take control of loss and make 1s not
    # significant. As an extreme case, the model may simply report 0 everywhere

    # do the inference
    # x, y = next_batch!(test_ds)
    # sup_view(model, x[:,8], y[:,8])
end

function test()
    exp_sup(3)
    exp_sup(5)
    exp_sup(7)
    exp_sup(10)
    exp_sup(10, ng=100000, N=1)
    exp_sup(10, ng=1000, N=100)
    exp_sup(20, ng=10000, N=2)


    # so it does not work
    exp_sup(5, ng=1e3, N=2)     # prec=0.58, recall=0.80
    exp_sup(5, ng=1e3, N=20)    # prec=0.80, recall=0.95
    exp_sup(5, ng=5e3, N=20)    # prec=0.93, recall=0.98
    # this actually generates 99xx graphs
    exp_sup(5, ng=1e4, N=20)    # prec=0.92, recall=0.97
    # with increased N, it works much better
    exp_sup(5, ng=5e3, N=50)    # prec=0.96, recall=0.98
    exp_sup(5, ng=5e3, N=100)   # prec=0.97, recall=0.99
    # exp_sup(5, ng=1e4, N=10)
    # exp_sup(5, ng=1e4, N=20)
    # prec=0.94, recall=0.98
    exp_sup(5, ng=5e3, N=50, train_steps=5e5) # prec=0.98, recall=0.99
    # prec=0.87, recall=0.93
    exp_sup(7, ng=1e4, N=50, train_steps=5e5) # prec=0.92, recall=0.96
    exp_sup(10, ng=1e4, N=100, train_steps=5e5) # prec=0.83, recall=0.87
    exp_sup(10, ng=1e5, N=50, train_steps=5e5)  # prec=0.85, recall=0.88
    exp_sup(15, ng=1e4, N=100, train_steps=5e5) # prec=0.68, recall=0.72
    exp_sup(20, ng=1e4, N=100, train_steps=5e5)
    exp_sup(20, ng=1e5, N=50, train_steps=5e5)
end

function sup_view(model, x, y)
    length(size(x)) == 1 || error("x must be one data")
    # visualize ground truth y
    d = convert(Int, sqrt(length(y)))
    g = DiGraph(reshape(y, d, d))
    display(g)

    out = cpu(model)(x)
    reshape(threshold(out, 0.3), d, d) |> DiGraph |> display
    nothing
end