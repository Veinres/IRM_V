function maximise(fig_handles)

if ~exist('fig_handles','var') || isempty(fig_handles)
    % collect all currently open figures
    fig_handles = findall(0, 'Type', 'figure'); 
end

% maximise figues one by one
for i = 1:numel(fig_handles)
    set(fig_handles(i), 'WindowState', 'maximized');
end

end
