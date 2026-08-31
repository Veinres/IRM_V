function [outputs, inputs] = runs(output, input, metadata, options)
%RUNS extract the outputs and inputs for the runs of a parameter scan
% =========================================================================
% When collecting the results of a parameter scan, only the input deltas
% and the solution vector of each run are kept. This function can be used
% to rebuild the inputs and reconstruct the full outputs of all runs of a
% parameter scan.
%
% Usually, the output of most runs is not of much interest and since this
% is a rather time-consuming operation, the 'nrs' keyword argument can be
% used to specify a subset of runs to process. The returned cell arrays
% will still have one cell per run, but only cells corresponding to the
% specified runs will be non-empty.
%
% If a parallel pool is running, the different runs will be processed in
% parallel.
%
% See also : rslt.run.output
%
% ARGUMENTS ---------------------------------------------------------------
%
%   output      (struct), raw output of runs
%
%   input       (struct), input for runs
%
%   metadata    (table), metadata for the runs
%
% NAME-VALUE --------------------------------------------------------------
%
%   'nrs'       (double, (:,1)), numbers of the runs for which the output
%                   should be extracted
%
% RETURN ------------------------------------------------------------------
%
%   outputs     (cell), detailed outputs
%
%   inputs      (cell), reconstructed inputs
%
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ NOTE ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% This function requires Matlab 2019b or later.
% =========================================================================

%% NOTES: -----------------------------------------------------------------
% -------------------------------------------------------------------------

%% Argument parsing and validation
arguments
   output struct
   input struct
   metadata table
end
arguments
    options.nrs (:,1) = 1:length(output.n)
end

%%

n_runs = length(output.n);
outputs = cell([n_runs, 1]);
inputs = cell([n_runs, 1]);

t = output.t;
n = output.n;
diff = input.diff;
base_input = input.input;
skip = true([n_runs,1]);
skip(options.nrs) = false;
p_vals = metadata.p_vals;

n_workers = 1;
if ~isempty(gcp('nocreate'))
    n_workers = gcp().NumWorkers;
end
if n_workers > 1
    parfor i = 1:length(outputs)
        if skip(i); continue; end
        tmp = util.struct.apply(base_input, diff{i});
        inputs{i} = tmp;
        inputs{i} = tmp;
        if ~isfield(inputs{i}.Rea, 'Rt') % for compatibility
            inputs{i} = adjustInput(tmp, p_vals{i}.f, p_vals{i}.beta_t, p_vals{i}.r); % NOTE : this should just be a temporary fix % FIXME
        end
        % also doesn't work if sd or z2 are fitting parameters
        outputs{i} = rslt.run.output(t{i}, n{i}, inputs{i});
    end
else
    for i = 1:length(outputs)
        if skip(i); continue; end
        tmp = util.struct.apply(base_input, diff{i});
        inputs{i} = tmp;
        if ~isfield(inputs{i}.Rea, 'Rt') % for compatibility
            inputs{i} = adjustInput(tmp, p_vals{i}.f, p_vals{i}.beta_t, p_vals{i}.r); % NOTE : this should just be a temporary fix % FIXME
        end
        % also doesn't work if sd or z2 are fitting parameters
        outputs{i} = rslt.run.output(t{i}, n{i}, inputs{i});
    end
end

end
