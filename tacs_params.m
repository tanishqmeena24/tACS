%% TACS Parameters
%Settings: Intensity
pIntensity = struct("Action",7,"Intensity",2);
JSONIntensity = jsonencode(pIntensity);

%Settings: Waveform Change tACS
ptACS = struct('Action',7,'WaveformType','tACS');
JSONtACS = jsonencode(ptACS);

%Settings: Duration
pDuration = struct("Action",7,"Duration",10);
JSONDuration = jsonencode(pDuration);

%Settings: Delay
pDelay = struct("Action",7,"Delay",50);
JSONDelay = jsonencode(pDelay);

%Settings: RampUp
pRampUp = struct("Action",7,"RampUp",3);
JSONRampUp = jsonencode(pRampUp);

%Add Channel
pChannel = struct("Action",0,"ChannelNumber",2);
JSONaddChannel = jsonencode(pChannel);

%Settings: Frequency
pFrequency = struct('Action',7,'ChannelNumber',18,'Frequency',1.8);
JSONFrequency = jsonencode(pFrequency);

%Load Device
pLoad = struct("Action",3);
JSONLoad = jsonencode(pLoad);

%Starting Stimulation 
pstartStimulation = struct("Action",4);
JSONstartStimulation = jsonencode(pstartStimulation);

%Stop Stimulation 
pstopStimulation = struct("Action",5);
JSONstopStimulation = jsonencode(pstopStimulation);

%% -------------------------------------------------------------------- %%

%% Sending Commands to MXN

% outlet.push_sample({JSONIntensity});
% pause(2)
% outlet.push_sample({JSONtACS});
% pause(2)
% outlet.push_sample({JSONDuration});
% pause(2)
% outlet.push_sample({JSONDelay});
% pause(2)
% outlet.push_sample({JSONRampUp});
% pause(2)
% outlet.push_sample({JSONaddChannel});
% pause(2)
% outlet.push_sample({JSONLoad});
% pause(2)
% outlet.push_sample({JSONstartStimulation});
% pause(2);
% outlet.push_sample({JSONstopStimulation});
% pause(2)
