classdef Lattice_Plot < handle

    properties
        lattice

        lines
        patches
        links

        link_pairs
        neigh_pairs
        neigh_dir

        ax_size
        ax_handle
    end

    properties (Dependent=true)
        patch_ind
        line_ind
        link_ind
    end

    methods
        function o = Lattice_Plot(lattice, ax)
            if nargin < 2
                ax = gca;
            end

            o.ax_handle = ax;
            o.lattice = lattice;
        end 

        function Setup(o)
            
            cla(o.ax_handle);  % Clear axes
            axes(o.ax_handle); % Create/focus axes
            hold on;

            % Get patch center locations
            cx = o.lattice.cx(:);   cy = o.lattice.cy(:);
            % Get border offsets
            ox = o.lattice.ox;      oy = o.lattice.oy;


            %% Patches

            % Create patch objects
            for i = numel(cx):-1:1
                o.patches(i) = patch(cx(i) + ox, cy(i) + oy, 'r');
            end

            o.patches = handle(o.patches);  % Should already be a handle, this fixes it if not

            % Set default patch/edge color
            [o.patches(:).FaceColor] = deal([1 1 1]);   % White
            [o.patches(:).FaceAlpha] = deal(0);         % Transparent
            [o.patches(:).EdgeColor] = deal([1 1 1]);   % White
            [o.patches(:).Visible] = deal('on');        % Visible

            %% Borders/lines
            % List of neighbouring indices
            o.neigh_pairs = o.lattice.Neigh_Pairs();
            % Index into border offset coords
            [~, ~, o.neigh_dir] = o.lattice.Neigh_Pairs_To_Mat(o.neigh_pairs);

            [x, y] = o.lattice.IndToXY(o.neigh_pairs(:, 1));
            x = repmat(x, [1 2]);
            y = repmat(y, [1 2]);

            ndd = [o.neigh_dir, o.neigh_dir + 1];
            x = x + ox(ndd);
            y = y + oy(ndd);

            o.lines = plot(x', y', 'k');

            %% Links
            o.link_pairs = unique(sort(o.neigh_pairs, 2), 'rows');
            [x1, y1] = o.lattice.IndToXY(o.link_pairs(:, 1));
            [x2, y2] = o.lattice.IndToXY(o.link_pairs(:, 2));
            % xb = mean([x1 x2], 2);   yb = mean([y1 y2], 2);
            % x1 = mean([x1 xb], 2);   x2 = mean([x2 xb], 2);
            % y1 = mean([y1 yb], 2);   y2 = mean([y2 yb], 2);

            o.links = plot([x1 x2]', [y1 y2]', 'k');
            [o.links(:).Visible] = deal('off');

            % Set axis
            axis([min(x(:)) max(x(:)) min(y(:)) max(y(:))]);
            o.ax_size = axis;
        end

        function Activate_Patches(o, ind, is_active)
            % Make a set of sites visible or invisible

            if islogical(ind)
                ind = o.patch_ind(ind);
            end

            % Default to turning on all given indices
            if nargin < 3
                is_active = true(size(ind));
            end

            % Allow specifying a single state to set all given indices to
            if numel(is_active) == 1
                is_active = repmat(is_active, size(ind)) == 1;
            end

            if ~isempty(ind)
                % Make active sites visible
                if nnz(is_active) ~= 0
                    [o.patches(ind(is_active)).Visible] = deal('on');
                    [o.patches(ind(is_active)).FaceAlpha] = deal(1);
                    [o.patches(ind(is_active)).EdgeAlpha] = deal(1);
                end
                % Make inactive sites invisible
                if nnz(~is_active) ~= 0
                    [o.patches(ind(~is_active)).Visible] = deal('off');
                    [o.patches(ind(~is_active)).FaceAlpha] = deal(0);
                    [o.patches(ind(~is_active)).EdgeAlpha] = deal(0);
                end
            end
        end

        function Update_Patches(o, ind, face_color, edge_color)

            if islogical(ind)
                ind = o.patch_ind(ind);
            end

            if ~isempty(ind)
                % Update face color
                if nargin >= 3 && ~isempty(face_color)
                    if ~iscell(face_color)  % Set all faces to the same color
                        [o.patches(ind).FaceColor] = deal(face_color); 
                    else                    % Individually specify colors
                        [o.patches(ind).FaceColor] = deal(face_color{:}); 
                    end
                end

                % Update edge color
                if nargin >= 4 && ~isempty(edge_color)
                    if ~iscell(edge_color)  % Set edges of all pathes to same color
                        [o.patches(ind).EdgeColor] = deal(edge_color);
                    else                    % Individually specify edge colors
                        [o.patches(ind).EdgeColor] = deal(edge_color{:});
                    end
                end
            end
        end

        function Activate_Links(o, link_pairs, is_active)
            
            if isempty(link_pairs)
                return
            end
            
            if numel(link_pairs) > 2 && isrow(link_pairs)
                link_pairs = link_pairs';
            end
            
            if size(link_pairs, 2) == 1
                if islogical(link_pairs)
                    ii = find(link_pairs);
                else
                    ii = link_pairs;
                end
            else % Identify correct links
                ii = find(ismember(sort(o.link_pairs, 2), sort(link_pairs, 2), 'rows'));
            end

            if nargin < 3
                is_active = ones(size(ii(:,1))) ~= 0;
            elseif numel(is_active) == 1
                is_active = repmat(is_active, size(ii(:, 1))) ~= 0;
            else
                is_active = is_active ~= 0;
            end

            if ~isempty(ii)
                if ~isempty(ii(is_active))
                    [o.links(ii(is_active)).Visible] = deal('on');
                end

                if ~isempty(ii(~is_active))
                    [o.links(ii(~is_active)).Visible] = deal('off');
                end
            end
        end

        function Update_Links(o, link_pairs, weight)
            if isempty(link_pairs)
                return
            end
            
            if numel(link_pairs) > 2 && isrow(link_pairs)
                link_pairs = link_pairs';
            end
            
            if nargin < 3
                weight = ones(size(link_pairs(:,1))) ~= 0;
            elseif numel(weight) == 1
                weight = repmat(weight, size(link_pairs(:, 1))) ~= 0;
            end

            if size(link_pairs, 2) == 1
                if islogical(link_pairs)
                    ii = find(link_pairs);
                else
                    ii = link_pairs;
                end
            else % Identify correct links
                [~, ii] = ismember(sort(link_pairs, 2), sort(o.link_pairs, 2), 'rows');
            end

            weight = num2cell(weight);

            if ~isempty(ii)
                if ~isempty(ii)
                    [o.links(ii).LineWidth] = deal(weight{:});
                end
            end
        end

        function Update_Borders(o, ind, line_width, line_color)
            % Update width and color of lines

            if islogical(ind)
                ind = o.line_ind(ind);
            end

            if ~isempty(ind)
                if nargin >= 3 && ~isempty(line_width)
               
                    if numel(line_width) == 1
                        line_width = repmat(line_width, size(ind));
                    end
                    
                    % Hide lines that would have width 0
                    hidden = line_width == 0;
                    if nnz(hidden) ~= 0
                        [o.lines(ind(hidden)).Visible] = deal('off');
                    end
                    if nnz(~hidden) ~= 0
                        [o.lines(ind(~hidden)).Visible] = deal('on');
                    end

                    % Set line width
                    line_width(hidden) = 1;     % attempting to set width = 0 results in an error 
                    lw = num2cell(line_width);  % widths can be specified individually, or once for all given lines
                    [o.lines(ind).LineWidth] = deal(lw{:});
                end

                if nargin >= 4 && ~isempty(line_color)
                    % Update line color
                    if ~iscell(line_color)  % Set all lines to same color
                        [o.lines(ind).Color] = deal(line_color);
                    else                    % Individually specify line color
                        [o.lines(ind).Color] = deal(line_color{:});
                    end
                end
            end
        end

        function val = get.patch_ind(o)
            val = 1:numel(o.patches);
        end

        function val = get.line_ind(o)
            val = 1:numel(o.lines);
        end

        function val = get.link_ind(o)
            val = 1:size(o.link_pairs, 1);
        end
    end

end
