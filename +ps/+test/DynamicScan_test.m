% 1. Set up grid & select MeshRefinement Depth
depth = 4;
max_sim = 1000;
pscan = ps.GridRefinementScan('test', 'f', linspace(0,1,101), 'beta', linspace(0,1,101));
% 2. Set up parallel pool and determine number of workers
pool = parpool();
n_workers = pool.NumWorkers;
% 3. Launch mesh refinement scan
rmscan = rmscan.next_grid();
for level=1:depth
    % 3a. Split grid into batches
    batches = rmscan.split(n_workers, n_batches);
    % 3b. Launch batches
    parfor i_batch=1:n_batches
        para, ind = batches{i_batch}.next();
        res = struct();
        while ~isempty(para)
            % Perform simulation
            res.ind = ind;
            res.para = para;
            res = phony_sim(res);
            % Save simulation results
            batches{i_batch}.save_results(res);
            % Get next simulation parameters
            para, ind = batches{i_batch}.next();
        end
    end
    % 3c. Reassemble results and put grid back together
    rmscan.reassemble(batches);
    pscan.collect(rmscan);
    % 3d. Create new, refined grid
    if level < depth
        rmscan = rmscan.next_grid();
    end
end

function res = phony_sim(res)
    A = rand(3000);
    B = rand(3000);
    d = det(A*B);
    res.d = d;
end