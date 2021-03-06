classdef tdtDevice < handle

  properties
    deviceName = '';
    busName = '';
    deviceNumber = nan;
    rcxFilename = '';
    handle = [];
  end

  methods
    
    function initialise(obj, deviceInfo, rcxFilename, requestedSampleRateHz)
                
      tdt50k = 48828.125;

      sampleRates =   [0.125 0.25 0.5 1 2 4 8]*tdt50k;
      sampleRateIDs = [    0    1   2 3 4 5 6];

      % for RX6, available sample rates are
      % tdt50k * [1/8 1/4 1/2 1 2 4]
      % tdt50k * 8/7 * [1/8 1/4 1/2 1 2 4]
      % tdt50k * 4/3 * [1/8 1/4 1/2 1 2 4]
      % tdt50k * 8/5 * [1/8 1/4 1/2 1 2]
      % We'll keep the standard set and IDs, and use them if possible.
      % Out of a sense of conservatism. Note that the find below
      % chooses the first matching rate which will match the standard
      % 0-6 ID if its available.
      if strcmp(deviceInfo.name, 'RX6')
	extras = [tdt50k * [1/8 1/4 1/2 1 2 4] ...
		  tdt50k * 8/7 * [1/8 1/4 1/2 1 2 4] ...
		  tdt50k * 4/3 * [1/8 1/4 1/2 1 2 4] ...
		  tdt50k * 8/5 * [1/8 1/4 1/2 1 2]];
	sampleRates = [sampleRates extras];
	sampleRateIDs = [sampleRateIDs extras];
     end

      f = find(floor(requestedSampleRateHz)==floor(sampleRates), 1);

      if length(f)==1
        %sampleRate = sampleRates(f);
        sampleRateID = sampleRateIDs(f);
      else
        errorBeep('Unknown sample rate');
      end

      fprintf(['  * Initialising ' deviceInfo.name '\n']);
      obj.handle = actxserver('RPco.x', [5 5 26 26]);

      if invoke(obj.handle, ['Connect' deviceInfo.name], ...
                  deviceInfo.busName, deviceInfo.deviceNumber) == 0
        errorBeep(sprintf('Cannot connect to %s #%d on %s bus', ...
                  deviceInfo.name, deviceInfo.deviceNumber, deviceInfo.busName));
      end
      obj.deviceName = deviceInfo.name;
      obj.busName = deviceInfo.busName;
      obj.deviceNumber = deviceInfo.deviceNumber;

      if invoke(obj.handle, 'LoadCOFsf', rcxFilename, sampleRateID) == 0
        errorBeep(['Cannot upload ' rcxFilename ]);
      end
      obj.rcxFilename = rcxFilename;
      
      if invoke(obj.handle, 'Run') == 0
        errorBeep('Stimulus RCX Circuit failed to run.');
      end
    
      %[ok, message] = obj.checkDevice(requestedSampleRateHz, versionTagName, versionTagValue);
      %
      %if ok
      %  fprintf(['  * ' deviceName ' ready, sample rate = ' num2str(obj.handle.GetSFreq) ' Hz\n']);
      %else
      %  errorBeep(['Couldn''t initialise ' deviceName ': ' message]);
      %end
    end
    
    function val = versionTagValue(obj)
        val = obj.handle.GetTagVal(obj.versionTagName);
    end
        
    function [ok, message] = checkDevice(obj, ...
                    deviceInfo, sampleRateHz, versionTagName, versionTagValue)
      % 
      % Check whether a TDT device is in the desired state. If not, return ok=false
      % and provide an explanatory message that a calling function can print to
      % the screen.
      %
      % device: handle to the device
      % sampleRateHz: the sample rate you want
      % versionTagName: the name of a tag in the RCX file that we're using to 
      %   store a circuit version number
      % versionTagValue: the version number expected

      ok = true;
      message = '';
            
      if ~strcmp(obj.deviceName, deviceInfo.name)
        ok = false;
        message = 'wrong stimulus device';
        return;
      end
      
      if ~strcmp(obj.busName, deviceInfo.busName)
        ok = false;
        message = 'wrong bus';
        return;
      end
      
      if obj.deviceNumber~=deviceInfo.deviceNumber
        ok = false;
        message = 'wrong device number';
        return;
      end
      
      currentVersionTagValue = obj.handle.GetTagVal(versionTagName);
      if currentVersionTagValue~=versionTagValue
        ok = false;
        message = 'wrong circuit loaded';
        return;
      end
      
      currentSampleRateHz = obj.sampleRate;
      if floor(currentSampleRateHz)~=floor(sampleRateHz)
        ok = false;
        message = ['wrong sample rate -- requested ' num2str(sampleRateHz) ', got ' num2str(obj.sampleRate)];
        return;
      end
 
      
      status = obj.deviceStatus;
      if status~=7
        ok = false;
        message = ['reports wrong status -- code ' num2str(obj.deviceStatus)];
      end
      
      fprintf('  * Device %s (%s%d) OK: %s v.%d @ %0.0fHz\n', deviceInfo.name, ...
          deviceInfo.busName, deviceInfo.deviceNumber, versionTagName(4:end-3), ...
          versionTagValue, currentSampleRateHz);
    end

    function rate = sampleRate(obj)
        rate = obj.handle.GetSFreq;
    end
    
    function status = deviceStatus(obj)
        status = bitand(obj.handle.GetStatus,7);
    end
    
  end

end
