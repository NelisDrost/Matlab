function out = list_permute_RAM(varargin)
% Creates a list of all possible combination of elements from each of the input lists.
% Output has one column per input vector, and one row per combination.
% e.g.: 
% list_permute_RAM(1:2, 1:3, 1:2)
% 1 1 1
% 1 1 2
% 1 2 1
% 1 2 2
% 1 3 1
% 1 3 2
% 3 1 1
% 3 1 2
% 3 2 1
% 3 2 2
% 3 3 1
% 3 3 2

% Number of columns
n = nargin;

% Number of elements in each input
nn = cellfun(@numel, varargin);

% Number of resulting combinations
no = prod(nn);

% Start with the last list
out = varargin{n}(:);

for i = n-1:-1:1

	% Get the number of combinations in the existing output
    so = size(out,1);

    % Replicate this once for each item in the current list
    out = repmat(out, [nn(i) 1]);
    % Then prepend the current list, with each element replicated to the number of elements in the previous list.
    % (the reshape(repmat(...)) here collates the elements, rather than repeating them)
	out = [reshape(repmat(varargin{i}(:)', [so 1]), [nn(i) * so 1])...
        out];

end
end