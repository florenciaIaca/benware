function grid = grid_amns()

  % controlling the sound presentation
  grid.sampleRate = 24414.0625*2;  % ~100kHz
  grid.stimGenerationFunctionName = 'loadStimAndCompensate';
  grid.stimDir = 'e:\auditory-objects\sounds-uncalib\AMNs\';
  grid.stimFilename = 'AMN.%1_%2.wav';
  
  % stimulus grid structure
  grid.stimGridTitles = {'id1', 'id2', 'Level'};  
  grid.stimGrid = [createPermutationGrid(1:2, 1:6, 80)];

  global CALIBRATE;
  if CALIBRATE
   fprintf('Calibration only!!\n');
   pause;
   grid.stimGrid = [999 999 80]; % switching contrast, loud
  end
  
  % compensation filter
  grid.initFunction = 'loadCompensationFilters';
  grid.compensationFilterFile = ...
    'e:\auditory-objects\calibration\calib.ben.18.11.2013\compensationFilters.mat'; % 50kHz
  %grid.compensationFilterFile = ...
  %  '/Users/ben/scratch/expt.42/calib.expt42/compensationFilters100k.mat';

  grid.compensationFilterVarNames = {'compensationFilters.L', 'compensationFilters.R'};

  % sweep parameters
  grid.postStimSilence = 0;
  grid.repeatsPerCondition = 5;
  
  % set this using absolute calibration
  grid.stimLevelOffsetDB = [13 13]-27-25-10+19+43;
  