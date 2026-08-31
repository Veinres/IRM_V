function out = output(t, n, input, options)
%OUTPUT compute fluxes and rates etc. from densities
% =========================================================================
%
%   See also: rslt.run.output, rslt.run.fom
%
% ARGUMENTS ---------------------------------------------------------------
%
%   t           (double (:,1)), simulation time of IRM run
%
%   n           (double (:,n_species)), time-resolved density of species
%
%   input       (struct), input used for IRM run
%
% NAME-VALUE --------------------------------------------------------------
%
%   'SaveLocation'  (char), directory where .mat files should be saved
%                       By default, nothing is saved.
%
% RETURN ------------------------------------------------------------------
%
%   out         (struct), struct containing time-resolved properties
%
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ NOTE ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% This function requires Matlab 2019b or later.
% =========================================================================

%% NOTES: -----------------------------------------------------------------
% -------------------------------------------------------------------------

%% Argument parsing and validation
arguments
    t (:,1) double
    n (:,:) double
    input struct
    options.SaveLocation char = ''
end

%%

for i=1:length(t)
    % plug the obtained solutions into ODEfile to obtain the 'out.'
    [dndt_, out_] = ODEfile(t(i) , n(i,:), input);
    out.dndt(i,:) = dndt_; % combine the rates of species into 'out'
    % Write them into the 'Out' structure which includes the time as well
    if i == 1
        fn = fieldnames(out_);
        fnN = length(fn);
    end
    for k = 1:fnN
        [a,b] = size(out_.(fn{k}));
        if a == 1 && b == 1 % If the quantity is scalar at time t
            out.(fn{k})(i,1) = out_.(fn{k});
        elseif a == 1 || b == 1 % the quantity is a vector at time t
            out.(fn{k})(i,:) = out_.(fn{k});
        else % if the quantiy is a 2D matrix at time t
            out.(fn{k})(i,:,:) = out_.(fn{k});
        end
    end
end

% The densities and time vector have been calculated by the first run of
% the solver already, we add them on the 'Out' structure.
out.n = n;
out.t = t;

% Saving output
if ~isempty(options.SaveLocation)
    save(fullfile(options.SaveLocation,'Output'), '-struct', 'out');
end

end
