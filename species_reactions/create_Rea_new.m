function Rea=create_Rea_new(Spe,reactions)
ReaSize=size(reactions);
nor=length(reactions); % number of reacitons
% Processing reactions into simpler cells or tables
type=cell(nor,1);
Rcell=type;
Pcell=type;
tags=type;
Energy_vec=transpose(Spe.Energy);
for i=1:nor
    %kk{i}=reaction_func(reactions(i).coef_type,reactions(i).coeffs); % write in the values of K_A vector
    type{i}=reactions(i).type; % the type string information
    Rcell{i}=reactions(i).React;
    Pcell{i}=reactions(i).Prod;
    tags{i}=reactions(i).tag;
end

%  reaction types (logical vectors)

% the structure, Reactype, keeps the logical indices for react. types
Reactype.eH = zeros(ReaSize);
Reactype.eC = zeros(ReaSize);

% create a structure that can return the reaction number by tag names
for i=1:length(tags)
    if isempty(tags{i})
        tags{i}=sprintf('r%d',i);
    end
    rn.(tags{i})=i; % rn represents reaction names
end
 %%  Validity of the provdied "Key"(Names) to the species Names in reactions
 % Check if the provided "Names" cell contains  all the string notations mentioned in the React and Prod as input.
 % case : stop function and give warning!
 % case2: don't stop but give warning when there's not a single reaction
 % for a certain species.
 
 
 %% From string formalism to matrix formalism
[ R , P ] = R_P_former_STR ( Spe.Names, reactions );
Vif=(P-R)*Energy_vec;
Range.penning=[];
Range.excC=[];
Range.excH=[];
Range.dexcC=[];
Range.dexcH=[];
Range.ionC=[];
Range.ionH=[];
Range.ehtype=[];
Range.ectype=[];
Range.ionparent=zeros(ReaSize); % -> non-electron impact reactions get 0
nprod_e=zeros(ReaSize);
for i=1:nor
    
    if strcmp(reactions(i).type,'pen')
        Range.penning(end+1)=i;
    end
    if strcmp(reactions(i).type,'dexc')
        if ismember('eh',reactions(i).React)
            Range.dexcH(end+1)=i;
        else
            Range.dexcC(end+1)=i;
        end
    elseif strcmp(reactions(i).type,'exc')
        if ismember('eh',reactions(i).React)
            Range.excH(end+1)=i;
        else
            Range.excC(end+1)=i;
        end
    end
    if strcmp(reactions(i).type,'ion')
        
        input_particles=reactions(i).React;
        nprod_e(i)=sum(strcmp('e',reactions(i).Prod))-sum(strcmp('e',reactions(i).React));
        
        [isehtype,location]=ismember('eh',input_particles);
        if not(isehtype)
            [isetype,location]=ismember('e',input_particles);
        end
        if isehtype
            Range.ionH(end+1)=i;
            input_particles(location)=[];
            if length(input_particles)>1
                disp('wrong number of elements for reactionlist number:')
                disp(i)
            else
                Range.ionparent(i)=Spe.s.(input_particles{1});
            end
        end
        if isetype
            Range.ionC(end+1)=i;
            input_particles(location)=[];
            if length(input_particles)>1
                disp('wrong number of elements for reactionlist number:')
                disp(i)
            else
                Range.ionparent(i)=Spe.s.(input_particles{1});
            end
        end
        isehtype=false;
        isetype=false;
    end
    if ismember('eh',reactions(i).React)
        Range.ehtype(end+1)=i; % NOTE : this isn't actually used anywhere
        Reactype.eH(i)=1; % NOTE : however this is
    else
        Range.ectype(end+1)=i; % what about penning and charge exchange? % NOTE : this isn't actually used anywhere
        Reactype.eC(i)=1; % NOTE : this isn't actually used anywhere, instead Reactype.eH == 0 is used
    end
end

%% Reaction ionization range
%{
Range.ion=[];
for i=1:nor
    if P(i,Spe.s.e)=R
end
%}
%% Save it to the big structure!
Rea.Range=Range;
Rea.Reactype=Reactype;
Rea.R=R;
Rea.P=P;
Rea.tags=tags;
Rea.rn=rn;
Rea.reactions=reactions;
Rea.Rcell=Rcell;
Rea.Pcell=Pcell;
Rea.nprod_e=nprod_e;
Rea.Vif=transpose(Vif);
