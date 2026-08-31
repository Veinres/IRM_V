function [year, minor] = getMatlabVersion()
    res = sscanf(version('-release'), '%4d%1s');
    year = res(1);
    minor = char(res(2));
end
