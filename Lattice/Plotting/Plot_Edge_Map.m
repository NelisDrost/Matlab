function out = Plot_Edge_Map(map, lattice)

    % Setup a Lattice_Plot object to handle the actual plotting
    figure;
    out = Lattice_Plot(lattice, gca); 
    out.Setup;
    
    % Renumber map loci so that only the numbers 1:n are used,
    % where n is the number of unique areas
    [~, ~, map] = unique(map);  
    % Note that the above step isn't necessary here, but may be good practice

    % Get the relabelled identifiers of each node in each pair
    map_pairs = map(lattice.Neigh_Pairs);

    % When these identifiers differ (i.e.: the link connects 2 different areas)
    % we draw a line for that border
    line_width = map_pairs(:,1) ~= (map_pairs(:,2));
    line_width = line_width * 1; % Convert boolean to number

    % Draw lines only for borders between different areas
    out.Update_Borders(out.line_ind, line_width(:));
end