function Blind
% Reproduction on Bpod of protocol used in the PatonLab, MATCHINGvFix

global BpodSystem
global TaskParameters

%% Task parameters
TaskParameters = BpodSystem.ProtocolSettings;
if isempty(fieldnames(TaskParameters))
    %% General
    TaskParameters.GUI.Ports_LMR = '123';
    TaskParameters.GUI.ITI = 1; % (s)
    TaskParameters.GUI.VI = false; % random ITI
    TaskParameters.GUIMeta.VI.Style = 'checkbox';
    TaskParameters.GUI.ChoiceDeadline = 10;
    TaskParameters.GUIPanels.General = {'Ports_LMR','ITI','VI','ChoiceDeadline'};

    %% Center Port ("stimulus sampling")
    TaskParameters.GUI.LoopbackFix = true; % breaking fixation (FixTimeMin) doesn't abort trial
    TaskParameters.GUIMeta.LoopbackFix.Style = 'checkbox';
    TaskParameters.GUI.BreakFixPenalty = 0;
    TaskParameters.GUI.FixTimeMin = 0.2;
    TaskParameters.GUI.StimDelay = 0;
    TaskParameters.GUIMeta.StimDelay.Style = 'text';
    TaskParameters.GUI.TargetStimGuided = 50; % Sets StimDelay so that this percentage of trials is stimulus guided
    TaskParameters.GUIPanels.CenterPort = {'LoopbackFix','BreakFixPenalty','FixTimeMin','StimDelay','TargetStimGuided'};

    %% Side Ports & Clicks
    TaskParameters.GUI.BNCout = 2;
    TaskParameters.GUI.FeedbackDelaySelection = 2;
    TaskParameters.GUIMeta.FeedbackDelaySelection.Style = 'popupmenu';
    TaskParameters.GUIMeta.FeedbackDelaySelection.String = {'Fix','AutoIncr','TruncExp','Uniform'};
    TaskParameters.GUI.FeedbackDelayMin = 0.2;
    TaskParameters.GUI.FeedbackDelayMax = 1;
    TaskParameters.GUI.FeedbackDelayTau = 0.4;
    TaskParameters.GUI.FeedbackDelay = TaskParameters.GUI.FeedbackDelayMin;
    TaskParameters.GUIMeta.FeedbackDelay.Style = 'text';
    TaskParameters.GUI.MinCutoff = 50;
    TaskParameters.GUI.ClickTrainDur = 1;
    TaskParameters.GUI.ClickRate = 100;
    TaskParameters.GUI.EarlySoutPenalty = 0;
    TaskParameters.GUI.RewardDelay = .2; % From click train onset
    TaskParameters.GUI.Grace = 0.1;
    TaskParameters.GUIPanels.SidePorts = {'BNCout','FeedbackDelaySelection','FeedbackDelayMin','FeedbackDelayMax','FeedbackDelayTau','FeedbackDelay','MinCutoff','ClickTrainDur','ClickRate','EarlySoutPenalty','RewardDelay','Grace'};

    % Reward
    TaskParameters.GUI.Unbias = true;
    TaskParameters.GUIMeta.Unbias.Style = 'checkbox';
    TaskParameters.GUI.ProbRwdBias = 0.5;
    TaskParameters.GUIMeta.ProbRwdBias.Style = 'text';
    TaskParameters.GUI.rewardAmount = 30;
    TaskParameters.GUIPanels.Reward = {'rewardAmount','Unbias','ProbRwdBias'};

    TaskParameters.GUI = orderfields(TaskParameters.GUI);
end
TaskParameters.GUI.FeedbackDelay = TaskParameters.GUI.FeedbackDelayMin;

BpodParameterGUI('init', TaskParameters);

%% Initializing data (trial type) vectors
BpodSystem.Data.Custom.BaitedL = rand < .5; % BaitedR = not(BaitedL)

if BpodSystem.Data.Custom.BaitedL
    BpodSystem.Data.Custom.LeftClickTrain{1} = GeneratePoissonClickTrain(TaskParameters.GUI.ClickRate,TaskParameters.GUI.ClickTrainDur);
    BpodSystem.Data.Custom.RightClickTrain{1} = min(BpodSystem.Data.Custom.LeftClickTrain{1});
else
    BpodSystem.Data.Custom.RightClickTrain{1} = GeneratePoissonClickTrain(TaskParameters.GUI.ClickRate,TaskParameters.GUI.ClickTrainDur);
    BpodSystem.Data.Custom.LeftClickTrain{1} = min(BpodSystem.Data.Custom.RightClickTrain{1});
end
if ~BpodSystem.EmulatorMode
    SendCustomPulseTrain(1, BpodSystem.Data.Custom.RightClickTrain{1}, ones(1,length(BpodSystem.Data.Custom.RightClickTrain{1}))*5);
    SendCustomPulseTrain(2, BpodSystem.Data.Custom.LeftClickTrain{1}, ones(1,length(BpodSystem.Data.Custom.LeftClickTrain{1}))*5);
end

BpodSystem.Data.Custom.ChoiceLeft(1) = NaN;
BpodSystem.Data.Custom.BrokeFix(1) = false;
BpodSystem.Data.Custom.EarlySout(1) = false;
BpodSystem.Data.Custom.StimGuided(1) = false;
BpodSystem.Data.Custom.Rewarded(1) = false;
BpodSystem.Data.Custom.Grace(1) = false;
BpodSystem.Data.Custom.RewardMagnitude(1) = TaskParameters.GUI.rewardAmount;
BpodSystem.Data.Custom.CenterPokeDur(1) = NaN;
BpodSystem.Data.Custom.SidePokeDur(1) = NaN;

%server data
BpodSystem.Data.Custom.Rig = getenv('computername');
[~,BpodSystem.Data.Custom.Subject] = fileparts(fileparts(fileparts(fileparts(BpodSystem.DataPath))));

BpodSystem.Data.Custom = orderfields(BpodSystem.Data.Custom);

%% Set up PulsePal
load PulsePalParamStimulus.mat
load PulsePalParamFeedback.mat
BpodSystem.Data.Custom.PulsePalParamStimulus=PulsePalParamStimulus;
BpodSystem.Data.Custom.PulsePalParamFeedback=PulsePalParamFeedback;
clear PulsePalParamFeedback PulsePalParamStimulus
BpodSystem.SoftCodeHandlerFunction = 'SoftCodeHandler';
if ~BpodSystem.EmulatorMode
    ProgramPulsePal(BpodSystem.Data.Custom.PulsePalParamStimulus);
    SendCustomPulseTrain(1, BpodSystem.Data.Custom.RightClickTrain{1}, ones(1,length(BpodSystem.Data.Custom.RightClickTrain{1}))*5);
    SendCustomPulseTrain(2, BpodSystem.Data.Custom.LeftClickTrain{1}, ones(1,length(BpodSystem.Data.Custom.LeftClickTrain{1}))*5);
end

%% Initialize plots
temp = SessionSummary();
for i = fieldnames(temp)'
    BpodSystem.GUIHandles.(i{1}) = temp.(i{1});
end
clear temp
BpodNotebook('init');

%% Main loop
RunSession = true;
iTrial = 1;

while RunSession
    TaskParameters = BpodParameterGUI('sync', TaskParameters);

    sma = stateMatrix();
    SendStateMatrix(sma);
    RawEvents = RunStateMatrix;
    if ~isempty(fieldnames(RawEvents))
        BpodSystem.Data = AddTrialEvents(BpodSystem.Data,RawEvents);
        SaveBpodSessionData;
    end
    HandlePauseCondition; % Checks to see if the protocol is paused. If so, waits until user resumes.
    if BpodSystem.BeingUsed == 0
        return
    end

    updateCustomDataFields(iTrial)
    iTrial = iTrial + 1;
    BpodSystem.GUIHandles = SessionSummary(BpodSystem.Data, BpodSystem.GUIHandles, iTrial);
end
end
