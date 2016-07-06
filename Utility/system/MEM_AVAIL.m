function bytes = MEM_AVAIL()


if ispc
	mem = memory;
	bytes = mem.MaxPossibleArrayBytes;
elseif isunix
	[r,w] = unix('free | grep Mem');
	stats = str2double(regexp(w, '[0-9]*', 'match'));
	memsize = stats(1);
	freemem = stats(3);
	bytes = freemem;
end