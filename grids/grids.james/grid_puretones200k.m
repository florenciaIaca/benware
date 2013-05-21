function grid = grid_puretones200k()

  % controlling the sound presentation
  grid.sampleRate = 24414.0625*16/3;  % ~200kHz
  grid.stimGenerationFunctionName = 'makeCalibTone';

  % compensation filter
  grid.initFunction = 'loadCompensationFilters';
  grid.compensationFilterFile = ...
    'e:\auditory-objects\calibration\james.expt.8\calibL_200k.mat';
  grid.compensationFilterVarNames = {'calibL_200k.filter'};  
  
  % stimulus grid structure
  grid.stimGridTitles = {'Frequency', 'Duration (ms)', 'Level (dB)'};

  % frequencies and levels
  freq_min = 4000;
  freq_max = 64000*2^(.5);
  freq_step_oct = 1/4;
  n_steps = floor(log2(freq_max/freq_min)/freq_step_oct);
  freqs = logspace(log10(freq_min), log10(freq_max), n_steps+1);
 
  levels = 80:10:100;
  grid.stimGrid = createPermutationGrid(freqs, 50, levels);
  
  %fprintf('For calibration only!\n');
  %grid.stimGrid = [10000 500 90];
  
  % sweep parameters
  grid.sweepLength = 1;
  grid.repeatsPerCondition = 30;
  
  % set this using absolute calibration
  grid.stimLevelOffsetDB = [-28+0 0]; % previous -179
  
  
