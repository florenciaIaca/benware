function stim = loadStimFileAndCompensate(stimFile, compensationFilters, level)
% stim = loadStimFileAndCompensate(stimFile, compensationFilters, level)
%
% Load a mono f32 or wav file and compensate using however many compensation
% filters are available. The correct stimulus files are found by
% finding experiment parameters in the grid and expt structures, and 
% using constructStimPath to replace % tokens with appropriate values
% (sweepNum, etc)
%
% This is the standard benware function for doing this job. Others may and do
% exist for special reasons, but this is usually the one to use.
% 
% stimFile -- stimulus file name
% compensationFilters -- struct
% level -- nominal level in dB

% get hashes of stimulus and compensation filters
hashoptions.Input = 'file';
stimhash = DataHash(stimFile, hashoptions);
filterhash = DataHash(compensationFilters);

cacheDir = sprintf('.%sstimcache%s', filesep, filesep);
cacheName = sprintf('%s%s.%s.mat', cacheDir,  stimhash, filterhash);

if exist(cacheName, 'file')
	% load from cache
	fprintf('\n  * loading compensated version from cache...')
	s = load(cacheName);
	stim = s.stim;
	
else
	fprintf('\n  * compensating...\n');

	% load the stimulus
	if strcmp(stimFile(end-3:end), '.f32')
		uncalib = readf32(stimFile);
	elseif strcmp(stimFile(end-3:end), '.wav')
		uncalib = audioread(stimFile);
	end

	% apply compensation filter
	for chan = 1:length(compensationFilters)
		stim(chan, :) = conv(uncalib, compensationFilters{chan});
	end

	% save in cache
	if ~exist(cacheDir, 'dir')
		mkdir(cacheDir);
	end

	fprintf('  * saving compensated version to cache...')
	save(cacheName, 'stim');

end

% apply level offset
level_offset = level - 80;
stim = stim * 10^(level_offset / 20);

fprintf(['done after ' num2str(toc) ' sec.\n']);

