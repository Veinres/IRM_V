function create_Spe_new( spe,fdnames,Refill_gases,Target,filename)
PSpecies=[Refill_gases,Target];
% create_species_new( ["Ar", "Ne"],"Cu")
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
range=1:length(spe);
for j=1:length(fdnames)
for i=1:length(range)
    if ischar(spe{i}{j})
        Spe.(fdnames{j}){i}=spe{range(i)}{j};
    else
        Spe.(fdnames{j})(i)=spe{range(i)}{j};
    end
end 
end
for i=1:length(PSpecies)
    ss.(PSpecies{i})=[];
    for j=range
        if  ismember(Spe.PSpecies(j),PSpecies(i))
            ss.(PSpecies{i})=[ss.(PSpecies{i}), j];
        end
    end    
end
ss.Targetgroup=[];
for i=1:length(Target)
    for j=range
        if  ismember(Spe.PSpecies(j),Target(i))
            ss.Targetgroup(end+1)=j;
        end
    end
end
ss.Refill_gasesgroup=[];
for i=1:length(Refill_gases)
    for j=range
        if  ismember(Spe.PSpecies(j),Refill_gases(i))
            ss.Refill_gasesgroup(end+1)=j;
        end
    end
end


for i=range
    s.(Spe.Names{i})=i; % dynamically create the s structure that contains the order of the species
end
Spe.ss=ss;
Spe.s=s;
Spe.PSpeciess=PSpecies;
Spe.Refill_gases=Refill_gases;
Spe.Target=Target;

% FIXME MERGE: switch to the datetime version
if ~exist('filename','var')
    % filename = Spe_ArC;
    filename = strcat('Spe_',Refill_gases{1:end},Target{1:end});
    % filename = strcat('new_Spe_',datetime(datetime(),'Format','dd-MM-yyyy_hh-mm-ss')); 
end
save(filename,'Spe');
create_reactions_new(Spe);

end

