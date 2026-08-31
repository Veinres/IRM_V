function txt = label_from_savelocation(savepath)

% TODO : this is specific to the Cu-IRM paper and should therefore be moved

discharges = cell(0);
label = cell(0);
% Historic discharges
discharges{end+1} = {'ArCu','HiPSTER','20A'};
%label{end+1} = 'a) I';
label{end+1} = '(a)';
discharges{end+1} = {'ArCu','Sinex2','04Pa'};
%label{end+1} = 'b) II';
label{end+1} = '(b)';
discharges{end+1} = {'ArCu','Sinex2','27Pa'};
%label{end+1} = 'c) III';
label{end+1} = '(c)';
% % IFF measurements discharges
discharges{end+1} = {'ArCu','HiPSTER','40us','0.5Pa','180A'};
%label{end+1} = 'a) A';
label{end+1} = '(a)';
discharges{end+1} = {'ArCu','HiPSTER','80us','0.4Pa','165A'};
%label{end+1} = 'b) B';
label{end+1} = '(b)';
discharges{end+1} = {'ArCu','HiPSTER','80us','2.7Pa','235A'};
%label{end+1} = 'c) C';
label{end+1} = '(c)';

for i_d = 1:length(discharges)
    correct = true;
    for j = 1:length(discharges{i_d})
        if ~contains(savepath,discharges{i_d}{j},'IgnoreCase',true);
            correct = false;
            break;
        end
    end
    if correct
        break;
    end
end

if correct
    txt = label{i_d};
else
    txt = '';
end

end