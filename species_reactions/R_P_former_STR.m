function [ R,P ] = R_P_former_STR( Names,RTs )
%
num_species=length(Names); % width of R,P
num_reactions=size(RTs,2);
R=zeros(num_reactions,num_species);
P=zeros(num_reactions,num_species);

for i=1:num_reactions
    Reactants=RTs(i).React;  
    Products=RTs(i).Prod;
    
    if ~iscell(Reactants) % indicating a zero or a 1x1 char
        m=Reactants;
        if m==0 
        else
        j=find(strcmp(m,Names));
        R(i,j)=1;
            if size(j,2)==0
                disp('Cell of names doesnt contain a name in the reaction set (Reactants)')
            end
        end
    else
        for k =1:length(Reactants)
            m=Reactants{k};
            j=find(strcmp(m,Names));
            R(i,j)=R(i,j)+1;
            if size(j,2)==0
                disp('Cell of names doesnt contain a name in the reaction set (Reactants)')
            end
        end
        
        
    end

    if ~iscell(Products) % indicating a zero or a 1x1 char
        m=Products;
        if m==0 
        else
        j=find(strcmp(m,Names));
        P(i,j)=1;
            if size(j,2)==0
                i
                disp('Cell of names doesnt contain a name in the reaction set (Products)')
            end
        end
    else
        for k =1:length(Products)
            m=Products{k};
            j=find(strcmp(m,Names));
            P(i,j)=P(i,j)+1;
            if size(j,2)==0
                i
                disp('Cell of names doesnt contain a name in the reaction set (Products)')
            end
        end
    end
end
