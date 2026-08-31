%SOF Save Open Figures
% DEPRECATED

%% Parameters
% Change the values in this section

% figure will be saved in: results/<user>/<subfolder>/figs/
% <user>:
user = 'joel';
% <subfolder>:
subfolder = 'no_const';
subfolder = 'const';
% subfolder = 'ArCu_HiPSTER_single';
% subfolder = 'ArCu_HiPSTER_20A_single';
% subfolder = 'ArCu_Sinex2_04Pa_single';
% subfolder = 'ArCu_Sinex2_27Pa_single';
% subfolder = 'ArCu_Sinex1_single';
% subfolder = 'ArCu_HiPSTER_40us_0.5Pa_360A_single';
% subfolder = 'ArCu_HiPSTER_80us_2.7Pa_235A_single';
% subfolder = 'ArCu_HiPSTER_80us_2.7Pa_165A_single';
% subfolder = 'ArCu_HiPSTER_80us_2.7Pa_360A_single';
% subfolder = 'ArCu_HiPSTER_80us_0.4Pa_165A_single';
% subfolder = 'ArCu_HiPSTER_80us_0.4Pa_235A_single';
% subfolder = 'ArCu_HiPSTER_40us_0.5Pa_235A_single';
% subfolder = 'ArCu_HiPSTER_40us_0.5Pa_165A_single';
% subfolder = 'ArCu_HiPSTER_40us_0.5Pa_200A_single';
% subfolder = 'ArCu_HiPSTER_40us_0.5Pa_130A_single';
% subfolder = 'ArCu_HiPSTER_80us_0.4Pa_200A_single';
% subfolder = 'ArCu_HiPSTER_80us_0.4Pa_130A_single';
% subfolder = 'ArCu_HiPSTER_80us_2.7Pa_200A_single';
% subfolder = 'ArCu_HiPSTER_80us_2.7Pa_130A_single';
% subfolder = 'ArCu_HiPSTER_80us_0.4Pa_360A_single';
% whether to save to .fig
save_figs = true;

% specify any number of additional formats to save to:
% example: plot_format = {'png', 'eps'};
% available formats are: 'jpg','jpeg','png','tif','tiff','pdf','emf','eps'
plot_format = {'png','eps'};

%% Saving all open figures
possible_formats = {'jpg', 'jpeg',...
                    'png',...
                    'tif', 'tiff',...
                    'pdf',...
                    'emf',...
                    'eps'};

% Collect all currently open figures
figHandles = findall(0, 'Type', 'figure'); 

directory = fullfile('results', user, subfolder, 'figs');

% create folder
if ~exist(directory, 'dir')
	mkdir(directory)
end

% save figures as .fig and any other specified format
for i = 1:numel(figHandles)
    fp = strrep(figHandles(i).Name, ' ', '_');
    if strcmp(fp,'')
        fp = sprintf('fig%i',i);
    end
    if save_figs
        fn = fullfile(directory, strcat(fp, '.fig'));
        savefig(figHandles(i), fn);
    end
    for j=1:length(plot_format)
        if any(strcmp(plot_format{j}, possible_formats))
            fn = fullfile(directory, strcat(fp, '.', plot_format{j}));
            exportgraphics(figHandles(i), fn);
        end
    end
end

fprintf("Figures saved.\n") % FIXME
