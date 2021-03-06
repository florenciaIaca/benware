function newpen(n)
% newpen(n)
% 
% Update the penetration number in the expt structure and save it
% Adds 1 if you don't specify a number
%
% Run this when you start a new penetration
setpath;

loadexpt;

if ~exist('n', 'var')
  n = expt.penetrationNum + 1;
end

expt.penetrationNum = n;
fprintf('Setting penetration number to %d\n', n);

in = demandinput('Do you need to update probe info? [y/N] ', 'yn', 'n');
if lower(in)=='y'
	if isfield(expt, 'probes')
		expt.probes = chooseProbes(expt.probes);
	else
		expt.probes = chooseProbes;
	end

	expt.channelMapping = generateChannelMapping(expt.probes);
end

printExpt(expt);

saveexpt;
