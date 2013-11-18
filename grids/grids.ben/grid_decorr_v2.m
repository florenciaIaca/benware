function grid = grid_decorr_v2()

  % controlling the sound presentation
  grid.sampleRate = 24414.0625*4;  % ~100kHz
  grid.stimGenerationFunctionName = 'loadStimAndCompensate';
  grid.stimDir = 'e:\auditory-objects\sounds-uncalib\decorr.v2\';
  grid.stimFilename = 'drc.cond.%1.token.%2.f32';
  
  % stimulus grid structure
  grid.stimGridTitles = {'Condition', 'Token', 'Level'};  
  grid.stimGrid = [createPermutationGrid(1:12, 1:2, 80)];

  global CALIBRATE;
  if CALIBRATE
   fprintf('Calibration only!!\n');
   pause;
   grid.stimGrid = [4 1 80]; % switching contrast, loud
  end
  
  % compensation filter
  grid.initFunction = 'loadCompensationFilters';
  grid.compensationFilterFile = ...
    'e:\auditory-objects\calibration\calib.ben.18.11.2013\compensationFilters.100k.mat'; % 100kHz
  %grid.compensationFilterFile = ...
  %  '/Users/ben/scratch/expt.42/calib.expt42/compensationFilters100k.mat';

  grid.compensationFilterVarNames = {'compensationFilters.L', 'compensationFilters.R'};

  % sweep parameters
  grid.postStimSilence = 0;
  grid.repeatsPerCondition = 4;
  
  % set this using absolute calibration
  grid.stimLevelOffsetDB = [13 13]-27-25-10+19;
  