function waveform = gen_drc(fs, freqs, levels, chord_duration, ramp_duration)
% gen_drc() -- create a DRC waveform from a grid of levels
%   Usage:
%      waveform = gen_drc(fs, freqs, levels, chord_duration, ramp_duration)
%   Parameters:
%      fs              sample rate
%      freqs           the frequencies of the tones to use
%      levels          grid of levels (n_freqs x n_chords)
%      chord_duration  in seconds
%      ramp_duration   in seconds
%   Outputs:
%      waveform        waveform containing DRCs at different level
%
% Differences between this and the last version (very similar to Neil's classic DRCs)
% * at every transition (inc start/end), there is a cosine ramp in amplitude, not level
% * the first chord is the same as others
% * the end is slightly different
%
% Author: ben.willmore & astrid.klinge@googlemail.com & stef@nstrahl.de
% Version: $Id:$

do_debug = false;

n_chords = size(levels, 2);
n_freqs = size(levels, 1);

%% list of samples on which chords will start
chord_start_times = (0:n_chords)*chord_duration;
chord_start_samples = round(chord_start_times*fs)+1;

%% make a standard envelope for a single chord (ramp up then hold)
ramp_samples = round(ramp_duration .* fs);
rt = linspace(-pi/2, pi/2, ramp_samples);
cosramp = sin(rt)/2+0.5;
max_chordlen = max(diff(chord_start_samples));
chord_env = [cosramp ones(1, max_chordlen-ramp_samples)];

%% time vector for whole stimulus
total_samples = max(chord_start_samples)-1 + ramp_samples;
t = (0:(total_samples-1))/fs;

%% convert level to amplitude in atmospheric pressure (Pascal)
amplitudes = 20e-6*10.^(levels/20);

%% build up stimulus, one tone at a time
waveform = [];

for freq_idx = 1:n_freqs
	fprintf('.');

	% make carrier sinusoid
	if isvector(freqs)
        freq = freqs(freq_idx);
        carrier = sin(2*pi*freq*t);
    else
        idx  = arrayfun(@(x,y) repmat(x,[1 y]),1:n_chords,diff(chord_start_samples),'UniformOutput',false);  % allow different sample lenghts for each chord
        freq = freqs(freq_idx,cell2mat(idx));
        freq = horzcat(freq(1)*ones(1,floor(length(cosramp)/2)),freq,freq(end)*ones(1,ceil(length(cosramp)/2)));
        % we need to correct for the phase jumps from one chord to another by calculating the difference between the phase at the end of the previous and the phase at the beginning of the
        % following chord and correcting the phase of the following chord to match it to the phase from the previous chord
        pos           = [0 ramp_duration/2*ones(1,n_chords)] + (0:(n_chords))*chord_duration; % get positions in seconds where frequency changes
        phase_diff    = -2*pi* [0 diff(freqs(freq_idx,:))] .* pos(1:end-1);                   % get phase offsets/jumps to remove
        phase_diff    = phase_diff + phase_diff(2);                                           % introduce random phase by starting chord 1 with phase offset between chord 1 and 2
        phase_correct = [0 cumsum(phase_diff(1:end-1))];                                      % we need to propagate our phase corrections
        
        temp = phase_diff+phase_correct;
        phi  = temp(cell2mat(idx));        % reuse idx from above
        phi  = horzcat(phi(1)*ones(1,floor(length(cosramp)/2)),phi,phi(end)*ones(1,ceil(length(cosramp)/2)));
        
        carrier = sin(2*pi*freq.*t+phi);
    end

	% make envelope
	env = {};

	last_level = 0;

	% ramp from the last amplitude
	% to the current one, then hold at the current amplitude

	for chord_idx = 1:n_chords
		level = sqrt(2) * amplitudes(freq_idx, chord_idx); % sqrt(2) to calibrate to RMS of this sinus function
		len = chord_start_samples(chord_idx+1) - chord_start_samples(chord_idx);

		env{chord_idx} = last_level+chord_env(1:len)*(level-last_level);
		last_level = level;
	end

	% final ramp down to zero
	level = 0;
	env{end+1} = last_level+cosramp*(level-last_level);

    if do_debug
        n_chord_pos = [1 cumsum(cellfun(@length,env))+ round(ramp_samples/2)+1];   % remember where the next chords do begin
        n_chord_pos(end) = 	n_chord_pos(end) - round(ramp_samples/2);
    end
    env = cell2mat(env);

	% superpose the frequency channels on one another to
	% get a single sound vector
	if isempty(waveform)
		waveform = carrier .* env;
	else
		waveform = waveform + carrier .* env;
    end
end

if do_debug
    %% compute RMS level for all n_chords
    rms_chords = zeros(n_chords,1);
    for i=1:n_chords
        wav_chord = waveform(n_chord_pos(i):n_chord_pos(i+1));
        rms_chords(i) = sqrt(sum(wav_chord.^2)/ length(wav_chord));
    end
    subplot(3,1,1)
    plot(waveform)
    subplot(3,1,2)
    plot(rms_chords);
    grid minor
    ylabel('RMS level (Pascal)');
    subplot(3,1,3)
    plot(20*log10(rms_chords/20e-6));
    title(['mean rms: ' num2str(mean(20*log10(rms_chords/20e-6)))])
    grid minor
    ylabel('RMS level (dB SPL)');
    xlabel('Chord number');
end