function [data,timeStamp] = runSweep(sweepLen,stim,nextStim,channelMapping)
%% Run a sweep, ASSUMING THAT THE STIMULUS HAS ALREADY BEEN UPLOADED
%% Upload the next stimulus at the same time, then reset the stimDevice
%% and inform the stimDevice of the stimulus length

global zBus stimDevice dataDevice;
global fs_in fs_out;

% reset data device and tell it how long the sweep will be
resetDataDevice(sweepLen*1000);

% check for stale data in data device buffer
if any(countAllData~=0)
  error('Stale data in data buffer');
end

% check that the correct stimulus is in the TDT buffer
sz = size(stim,2);
rnd = floor(100+rand*(sz-300));
checkData = [downloadStim(0,100) downloadStim(rnd,100) downloadStim(sz-100,100)];
d = max(max(abs(checkData - [stim(:,1:100) stim(:,rnd+1:rnd+100) stim(:,end-99:end)])));

if d>10e-7
  keyboard;
  error('Stimulus mismatch!');
end

%keyboard;
% make matlab buffer for data
data = {};
for chan = 1:32
  data{chan} = zeros(1,ceil(sweepLen*fs_in));
end
index = zeros(1,32);

% keep track of how much of stimulus has been uploaded
stimIndex = 0;

% trigger stimulus presentation and data collection
timeStamp = clock;
triggerZBus;

fprintf('Sweep triggered.\n');

% while trial is running:
% * upload next stimulus as far as possible
% * download data as fast as possible while trial is running
% * plot incoming data
figure(2);
while any(index~=index(1)) || any(abs(index-round(sweepLen*fs_in))>1)
  maxStimIndex = getStimIndex;
  if ~isempty(nextStim)
    if stimIndex==(size(nextStim,2)-1)
      fprintf(['Next stimulus uploaded after ' num2str(toc) ' sec.\n']);
    elseif maxStimIndex>stimIndex
      uploadStimulus(nextStim(:,stimIndex+1:maxStimIndex),stimIndex);
      stimIndex = maxStimIndex;
    end
    %stimIndex
  end
  for chan = 1:32
    newdata = downloadData(channelMapping(chan),index(chan));
    data{chan}(index(chan)+1:index(chan)+length(newdata)) = newdata;
    index(chan) = index(chan)+length(newdata)-1;
    subplot(8,4,chan);
    plot((1:100:length(data{chan}))/fs_in,data{chan}(1:100:end));
  end
  %index
  %ceil(sweepLen*fs_in)
  drawnow;
end

fprintf(['Sweep done after ' num2str(toc) ' sec.\n']);

if ~isempty(nextStim)
  if stimIndex~=(size(nextStim,2)-1)
    uploadStimulus(nextStim(:,stimIndex+1:end),stimIndex);
    fprintf(['Next stimulus uploaded after ' num2str(toc) ' sec.\n']);
  end
end

% check all channels have the same amount of data
dataLen = length(data{1});
for ii = 2:32
  if length(data{ii})~=dataLen
    error('Different amounts of data from different channels');
  end
end

fprintf(['Got ' num2str(dataLen) ' samples from 32 channels (' num2str(dataLen/fs_in) ' sec).\n']);

resetStimDevice;

global checkdata
if checkdata
  fprintf('Checking stim...');
  teststim = downloadStim(0,size(nextStim,2));
  d = max(abs(nextStim-teststim));
  if d>10e-7
    error('Stimulus mismatch!');
  end
  fprintf([num2str(size(d,2)) ' samples verified.\n']);
  fprintf('Checking data...');
  testdata = downloadAllData;
  for chan = 1:32
    d = max(abs(data{chan}-testdata{chan}));
    if d>0
      error('Data mismatch!');
    end
  end
  fprintf([num2str(length(data{chan})) ' samples verified.\n']);
  fprintf(['done after ' num2str(toc) ' sec.\n']);
end
