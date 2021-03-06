function grid = grid_SH_En_C()
  % mega-grid for Sparseness / Environmental / CRF04

  % controlling the sound presentation
  grid.stimGenerationFunctionName = 'loadStereo';
  grid.stimDir = 'E:\auditory-objects\sounds.calib.expt%E\%N\';
  grid.sampleRate = 24414.0625*2;  % ~50kHz

  % essentials
  grid.name = 'SH.En.C';
  grid.stimFilename = 'source.%1.mode.%2.BF.%3.token.%4.set.%5.stimnum.%6.%L.f32';
  
  % stimulus grid structure
  grid.stimGridTitles = {'Source', 'Mode', 'BF', 'Token', 'Set', 'StimID', 'NominalLevel', 'Level'};

  grid.stimGrid = [...
    createPermutationGrid(0, 5, 0, 0:9, 0, 0,    80, (-92 + 80)); ... % CRF04
    createPermutationGrid(1, 0, 0, 0,   2, 1:12, 80, (-129 + 80)); ... % Sparseness Repeat 1
    createPermutationGrid(1, 0, 0, 0,   2, 1:12, 80, (-129 + 80)); ... % Sparseness Repeat 2
    createPermutationGrid(1, 0, 0, 0,   2, 1:12, 80, (-129 + 80)); ... % Sparseness Repeat 1
    2, 0, 0, 0, 1, 1, 82, -48; ... % Environmental Repeat 1
    2, 0, 0, 0, 1, 2, 80, -50; ...
    2, 0, 0, 0, 1, 3, 80, -50; ...
    2, 0, 0, 0, 1, 4, 80, -50; ...
    2, 0, 0, 0, 1, 5, 80, -50; ...
    2, 0, 0, 0, 1, 6, 80, -50; ...
    2, 0, 0, 0, 1, 7, 75, -55; ...
    2, 0, 0, 0, 1, 8, 80, -50; ...
    2, 0, 0, 0, 1, 1, 82, -48; ... % Environmental Repeat 1
    2, 0, 0, 0, 1, 2, 80, -50; ...
    2, 0, 0, 0, 1, 3, 80, -50; ...
    2, 0, 0, 0, 1, 4, 80, -50; ...
    2, 0, 0, 0, 1, 5, 80, -50; ...
    2, 0, 0, 0, 1, 6, 80, -50; ...
    2, 0, 0, 0, 1, 7, 75, -55; ...
    2, 0, 0, 0, 1, 8, 80, -50];
  
  % sweep parameters
  grid.postStimSilence = 0.2;
  grid.repeatsPerCondition = 10;
  
  % set this using absolute calibration
  grid.stimLevelOffsetDB = [-5, 0];
  
