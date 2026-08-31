function mustBeValidSpeciesInfo(a)
%MUSTBEVALIDSPECIESINFO checks if the supplied species structure is valid
    eidType = '';
    switch class(a)
        case 'struct'
            if ~( isfield(a, 'Refill_gases')...
               && isfield(a, 'Target')...
               && isfield(a, 'Names')...
               && isfield(a, 's')...
               && isfield(a, 'Energy'))
                eidType = 'mustBeValidSpeciesInfo:missingStructFields';
                msgType = 'Input species struct is missing a required field.';
            end
        case 'table'
            if ~( isfield(a.Properties.UserData, 'refill')...
               && isfield(a.Properties.UserData, 'target')...
               && ismember('Names', a.Properties.VariableNames)...
               && ismember('E', a.Properties.VariableNames))
                eidType = 'mustBeValidSpeciesInfo:missingTableFields';
                msgType = 'Input species table is missing a required field.';
            end
        otherwise
            eidType = 'mustBeValidSpeciesInfo:notValidClass';
            msgType = 'Input must be either a species table or a struct containing relevant information.';
    end
    if ~isempty(eidType)
        throwAsCaller(MException(eidType,msgType))
    end
end
