classdef tdtBlockedDataDevice < tdtDevice
  % this attempts to be faster than the standard tdtStimDevice by 
  % using MCSerStore. however, it's acutally slower for long stimuli
  % d'oh
  
  properties
    nChannels = nan;
    rcxSetup = [];
  end

  methods

    function obj = tdtBlockedDataDevice(deviceInfo, requestedSampleRateHz, channelMap, ~)
      % initialise the class itself
      obj.rcxSetup.rcxFilename = ['benware/tdt/' deviceInfo.name '-blocked.rcx'];
      obj.rcxSetup.versionTagName = [deviceInfo.name 'BlockedVer'];
      obj.rcxSetup.versionTagValue = 3;

      % initialise the device
      obj.initialise(deviceInfo, requestedSampleRateHz, channelMap);
    end
    
    function initialise(obj, deviceInfo, requestedSampleRateHz, channelMap)
      obj.initialise@tdtDevice(deviceInfo, obj.rcxSetup.rcxFilename, requestedSampleRateHz);
      obj.setChannelMap(channelMap);
      obj.nChannels = length(channelMap);
      if ~obj.checkDevice(deviceInfo, requestedSampleRateHz, channelMap);
        errorBeep('DataDevice is not in requested state after initialisation');
      end
    end

    function [ok, message] = checkDevice(obj, deviceInfo, sampleRate, channelMap)
        % call this to make sure the TDT is in the desired state
        [ok, message] = obj.checkDevice@tdtDevice(deviceInfo, sampleRate, ...
            obj.rcxSetup.versionTagName, obj.rcxSetup.versionTagValue);
        obj.setChannelMap(channelMap);
    end

    function map = channelMap(obj)
      map = obj.handle.ReadTagVEX('ChanMap', 0, obj.nChannels ,'I32', 'F64', 1);
    end

    function setChannelMap(obj, channelMap)
       obj.handle.WriteTagVEX('ChanMap',0,'I32',channelMap);
    end
    
    function data = downloadAvailableData(obj, offset)
        channelsPerBlock = 16;

        nBlocks = ceil(obj.nChannels/channelsPerBlock);
        maxIndex = zeros(1,nBlocks);
        for block = 1:nBlocks
            maxIndex(block) = obj.handle.GetTagVal(['ADidx' num2str(block)]);
        end
        maxIndex = min(maxIndex);
        maxSample = floor(maxIndex/channelsPerBlock);
        nSamples = maxSample-offset;
        
        data = nan(nBlocks*channelsPerBlock, nSamples);

        for block = 1:nBlocks
            maxChan = block*channelsPerBlock;
            d = obj.handle.ReadTagVEX(['ADwb' num2str(block)], offset, nSamples, 'f32', 'f64', channelsPerBlock);
            data(maxChan-channelsPerBlock+1:maxChan,:) = d;
        end
        data = data(1:obj.nChannels, :);
 
    end

    function data = downloadAllData(obj)
      % this no longer needs to output a cell array
      channelsPerBlock = 16;
        
      nBlocks = ceil(obj.nChannels/channelsPerBlock);
      maxIndex = zeros(1,nBlocks);
      for block = 1:nBlocks
          maxIndex(block) = obj.handle.GetTagVal(['ADidx' num2str(block)]);
      end
      maxIndex = min(maxIndex);
      maxSample = floor(maxIndex/channelsPerBlock);
      nSamples = maxSample;
      
      data = nan(nBlocks*channelsPerBlock, nSamples);
      
      for block = 1:nBlocks
          maxChan = block*channelsPerBlock;
          d = obj.handle.ReadTagVEX(['ADwb' num2str(block)], 0, nSamples, 'f32', 'f64', channelsPerBlock);
          data(maxChan-channelsPerBlock+1:maxChan,:) = d;
      end
      data = data(1:obj.nChannels, :);
      
      data = mat2cell(data, ones(obj.nChannels, 1), size(data, 2));
    end
    
    function reset(obj, trialLen)
      if nargin==2
        obj.handle.SetTagVal('recdur',trialLen);
      end
      obj.handle.SoftTrg(9);
    end
    
    function setAudioMonitorChannel(obj, chan)
      obj.handle.SetTagVal('MonChan',chan);
    end
    
    function softTrigger(obj)
      obj.handle.SoftTrg(1);
    end

    function index = countAllData(obj, nChannels)
      % index = countAllData(dataDevice, nChannels)
      %
      % Count the number of samples available on each channel of the data Device
      % i.e. the index that the serial buffers have reached
      % 
      % dataDevice: A handle to the data device
      % nChannels: The number of channels that you want information about
      % index: 1xnChannels vector of buffer indexes

      index = nan(1, nChannels);
      for chan = 1:nChannels
          index(chan) = obj.handle.GetTagVal(['ADidx' num2str(chan)]);
      end
    end
    
    function index = countData(obj, chan)
      % index = countData(dataDevice, chan)
      %
      % Count number of samples available on a specified channel of the 
      % data device
      %
      % dataDevice: handle of the data device
      % chan: the number of the channel you want
      % index: the index that the serial buffer has reached

      index = obj.handle.GetTagVal(['ADidx' num2str(chan)]);
    end
    
  end
end
