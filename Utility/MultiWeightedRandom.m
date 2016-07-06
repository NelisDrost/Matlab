function out = MultiWeightedRandom(p, n, w)
% Samples n random numbers from population p, where the probability distribution
% is individually specified for each of those n samples.  Each column of w provides
% the weights on p for each of the n random samples.
% 
% Note that orientation of w is for optimisation
%
% Trivial example:
% p = [1 2 3];
% n = 4;
% w = [0 1 0 1;
%      1 0 1 1;
%      1 0 2 1];
% Would result in four random numbers:
% - the first has an equal probabilty of being 2 or 3
% - the second will always be 1
% - the third is twice as likely to be 3 as 2
% - the fourth has an equal probability of being 1, 2 or 3


assert(size(w,2) == n, 'MultiWeightedRandom - w should have n columns');
assert(size(w,1) == numel(p), 'MultiWeightedRandom - w should have one row for each element in p');

w2 = bsxfun(@rdivide, cumsum(w), sum(w));

out = sum(bsxfun(@ge, rand(1,n), w2)) + 1;

out = p(out);