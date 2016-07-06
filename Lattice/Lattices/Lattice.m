classdef Lattice < handle
% Common base class for lattices

    properties
        sz      % Width & height of lattice area
        spacing % Distance between patch centers
        cx      % X &
        cy      % Y coordinate of patch centers
    end

    properties (Hidden)
        offset_x    % Raw x/y coordinates of 
        offset_y    % patch vertices (does not include spacing)
    end

    properties (Dependent=true)
        num     % Total number of sites
        ind     % List of linear indices of sites

        ox      % Actual x/y coordinates of 
        oy      % patch vertices
    end

    methods
        function o = Lattice(sz, spacing, offset_x, offset_y)
            % Constructor, simply accepts data from child classes
            o.sz = sz;
            o.spacing = spacing;
            o.offset_x = offset_x;
            o.offset_y = offset_y;
        end
    end

    %% Methods which child classes must implement
    methods (Abstract)
        IndToXY(o, i)   % Convert linear index to coordinates
        
        PlotCoords(o)   % Display lattice, labelled with each possible coordinate scheme

        Neigh_Pairs(o)  % Return list of connected pairs, using linear index
        Dir_To_Edge_Ind(o, dir) % Identify which edge lies in a given direction from a nodes center
    end

    %% Neighbours
    methods
        function out = Sample(o, data)
            % Assigns data to lattice cells from a rectangular data array,
            % e.g.: from an image
            dat_sz = size(data);

            mnx = min(o.cx(:));
            mxx = max(o.cx(:));
            mny = min(o.cy(:));
            mxy = max(o.cy(:));

            xx = @(x) floor(1 + ((x - mnx) ./ (mxx - mnx)) .* (dat_sz(2) - 1));
            yy = @(y) floor(1 + ((y - mny) ./ (mxy - mny)) .* (dat_sz(1) - 1));

            ii = sub2ind(dat_sz, yy(o.cy(:)), xx(o.cx(:)));
            out = reshape(data(ii), o.sz);
        end

        function [neigh_mat, dir, diri, dir_mat] = Neigh_Pairs_To_Mat(o, i, j)

            % If called without arguments, use this lattices Neigh_Pairs function
            if nargin < 2
                [i, j] = o.Neigh_Pairs;
            end

            % Unpack 2 column pairs matrix if provided
            if nargin == 2
                j = i(:,2);
                i = i(:,1);
            end

            % Location
            xc = [o.cx(i), o.cx(j)];
            yc = [o.cy(i), o.cy(j)];

            % Direction from i to j
            dir = atan2(yc(:,2) - yc(:,1), xc(:,2) - xc(:,1));

            % Index of that direction (for plotting borders)
            diri = o.Dir_To_Edge_Ind(dir);

            % Index pairs by the number of pairs from each source (i)
            num_neighs = accumarray(i, 1);
            neigh_ind = i;
            for k = 1:numel(num_neighs)
                neigh_ind(i == k) = 1:num_neighs(k);
            end
                
            % Use the above indices to arrange neighbour pairs (and other data)
            % into a matrix with one column per source
            nm_sz = [o.num, max(num_neighs)];
            neigh_mat = nan(nm_sz);
            neigh_mat(sub2ind(nm_sz, i, neigh_ind)) = j;

            dir_mat = nan(nm_sz);
            dir_mat(sub2ind(nm_sz, i, neigh_ind)) = dir;
        end

        function [neigh_pairs] = Sea_Neighbours(o, sea_map, sea_range)

            np = o.Neigh_Pairs();
            ix = o.cx(:); iy = o.cy(:);

            % Distance between pairs
            pair_dists = sqrt(bsxfun(@minus, ix, ix').^2 + bsxfun(@minus, iy, iy').^2);

            % Convert sea map into discrete (disconnected) regions
            map_regions = floodfill_lattice(sea_map, np);

            % Find sea regions neighbouring sites
            sea_neighs = np;
            sea_neighs(:,2) = map_regions(sea_neighs(:,2));
            sea_neighs = sea_neighs(~isnan(sea_neighs(:,2)),:);             % Remove pairs with no sea target
            sea_neighs = sea_neighs(isnan(map_regions(sea_neighs(:,1))),:); % Remove pairs with no land source

            % Pick only pairs in range
            [i, j] = find(pair_dists < sea_range & pair_dists ~= 0);
            ii = isnan(map_regions(i)) & isnan(map_regions(j)) ...  % Remove possible pairs where one both are in the sea
                & ismember(i, sea_neighs(:,1)) & ismember(j, sea_neighs(:,1)); % Remove pairs wheter either site isn't on the coast

            % NOTE - currently this function returns connections that are within sea_range
            % 'as the crow flies', not that distance using only sea connections.  That would 
            % require pathfinding (connection matrix), which can be added later.

            % Select those pairs that share a sea
            valid = false(numel(ii),1);
            regs = unique(map_regions(~isnan(map_regions)));
            for k = 1:numel(regs)
                jj = sea_neighs(:,2) == regs(k);
                kk = ismember(i, sea_neighs(jj,:)) & ismember(j, sea_neighs(jj, :));
                valid(kk) = true;
            end

            ii = ii & valid;
            neigh_pairs = [i(ii), j(ii)];
        end

        function [neigh_pairs] = Ranged_Neigh_Pairs(o, range)

            ix = o.cx(:); iy = o.cy(:);

            % Distance between pairs
            pair_dists = sqrt(bsxfun(@minus, ix, ix').^2 + bsxfun(@minus, iy, iy').^2);

            % Pick only pairs in range
            [i, j] = find(pair_dists < range & pair_dists ~= 0);

            neigh_pairs = [i, j];
        end
    end

    %% Plotting
    methods
        function Plot(o)
            subplot(2,2,1);
            plot(o.ox, o.oy);
            title('Edges');
            subplot(2,2,2);
            patch(o.ox, o.oy, 'k');
            title('Patch');
            subplot(2,2,3);
            scatter(o.cx(:), o.cy(:));
            title('Centers');
            subplot(2,2,4);
            for i = 1:numel(o.cx);
                patch(o.cx(i) + o.ox, o.cy(i) + o.oy, 'w');
            end
            title('Lattice');
        end

        function PlotIndex(o)
            for i = 1:numel(o.cx)
                patch(o.cx(i) + o.ox, o.cy(i) + o.oy, 'w');
                t = text(o.cx(i), o.cy(i), sprintf('%i', i));
                set(t, 'HorizontalAlignment', 'center');
            end
            title('Linear Index');
        end

        function PlotGrid(o)
            for i = 1:numel(o.cx)
                patch(o.cx(i) + o.ox, o.cy(i) + o.oy, 'w');
            end
        end            

        function PlotNeighs(o)
            cla;
            hold on
            for i = 1:numel(o.cx);
                patch(o.cx(i) + o.ox, o.cy(i) + o.oy, 'w');
                t = text(o.cx(i), o.cy(i), sprintf('%i', i));
                set(t, 'HorizontalAlignment', 'center');
            end

            ij = o.Neigh_Pairs;
            x = [o.cx(ij(:,1)), o.cx(ij(:,2))];
            y = [o.cy(ij(:,1)), o.cy(ij(:,2))];
            plot(x', y');
        end
    end

    %% Getters
    methods
        function val = get.num(o)
            val = numel(o.cx);
        end

        function val = get.ind(o)
            val = (1:o.num)';
        end

        function val = get.ox(o)
            val = o.spacing .* o.offset_x;
        end

        function val = get.oy(o)
            val = o.spacing .* o.offset_y;
        end
    end
end