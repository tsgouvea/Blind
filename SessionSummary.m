function GUIHandles = SessionSummary(Data, GUIHandles, iTrial, nTrialsToShow)

%global nTrialsToShow %this is for convenience
%global BpodSystem
global TaskParameters
if nargin < 4 %custom number of trials to display
    nTrialsToShow = 90; %default
end

if nargin < 2 % plot initialized (either beginning of session or post-hoc analysis)
    if nargin > 0 % post-hoc analysis
        TaskParameters.GUI = Data.Settings.GUI;
    end

    GUIHandles = struct();
    GUIHandles.Figs.MainFig = figure('Position', [200, 200, 1000, 400],'name','Outcome plot','numbertitle','off', 'MenuBar', 'none', 'Resize', 'off');
    GUIHandles.Axes.OutcomePlot.MainHandle = axes('Position', [.06 .15 .91 .3]);
    GUIHandles.Axes.TrialRate.MainHandle = axes('Position', [[1 0]*[.06;.12] .6 .12 .3]);
    GUIHandles.Axes.CenterPokeDur.MainHandle = axes('Position', [[2 1]*[.06;.12] .6 .12 .3]);
    GUIHandles.Axes.SidePokeDur.MainHandle = axes('Position', [[3 2]*[.06;.12] .6 .12 .3]);
    GUIHandles.Axes.StimGuided.MainHandle = axes('Position', [[4 3]*[.06;.12] .6 .12 .3]);
    GUIHandles.Axes.Wager.MainHandle = axes('Position', [[5 4]*[.06;.12] .6 .12 .3]);

    %% Outcome
    axes(GUIHandles.Axes.OutcomePlot.MainHandle)
    GUIHandles.Axes.OutcomePlot.StimL = line(-1,.75, 'LineStyle','none','Marker','^','MarkerEdge','k','MarkerFace','none', 'MarkerSize',5);
    GUIHandles.Axes.OutcomePlot.StimR = line(-1,.25, 'LineStyle','none','Marker','v','MarkerEdge','k','MarkerFace','none', 'MarkerSize',5);
    GUIHandles.Axes.OutcomePlot.Fict = line(-1,1, 'LineStyle','none','Marker','o','MarkerEdge','k','MarkerFace','none', 'MarkerSize',8);
    GUIHandles.Axes.OutcomePlot.CurrentTrialCircle = line(-1,0.5, 'LineStyle','none','Marker','o','MarkerEdge','k','MarkerFace',[1 1 1], 'MarkerSize',6);
    GUIHandles.Axes.OutcomePlot.CurrentTrialCross = line(-1,0.5, 'LineStyle','none','Marker','+','MarkerEdge','k','MarkerFace',[1 1 1], 'MarkerSize',6);
    GUIHandles.Axes.OutcomePlot.Rewarded = line(-1,1, 'LineStyle','none','Marker','o','MarkerEdge','g','MarkerFace','g', 'MarkerSize',6);
    GUIHandles.Axes.OutcomePlot.Unrewarded = line(-1,1, 'LineStyle','none','Marker','o','MarkerEdge','r','MarkerFace','r', 'MarkerSize',6);
    GUIHandles.Axes.OutcomePlot.NoResponse = line(-1,1, 'LineStyle','none','Marker','o','MarkerEdge','b','MarkerFace','none', 'MarkerSize',6);
    GUIHandles.Axes.OutcomePlot.BrokeFix = line(-1,0, 'LineStyle','none','Marker','d','MarkerEdge','none','MarkerFace','b', 'MarkerSize',6);
    GUIHandles.Axes.OutcomePlot.EarlySout = line(-1,0, 'LineStyle','none','Marker','d','MarkerEdge','none','MarkerFace','b', 'MarkerSize',6);
    GUIHandles.Axes.OutcomePlot.CumRwd = text(1,1,'0mL','verticalalignment','bottom','horizontalalignment','center');
    set(GUIHandles.Axes.OutcomePlot.MainHandle,'TickDir', 'out','YLim', [-1, 2],'XLim',[0,nTrialsToShow], 'YTick', [0 1],'YTickLabel', {'Right','Left'}, 'FontSize', 16);
    xlabel(GUIHandles.Axes.OutcomePlot.MainHandle, 'Trial#', 'FontSize', 18);
    hold(GUIHandles.Axes.OutcomePlot.MainHandle, 'on');
    %% Trial rate
    hold(GUIHandles.Axes.TrialRate.MainHandle,'on')
    GUIHandles.Axes.TrialRate.TrialRate = line(GUIHandles.Axes.TrialRate.MainHandle,[0 1],[0 1], 'LineStyle','-','Color','k','Visible','on','linewidth',3);
    GUIHandles.Axes.TrialRate.TrialRateL = line(GUIHandles.Axes.TrialRate.MainHandle,[0 1],[0 1], 'LineStyle','-','Color',[254,178,76]/255,'Visible','on','linewidth',3);
    GUIHandles.Axes.TrialRate.TrialRateR = line(GUIHandles.Axes.TrialRate.MainHandle,[0 1],[0 1], 'LineStyle','-','Color',[49,163,84]/255,'Visible','on','linewidth',3);
    GUIHandles.Axes.TrialRate.MainHandle.XLabel.String = 'Time (min)';
    GUIHandles.Axes.TrialRate.MainHandle.YLabel.String = 'nTrials';
    GUIHandles.Axes.TrialRate.MainHandle.Title.String = 'Trial rate';
    %% ST histogram
    hold(GUIHandles.Axes.CenterPokeDur.MainHandle,'on')
    GUIHandles.Axes.CenterPokeDur.MainHandle.XLabel.String = 'Time (s)';
    GUIHandles.Axes.CenterPokeDur.MainHandle.YLabel.String = 'trial counts';
    GUIHandles.Axes.CenterPokeDur.MainHandle.Title.String = 'Center poke dur';
    %% FT histogram
    hold(GUIHandles.Axes.SidePokeDur.MainHandle,'on')
    GUIHandles.Axes.SidePokeDur.MainHandle.XLabel.String = 'Time (s)';
    GUIHandles.Axes.SidePokeDur.MainHandle.YLabel.String = 'trial counts';
    GUIHandles.Axes.SidePokeDur.MainHandle.Title.String = 'Side poke dur';
    %% StimGuided
    
    hold(GUIHandles.Axes.StimGuided.MainHandle,'on')
    GUIHandles.Axes.StimGuided.StimGuided = line(GUIHandles.Axes.StimGuided.MainHandle,[0 1],[0 1], 'LineStyle','-','Color',[166,101,195]/255,'Visible','on','linewidth',3);
    GUIHandles.Axes.StimGuided.PerfBlind = text(GUIHandles.Axes.StimGuided.MainHandle,0,1,'0.0','verticalalignment','bottom','horizontalalignment','center');
    GUIHandles.Axes.StimGuided.PerfStimGuided = text(GUIHandles.Axes.StimGuided.MainHandle,1,0,'0.0','verticalalignment','bottom','horizontalalignment','center');
%     GUIHandles.Axes.StimGuided.Value = line(GUIHandles.Axes.StimGuided.MainHandle,[0 1],[0 1], 'LineStyle','-','Color',[254,167,53]/255,'Visible','on','linewidth',3);
    GUIHandles.Axes.StimGuided.MainHandle.XLabel.String = 'Blind choice';
    GUIHandles.Axes.StimGuided.MainHandle.YLabel.String = 'Stim guided';
    GUIHandles.Axes.StimGuided.MainHandle.Title.String = 'Blind vs Stim guided';
    
    %% Time Wagering
%     hold(GUIHandles.Axes.Wager.MainHandle,'on')
%     %colors from [http://paletton.com/#uid=3000u0kllllaFw0g0qFqFg0w0aF]
%     GUIHandles.Axes.Wager.ExploitScatter = line(GUIHandles.Axes.Wager.MainHandle,[1,5],[0,0],'marker','o','linestyle','none','MarkerEdgeColor',[40, 60, 60]/100,'Visible','on');
%     GUIHandles.Axes.Wager.ExploreScatter = line(GUIHandles.Axes.Wager.MainHandle,[1,5],[0,0],'marker','o','linestyle','none','MarkerEdgeColor',[83.1, 41.6, 41.6]/100,'Visible','on');
%     GUIHandles.Axes.Wager.ExploitLine = line(GUIHandles.Axes.Wager.MainHandle,[1,5],[0,0],'Color',[13.3, 40, 40]/100,'Visible','on','linewidth',2);
%     GUIHandles.Axes.Wager.ExploreLine = line(GUIHandles.Axes.Wager.MainHandle,[1,5],[0,0],'Color',[50.2, 8.2, 8.2]/100,'Visible','on','linewidth',2);
%     GUIHandles.Axes.Wager.MainHandle.XLabel.String = 'log(pL/pR)';
%     GUIHandles.Axes.Wager.MainHandle.YLabel.String = 'Waiting time (s)';
%     GUIHandles.Axes.Wager.MainHandle.Title.String = 'Vevaiometric?';

else
    global TaskParameters
end

if nargin > 0
    if nargin < 3
        iTrial = Data.nTrials;
    end
    % Outcome
    [mn, ~] = rescaleX(GUIHandles.Axes.OutcomePlot.MainHandle,iTrial,nTrialsToShow); % recompute xlim

    set(GUIHandles.Axes.OutcomePlot.CurrentTrialCircle, 'xdata', iTrial, 'ydata', 0.5);
    set(GUIHandles.Axes.OutcomePlot.CurrentTrialCross, 'xdata', iTrial, 'ydata', 0.5);

    %Plot past trials
    ChoiceLeft = Data.Custom.ChoiceLeft;
    Rewarded = Data.Custom.Rewarded;
    if ~isempty(Rewarded)

        indxToPlot = mn:iTrial-1;

        ndxRwd = Rewarded(indxToPlot) == 1;
        Xdata = indxToPlot(ndxRwd);
        Ydata = ChoiceLeft(indxToPlot); Ydata = Ydata(ndxRwd);
        set(GUIHandles.Axes.OutcomePlot.Rewarded, 'xdata', Xdata, 'ydata', Ydata);
        
        ndxUrwd = Rewarded == 0 & not(Data.Custom.ChoiceMiss) & not(Data.Custom.EarlySout); ndxUrwd = ndxUrwd(indxToPlot);
        Xdata = indxToPlot(ndxUrwd);
        Ydata = ChoiceLeft(indxToPlot); Ydata = Ydata(ndxUrwd);
        set(GUIHandles.Axes.OutcomePlot.Unrewarded, 'xdata', Xdata, 'ydata', Ydata);

        ndxNocho = Data.Custom.ChoiceMiss(indxToPlot);
        Xdata = indxToPlot(ndxNocho);
        Ydata = ones(size(Xdata))*.5;
        set(GUIHandles.Axes.OutcomePlot.NoResponse, 'xdata', Xdata, 'ydata', Ydata);

        Ydata = [ones(sum(Data.Custom.BaitedL(indxToPlot)==1 & ~Data.Custom.StimGuided(indxToPlot)),1)', ...
            zeros(sum(Data.Custom.BaitedL(indxToPlot)==0 & ~Data.Custom.StimGuided(indxToPlot)),1)'];
        Xdata = [indxToPlot(Data.Custom.BaitedL(indxToPlot)==1 & ~Data.Custom.StimGuided(indxToPlot)), ...
            indxToPlot(Data.Custom.BaitedL(indxToPlot)==0 & ~Data.Custom.StimGuided(indxToPlot))];
        set(GUIHandles.Axes.OutcomePlot.Fict, 'xdata', Xdata, 'ydata', Ydata);
        
%         GUIHandles.Axes.OutcomePlot.StimL = line(-1,.75, 'LineStyle','none','Marker','^','MarkerEdge','k','MarkerFace','none', 'MarkerSize',8);
%         GUIHandles.Axes.OutcomePlot.StimR = line(-1,.25, 'LineStyle','none','Marker','v','MarkerEdge','k','MarkerFace','none', 'MarkerSize',8);

        ndxStimL = Data.Custom.BaitedL(indxToPlot)==1 & Data.Custom.StimGuided(indxToPlot);
        Ydata = .75*ones(sum(ndxStimL),1);
        Xdata = indxToPlot(ndxStimL);
        set(GUIHandles.Axes.OutcomePlot.StimL, 'xdata', Xdata, 'ydata', Ydata);
        
        ndxStimR = Data.Custom.BaitedL(indxToPlot)==0 & Data.Custom.StimGuided(indxToPlot);
        Ydata = .25*ones(sum(ndxStimR),1);
        Xdata = indxToPlot(ndxStimR);
        set(GUIHandles.Axes.OutcomePlot.StimR, 'xdata', Xdata, 'ydata', Ydata);        
    end
    if ~isempty(Data.Custom.BrokeFix)
        indxToPlot = mn:iTrial-1;
        ndxEarly = Data.Custom.BrokeFix(indxToPlot);
        XData = indxToPlot(ndxEarly);
        YData = 0.5*ones(1,sum(ndxEarly));
        set(GUIHandles.Axes.OutcomePlot.BrokeFix, 'xdata', XData, 'ydata', YData);
    end
    if ~isempty(Data.Custom.EarlySout)
        indxToPlot = mn:iTrial-1;
        ndxEarly = Data.Custom.EarlySout(indxToPlot);
        XData = indxToPlot(ndxEarly);
        YData = ChoiceLeft(indxToPlot); YData = YData(ndxEarly);
        set(GUIHandles.Axes.OutcomePlot.EarlySout, 'xdata', XData, 'ydata', YData);
    end
    %Cumulative Reward Amount
    R = Data.Custom.RewardMagnitude;
    ndxRwd = Data.Custom.Rewarded;
    C = zeros(size(R)); C(Data.Custom.ChoiceLeft==1&ndxRwd,1) = 1; C(Data.Custom.ChoiceLeft==0&ndxRwd,2) = 1;
    R = R.*C;
    set(GUIHandles.Axes.OutcomePlot.CumRwd, 'position', [iTrial+1 1], 'string', ...
        [num2str(sum(R(:))/1000) ' mL']);
    clear C

    %% Trial rate
    GUIHandles.Axes.TrialRate.TrialRate.XData = (Data.TrialStartTimestamp-min(Data.TrialStartTimestamp))/60;
    GUIHandles.Axes.TrialRate.TrialRate.YData = 1:numel(GUIHandles.Axes.TrialRate.TrialRate.XData);
    ndxCho = Data.Custom.ChoiceLeft(:)==1;
    GUIHandles.Axes.TrialRate.TrialRateL.XData = (Data.TrialStartTimestamp(ndxCho)-min(Data.TrialStartTimestamp))/60;
    GUIHandles.Axes.TrialRate.TrialRateL.YData = 1:numel(GUIHandles.Axes.TrialRate.TrialRateL.XData);
    ndxCho = Data.Custom.ChoiceLeft(:)==0;
    GUIHandles.Axes.TrialRate.TrialRateR.XData = (Data.TrialStartTimestamp(ndxCho)-min(Data.TrialStartTimestamp))/60;
    GUIHandles.Axes.TrialRate.TrialRateR.YData = 1:numel(GUIHandles.Axes.TrialRate.TrialRateR.XData);
    %% CenterPokeDur
    cla(GUIHandles.Axes.CenterPokeDur.MainHandle)
    temp = Data.Custom.CenterPokeDur;
    temp2 = min(temp,prctile(temp,99));
    temp2(isnan(temp)) = nan;
    GUIHandles.Axes.CenterPokeDur.Hist = histogram(GUIHandles.Axes.CenterPokeDur.MainHandle,...
        temp2);
    GUIHandles.Axes.CenterPokeDur.Hist.BinWidth = .05;
    GUIHandles.Axes.CenterPokeDur.Hist.EdgeColor = 'none';
    GUIHandles.Axes.CenterPokeDur.HistEarly = histogram(GUIHandles.Axes.CenterPokeDur.MainHandle,...
        temp(Data.Custom.BrokeFix));
    GUIHandles.Axes.CenterPokeDur.HistEarly.BinWidth = .05;
    GUIHandles.Axes.CenterPokeDur.HistEarly.EdgeColor = 'none';
    GUIHandles.Axes.CenterPokeDur.CutOff = plot(GUIHandles.Axes.CenterPokeDur.MainHandle,TaskParameters.GUI.StimDelay,0,'^k');

    %% Feedback delay
    cla(GUIHandles.Axes.SidePokeDur.MainHandle)
    temp = Data.Custom.SidePokeDur;
    temp2 = min(temp,prctile(temp,99));
    temp2(isnan(temp)) = nan;
    if isfield(TaskParameters,'GUIMeta') && strcmp(TaskParameters.GUIMeta.FeedbackDelaySelection.String{TaskParameters.GUI.FeedbackDelaySelection},'TruncExp')
        GUIHandles.Axes.SidePokeDur.Hist = histogram(GUIHandles.Axes.SidePokeDur.MainHandle,temp2(Data.Custom.Rewarded));
        %GUIHandles.Axes.SidePokeDur.Hist.BinWidth = 50;
        GUIHandles.Axes.SidePokeDur.Hist.EdgeColor = 'none';
        GUIHandles.Axes.SidePokeDur.HistEarly = histogram(GUIHandles.Axes.SidePokeDur.MainHandle,temp2(~Data.Custom.Rewarded));
        %GUIHandles.Axes.SidePokeDur.HistEarly.BinWidth = 50;
        GUIHandles.Axes.SidePokeDur.HistEarly.EdgeColor = 'none';
        GUIHandles.Axes.SidePokeDur.CutOff = plot(GUIHandles.Axes.SidePokeDur.MainHandle,TaskParameters.GUI.FeedbackDelay,0,'^k');
        GUIHandles.Axes.SidePokeDur.Expected = plot(GUIHandles.Axes.SidePokeDur.MainHandle,...
            linspace(min(temp2),max(temp2),100),...
            (GUIHandles.Axes.SidePokeDur.Hist.BinWidth * sum(Data.Custom.Rewarded)) * exppdf(linspace(min(temp2),max(temp2),100),TaskParameters.GUI.FeedbackDelayTau),'c');
    else
        GUIHandles.Axes.SidePokeDur.Hist = histogram(GUIHandles.Axes.SidePokeDur.MainHandle,temp2(~Data.Custom.EarlySout));
        GUIHandles.Axes.SidePokeDur.Hist.BinWidth = .05;
        GUIHandles.Axes.SidePokeDur.Hist.EdgeColor = 'none';
        GUIHandles.Axes.SidePokeDur.HistEarly = histogram(GUIHandles.Axes.SidePokeDur.MainHandle,...
            temp2(Data.Custom.EarlySout));
        GUIHandles.Axes.SidePokeDur.HistEarly.BinWidth = .05;
        GUIHandles.Axes.SidePokeDur.HistEarly.EdgeColor = 'none';
        GUIHandles.Axes.SidePokeDur.CutOff = plot(GUIHandles.Axes.SidePokeDur.MainHandle,TaskParameters.GUI.FeedbackDelay,0,'^k');
    end

    %% Stim Guided
    
    GUIHandles.Axes.StimGuided.StimGuided.XData = cumsum(Data.Custom.StimGuided(1:end-1)==0);
    GUIHandles.Axes.StimGuided.StimGuided.YData = cumsum(Data.Custom.StimGuided(1:end-1)==1);
    
%     GUIHandles.Axes.StimGuided.PerfBlind = text(1,0,'0.0','verticalalignment','bottom','horizontalalignment','center');
%     GUIHandles.Axes.StimGuided.PerfStimGuided = text(0,1,'0.0','verticalalignment','bottom','horizontalalignment','center');
    
    ndxBlind = ~isnan(Data.Custom.ChoiceLeft) & Data.Custom.StimGuided==0;
    perfBlind = sum(Data.Custom.ChoiceLeft(ndxBlind) == Data.Custom.BaitedL(ndxBlind)) / sum(ndxBlind);
    set(GUIHandles.Axes.StimGuided.PerfBlind, 'position', [.9*sum(Data.Custom.StimGuided(1:end-1)==0) .1*sum(Data.Custom.StimGuided(1:end-1)==1)], 'string', ...
        [sprintf('%0.2f',perfBlind)]);
    
    ndxStimGuided = ~isnan(Data.Custom.ChoiceLeft) & Data.Custom.StimGuided==1;
    perfStimGuided = sum(Data.Custom.ChoiceLeft(ndxStimGuided) == Data.Custom.BaitedL(ndxStimGuided)) / sum(ndxStimGuided);
    set(GUIHandles.Axes.StimGuided.PerfStimGuided, 'position', [.1*sum(Data.Custom.StimGuided(1:end-1)==0) .9*sum(Data.Custom.StimGuided(1:end-1)==1)], 'string', ...
        [sprintf('%0.2f',perfStimGuided)]);
    
end
end

function [mn,mx] = rescaleX(AxesHandle,CurrentTrial,nTrialsToShow)
FractionWindowStickpoint = .75; % After this fraction of visible trials, the trial position in the window "sticks" and the window begins to slide through trials.
mn = max(round(CurrentTrial - FractionWindowStickpoint*nTrialsToShow),1);
mx = mn + nTrialsToShow - 1;
set(AxesHandle,'XLim',[mn-1 mx+1]);
end
