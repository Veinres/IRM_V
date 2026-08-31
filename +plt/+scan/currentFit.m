function [fig] = currentFit(summary, inputs, outputs)
%CURRENTFIT plot the free and constrained current fits
    i_free = summary.nr.free;
    i_cnst = summary.nr.cnst;
    I_fit_free = [1e+6*outputs.t{i_free}, outputs.I_IRM{i_free}];
    if ~isnan(i_cnst)
        I_fit_cnst = [1e+6*outputs.t{i_cnst}, outputs.I_IRM{i_cnst}];
    else
        I_fit_cnst = [1e+6*outputs.t{i_free}, nan([length(outputs.t{i_free}),1])];
    end
    fig = plt.disch('', ...
        I_fit_cnst, 'left', '$I_{\rm IRM, cnst}$', {}, ...
        I_fit_free, 'left', '$I_{\rm IRM, free}$', {}, ...
        'Struct', inputs.input.disch);
    extra_time = 10;
    xlims(1) = util.num.roundTo(max(min(inputs.input.disch.T), - extra_time), 10, 'Multiples', true, 'Direction', 'down');
    if isfield(inputs.input.disch, 't_pulse_end')
        xlims(2) = util.num.roundTo(min(max(inputs.input.disch.T), inputs.input.disch.t_pulse_end + extra_time), 10, 'Multiples', true, 'Direction', 'up');
    else
        xlims(2) = util.num.roundTo(max(inputs.input.disch.T), 10, 'Multiples', true, 'Direction', 'down');
    end
    xlim(xlims);
    if isfield(summary, 'expnr')
        ax = gca;
        ax.Subtitle.String = sprintf("%d : %s", summary.expnr, ax.Subtitle.String);
    end
end
