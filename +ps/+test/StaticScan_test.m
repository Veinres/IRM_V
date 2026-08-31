% WIP - SHOULD BE MOVED

% 1. Set up grid
pg = ps.GridScan('test', 'f', linspace(0,1,10), 'beta', linspace(0,1,20));
% 2. Set up parallel pool and determine number of workers
n_workers = gcp().NumWorkers;
batch_size = 20;
% 3. Split grid into batches
batches = pg.split(n_workers, batch_size);
n_batches = numel(batches);
% 4. Launch batches
parfor i_batch=1:n_batches
    [para, ind] = batches(i_batch).next();
    res = struct();
    while ~isempty(para)
        % Perform simulation
        res.ind = ind;
        res.para = para;
        res = phony_sim(res);
        % Save simulation results
        batches(i_batch).save_results(res);
        % Get next simulation parameters
        [para, ind] = batches(i_batch).next();
    end
end
% 5. Reassemble results and put grid back together
pg.reassemble(batches);


function res = phony_sim(res)
    A = rand(3000);
    B = rand(3000);
    d = det(A*B);
    res.d = d;
end