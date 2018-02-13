
# register parallelization information (Creates a set of copies of R running in parallel and communicating over sockets & register the parallel backend with the foreach package)
cores = 8
cl = parallel::makeCluster(cores)
doParallel::registerDoParallel(cl)

# deregister parallel backend
if (cores > 1L)
  parallel::stopCluster(cl)
