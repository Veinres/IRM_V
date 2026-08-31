ps = ps.GridScan('testing/test','beta',0.1:0.1:1.0,'r',0.6:0.1:0.9,'f',0.05:0.05:0.2);

%% test sequential



%% test parallel



%% dummy_simulation

function result = dummy_simulation(beta,r,f,dim)
    
    % perform some relatively expensive non-sense computation
    s = rng(round(100^beta+100^r+100^f),'twister');
    A = rand(s,dim);
    B = rand(s,dim);
    C = A/B;
    results = det(C);
end