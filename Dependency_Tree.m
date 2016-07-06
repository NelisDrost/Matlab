function [fn, usage] = Dependency_Tree()

[fn, fc, im] = Build_File_List('.');

disp(fn);
disp(fc);

usage = zeros(numel(fc));
for i = 1:numel(fc)
	usage(:,i) = File_Contains_Call(fn{i}, fc);
end

end

function out = File_Contains_Call(caller, targets)
	fh = fopen(caller);
	data = fscanf(fh, '%s');
	fclose(fh);

	out = cellfun(@(x)~isempty(strfind(data,x)), targets);
end

function [fnames, fcall, is_function] = Build_File_List(folder)


	d = dir(folder);
	c = {d.name}';
	m = c(cellfun(@(x)~isempty(x), strfind(c,'.m')));
	m = cellfun(@(x)fullfile(folder,x),m,'UniformOutput',false);
	f = c(Find_Dirs(c));
	f = cellfun(@(x)fullfile(folder,x),f,'UniformOutput',false);
	nf = numel(f);
	for i = 1:nf
		m = [m; Build_File_List(f{i})];
	end

	if nargout >= 2
		fcall = cellfun(@call_name, m, 'UniformOutput', false);
	end

	if nargout >= 3
		is_function = cellfun(@(x)Is_Function(x), m);
	end

	fnames = m;
end

function out = Find_Dirs(fnames)

	% Remove ./../.git
	exclude = cellfun(@(x)isequal(x,'.'), fnames) | cellfun(@(x)isequal(x,'..'), fnames) | cellfun(@(x)isequal(x,'.git'), fnames);

	out = ~exclude & cellfun(@isdir, fnames);
end

function out = Is_Function(fname)
fh = fopen(fname);
out = isequal(fscanf(fh, '%s', 1), 'function');
fclose(fh);
end

function out = call_name(fname)
	[~,out,~] = fileparts(fname);
end