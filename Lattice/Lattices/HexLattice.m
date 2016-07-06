classdef HexLattice < Lattice

    properties
        c
        r
    end

    properties (Dependent=true)
        rad

        AxialInd
        CubicInd
        OffsetInd
    end

    properties(Constant)
        root3over2 = sqrt(3)/2;
        pi6i = 6 / pi;
    end

    methods
        % Constructor
        function o = HexLattice(sz, rad)
            o = o@Lattice(sz, rad, cos((0:6) * pi/3)./sqrt(3), sin((0:6) * pi/3)./sqrt(3));

            [o.c, o.r] = meshgrid(1:sz(2), 1:sz(1));
            [o.cx, o.cy] = o.OffsetToXY(o.c, o.r);
        end

        function [x, y] = IndToXY(o, i)
            [x, y] = o.OffsetToXY(o.c(i), o.r(i));
        end


        function PlotCoords(o)
            % Plot coordinate systems for checking

            % X, Y location
            subplot(2, 2, 1);
            for i = 1:numel(o.cx)
                patch(o.cx(i) + o.ox, o.cy(i) + o.oy, 'w');
                t = text(o.cx(i), o.cy(i), sprintf('%f, %f', o.cx(i), o.cy(i)));
                set(t, 'HorizontalAlignment', 'center');
            end
            title('Coords');

            % Offset coords
            subplot(2, 2, 2);
            for i = 1:numel(o.cx)
                patch(o.cx(i) + o.ox, o.cy(i) + o.oy, 'w');
                t = text(o.cx(i), o.cy(i), sprintf('%i, %i', o.c(i), o.r(i)));
                set(t, 'HorizontalAlignment', 'center');
            end
            title('Offset');

            % Axial coords
            subplot(2, 2, 3);
            axind = o.AxialInd();
            for i = 1:numel(o.cx)
                patch(o.cx(i) + o.ox, o.cy(i) + o.oy, 'w');
                t = text(o.cx(i), o.cy(i), sprintf('%i, %i', axind(i,1), axind(i,2)));
                set(t, 'HorizontalAlignment', 'center');
            end
            title('Axial');

            % Cubic coords
            subplot(2, 2, 4);
            cubind = o.CubicInd();
            for i = 1:numel(o.cx)
                patch(o.cx(i) + o.ox, o.cy(i) + o.oy, 'w');
                t = text(o.cx(i), o.cy(i), sprintf('%i, %i, %i', cubind(i, 1), cubind(i, 2), cubind(i, 3)));
                set(t, 'HorizontalAlignment', 'center');
            end
            title('Cubic');
        end

        function [i, j] = Neigh_Pairs(o)
            % Get a list of neighbouring sites

            ii = o.CubicInd;
            % Difference in index in each axis
            x = bsxfun(@minus, ii(:,1), ii(:,1)');
            y = bsxfun(@minus, ii(:,2), ii(:,2)');
            z = bsxfun(@minus, ii(:,3), ii(:,3)');

            % Pairs (i, j in matrix) where that difference is 1 or less
            xb = abs(x) <= 1;
            yb = abs(y) <= 1;
            zb = abs(z) <= 1;

            % Exclude links to self
            self = x == 0 & y == 0 & z == 0;

            % Sites are neighbours if they are at most 1 step away in each direction
            [i, j] = find(xb & yb & zb & ~self);

            % Optionally return output as 2 column matrix, if only one output is requested
            if nargout == 1
                i = [i j];
            end
        end

        function diri =  Dir_To_Edge_Ind(o, dir)
            % Get the index associated with the direction between two sites.
            % This is used primarily for selecting a pair of point from the offset
            % list for plotting borders between sites.
            diri = (mod(round(dir * o.pi6i), 12) + 1) * .5;
        end

        % Index getters
        function val = get.AxialInd(o)
            [q_, r_] = o.OffsetToAxial(o.c(:), o.r(:));
            val = [q_, r_];
        end

        function val = get.CubicInd(o)
            [x_, y_, z_] = o.OffsetToCubic(o.c(:), o.r(:));
            val = [x_, y_, z_];
        end

        function val = get.OffsetInd(o)
            val = [o.c(:), o.r(:)];
        end

        function ind = PointToIndex(o, x, y)
            % Imperfect, horizontal corners misattributed
            % X, Y to offset
            q_ = x ./ HexLattice.root3over2;
            r_ = (y - (q_+1)./2);

            % Convert to cubic for rounding
            [x_, y_, z_] = HexLattice.AxialToCubic(q_, r_);

            rx = round(x_);
            ry = round(y_);
            rz = round(z_);

            dx = abs(rx - x_);
            dy = abs(ry - y_);
            dz = abs(rz - z_);

            if dx > dx && dx > dz
                rx = -ry - rz;
            elseif dy > dz
                ry = -rx - rz;
            else
                rz = -rx - ry;
            end

            % Convert to linear index
            [c_, r_] = HexLattice.CubicToOffset(rx, ry, rz);

            ind = sub2ind(o.sz, r_, c_);
        end

        % Getters    
        function val = get.rad(o)
            val = o.spacing;
        end
    end

    methods(Static)
        %% Indices to spatial coordinates
        

        function [x, y] = OffsetToXY(c, r)
            x = c .* HexLattice.root3over2;
            y = r + (mod(c-1,2) * .5);
        end

        function [x, y] = AxialToXY(q, r)
            [c_, r_] = HexLattice.AxialToOffset(q, r);
            [x, y] = HexLattice.OffsetToXY(c_, r_);
        end

        function [x, y] = CubicToXY(x, y, z)
            [c_, r_] = HexLattice.CubicToOffset(x, y, z);
            [x, y] = HexLattice.OffsetToXY(c_, r_);
        end

        %% Conversion between coordinate types
        function [q, r] = CubicToAxial(x, y, z)
            q = x;
            r = z;
        end

        function [x, y, z] = AxialToCubic(q, r)
            x = q;
            z = r;
            y = -x-z;
        end

        function [c, r] = CubicToOffset(x, y, z) % Even-q offset
            c = x;
            r = z + (x + mod(x,2)) .* .5;
        end

        function [x, y, z] = OffsetToCubic(c, r)
            x = c;
            z = r - (c + mod(c,2)) .* .5;
            y = -x-z;
        end

        function [c, r] = AxialToOffset(q, r)   % Even-q offset
            [x, y, z] = HexLattice.AxialToCubic(q, r);
            [c, r] = HexLattice.CubicToOffset(x, y, z);
        end

        function [q, r] = OffsetToAxial(c, r)
            [x, y, z] = HexLattice.OffsetToCubic(c, r);
            [q, r] = HexLattice.CubicToAxial(x, y, z);
        end
    end
end