%%  N2-N2

% TODO:
% look into using strings or even categoricals/enums for species and
% classes

%% 1. import species
e = material.electron.species();
n2 = material.gas.n2.species();
%% 2. generate species classes
n2_cl = createClasses(n2);
e_cl = createClasses(e);
%% 3. generate reactions classes
e_n2_rcl = createReactionClasses(e_cl, n2_cl, 3);
n2_n2_rcl = createReactionClasses(n2_cl, n2_cl, 3);
%% 4. filter reactions classes
e_n2_rcl = filterReactionClasses(e_n2_rcl);
n2_n2_rcl = filterReactionClasses(n2_n2_rcl);
%% 5. expand reactions
n2_n2_rea = expandReactionTable(n2_n2_rcl, n2_cl, n2, n2_cl, n2);
e_n2_rea = expandReactionTable(e_n2_rcl, n2_cl, n2, e_cl, e);
%% 6. classify and filter reactions
n2_n2_rea = filterReactionTable(n2_n2_rea, n2, n2);
e_n2_rea = filterReactionTable(e_n2_rea, n2, e);
%% 7. add hot electron variants
n2_n2_rea = addHotEVariants(n2_n2_rea);
e_n2_rea = addHotEVariants(e_n2_rea);
%% 8. check, load and adapt crosssections
%% 9. compute rate coefficients

%% function definitions

function r_table = addHotEVariants(r_table)
    % TODO : implement
end

function r_table = filterReactionTable(r_table, spe1, spe2)
    % TODO : implement
end

function r_classes = filterReactionClasses(r_classes)
    n_prod = cellfun(@(x) length(x), r_classes.P);
    n_prod_e = cellfun(@(rc) sum(cellfun(@(p) strcmp(p,'e'), rc)), r_classes.P);
    r_classes.n_prod = n_prod;
    r_classes.n_prod_e = n_prod_e;
    % 1. filter reactions with two reactants and only one product
    rc_filter = n_prod >= 2;
    % 2. filter reactions with more than two products (excluding electrons)
    rc_filter = rc_filter & (n_prod-n_prod_e) <= 2;

    r_classes = r_classes(rc_filter,:);
end

function r_classes = createReactionClasses(class1, class2, max_products)
    nclasses1 = height(class1);
    nclasses2 = height(class2);
    rclasses = table('Size',[nclasses1*nclasses2,5], ...
        'VariableTypes', {'cell','cell','double','cell','cell'}, ...
        'VariableNames', {'R','comp','Q','P','nPe'});
    ind = 0;
    nr = 0;
    sp_classes = vertcat(class1, class2);
    [~,ia] = unique(sp_classes.rep);
    sp_classes = sp_classes(ia,:);
    same_classes = nclasses1 == nclasses2 && nclasses1 == height(sp_classes);
    for i=1:nclasses1
        if same_classes
            % if both classes of species involved in the reaction are the
            % same, we only have to do half as much work since the order of
            % the reactants is irrelevant
            % (A + B -> C + D == B + A -> C + D)
            start_ind = i;
        else
            start_ind = 1;
        end
        for j=start_ind:nclasses2
            ind = ind + 1;
            % define reactants
            rclasses.R{ind} = {class1.rep{i}, class2.rep{j}};
            % sum up atoms and total charge of reactants
            rclasses.comp{ind} = horzcat(class1.comp{i}, class2.comp{j});
            rclasses.Q(ind) = sum([class1.Q(i),class2.Q(j)]);
            [elem, cnt] = util.base.uniqueCount(rclasses.comp{ind});
            rclasses.comp_dict{ind} = dictionary(elem, cnt);
            % ignore free electrons since their number isn't necessarily conserved
            comp = rclasses.comp_dict{ind};
            kys = keys(comp);
            comp(kys(kys == -1)) = [];
            % infer possible products
            [prods, ne] = possibleProducts(comp, rclasses.Q(ind), ...
                sp_classes, max_products);
            % define products
            rclasses.P{ind} = prods;
            rclasses.nPe{ind} = ne;
            nr = nr + length(prods);
        end
    end
    r_classes = table('Size',[nr,5], ...
        'VariableTypes', {'cell','cell','double','cell','string'}, ...
        'VariableNames', {'R','comp','Q','P','type'});
    ind = 1;
    for i = 1:height(rclasses)
        for j = 1:length(rclasses.P{i})
            r_classes.R{ind} = rclasses.R{i};
            r_classes.comp{ind} = rclasses.comp{i};
            r_classes.Q(ind) = rclasses.Q(i);
            r_classes.P{ind} = horzcat(rclasses.P{i}{j},repmat({'e'}, [1,rclasses.nPe{i}(j)]));
            r_classes.type(ind) = reactionType(r_classes.R{ind}, r_classes.P{ind}, sp_classes);
            ind = ind + 1;
        end
    end
end

function type = reactionType(R, P, spe_cl)
    ne_R = sum(strcmp(R, 'e')); ne_P = sum(strcmp(P, 'e'));
    if ne_P > ne_R
        type = "ion";
    elseif ne_P == ne_R
        n_R = length(R); n_P = length(P);
        if n_P-ne_P > n_R-ne_R
            type = "dis";
        elseif n_P-ne_P == n_R-ne_R
            for i = 1:length(P)
                if spe_cl.Q(strcmp(spe_cl.rep,P{i})) ~= 0 && ~ismember(P{i},R)
                    type = "cht";
                    return;
                end
            end
            type = "exc"; % note : this captures every that isn't in another category
        else
            type = "as";
        end
    else
        type = "rec";
    end
end

function classes = createClasses(spe)
%CREATECLASSES create classes of species
% species of the same composition and charge are in the same class
% the idea is, that rates for reacitons involving higher energy states
% of some reactant can potentially be obtained by threshold reduction
    [~, ia, ic] = unique([cellfun(@(x) sprintf("%d,",x), spe.comp),spe.M,spe.Q], 'rows');
    classes = table('Size',[length(ia),6], ...
        'VariableTypes', {'cell','double','double','cell','cell','cell'}, ...
        'VariableNames', {'rep','M','Q','comp','members','comp_dict'});
    classes.M = spe.M(ia);
    classes.Q = spe.Q(ia);
    for i = 1:height(classes)
        classes.members{i} = find(ic==i);
        classes.rep(i) = spe.name(classes.members{i}(1));
        classes.comp(i) = spe.comp(classes.members{i}(1));
        [elem, cnt] = util.base.uniqueCount(classes.comp{i});
        classes.comp_dict{i} = dictionary(elem, cnt);
    end
end

function [prods, ne] = possibleProducts(comp_dict, Q, sclasses, max_prod)
%POSSIBLEPRODUCTS find all combiations of species that add up to a given
%composition and total charge

    % We use a recursive algorithm to try and find all possible
    % combinations of products for a given reaction. To this end, we sum up
    % the atoms of each element to create a pool of atoms available to
    % produce products.
    % We then go through the list of species and test for each, if it could
    % possibly be a product of the reaction. This is the case only if there
    % are enough available atoms of the correct element/type to produce
    % that species. If the species can be produced, the required atoms are
    % subtracted and we recurse on the smaller pool of available atoms.
    % To ensure that every combination is only found once, we only stop
    % considering a species once all the possible combination involving
    % that species have been tried. To make this more efficient, we start
    % with the largest species and test the species in order of decreasing
    % size.

    % 1. sort the species (classes) by number of atoms
    [~,ind] = sort(cellfun(@(x) length(x), sclasses.comp), 'descend');

    % 2. start the recursive algorithm. We limit the maximum allowed number of
    % products to 4.
    % NOTE : Maybe 2 would actually be sufficient?
    prods = possibleProductsRec(comp_dict, sclasses(ind,:), 1, max_prod);

    % 3. charge balance : add electrons to the products as required and
    % remove reactions that cannot satisfy the charge balance
    charges = dictionary(sclasses.rep, sclasses.Q);
    pQ = cellfun(@(x) sum(charges(x)), prods);
    ne = (pQ - Q);
    prods = prods(ne >= 0);
    ne = ne(ne >= 0);
end

function prods = possibleProductsRec(comp_dict, sclasses, depth, max_prod)
%POSSIBLEPRODUCTREC recursive kernel for possibleProducts
    if depth > max_prod
        prods = {};
        return;
    end
    prods = cell([height(sclasses),1]);
    for i = 1:height(sclasses)
        new_comp = deduct(comp_dict, sclasses.comp_dict{i});
        if isempty(new_comp)
            prods{i} = {};
            continue;
        end
        if all(values(new_comp) == 0)
            prods{i} = {{sclasses.rep{i}}};
            continue;
        end

        sub_prods = possibleProductsRec(new_comp, sclasses(i:end,:), depth+1, max_prod);
        for j = 1:length(sub_prods)
            sub_prods{j} = horzcat(sclasses.rep{i},sub_prods{j});
        end
        if ~isempty(sub_prods)
            prods{i} = sub_prods;
        end
    end
    prods = horzcat(prods{:});
end

function new_comp = deduct(comp_dict1, comp_dict2)
%DEDUCT subtract components in second dict from first dict
% returns empty if a component is not part of first dict or its number is too low
    new_comp = comp_dict1;
    kys = keys(comp_dict2);
    for i = 1:length(kys)
        if ~isKey(new_comp,kys(i))
            new_comp = [];
            return;
        end
        new_comp(kys(i)) = new_comp(kys(i)) - comp_dict2(kys(i));
        if new_comp(kys(i)) < 0
            new_comp = [];
            return;
        end
    end
end

function rea = expandReactionTable(reacl, specl1, spe1, specl2, spe2)
    variants = dictionary(vertcat(specl1.rep,specl2.rep), ...
        vertcat( ...
        cellfun(@(x) spe1.name(x), specl1.members, 'UniformOutput', false), ...
        cellfun(@(x) spe2.name(x), specl2.members, 'UniformOutput', false)) ...
        );
    variants({'e'}) = {{'e'}}; % all reaction can produce e, and ec/eh distinction is made separatly

    rea = table('Size',[0,3], ...
        'VariableTypes', {'cell','cell','cell'}, ...
        'VariableNames', {'R','P','type'});

    for i = 1:height(reacl)
        tmp = expandReaction(reacl.R{i}, reacl.P{i}, variants, reacl.type{i});
        rea = vertcat(rea, tmp);
    end
end

function rea = expandReaction(reactants, products, variants, type)
%EXPANDREACTION generate all variations of a reaction
    species = horzcat(reactants, products); % species involved
    nvs = cellfun(@(x) length(first(variants({x}))), species); % number of variants
    ls = flip(cumprod(flip(nvs))); ls(end+1) = 1; % number of consecutive repetitions of a variant for each species
    ns = length(species); % number of species
    nrt = length(reactants); npr = length(products);
    nr = ls(1); % number of reactions (unpruned)
    reactions = cell(nr, ns);
    % generate all variations:
    % We iterate through the species from left to right in the reaction eq.
    % starting of with the first reactant and ending with the last product.
    % For each species, we insert as many consecutive entries of the same
    % variant as possible. I.e. the first reactant varies the slowest and
    % the last product varies the fastest.
    for i_s = 1:ns
        i_start = 1;
        vs = first(variants(species(i_s)));
        while i_start + nvs(i_s) - 1 <= nr
            for i_v = 1:nvs(i_s)
                i_end = i_start + ls(i_s+1) - 1;
                reactions(i_start:i_end,i_s) = vs(i_v);
                i_start = i_end + 1;
            end
        end
    end
    rea = table('Size', [nr,3], ...
        'VariableTypes', {'cell','cell','cell'}, ...
        'VariableNames', {'R','P','type'});
    crep = cell([nr,1]);
    for i_r = 1:nr % uniform representation
        rea.R{i_r} = reactions(i_r,1:nrt);
        rea.P{i_r} = reactions(i_r,nrt+1:end);
        rea.type{i_r} = type;
        crep{i_r} = canonicalRep(rea.R{i_r}, rea.P{i_r});
    end
    % remove duplicates
    [~,ia] = unique(crep, 'stable');
    rea = rea(ia,:);
    crep = crep(ia);
    % remove "non-reactions"
    rea = rea(cellfun(@(x)~isempty(x),crep),:);
end

function crep = canonicalRep(rcts, prds)
%CANONICALREP a unique str representing the reaction
    R = sort(rcts);
    rstr = sprintf('%s,', R{:});
    P = sort(prds);
    pstr = sprintf('%s,', P{:});
    if cellEq(R, P)
        crep = '';
        return;
    end
    crep = strcat(rstr(1:end-1), ':', pstr(1:end-1));
end

function e = cellEq(A, B)
    e = false;
    if numel(A) ~= numel(B); return; end
    for i = 1:numel(A)
        if ~strcmp(A{i}, B{i}); return; end
    end
    e = true;
end

function f = first(cellarr)
    f = cellarr{1};
end

function y = get(x,ind)
    if length(x) < ind
        y = '';
    else
        y = x{ind};
    end
end
