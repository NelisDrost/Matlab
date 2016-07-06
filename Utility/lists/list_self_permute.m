function out = list_self_permute(a)
%% Creates a list of all possible combinations of a and b
% a & b should be column vectors, or 2d matrices where each row is an
% element in the list

%%
ai = 1:length(a);

%%
[x, y] = ndgrid(ai, ai);
%%
ind = tril(true(length(a)),-1);

out = [a(y(ind),:), a(x(ind),:)];

end