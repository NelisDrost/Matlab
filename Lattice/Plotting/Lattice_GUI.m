classdef Lattice_GUI < handle

    properties
        lplot   % Lattice plot object

        fh      % Figure handle
        pl_ax   % Figure area
        g_ui_p  % GUI area

        selection   % Patch for highlighting selection
        selected_ind
    end

    properties(Dependent=true)
        lattice
    end

    methods
        function o = Lattice_GUI(lattice)
            o.fh = figure;
            o.pl_ax = subplot(3,1,[1 2]);
            o.lplot = Lattice_Plot(lattice, o.pl_ax);
            o.lplot.Setup;
            
            o.selection = patch(lattice.cx(1) + lattice.ox, lattice.cy(1) + lattice.oy, 'r');
            o.selection.FaceAlpha = 0;
            o.selection.EdgeColor = 'c';

            set(o.fh, 'WindowButtonUpFcn', @o.MouseDown);
%             set(o.fh, 'WindowButtonDownFcn', @o.MouseDown);

            o.g_ui_p = uipanel('FontSize', 12, 'Position', [.13 .11 .775 .2157]);
        end

        function MouseDown(o, ~, ~)
            if isMultipleCall(); return; end        % Do not allow overlapping calls
            if ~isequal(gca, o.pl_ax); return; end  % This only applies to the plot axis
            
            % Get mousep position
            cc = get(gca, 'CurrentPoint');
            x = cc(1,1); y = cc(1,2);
            % Filter positions outside grid
            if x < o.lplot.ax_size(1) || x > o.lplot.ax_size(2) || y < o.lplot.ax_size(3) || y > o.lplot.ax_size(4); return; end

            % Move selection to clicked cell            
            o.Select_Cell(o.lplot.lattice.PointToIndex(cc(1,1), cc(1,2)));
        end

        function Select_Cell(o, ind)
            o.selected_ind = ind;
            o.selection.Vertices = [o.lattice.cx(ind) + o.lattice.ox(:), o.lattice.cy(ind) + o.lattice.oy(:)];
        end

        function val = get.lattice(o)
            val = o.lplot.lattice;
        end
    end
end