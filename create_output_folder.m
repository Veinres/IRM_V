function [dir_output]=create_output_folder(folder_name, dir_results, nr)
%save_output: To create the results saving folder
%   Takes a given folder_name string and trys to create a folder of this
%   name inside the fixed folder "results". If the file already exists,
%   numerical ordering is automatically added to the folder_name. The final
%   directory of where to save your results is outputed as the string
%   'dir_output'.

% MRu: this should be a faster way to do it: 
files=dir(fullfile(dir_results));
directoryNames = {files([files.isdir]).name};
directoryNames = directoryNames(~ismember(directoryNames,{'.','..'}));  % list of directory names without '.' and '..' 
if ~exist('nr', 'var') || isempty(nr)
    nr = size(directoryNames,2) + 1;  % number of directories already created
end
folder_name_N=fullfile(dir_results,strcat(folder_name,sprintf('%d',nr)));
mkdir(folder_name_N);
mkdir(fullfile(folder_name_N, 'plot'));
mkdir(fullfile(folder_name_N, 'txt'));

dir_output = folder_name_N;
end

