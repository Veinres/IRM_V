function [summary, metadata, results, inputs, outputs, best] = collect(foldername, options)
%COLLECT collect the results of a parameter scan
% =========================================================================
% Collect the results from individual runs of a parameter scan from the
% "Input", "Output", "Analysed", "Additional" and "Metadata" .mat-files
% in the respective "run_Pfit" folders.
%
% See also : rslt.study.summarise , rslt.study.collect
%
% ARGUMENTS ---------------------------------------------------------------
%
%   foldername  (string, folder), path to results of parameter scan
%
% NAME-VALUE --------------------------------------------------------------
%
%   'SaveLocation'  (string, optional, default=''), save location
%                       Location where collected results will be saved.
%                       There are three options:
%                       If the save location is
%                       1. a .mat file (has a .mat extension),
%                          the results will be saved as a single .mat file
%                       2. not a mat file (has no .mat extension),
%                          the results will be saved as individual .mat
%                          files (summary.mat, metadata.mat, results.mat,
%                          input.mat, output.mat, and best.mat) at the
%                          specified location (possible file extensions in
%                          the specified path will be discarded)
%                          % FIXME: file extensions other than .mat should
%                          raise an error instead
%                       3. is empty,
%                          the results will not be saved
%
%   'Id'            (string, optional, default=''), simulation identifier
%                       Will be used in summary. Can be helpful when
%                       joining summaries of different simulations.
%
%   'Constraint'    (function handle, optional), fitting constraint
%                       Can be used to apply custom constraints when
%                       fitting. Takes the results table as input and must
%                       produce either a list of indecies of the accepted
%                       runs or a logical array of length <n_runs>.
%                       Example:
%                           foo = @(res) abs(res.F_dep - 0.5) < 0.1
%                       For a list of available fields, consult the
%                       description of the return values below.
%
%   'FFluxLim'      (double array (2,1), optional), Acceptance bounds for
%                       IFF. Can be used instead of a custom constraint
%                       function.
%
%                       NOTE: if neither Constraint nor FFluxLim are
%                       specified and the disch structure has a measured
%                       ionised flux fraction, that ionised flux fraction
%                       is used with a tolerance of 5%
%
% RETURN ------------------------------------------------------------------
%
%   summary     (table), overview of the most important results of the
%                   whole parameter scan
%                   Fields:
%                   - id            identifier for parameter scan
%                   - nr            numbers of best fit (*)
%                   - r             recapture probability (*)
%                   - beta_t_p      back-attraction probability (*)
%                   - f             IR potential drop fraction (*)
%                   - beta_t_av     average back-attraction probability (*)
%                   - alpha_t_p     average ion. proba. during pulse (*)
%                   - alpha_t_av    average ion. probability (*)
%                   - F_flx         ionized flux fraction (*)
%                   - F_ion         target material ion. fraction (*)
%                   - F_dep         deposition rate fraction (*)
%                   - F_cur         max. target mat. ion current fract. (*)
%                   - F_rar         max. working gas rarefaction (*)
%                   - foms          different figures-of-merit (*)
%                   - date          date of execution
%                   - n_runs        number of runs
%                   - t_exec_int    internal (/integration) execution time
%                   - t_exec_tot    total execution time
%                   (*) these fields have subfields for the best fit with
%                   (cnst) and without (free) constraints
%
%   metadata    (table), metadata for each individual run
%                   Fields:
%                   - nr            number
%                   - p_vals        fitting parameter values
%                   - t_start       starting time
%                   - t_exec        execution time
%                   - t_end         value of indep. var. at end of sim.
%                   - n_eval        number of integrand evaluations
%                   - exit_status   exit status
%                                   - "success"
%                                   - "unknown"
%                                   - "failure:limit:stepSize"
%                                   - "failure:limit:numberOfCalls"
%                                   - "failure:limit:executionTime"
%                                   - "failure:error"
%                   - path          path to results
%
%   results     (table), analysis (scalar) results for individual runs
%                   Fields:
%                   - nr            number
%                   - r             recapture proba.
%                   - beta_t_p      back-attraction proba. during pulse
%                   - f             IR pot. drop fraction
%                   - fom           figure-of-merit
%                   - beta_t_av     average back-attraction proba.
%                   - alpha_t_p     average ion. proba. during pulse
%                   - alpha_t_av    average ion. proba.
%                   - F_flx         ionized flux fraction
%                   - F_ion         target material ion. fraction
%                   - F_dep         deposition rate fraction
%                   - F_cur         max. target material ion current fract.
%                   - F_rar         max. working gas rarefaction
%                   - foms          different figures-of-merit
%
%   inputs      (struct), (compressed) input for individual runs
%                   Fields:
%                   - input         input for representative sim. run
%                   - diff          diff. for each run input compared to
%                                   the representative input (prev. field)
%                                   (*)
%                   - hash          hash of input (WIP)
%                   - src_hash      hash of source code at execution (WIP)
%                   - git_id        git commit sha1 id at execution
%                   (*) the original input for each run can be
%                   reconstructed using util.struct.apply(input, diff{i})
%
%   outputs     (struct), raw output (t, n(t), I(t)) for individual runs
%                   Fields:
%                   - t             values of indep. var.
%                   - n             values of dep. var.
%                   - I_IRM         the reconstructed discharge current
%                   - i2s           map from indices to species
%                   - s2i           map from species to indices
%
%   best        (struct), all (analysed) output results for best fit runs
%                   Fields:
%                   - free          sim. output for best fit w/o constraint
%                   - cnst          sim. output for best fit w/ constraint
%
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ NOTE ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% This function requires Matlab 2019b or later.
% =========================================================================

%% NOTES: -----------------------------------------------------------------
% -------------------------------------------------------------------------

%% Argument parsing and validation
arguments
    foldername char {mustBeFolder}
    options.SaveLocation char = ''
    options.Id string = ""
    options.Constraint = []
    options.FFluxLim (1,2) double = [Inf,Inf]
end

%% Fetch directory names
files = dir(foldername);
files = files([files.isdir] & ...
    cellfun(@(x) length(x) >= 8 && strcmp(x(1:8),"run_Pfit"),{files.name}));
n_runs = length(files);

%% Setup tables
% overall result (best fom/flux) and stats
summary     = setup_summary(n_runs);
% metadata for individual runs
metadata    = setup_metadata(n_runs);
% results of individual runs
results     = setup_results(n_runs);
% input parameters
inputs       = setup_input(n_runs);
% output {n(t), I(t), t}
outputs      = setup_output(n_runs);
% best fit results
best        = struct();

%% Import results
for i_run = 1:n_runs
    path = fullfile(files(i_run).folder,files(i_run).name);
    % try and load everything
    [metadata_, analysed_, input_, output_, additional_] = load_mat_files(path);

    % input
    t_target = NaN;
    if ~isempty(input_)
        if isempty(fields(inputs.input))
            inputs.input = input_;
        end
        t_target = input_.solver.time(end);
        inputs.diff{i_run} = util.struct.diff(inputs.input, input_);
        inputs.hash(i_run) = NaN; %FIXME : struct.hash(input_); (get from metadata - compute at simtime)
    end
    if isempty(inputs.src_hash)
        inputs.src_hash = NaN; % FIXME : src.hash(); (get from scan metadata)
    end
    if isempty(inputs.git_id)
        inputs.git_id = NaN; % FIXME : git.head(); (get from scan metadata)
    end

    % output
    if ~isempty(output_) 
        outputs.t{i_run} = output_.t;
        outputs.I_IRM{i_run} = sum(output_.I,2);
        outputs.n{i_run} = output_.n;
    end
    if ~isempty(input_)
        if isempty(outputs.i2s)
            outputs.i2s = input_.Spe.Names;
        end
        if isempty(fields(outputs.s2i))
            outputs.s2i = input_.Spe.s;
        end
    end

    % metadata
    mat_files = dir(fullfile(path,"*.mat"));
    if ~isempty(metadata_)
        metadata.nr(i_run)          = try_field(metadata_, "nr"         , i_run);
        metadata.p_vals{i_run}      = try_field(metadata_, "p_vals"     , p_vals(input_));
        metadata.t_start(i_run)     = try_field(metadata_, "t_start"    , start_time(mat_files));
        metadata.t_exec(i_run)      = try_field(metadata_, "t_exec"     , t_exec(mat_files));
        metadata.t_end(i_run)       = try_field(metadata_, "t_end"      , t_end(output_));
        metadata.n_eval(i_run)      = try_field(metadata_, "n_eval"     , NaN);
        metadata.exit_status(i_run) = try_field(metadata_, "exit_status", 'unknown');
        metadata.path(i_run)        = try_field(metadata_, "path"       , path);
    else
        metadata.nr(i_run)          = i_run;
        metadata.p_vals{i_run}      = p_vals(input_);
        metadata.t_start(i_run)     = datetime(t_start(mat_files), 'convertFrom', 'datenum');
        metadata.t_exec(i_run)      = t_exec(mat_files);
        metadata.t_end(i_run)       = t_end(output_);
        metadata.n_eval(i_run)      = NaN;
        metadata.exit_status(i_run) = 'unknown';
        metadata.path(i_run)        = path;
    end

    % results
    results.nr(i_run) = metadata.nr(i_run);
    if ~isempty(analysed_)
        % fitting parameters
        results.r(i_run)            = try_field(analysed_, "r", NaN);
        results.beta_t_p(i_run)     = try_field(analysed_, "beta1", NaN);
        results.f(i_run)            = try_field(analysed_, "f", NaN);
        % fom
        results.fom(i_run)          = try_field(analysed_, "fom", NaN);
        % back attraction probability
        results.beta_t_av(i_run)    = try_field(analysed_, "beta_av", NaN);
        % ionization probability
        results.alpha_t_p(i_run)    = try_field(analysed_, "alpha_R", NaN);
        results.alpha_t_av(i_run)   = try_field(analysed_, "alpha_R_all", NaN);
        % fractions (deposition, ion. flux, ion. density)
        results.F_flx(i_run)        = try_field(analysed_, "F_flux", NaN);
        results.F_ion(i_run)        = try_field(analysed_, "F_density", NaN);
        results.F_dep(i_run)        = try_field(analysed_, "Fdep_Gamma", NaN);
        results.F_cmp(i_run)        = metadata.t_end(i_run)/t_target;
        results.foms{i_run}         = try_field(metadata_, "foms", foms(analysed_)); % metadata.foms{i_run};
    end
    if ~isempty(output_) && ~isempty(input_) && length(output_.t) > 1
        % target ion current fraction
        target_ion = ismember(input_.Spe.PSpecies,input_.Spe.Target) & ...
            (input_.Spe.Q > 0);
        working_gas_ion = ismember(input_.Spe.PSpecies,input_.Spe.Refill_gases) & ...
            (input_.Spe.Q > 0);
        results.F_cur(i_run) = trapz(output_.t,sum(output_.I(:,target_ion),2))/...
            trapz(output_.t,sum(output_.I,2));
        % max rarefaction min(sum(n_wg(t))/sum(n_wg(0)))
        ar_neutral = ismember(input_.Spe.PSpecies,input_.Spe.Refill_gases) & ...
            (input_.Spe.Q == 0);
        results.F_rar(i_run) = min(sum(output_.n(:,ar_neutral),2))/sum(output_.n(1,ar_neutral),2);
    else
        results.F_cur(i_run) = NaN;
        results.F_rar(i_run) = NaN;
    end

end
% convert cell array to struct where possible
cell_vars = {'p_vals', 'foms'};
% FIXME : this might be problematic later on, if it is always assumed that
% p_vals and foms is a struct. At the same time, this should only fail, if
% the foms / p_vals structures don't have the same fields for each run,
% which shouldn't be the case anyway.
% Might be an issue when concatenating results from different parameter
% scans, but there is no good reason to do so anyway.
for i = 1:length(cell_vars)
    try
        if isfield(metadata, cell_vars{i})
            tmp = cell2struct(metadata.(cell_vars{i})); % FIXME
            metadata.(cell_vars{i}) = tmp;
        end
    catch ME
    end
    try
        if isfield(results, cell_vars{i})
            tmp = cell2struct(results.(cell_vars{i})); % FIXME
            results.(cell_vars{i}) = tmp;
        end
    catch ME
    end
end

% summary
flds = {'nr','r','beta_t_p','f','fom'};
flds = horzcat(flds,  {'beta_t_av', 'alpha_t_p', 'alpha_t_av'});
flds = horzcat(flds,  { 'F_flx' , 'F_ion' , 'F_dep' , 'F_cur' , 'F_rar'});
flds = horzcat(flds,  { 'F_cmp'});
flds = horzcat(flds,  { 'foms'});
% free (best fit without constraints)
[~, i_free] = min(results.fom);
for i = 1:length(flds)
    summary.(flds{i}).free = results.(flds{i})(i_free);
end
% constrained (best fit under some constraints)
% 1. if available, use explicit constraint function
% 2. failing that, if available, use explicit IFF bounds
% 3. failing that, use the IFF value specified in the disch structure +-5%
% 4. failing that, leave best fit under constraints empty
admissible = [];
if isa(options.Constraint,'function_handle')
    try
        admissible = options.Constraint(results);
    catch ME
        warning("irm:results:collect:ConstraintEvaluationFailure", ...
            "Evaluation of custom constraint function failed. Falling back to IFF bounds.");
        if options.FFluxLim(1) < 1 && options.FFluxLim(2) > options.FFluxLim(1)
            admissible = results.F_flux >= options.FFluxLim(1) & ...
                results.F_flux <= options.FFluxLim(2);
        else
            warning("irm:results:collect:InvalidIFFBounds", ...
                "IFF bounds do not intersect a finite interval between 0 and 1.");
            admissible = [];
        end
    end
else
    if isnan(options.FFluxLim(2) - options.FFluxLim(1)) && ...
       isfield(inputs.input.disch, "F_flux")
       tol = 0.05; % default 5% tolerance on IFF
       options.FFluxLim(1) = inputs.input.disch.F_flux - tol;
       options.FFluxLim(2) = inputs.input.disch.F_flux + tol;
    end
    if options.FFluxLim(1) < 1 && options.FFluxLim(2) > options.FFluxLim(1)
        admissible = results.F_flx >= options.FFluxLim(1) & ...
            results.F_flx <= options.FFluxLim(2);
    else
        warning("irm:results:collect:InvalidIFFBounds", ...
            "IFF bounds do not intersect a finite interval between 0 and 1.");
        admissible = [];
    end
end
if ~isempty(admissible) && any(admissible)
    nrs = results.nr(admissible);
    fom = results.fom(admissible);
    [~, i_cnst] = min(fom);
    i_cnst = nrs(i_cnst);
    for i = 1:length(flds)
        summary.(flds{i}).cnst = results.(flds{i})(i_cnst);
    end
else
    for i = 1:length(flds)
        summary.(flds{i}).cnst = NaN;
    end
end
if ~isempty(options.Id)
    summary.id = options.Id;
else
    tmp = split(foldername, {'\', '/'});
    summary.id = tmp{end};
end
summary.date = min(metadata.t_start);
summary.n_runs = height(metadata);
summary.t_exec_int = seconds(sum(metadata.t_exec));
summary.t_exec_int.Format = "hh:mm:ss";
summary.t_exec_tot = max(metadata.t_start + metadata.t_exec*(1/86400)) - min(metadata.t_start);
summary.t_exec_tot.Format = "hh:mm:ss";
% export best results
if summary.nr.free > 0
    best.free = load(fullfile(metadata.path(summary.nr.free),'Output.mat'));
end
if summary.nr.cnst > 0
    best.cnst = load(fullfile(metadata.path(summary.nr.cnst),'Output.mat'));
end

%% Export collected results
if ~isempty(options.SaveLocation)
    [fpath, fname, fext] = fileparts(options.SaveLocation);
    if strcmp(fext,'.mat')
        try
            save(fullfile(options.SaveLocation), ...
                "summary", "metadata", "results", "inputs", "outputs", "best");
        catch ME
            warning("An error occured while trying to save results to <%s> :", ...
                fullfile(options.SaveLocation));
            disp(ME.message)
        end
    elseif isempty(fext)
        objs = ["summary", "metadata", "results", "input", "output", "best"];
        if ~isfolder(fullfile(fpath, fname))
            mkdir(fullfile(fpath, fname));
        end
        for i = 1:length(objs)
            try
                save(fullfile(fullfile(fpath, fname), strcat(objs{i},".mat")), ...
                    objs{i});
            catch ME
                warning("An error occured while trying to save <%s> to <%s> :", ...
                    objs{i}, fullfile(fullfile(fpath, fname), strcat(objs{i},".mat")));
                disp(ME.message)
            end
        end
    else
        warning("Invalid save location. 'SaveLocation' must be either a .mat file or a folder. Collected results have not been saved.");
    end
end

end

%% Function definitions

function [summary] = setup_summary(n_runs)
    vars = {'nr'    , 'r'     , 'beta_t_p', 'f'     , 'fom'   };
    vars = horzcat(vars,  {'beta_t_av', 'alpha_t_p', 'alpha_t_av'});
    vars = horzcat(vars,  { 'F_flx' , 'F_ion' , 'F_dep' , 'F_cur' , 'F_rar'});
    vars = horzcat(vars,  { 'F_cmp'});
    vars = horzcat(vars,  { 'foms'});
    n_vars   = length(vars);
    types   = repmat({'table'}, [1,n_vars]);

    summary = table('Size', [1,n_vars], ...
        'VariableTypes', types, ...
        'VariableNames', vars);
    for i = 1:n_vars-1
        summary.(vars{i}) = table('Size', [1,2], ...
            'VariableTypes', {'double', 'double'}, ...
            'VariableNames', {'free'   , 'cnst'});
    end
    summary.(vars{n_vars}) = table('Size', [1,2], ...
            'VariableTypes', {'struct', 'struct'}, ...
            'VariableNames', {'free'   , 'cnst'});

    summary.id = string();
    summary.date = datetime();
    summary.n_runs = n_runs;
    summary.t_exec_int = 0;
    summary.t_exec_tot = 0;
    summary = movevars(summary, 'id', 'before', 'nr');
end

function [metadata] = setup_metadata(n_runs)
%SETUP_METADATA setup table for simulation runs metadata

    % metadata for individual runs
    vars = {'nr'    , 'p_vals', 't_start' , 't_exec', 't_end'};
    types= {'double', 'cell'  , 'datetime', 'double', 'double'};
    vars = horzcat(vars, {'n_eval', 'exit_status', 'path'  }); % , 'foms'
    types= horzcat(types,{'double' , 'categorical', 'string'}); % , 'cell'
    n_vars = length(vars);
    metadata = table('Size', [n_runs,n_vars], ...
        'VariableTypes', types, ...
        'VariableNames', vars);
end

function [results] = setup_results(n_runs)
%SETUP_RESULTS setup table for simulation runs results

    % results of individual runs
    vars = {'nr'    , 'r'     , 'beta_t_p', 'f'     , 'fom'   };
    types= {'double', 'double', 'double'  , 'double', 'double'};
    vars = horzcat(vars,  {'beta_t_av', 'alpha_t_p', 'alpha_t_av'});
    types= horzcat(types, {'double'   , 'double'   , 'double'  });
    vars = horzcat(vars,  { 'F_flx' , 'F_ion' , 'F_dep' , 'F_cur' , 'F_rar'});
    types= horzcat(types, { 'double', 'double', 'double', 'double', 'double'});
    vars = horzcat(vars,  { 'F_cmp'});
    types= horzcat(types, { 'double'});
    vars = horzcat(vars,  { 'foms'});
    types= horzcat(types, { 'cell'});
    n_vars = length(vars);
    results = table('Size', [n_runs,n_vars], ...
        'VariableTypes', types, ...
        'VariableNames', vars);
end

function [output] = setup_output(n_runs)
%SETUP_OUTPUT setup structre for simulation run outputs

    % output {n(t), I(t), t}
    output.t            = cell([n_runs,1]);
    output.I_IRM        = cell([n_runs,1]);
    output.n            = cell([n_runs,1]);
    output.i2s          = cell(0); % dummy
    output.s2i          = struct(); % dummy
end

function [input] = setup_input(n_runs)
%SETUP_INPUT setup structure for simulation run inputs

    % input parameters
    input.input = struct(); % dummy
    input.diff  = cell([n_runs,1]);
    input.hash  = repmat(string(), [n_runs,1]);
    input.src_hash = string();
    input.git_id = string();
end

function [metadata_, analysed_, input_, output_, additional_] = load_mat_files(path)
%LOAD_MAT_FILES try and load matfiles associtated with simulation run
    if exist(fullfile(path,'Metadata.mat'),'file')
        try
            metadata_ = load(fullfile(path,'Metadata.mat'));
        catch ME
            metadata_ = [];
        end
    else
        metadata_ = [];
    end
    if exist(fullfile(path,'Analysed.mat'),'file')
        try
            analysed_ = load(fullfile(path,'Analysed.mat'));
        catch ME
            analysed_ = [];
        end
    else
        analysed_ = [];
    end
    if exist(fullfile(path,'Input.mat'),'file')
        try
            input_ = load(fullfile(path,'Input.mat'));
        catch ME
            input_ = [];
        end
    else
        input_ = [];
    end
    if exist(fullfile(path,'Output.mat'),'file')
        try
            output_ = load(fullfile(path,'Output.mat'));
        catch ME
            output_ = [];
        end
    else
        output_ = [];
    end
    if exist(fullfile(path,'Additional.mat'),'file')
        try
            additional_ = load(fullfile(path,'Additional.mat'));
        catch ME
            additional_ = [];
        end
    else
        additional_ = [];
    end
end

function val = try_field(S, fld, fallback)
%TRY_FIELD return value of field if it exists and fallback otherwise
    if isfield(S, fld)
        val = S.(fld);
    else
        val = fallback;
    end
end

%% Fallback functions

function pvals = p_vals(input)
%P_VALS extract parameter values from input struct
    pvals = struct();
    if ~isempty(input) && ...
        isfield(input,'r') && ...
        isfield(input,'beta') && ...
        isfield(input,'f')
        
        pvals.r = input.r;
        pvals.beta_t = input.beta;
        pvals.f = input.f;
    end
end

function time = t_start(mat_files)
%START_TIME get start time from input file timestamp
    input_file = mat_files(strcmp("Input.mat",{mat_files.name}));
    if ~isempty(input_file) && isfield(input_file,'datenum')
        time = input_file.datenum;
    else
        time = 0;
    end
end

function time = t_exec(mat_files)
%T_EXEC calculate execution time from file timestamps
    input_file = mat_files(strcmp("Input.mat",{mat_files.name}));
    if ~isempty(input_file) && isfield(input_file,'datenum')
        start_time = input_file.datenum;
    else
        start_time = 0;
    end
    output_file = mat_files(strcmp("Output.mat",{mat_files.name}));
    if ~isempty(output_file) && isfield(output_file,'datenum')
        end_time = output_file.datenum;
    else
        end_time = 0;
    end
    time = (end_time - start_time)*86400;
end

function t_end = t_end(output_)
%T_END get last value of indep. var from simulation output
    if ~isempty(output_)
        t_end = max(output_.t);
    else
        t_end = NaN;
    end
end

function foms = foms(analysed_)
%FOMS get foms from analysed.mat
    foms = struct();
    if ~isempty(analysed_)
        foms = try_field(analysed_, "foms", struct());
    end
end
