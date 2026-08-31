%% Test soa2aos and aos2sao:

s_sz = @(S) deal(cellfun(@(x) size(S(1).(x)), fields(S(1)), 'UniformOutput', false), size(S));

S = cell(0);

%% Example 1:
i = 1;

S{i}.A = rand(3,4,4,10,2);
S{i}.B = rand(5,3,4,4);
S{i}.C = rand(2,5,3,4,4);

[fsz, ssz] = s_sz(S{i});

T{i} = util.struct.soa2aos(S{i});

[fsz, ssz] = s_sz(T{i});

expsz = [3,4,4];
expfsz = {[10,2],[5,1],[2,5]};

assert( cell_eq(expfsz, fsz) && all(expsz == ssz) , "Test failed.");
fprintf("Test sucessful!\n");

A{i} = util.struct.aos2soa(T{i});

[fsz, ssz] = s_sz(A{i});

expsz = [1,1];
expfsz = {[10,2,3,4,4],[5,1,3,4,4],[2,5,3,4,4]};

assert( cell_eq(expfsz, fsz) && all(expsz == ssz) , "Test failed.");
fprintf("Test sucessful!\n");

%% Example 2:
i = 2;

S{i}.A = rand(3,2,4,4,10);
S{i}.B = rand(5,4,4,3,2);
S{i}.C = rand(2,3,4,4,5);

[fsz, ssz] = s_sz(S{i});

T{i} = util.struct.soa2aos(S{i});

[fsz, ssz] = s_sz(T{i});

expsz = [3,2];
expfsz = {[4,4,10],[5,4,4],[4,4,5]};

assert( cell_eq(expfsz, fsz) && all(expsz == ssz) , "Test failed.");
fprintf("Test sucessful!\n");

A{i} = util.struct.aos2soa(T{i});

[fsz, ssz] = s_sz(A{i});

expsz = [1,1];
expfsz = {[4,4,10,3,2],[5,4,4,3,2],[4,4,5,3,2]};

assert( cell_eq(expfsz, fsz) && all(expsz == ssz) , "Test failed.");
fprintf("Test sucessful!\n");

%% Example 3:
i = 3;

S{i}.A = rand(3,2,4,4,10);
S{i}.B = rand(5,4,4,3,2);
S{i}.C = rand(4,2,3,4,5);

[fsz, ssz] = s_sz(S{i});

T{i} = util.struct.soa2aos(S{i});

[fsz, ssz] = s_sz(T{i});

expsz = [3,1];
expfsz = {[2,4,4,10],[5,4,4,2],[4,2,4,5]};

assert( cell_eq(expfsz, fsz) && all(expsz == ssz) , "Test failed.");
fprintf("Test sucessful!\n");

A{i} = util.struct.aos2soa(T{i});

[fsz, ssz] = s_sz(A{i});

expsz = [1,1];
expfsz = {[4,4,10,3,2],[5,4,4,3,2],[4,4,5,3,2]};

assert( cell_eq(expfsz, fsz) && all(expsz == ssz) , "Test failed.");
fprintf("Test sucessful!\n");

%% Example 4:
i = 4;

S{i}.A = rand(2,2,4,2,3);
S{i}.B = rand(1,3,4,2,3);

[fsz, ssz] = s_sz(S{i});

T{i} = util.struct.soa2aos(S{i});

[fsz, ssz] = s_sz(T{i});

expsz = [4,2,3];
expfsz = {[2,2],[1,3]};

assert( cell_eq(expfsz, fsz) && all(expsz == ssz) , "Test failed.");
fprintf("Test sucessful!\n");

A{i} = util.struct.aos2soa(T{i});

[fsz, ssz] = s_sz(A{i});

expsz = [1,1];
expfsz = {[2,2,4,2,3],[1,3,4,2,3]};

assert( cell_eq(expfsz, fsz) && all(expsz == ssz) , "Test failed.");
fprintf("Test sucessful!\n");

%% Function defintions

function eq = cell_eq(C1, C2)
    eq = false;
    if length(C1) ~= length(C2)
        return;
    end
    for i = 1:numel(C1)
        try
            if C1{i} ~= C2{i}
                return;
            end
        catch
            return;
        end
    end
    eq = true;
end
