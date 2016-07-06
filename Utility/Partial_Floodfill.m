function out = Partial_Floodfill(neigh_pairs)
% Floodfill on a list of pairs only, without a map
% Almost certainly simpler to make this the basic operation of floodfill,
% then build floodfill_lattice ontop of this

% Renumber neigh pairs to contiguous block 1:n, where n is the number of uniqe indices in neigh_pairs
[~, npr, npu] = unique(neigh_pairs);    
npr = neigh_pairs(npr);                 % npr allows conversion back to original indices
npr = npr(:);
npu = reshape(npu, size(neigh_pairs));  % npu is the relabelled neigh_pairs
n = numel(npr);

map = floodfill_lattice(1:n, npu);

ind = (1:n)';
out = [npr(ind), npr(map')];
