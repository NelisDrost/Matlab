function out = list_permute(a, b)
%% Creates a list of all possible combinations of a and b
% a & b should be column vectors, or 2d matrices where each row is an
% element in the list

%%
ai = 1:length(a);
bi = 1:length(b);
%%
[x, y] = ndgrid(ai, bi);
%%
out = [a(x(:),:), b(y(:),:)];

end