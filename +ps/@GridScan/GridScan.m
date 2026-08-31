classdef GridScan < ps.StaticScan
    methods
        function obj = GridScan(results_path, parameter, values)
            arguments
                results_path char
            end
            arguments (Repeating)
                parameter ps.Parameter
                values (1,:) double
            end
            obj@ps.StaticScan([parameter{:}], results_path, combvec(values{:}));
        end
    end
end

