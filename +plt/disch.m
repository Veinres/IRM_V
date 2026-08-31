function fig = disch(filename, y_t, yaxis, label, pltArgs, options)
%DISCH plot an irm input structure (disch)
% =========================================================================
% Import a discharge .mat file or plot a discharge structure "disch" in the
% current workspace.
%
% ARGUMENTS ---------------------------------------------------------------
%
%   filename    (string, file), path to discharge .mat-file
%                   The .mat-file must contain a structure named "disch"
%                   with fields:
%                   - U                         : discharge voltage
%                   - I                         : discharge current 
%                   - T                         : time
%                   - dt (optional)             : time step
%                   - p (optional)              : pressure
%                   - F_flux (optional)         : ionized flux fraction
%                   - t_pulse_end (optional)    : pulse duration (beta
%                                                  cutoff)
%                   Will attempt to plot a struct with name "disch" in the
%                   current workspace instead if no filename is specified.
%
% REPEATING ARGUMENTS -----------------------------------------------------
%
%   y_t         (double, (:,2)), additional curve
%                   1st collumn : time
%                   2nd collumn : value
%
%   yaxis       (char), which axis to plot on {'left', 'right'}
%
%   label       (char), legend string
%
%   pltArgs     (cell), Additional arguments for the plot function
%
% NAME-VALUE --------------------------------------------------------------
%
%   'Disp'      (logical), wether to display the structure
%
%   'Struct'    (struct), plot discharge struct instead
%
%   'xLim'      (double, (1,2)) : x-axis limits
%
%   'I_fit'     (double, (:,2)), fitted current and time
%                   1st collumn : time
%                   2nd collumn : current
%
% RETURN ------------------------------------------------------------------
%
%   fig         (figure handle), plotted figure
%
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ NOTE ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% This function requires Matlab 2019b or later.
% =========================================================================

%% NOTES: -----------------------------------------------------------------
% -------------------------------------------------------------------------

%% Argument parsing and validation
arguments
    filename char = ''
end
arguments (Repeating)
    y_t (:,2) double
    yaxis char {mustBeMember(yaxis, {'left', 'right'})}
    label char
    pltArgs cell
end
arguments
    options.Disp logical = false
    options.Struct struct = struct()
    options.xLim (1,2) double = [0,0]
    options.I_fit (:,2) double = []
end

%% Select disch structure
if ~isempty(fields(options.Struct))
    disch = options.Struct;
else
    if isempty(filename)
        % dirty trick to allow calling plotDisch without an argument
        if evalin('caller', "exist('disch','var')")
            disch = evalin('caller', 'disch');
        else
            fig = [];
            warning("Could not plot discharge. No filename specified and no disch structure present in workspace.");
            return;
        end
    elseif isfile(filename)
        try
            disch = load(filename, 'disch').disch;
        catch
            fig = [];
            warning("Could not plot discharge.");
            return;
        end
    else
        fig = [];
        warning("Could not plot discharge. Specified file does not exist.");
        return;
    end
end

%% Plot disch structure
if options.Disp
    disp(disch);
end
additional_curves = util.base.distribute(y_t, yaxis, label, pltArgs);
fig = plotDisch(disch, options.xLim, options.I_fit, additional_curves);

end

%% Functions

function fig = plotDisch(disch, tlim, I_fit, additional_curves)
%PLOTDISCH plot a discharge structure (IRM input)
    if isfield(disch,'U')
        U_ = 'U';
    else
        U_ = 'V';
    end
    if ~isempty(I_fit)
        fig = plt.cv(disch.I, disch.(U_), disch.T, additional_curves{:}, ...
            "xLim", tlim, "I_fit", I_fit, 'MaxTicks', 5, 'MinTicks', 2);
    else
        fig = plt.cv(disch.I, disch.(U_), disch.T, additional_curves{:}, ...
            "xLim", tlim, "MaxTicks", 5, "MinTicks", 2);
    end
    if isfield(disch,'t_pulse_end')
        figure(fig);
        hold on;
        scatter(disch.t_pulse_end,0,'ko');
        % remove corresponding legend entry
        fig.CurrentAxes.Legend.String = fig.CurrentAxes.Legend.String(1:end-1);
        if tlim(1) == tlim(2)
            xlims = xlim();
            xlims(2) = util.num.roundTo(disch.t_pulse_end*1.1, 0:50:5000, ...
                'Direction', 'up');
            xlim(xlims);
        end
    end
    str = "";
    if isfield(disch,'p')
        str = strcat("$p=",sprintf("%4.2f",disch.p),"\rm{Pa}$");
    end
    if isfield(disch,'F_flux')
        if ~isempty(str)
            str = strcat(str, ", ");
        end
        str = strcat(str, "$F_\mathrm{flux}=", sprintf("%i",round(100*disch.F_flux)),"\%$");
    end
    if ~isempty(str)
        figure(fig);
        subtitle(str, ...
            'FontSize', fig.CurrentAxes.Legend.FontSize, ...
            'Interpreter', 'latex');
    end
end
