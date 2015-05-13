function out = list_self_permute_RAM(a)
%% Creates a list of all possible combinations of a and b
% a & b should be column vectors, or 2d matrices where each row is an
% element in the list
% This produces identical output to:
% out = nchoosek(a, 2);
% but is MUCH faster
%
% Memory efficient version of list_self_permute
% Faster for numel(a) > ~300
% (probably because of memory allocation time, not computation)

% Number of elements in a
n = numel(a);
% Number of elements in output
no = nchoosek(n,2);

% Assign output variable size
out = zeros(no, 2);

% Insertion index
is = 1;
ie = n-1;

% Source index
si = 2;
se = n;

for i = 1:n
	% Copy source block to output
	out(is:ie,1) = a(i);
	out(is:ie,2) = a(si:se);

	% Insert next block after this one
	is = ie + 1;
	% Next block is length of original vector, minus the number of indices already paired against
	ie = ie + n - i - 1;

	% Next source block includes one less index
	si = si + 1;
	se = n;
end
end