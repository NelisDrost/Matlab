classdef SquareLattice < Lattice

    properties
        c
        r
    end

    properties (Dependent=true)
        edge_length

        SubInds
    end

    methods
        % Constructor
        function o = SquareLattice(sz, rad)
            o = o@Lattice(sz, rad, [.5 .5 -.5 -.5 .5], [-.5 .5 .5 -.5 -.5]);

            [o.c, o.r] = meshgrid(1:sz(2), 1:sz(1));
            [o.cx, o.cy] = o.SubToXY(o.c, o.r);
        end

        %% Indices to spatial coordinates
        function [x, y] = IndToXY(o, i)
            [x, y] = o.SubToXY(o.c(i), o.r(i));
        end

        function [x, y] = SubToXY(o, c, r)
            x = c .* o.spacing;
            y = r .* o.spacing;
        end

        function PlotCoords(o)
            % Plot coordinate systems for checking

            % X, Y location
            subplot(1, 2, 1);
            for i = 1:numel(o.cx)
                patch(o.cx(i) + o.ox, o.cy(i) + o.oy, 'w');
                t = text(o.cx(i), o.cy(i), sprintf('%f, %f', o.cx(i), o.cy(i)));
                set(t, 'HorizontalAlignment', 'center');
            end
            title('Coords');

            % Subscript index
            subplot(1, 2, 2);
            for i = 1:numel(o.cx)
                patch(o.cx(i) + o.ox, o.cy(i) + o.oy, 'w');
                t = text(o.cx(i), o.cy(i), sprintf('%i, %i', o.c(i), o.r(i)));
                set(t, 'HorizontalAlignment', 'center');
            end
            title('Subscript index');
        end

        function [i, j] = Neigh_Pairs(o)
            % Get a list of neighbouring sites

            ii = o.SubInds;
            % Difference in index in each axis
            x = bsxfun(@minus, ii(:,1), ii(:,1)');
            y = bsxfun(@minus, ii(:,2), ii(:,2)');

            % Pairs (i, j in matrix) where that difference is 1 or less
            xb = abs(x) <= 1;
            yb = abs(y) <= 1;

            % Exclude links to self, and diagonals
            self = x == 0 & y == 0;
            diag = abs(x) == 1 & abs(y) == 1;

            % Sites are neighbours if they one step away from 
            % eachother in one direction, but not diagnoally
            [i, j] = find(xb & yb & ~self & ~diag);

            % Optionally return output as 2 column matrix, if only one output is requested
            if nargout == 1
                i = [i j];
            end
        end

        function diri =  Dir_To_Edge_Ind(o, dir)
            % Get the index associated with the direction between two sites.
            % This is used primarily for selecting a pair of point from the offset
            % list for plotting borders between sites.
            diri = (mod(round(dir * (2/pi)), 4) + 1);
        end

        % Index getters
        function val = get.SubInds(o)
            val = [o.c(:), o.r(:)];
        end
    end

end