function [C,timingfile,userdefined_trialholder] = tACSuserloop(~,TrialRecord)

C = [];
timingfile = 'displayGratingsTiming_tACS.m';
userdefined_trialholder = '';

num_blocks = 100;
if mod(num_blocks,2) == 1
    error("num_blocks should be an even number")
end

persistent stimList
persistent stimPrev
persistent stimBorrow

persistent stimTable
persistent stimLength
persistent blockSum

persistent lsl_init
persistent tacs_loaded

if isempty(stimTable)

    % -----------------------------
    % Initialize LSL outlet
    % -----------------------------
    if isempty(lsl_init)

        Start_up();          % your LSL initialization script
        TrialRecord.User.outlet = outlet;
        lsl_init = true;

        disp('------------------------------------------')
        disp('1. Open stimulation GUI')
        disp('2. Login to GUI')
        disp('3. Connect GUI to stimulation device')
        disp('Press ENTER when ready')
        disp('------------------------------------------')

        pause;

    end

    % -----------------------------
    % Load tACS parameters
    % -----------------------------
    if isempty(tacs_loaded)

        tacs_parameters_script    % <-- your JSON parameter script

        TrialRecord.User.JSONIntensity = JSONIntensity;
        TrialRecord.User.JSONtACS = JSONtACS;
        TrialRecord.User.JSONDuration = JSONDuration;
        TrialRecord.User.JSONDelay = JSONDelay;
        TrialRecord.User.JSONRampUp = JSONRampUp;
        TrialRecord.User.JSONaddChannel = JSONaddChannel;
        TrialRecord.User.JSONLoad = JSONLoad;
        TrialRecord.User.JSONstartStimulation = JSONstartStimulation;
        TrialRecord.User.JSONstopStimulation = JSONstopStimulation;

        % Send configuration commands once
        outlet.push_sample({JSONIntensity}); pause(0.5)
        outlet.push_sample({JSONtACS}); pause(0.5)
        outlet.push_sample({JSONDuration}); pause(0.5)
        outlet.push_sample({JSONDelay}); pause(0.5)
        outlet.push_sample({JSONRampUp}); pause(0.5)
        outlet.push_sample({JSONaddChannel}); pause(0.5)
        outlet.push_sample({JSONLoad}); pause(0.5)

        tacs_loaded = true;

    end

    % -----------------------------
    % Stimulus parameters
    % -----------------------------
    params.RF = "IN";
    params.azi = 0;
    params.ele = 0;
    params.radii = 1000;
    params.sf = 0.5*(2.^(0:3));
    params.ori = (0:45:135);
    params.con = [0,25,50,100];

    stimTable = create_stimtable(params=params);
    stimLength = size(stimTable,1);

    TrialRecord.User.StimTable = stimTable;

    blockSum = 0;
    stimList = [];
    stimBorrow = [];
    stimPrev = [];

    return
end


stim_per_trial = 3;

if isfield(TrialRecord,'CurrentBlock')
    block = TrialRecord.CurrentBlock;
else
    block = 1;
end

if isfield(TrialRecord,'CurrentCondition')
    condition = TrialRecord.CurrentCondition;
else
    condition = 1;
end


if isempty(TrialRecord.TrialErrors)

    condition = 1;

elseif ~isempty(TrialRecord.TrialErrors) && 0==TrialRecord.TrialErrors(end)

    stimList = setdiff(stimList, stimPrev);
    condition = mod(condition+stim_per_trial-1, stimLength)+1;

end


if isempty(stimList)

    stimList = setdiff(1:stimLength, stimBorrow);
    block = block + blockSum + 1;

    stimBorrow = [];
    blockSum = 0;

end


if length(stimList)>=stim_per_trial

    stimCurrent = datasample(stimList, stim_per_trial, 'Replace',false);
    stimPrev = stimCurrent;

elseif length(stimList)+stimLength>stim_per_trial

    stimPrev = stimList;
    stimBorrow = datasample(1:stimLength, stim_per_trial-length(stimList),'Replace',false);

    stimCurrent = [stimList stimBorrow];
    stimCurrent = stimCurrent(randperm(stim_per_trial));

else

    stimPrev = stimList;

    blockSum = floor((stim_per_trial-length(stimList))/stimLength);

    stimBorrow = datasample(1:stimLength, stim_per_trial-length(stimList)-blockSum*stimLength,'Replace',false);

    stimCurrent = [stimList repmat(1:stimLength,1,blockSum) stimBorrow];
    stimCurrent = stimCurrent(randperm(stim_per_trial));

end


Info = stimTable(stimCurrent,:);

for j = string(Info.Properties.VariableNames)

    for i = 1:stim_per_trial
        Info_struct.(strcat(j,string(i))) = Info.(j)(i);
    end

end


TrialRecord.setCurrentConditionInfo(Info_struct);


stim = cell(1,stim_per_trial);

for i=1:stim_per_trial
    stim{i} = 'gen(make_grating.m)';
end

C = stim;

TrialRecord.User.Stimuli = stimCurrent;
TrialRecord.User.stim_idx = 1;


TrialRecord.NextBlock = block;
TrialRecord.NextCondition = condition;