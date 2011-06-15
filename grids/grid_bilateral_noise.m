function grid = grid_bilateral_noise

  % essentials
  grid.name = 'bilateral.noise';

  % controlling the sound presentation
  grid.stimGenerationFunctionName = 'makeBilateralNoise';
  grid.sampleRate = 24414.0625*2;  % ~50kHz

  % stimulus grid structure
  grid.stimGridTitles = {'Duration', 'LeftDelay', 'RightDelay', 'BothDelay', 'Level'};
  grid.stimGrid = [50 0 100 200 80];
  
  % sweep parameters
  grid.postStimSilence = 0.2; %seconds
  grid.repeatsPerCondition = 30;
  
  % set this using absolute calibration
  grid.stimLevelOffsetDB = -128;