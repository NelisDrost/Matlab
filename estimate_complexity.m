function [times, p_range] = estimate_complexity(func, pars, ranges, isfloating, res)

% func = @comp_test;
% pars = 3;
% ranges = [3 10; 3 5; 3 10];
% isfloating = [true true true];
% res = 4;

np = pars;

if nargin < 5
	res = ones(np, 1) * 4;
elseif numel(res) == 1
    res = ones(np, 1) .* res;
end

p_range = cell(1,np);
for i = 1:np

	p_range{i} = linspace(ranges(i,1), ranges(i,2), res(i));
	if ~isfloating(i)
		p_range{i} = unique(floor(p_range{i}));
	end

end

dims = cellfun(@numel, p_range);
if numel(dims) == 1
	dims = [dims 1];
end
times = zeros(dims);

ps = cell(np,1);
for i = 1:np
	ps{i} = p_range{i}(1);
end

it = tic;
func(ps{:});
base_time = toc(it);

min_time = base_time * prod(dims);

fprintf('Minimum possible time for computation : %f', min_time);

ps = list_permute_RAM(p_range{:});

indicies = cell(np,1);
for i = 1:np
	indicies{i} = 1:res(i);
end
% [indicies{1:np}]	= deal(1:res);
indicies = list_permute_RAM(indicies{:});

input('\nContinue?');

wb = waitbar(0, 'Running');
for i = 1:size(indicies,1)

	disp(indicies(i,:));

	pp = num2cell(ps(i,:));
	disp([pp{:}]);
	it = tic;
	func(pp{:});
	t = toc(it);

	disp(t);

	ii = num2cell(indicies(i,:));
	times(ii{:}) = t;
    waitbar(i/size(indicies,1), wb);
end
close(wb);

%% Detect noise for short times, recommend possibly longer run times


%% Detect interactions

for i = 1:np

	% Construct dimensions for calculating differences along each dimension
	if np == 1
		dim = [1; numel(times)];
	else
		dim = [ones(1,np); size(times)];
	end
	dim1 = dim; dim2 = dim;
	% We're dividing each value along a dimension by the previous value, so we want elements 1:(end-1) and 2:end
	dim1(2,i) = dim(2,i) - 1;
	dim2(1,i) = 2;

	% Convert these dimension bounds (e.g.: [1 1 2 1; 4 5 3 4]) to cells containing vectors of indicies, e.g.:
	% {[1 2 3 4]; [1 2 3 4 5]; [2 3]; [1 2 3 4]}; 
	fn = @(a) a(1):a(2);
	dim1 = cellfun(fn, mat2cell(dim1, 2, ones(1,np)), 'UniformOutput', false);
	dim2 = cellfun(fn, mat2cell(dim2, 2, ones(1,np)), 'UniformOutput', false);

	% Perform division on time data
	dat = times(dim2{:}) ./ times(dim1{:});

	% Construct similair data for parameter values, using only the parameter values along the current dimension
	pr = p_range{i};				% Get parameter values
	pr = pr(2:end) ./ pr(1:end-1);	% Divide, as for time values
	npr = numel(pr);				% Reshape so that vector runs along the dimension being assessed
	shape = ones(1,np);
	shape(i) = npr;
	if np == 1
		shape = [shape 1];
	end
	pr = reshape(pr, shape);
	shape = size(dat);				% Repmat so that parameter data has same size as dat above
	shape(i) = 1;
	pr = repmat(pr, shape);

	ldat = log(dat) ./ log(pr);		% Divide logs to get exponent
	m = mean(ldat(:));				% Get mean exponent
	err = sum((ldat(:) - m).^2);	% Check error, in ideal case all values should be the same

	if err > (numel(dat) * 1e-2)	% Warn user if there is significant error
		warning('estimate_complexity:non-exponent-complexity', 'Complexity for parameter {0} is not exponential', i);
		disp(err);
		disp(ldat);
	end

	% For now, simply print the exponent of each parameter
	fprintf('Parameter %i exponent : %f\n', i, m);

	% Future work:
	% - detect constant time (exponent = 0);
	% - detect log time
	% - detect factorial time
	% - detect additive time (i.e.: O(a^2*b^3+c))
end
