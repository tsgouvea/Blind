function updateCustomDataFields(iTrial)
global BpodSystem
global TaskParameters

statesThisTrial = BpodSystem.Data.RawData.OriginalStateNamesByNumber{iTrial}(BpodSystem.Data.RawData.OriginalStateData{iTrial});

%%
ChoicePort = 'X';
if any(strncmp('start_L',statesThisTrial,7))
    BpodSystem.Data.Custom.ChoiceLeft(iTrial) = 1;
    ChoicePort = floor(mod(TaskParameters.GUI.Ports_LMR/100,10));
elseif any(strncmp('start_R',statesThisTrial,7))
    BpodSystem.Data.Custom.ChoiceLeft(iTrial) = 0;
    ChoicePort = mod(TaskParameters.GUI.Ports_LMR,10);
end
ChoicePortOut = strcat('Port',num2str(ChoicePort),'Out');

BpodSystem.Data.Custom.StimGuided(iTrial) = any(strcmp('Cin_late',statesThisTrial));
BpodSystem.Data.Custom.BrokeFix(iTrial) = any(strcmp('BrokeFix',statesThisTrial));
BpodSystem.Data.Custom.EarlySout(iTrial) = any(strcmp('EarlySout',statesThisTrial));
BpodSystem.Data.Custom.ChoiceMiss(iTrial) = any(strcmp('choice_miss',statesThisTrial));
BpodSystem.Data.Custom.Rewarded(iTrial) = any(strncmp('water_',statesThisTrial,6));
BpodSystem.Data.Custom.RewardMagnitude(iTrial) = TaskParameters.GUI.rewardAmount;
for n = statesThisTrial
    if  regexp(n{1},'grace')
        graceState = n{1};
        BpodSystem.Data.Custom.Grace(iTrial) = true;
    end
end

%% Center port
if any(strcmp('Cin_late',statesThisTrial))
    BpodSystem.Data.Custom.CenterPokeDur(iTrial) = BpodSystem.Data.RawEvents.Trial{iTrial}.States.Cin_late(1,2) - BpodSystem.Data.RawEvents.Trial{iTrial}.States.Cin_early(1,1);
elseif any(strcmp('Cin_early',statesThisTrial))
    BpodSystem.Data.Custom.CenterPokeDur(iTrial) = diff(BpodSystem.Data.RawEvents.Trial{iTrial}.States.Cin_early);
end

%% Side ports

if any(strncmp('start',statesThisTrial,5))
    start_S = statesThisTrial{strncmp('start',statesThisTrial,5)};
    if any(strcmp('EarlySout',statesThisTrial))
        lastState = statesThisTrial{find(strcmp('EarlySout',statesThisTrial))-1}; % a grace period state
        BpodSystem.Data.Custom.SidePokeDur(iTrial) = BpodSystem.Data.RawEvents.Trial{iTrial}.States.(lastState)(1,1) -  BpodSystem.Data.RawEvents.Trial{iTrial}.States.(start_S)(1,1); % 
    else
        BpodSystem.Data.Custom.SidePokeDur(iTrial) = BpodSystem.Data.RawEvents.Trial{iTrial}.States.ITI(1,2) - BpodSystem.Data.RawEvents.Trial{iTrial}.States.(start_S)(1,1);
        if isfield(BpodSystem.Data.RawEvents.Trial{iTrial}.Events,ChoicePortOut)
            candidates = BpodSystem.Data.RawEvents.Trial{iTrial}.Events.(ChoicePortOut);
            candidates = candidates(candidates>BpodSystem.Data.RawEvents.Trial{iTrial}.States.(start_S)(1,1));
            if BpodSystem.Data.Custom.Grace(iTrial)
                candidates = candidates(candidates>BpodSystem.Data.RawEvents.Trial{iTrial}.States.(graceState)(end,end));
            end
            if ~isempty(candidates)
                BpodSystem.Data.Custom.SidePokeDur(iTrial) = min(candidates) -  BpodSystem.Data.RawEvents.Trial{iTrial}.States.(start_S)(1,1);
            end
        end
    end
end

% 
%% initialize next trial values

BpodSystem.Data.Custom.ChoiceLeft(iTrial+1) = NaN;
BpodSystem.Data.Custom.BrokeFix(iTrial+1) = false;
BpodSystem.Data.Custom.EarlySout(iTrial+1) = false;
BpodSystem.Data.Custom.ChoiceMiss(iTrial+1) = false;
BpodSystem.Data.Custom.StimGuided(iTrial+1) = false;
BpodSystem.Data.Custom.Rewarded(iTrial+1) = false;
BpodSystem.Data.Custom.Grace(iTrial+1) = false;
BpodSystem.Data.Custom.RewardMagnitude(iTrial+1) = TaskParameters.GUI.rewardAmount;
BpodSystem.Data.Custom.CenterPokeDur(iTrial+1) = NaN;
BpodSystem.Data.Custom.SidePokeDur(iTrial+1) = NaN;

%% Baiting
TaskParameters.GUI.ProbRwdBias = sum(BpodSystem.Data.Custom.Rewarded & BpodSystem.Data.Custom.ChoiceLeft == 1)/sum(BpodSystem.Data.Custom.Rewarded);
if TaskParameters.GUI.Unbias
    BpodSystem.Data.Custom.BaitedL(iTrial+1) = rand > TaskParameters.GUI.ProbRwdBias;
else
    BpodSystem.Data.Custom.BaitedL(iTrial+1) = rand > 0.5;
end

%% Fictive Reward (Click Trains)

if BpodSystem.Data.Custom.BaitedL(end)
    BpodSystem.Data.Custom.LeftClickTrain{iTrial+1} = GeneratePoissonClickTrain(TaskParameters.GUI.ClickRate,TaskParameters.GUI.ClickTrainDur);
    BpodSystem.Data.Custom.RightClickTrain{iTrial+1} = min(BpodSystem.Data.Custom.LeftClickTrain{iTrial+1});
    vL = ones(1,length(BpodSystem.Data.Custom.LeftClickTrain{iTrial+1}))*5;
    vR = zeros(1,length(BpodSystem.Data.Custom.RightClickTrain{iTrial+1}));
else
    BpodSystem.Data.Custom.RightClickTrain{iTrial+1} = GeneratePoissonClickTrain(TaskParameters.GUI.ClickRate,TaskParameters.GUI.ClickTrainDur);
    BpodSystem.Data.Custom.LeftClickTrain{iTrial+1} = min(BpodSystem.Data.Custom.RightClickTrain{iTrial+1});
    vL = zeros(1,length(BpodSystem.Data.Custom.LeftClickTrain{iTrial+1}));
    vR = ones(1,length(BpodSystem.Data.Custom.RightClickTrain{iTrial+1}))*5;
end
if ~BpodSystem.EmulatorMode
    ProgramPulsePal(BpodSystem.Data.Custom.PulsePalParamStimulus);
    SendCustomPulseTrain(1, BpodSystem.Data.Custom.RightClickTrain{iTrial+1}, vR);
    SendCustomPulseTrain(2, BpodSystem.Data.Custom.LeftClickTrain{iTrial+1}, vL);
end

% Set delay durs
%% Center port

if sum(~isnan(BpodSystem.Data.Custom.CenterPokeDur)) > 10
    TaskParameters.GUI.StimDelay = prctile(BpodSystem.Data.Custom.CenterPokeDur,100-TaskParameters.GUI.TargetStimGuided);
else
    TaskParameters.GUI.StimDelay = 0;
end

% 
%% Side ports
switch TaskParameters.GUIMeta.FeedbackDelaySelection.String{TaskParameters.GUI.FeedbackDelaySelection}
    case 'Fix'
        TaskParameters.GUI.FeedbackDelay = TaskParameters.GUI.FeedbackDelayMax;
    case 'AutoIncr'
        if sum(~isnan(BpodSystem.Data.Custom.SidePokeDur)) > 10
            TaskParameters.GUI.FeedbackDelay = prctile(BpodSystem.Data.Custom.SidePokeDur,TaskParameters.GUI.MinCutoff);
        else
            TaskParameters.GUI.FeedbackDelay = TaskParameters.GUI.FeedbackDelayMin;
        end
    case 'TruncExp'
        TaskParameters.GUI.FeedbackDelay = TruncatedExponential(TaskParameters.GUI.FeedbackDelayMin,...
            TaskParameters.GUI.FeedbackDelayMax,TaskParameters.GUI.FeedbackDelayTau);
    case 'Uniform'
        TaskParameters.GUI.FeedbackDelay = TaskParameters.GUI.FeedbackDelayMin + (TaskParameters.GUI.FeedbackDelayMax-TaskParameters.GUI.FeedbackDelayMin)*rand(1);        
end
TaskParameters.GUI.FeedbackDelay = max(TaskParameters.GUI.FeedbackDelayMin,min(TaskParameters.GUI.FeedbackDelay,TaskParameters.GUI.FeedbackDelayMax));
