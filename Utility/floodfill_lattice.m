function out = floodfill_lattice(map, neigh_pairs)
% Quick function for flood filling areas of a map based on neighbourhood
% rules given as pairs of neighbours
%
% Does not respect directionality of links, e.g.: whether neigh_pairs contains
% the links [A B], [B A] or both, the outcome of this function should be the same.
%
% Regions are labeled with the lowest index of any cell in that region

% Use map to identify size/shape of area, and location of active sites
map = map ~= 0;
% Label each active site with a unique integer
out = reshape(1:numel(map), size(map));
out(~map) = nan; % Inactive sites will be ignored

% Filter neigh_pairs list to include only those pairs where both nodes are
% in the active map
ii = ismember(neigh_pairs(:,1), out) & ismember(neigh_pairs(:,2), out);
np = neigh_pairs(ii,:);

% Iteratively merge connected regions
changed = 1;
while changed
    % Get the current region labels for each connected pair
    npi = out(np);
    % Filter to find those that aren't already in the same region
    jj = npi(:,1) ~= npi(:,2);
    if nnz(jj) == 0 % If there are no pairs not already in the same region,
        break       % we're done
    else
        % Using only those pairs identified above
        npi = npi(jj,:);

        % For each link identifying two differently labelled regions, that should
        % be connected, we relabel every node in the region with the greater label 
        % to have the same label as the region with the lesser label.

        % Identify the greater and lesser labels for every pair
        min_pair = min(npi, [], 2);
        max_pair = max(npi, [], 2);
        % Find ALL nodes in the map that have a label identified as the 
        % greater of any pair above
        [~, kk] = ismember(out, max_pair);
        % Relabel them with the label of the node they are paired with
        out(kk ~= 0) = min_pair(kk(kk ~= 0));

        % Could be improved by relabelling all greater nodes with the label of the 
        % least node found to be connected to any of them?
        % Find node in each pair that is greater
        % For each label that is greater atleast once
        % Find minimum of all connected labels
        % Relabel
        
        % OR 

        % Find all pairs that contain each label
        % Find mimimum of all labels connected to each label
        % Relabel all
    end
end