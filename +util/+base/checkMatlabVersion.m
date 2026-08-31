function [requirement_met] = checkMatlabVersion(required)
arguments
    required char
end

reqv = sscanf(required, '%4d%1s');
ryear = reqv(1);
rminor = char(reqv(2));

[year, minor] = util.base.getMatlabVersion();

requirement_met = false;
if year >= ryear && minor >= rminor
    requirement_met = true;
end

end
