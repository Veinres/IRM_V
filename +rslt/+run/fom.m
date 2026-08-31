function [fom, foms] = fom(I_D, I_IRM, t, options)
%FOM calculate the figure-of-merit of the simulated current (fom)
% =========================================================================
% Calculate the figure-of-merit (fom) using one of several predefined
% methods.
%
% ARGUMENTS ---------------------------------------------------------------
%
%   I_D         ((1,:), numeric), The measured discharge current
%
%   I_IRM       ((1,:), numeric), The simulated discharge current
%
%   t           ((1,:), numeric, optional), the time array corresponding to
%                   the supplied current arrays. Used in int, mR2, maxloc,
%                   and xy_pk methods if available.
%
% Name-Value --------------------------------------------------------------
%
%   method      (string, optional, default:'mR2'), Method to calculate fom.
%                   Possible options are:
%                       - 'int'     integrated absolute difference
%                       - 'mR2'     one minus R squared
%                                   (equivalent to int method, but with
%                                   square instead of absolute deviations.
%                                   Use `R2 = 1 - fom` to get actual R
%                                   squared value.)
%                       - 'pk'      difference at I_D max position
%                       - 'max'     difference in max
%                       - 'maxloc'  difference in max location
%                       - 'xy_pk'   euclidean distance between peaks
%
%   baseline    (string, optional, default:'zero') Whether to use
%                   I_IRM(t)=0 or I_IRM(t)=<I_D>_t as the baseline
%                   (baseline => fom=1). To get the proper R2, 'mean'
%                   should be used.
%                       - 'zero'    Compare to case I_IRM(t)=0
%                       - 'mean'    Compare to case I_IRM(t)=<I_D>_t
%
%   weights     (string, optional, default:'none') Whether to use weighted
%                   calculations. Only applies for 1-R2 and int methods.
%                       - 'const'   All points have the same weight
%                       - 'linear'  Points get weighted proportional to I_D
%                       - 'sqrt'    Points get weighted proportional to the
%                                   square root of the current
%                       - '1+lin'   Point get weighted proportional to
%                                   1+I_D/max(I_D)
%
%   cutoff      ((1,2), numeric)    Interval to which fom calculation will
%                                   be restricted. If a valid "t" argument
%                                   is supplied, the interval limits are
%                                   interpreted as times. If no valid "t"
%                                   argument is supplied, the interval
%                                   limits are interpreted as indecies
%                                   instead. If the smaller interval limit
%                                   is out of bounds, it is set to the
%                                   start of the array. If the larger limit
%                                   is out of bounds, it is set to the end
%                                   the array. If no valid "t" argument is
%                                   supplied at least one of the indecies
%                                   has to be positive. The order of the
%                                   interval limits does not matter.
%
% RETURN ------------------------------------------------------------------
%
%   fom         (float), figure of merit
%                   (0 for perfect fit, 1 for I_IRM(t)=0 or <I_D>_t
%                   depending on baseline)
%
%   foms        (struct), figure of merit according to every method
%                   only calculated if second output is actually asigned
%
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ NOTE ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% This function requires Matlab 2019b or later.
% Using complex values might result in undefined behaviour.
% =========================================================================

%% NOTES: -----------------------------------------------------------------

% -------------------------------------------------------------------------

%% Argument parsing and validation
arguments
    % required positional arguments
    I_D (1,:) {mustBeNumeric, mustBeReal}
    I_IRM (1,:) {mustBeNumeric, mustBeReal}
    
    % optional positional arguments
    t (1,:) {mustBeNumeric, mustBeReal} = 1.;
    
    % optional name-value pairs
    options.method {mustBeMember(options.method,{...
                                'int',...       % integral of absolute diff
                                'mR2',...       % sum of square diff
                                'pk',...        % value at discharge peak
                                'max',...       % max value
                                'maxloc',...    % max value location
                                'xy_pk'...      % relative distance of peak
                                })} = 'max'
                            
    options.baseline {mustBeMember(options.baseline,{...
                                'zero',...      % fom=1 at I_IRM(t)=0
                                'mean'...       % fom=1 at I_IRM(t)=<I_D>_t
                                })} = 'mean'
                            
    options.weights {mustBeMember(options.weights,{...
                                'const',...     % constant weights
                                'linear',...    % proportional weights
                                'sqrt'...       % weights proportional to sqrt
                                '1+lin'...      % quasi proportional weights
                                })} = 'const'
                            
    options.cutoff (1,2) {mustBeNumeric} = [0, 0]
end

if length(I_IRM) ~= length(I_D)
    
    if any(cellfun(@(s) strcmp(options.method,s), {'pk','xy_pk','maxloc','int','mR2'}))
        
        warning(strcat("The ",options.method,"-method is not supported for arrays of different size. Defaulting to max-method"));
        options.method = 'max';
    end
end

if length(t) ~= length(I_D)
    
    if any(cellfun(@(s) strcmp(options.method,s), {'xy_pk'}))
        
        warning(strcat("The ",options.method,"-method is not supported for if t array is not supplied. Defaulting to pk-method"));
        options.method = 'pk';
        
    elseif length(t) > 1
        
        warning(strcat("The t argument mus be either have the same size as I_D or be a scalar. Defaulting to t=1."));
        t = 1.;
    end
end

if ~all(options.cutoff == 0) && ( length(I_D) == length(I_IRM) )
    
    if optins.cutoff(1) > options.cutoff(2)
        options.cutoff = flip(options.cutoff);
    end
    
    start_ind = 1;
    end_ind = length(I_ID);
    
    if ( length(t) > 1 ) && ( length(t) == length(I_D) )
        
        start_ind = find(t >= optins.cutoff(1), 'first');
        if start_ind < 1
            % start at beginning if specified starting time is before
            % actual starting time
            start_ind = 1;
        end
        
        end_ind = find(t >= optins.cutoff(2), 'first');
        if end_ind < 1
            % include everything until the end of the pulse if the
            % specified ending time is before the actual starting time or
            % after the actual ending time
            end_ind = length(t);
        end
        
        t = t(start_ind:end_ind);
        
    elseif all(mod(options.cutoff,1) == 1) && ( options.cutoff(2) > 0 )
        % start at the beginning if specified starting index is negative
        % note that the at least one of the indecies has to be positive
        start_ind = max(1, min(options.cutoff(1), length(I_D)) );
        end_ind = min(options.cutoff(2), length(I_D));
    else
        warning("Non-valid cutoff option. Cutoff ignored.");
    end
    
    I_D = I_D(start_ind:end_ind);
    I_IRM = I_IRM(start_ind:end_ind);
end

if nargout>1
    methods = {'int','pk','max','maxloc','mR2','xy_pk'};
    
    if length(I_D) == length(I_IRM) && length(I_D) == length(t)
        methods{end+1} = 'mR2'; %'xy_pk';
    end
else
    methods = {options.method};
end

%% option dependent preparation

I_D_mean = 0.;
if strcmp(options.baseline,'mean')
    if ( length(t) == length(I_D) ) && ( max(t) ~= min(t) )
        I_D_mean = trapz(t,I_D,2)/(max(t)-min(t));
    else
        I_D_mean = mean(I_D);
    end
end

w = 1.;
if strcmp(options.weights,'linear')
    w = abs(I_D);
elseif strcmp(options.weights,'sqrt')
    w = sqrt(abs(I_D));
elseif strcmp(options.weights,'1+lin')
    w = 1+abs(I_D)/max(abs(I_D));
end

%% FOM calculation
for i_m=1:length(methods)
    
    switch methods{i_m}
        case 'mR2'
            fom = trapz(t,w.*(I_D-I_IRM).^2,2);
            fom = fom/trapz(t,w.*(I_D-I_D_mean).^2,2);
            
        case 'int'
            fom = trapz(t,w.*abs(I_D-I_IRM),2);
            fom = fom/trapz(t,w.*abs(I_D-I_D_mean),2);
            
        case 'pk'
            [I_D_pk, i_pk] = max(I_D);
            fom = abs(I_D_pk-I_IRM(i_pk))/abs(I_D_pk-I_D_mean);
            
        case 'max'
            fom = abs(max(I_D)-max(I_IRM))/abs(max(I_D-I_D_mean));
            
        case 'maxloc'
            [~, i_D_pk] = max(I_D);
            [~, i_IRM_pk] = max(I_IRM);
            if (i_IRM_pk == 1) && (i_D_pk ~= 1) % => no maximum (i.e. flat curve)
                fom = 1.;
            elseif ( length(t) == length(I_D) ) && ( max(t) ~= min(t) )
                fom = abs(t(i_D_pk)-t(i_IRM_pk))/(max(t)-min(t));
            else
                fom = abs(i_D_pk-i_IRM_pk)/length(I_D);
            end
            
        case 'xy_pk'
            [I_D_pk, i_D_pk] = max(I_D);
            [I_IRM_pk, i_IRM_pk] = max(I_IRM);
            
            if (i_IRM_pk == 0) && (i_D_pk ~= 0) % => no maximum (i.e. flat curve)
                fom = 1.;
            else
                fom = (I_D_pk-I_IRM_pk)^2/I_D_mean^2;
                
                if ( length(t) == length(I_D) ) && ( max(t) ~= min(t) )
                    fom = fom + (t(i_D_pk)-t(i_IRM_pk))^2/(max(t)-min(t))^2;
                else
                    fom = fom + (i_D_pk-i_IRM_pk)^2/(length(I_D))^2;
                end
                
                fom = sqrt(fom);
            end
            
    end
    foms.(methods{i_m}) = fom;
end

fom = foms.(options.method);

end
