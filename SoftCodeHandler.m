function SoftCodeHandler(softCode)

global BpodSystem
% global TaskParameters

if ~BpodSystem.EmulatorMode
    if softCode == 1 %noise
        SendCustomPulseTrain(1,cumsum(randi(9,1,601))/10000,(rand(1,601)-.5)*20); % White(?) noise on channel 1+2
        SendCustomPulseTrain(2,cumsum(randi(9,1,601))/10000,(rand(1,601)-.5)*20);
        TriggerPulsePal(1,2);
    elseif softCode == 2 %beep
        SendCustomPulseTrain(2,0:.001:.3,(ones(1,301)*3));  % Beep on channel 1+2
        SendCustomPulseTrain(1,0:.001:.3,(ones(1,301)*3));
        TriggerPulsePal(1,2);
    elseif softCode == 3 %
        SendCustomPulseTrain(2,0:.0007:.3,(ones(1,429)*3));  % Beep on channel 1+2
        SendCustomPulseTrain(1,0:.0007:.3,(ones(1,429)*3));
        TriggerPulsePal(1,2);
    end
end