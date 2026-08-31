function divs = get_nice_subdivisions(y1, y2, nlvls)
% TODOC
arguments
    y1 double
    y2 double
    nlvls double {mustBeInteger,mustBePositive} = 20
end

y_range = abs(y2-y1);
y_order = 10^ceil(log10(y_range));

n_divs = [2,4,5,8,10,20,40,50,80,100];
y_divs = y_order./n_divs;

y1_rounded = sign(y1)*ceil(abs(y1)./y_divs).*y_divs;
divs = cell(length(n_divs),1);
ndivs = zeros(length(n_divs),1);
for i = 1:length(n_divs)
    divs{i} = y1_rounded(i):y_divs(i):y2;
    ndivs(i) = length(divs{i}); 
end

[~,i] = min(abs(ndivs-nlvls));

divs = divs{i(1)};

end