function cofb(names)

figHandles = findall(0, 'Type', 'figure');
for i = 1:length(figHandles)
    if ~any(strcmpi(figHandles(i).Name, names))
        close(figHandles(i));
    end
end

end