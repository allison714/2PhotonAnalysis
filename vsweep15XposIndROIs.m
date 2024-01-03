% vsweep 15-480
% A. Cairns
% 11.14.23

% For code with detailed notes on this process 
% look at fullBarSweep4DindROIs.m

%% Fig. 02b, 02c  Individual ROIs: delF/F(position in degrees)
function [Fig_02b, Fig_02c] = vsweep15XposIndROIs(exp, info, param)
% Info: There are N flies and each fly has a 4x'M' double
% (the four rows are epochs: Rbar, Lbar, Ubar, Dbar.
% 'M' is ROIs per fly which varies for each fly,
% i.e. some flies have M=21 ROIs, some have M=34, etc)

% Variables
Nflies = size(info.analysis{1,1}.indFly, 2); % # flies
t_s = info.analysis{1,1}.timeX/1000; % time in sec
% Dummy Variables
totData = [];
RL15 = []; LR15 = []; RL30 = []; LR30 = [];
RL60 = []; LR60 = []; RL120 = []; LR120 = [];
RL240 = []; LR240 = []; RL480 = []; LR480 = [];
%% I. Create Matrices: 'totData' = all the data, 'LR or RL' for each epoch (v = 15,30,60,120,240,480)
% for loop to create a matrix, 'ROIcolEpochRow'
% totData is a cell where each col is a diff ROI, rows are epochs, and vals are delF/F
for flyfly = 1:Nflies
    ROIcolEpochRow = info.analysis{1,1}.indFly{1,flyfly}.p6_averagedTrials.snipMat;
    indflydata = reshape(ROIcolEpochRow, [], 1); % Reshape to a col vec
    % Each 'flyfly' willadd to the matrix not replace the value
    totData = [totData; indflydata]; % Concatenate: '[totData; indflydata]'
end
%% EVERY: 1st element is epoch(1)... every last element is epoch(end)
% create for loop to make a cell mats of individual epochs
numROIs = size(totData, 1);
for ii = 1:12:numROIs
    RL15 = [RL15; totData(ii)]; LR15 = [LR15; totData(ii+6)];
    RL30 = [RL30; totData(ii+1)]; LR30 = [LR30; totData(ii+7)];
    RL60 = [RL60; totData(ii+2)]; LR60 = [LR60; totData(ii+8)];
    RL120 = [RL120; totData(ii+3)]; LR120 = [LR120; totData(ii+9)];
    RL240 = [RL240; totData(ii+4)]; LR240 = [LR240; totData(ii+10)];
    RL480 = [RL480; totData(ii+5)]; LR480 = [LR480; totData(ii+11)];
end
%%  II. Plots 'Fig_05b' and 'Fig_05c'
% Convert t (sec) -> x (degrees)
epochProbeDur = [exp.params(:).duration];
epochDur = epochProbeDur(param.interleave_epochs+1:end);
pos0 = [exp.params(:).relativeX]; % includes probe
pos0 = pos0(param.interleave_epochs+1:end); % removes probe
delPos = [exp.params(:).dX]; % includes probe
delPos = delPos(param.interleave_epochs+1:end); % removes probe
stimPos = cell(1, length(delPos)); % Create a cell array to store the positions
stimEndPos = ones(length(delPos),1);
for jj = 1:length(delPos)
    stimPos{1,jj} = pos0(jj) + t_s * delPos(jj);
    stimEndPos(jj) = pos0(jj) + (epochDur(jj)/60) .* delPos(jj);
end
%% Plot 'Fig_05b': v = 15, 30, 60
Fig_02b = figure('Units', 'normalized', 'OuterPosition', [0, 0, 0.65, 1]);
for jj = 1:length(RL15)
    subplot(3,2,1); hold on; % Rbar subplot
    hold on;
    plot(stimPos{1,1},RL15{jj,1})
    title('RL15', 'Interpreter', 'latex')
    xline(-90, '-')
    xline(90, '-')
    xlabel('$x^\circ$', 'Interpreter', 'latex');
    ylabel('$\frac{\Delta F}{F}$ - $(\frac{\Delta F}{F})_{t = 0}$', 'Interpreter', 'latex');
    grid on;
    xlim([-95 115])
    subplot(3,2,2); hold on; % Lbar subplot
    plot(stimPos{1,2},LR15{jj,1})
    title('LR15', 'Interpreter', 'latex')
    xline(-90, '-')
    xline(90, '-')
    xlabel('$x^\circ$', 'Interpreter', 'latex');
    ylabel('$\frac{\Delta F}{F}$ - $(\frac{\Delta F}{F})_{t = 0}$', 'Interpreter', 'latex');
    grid on;
    xlim([-285 145])

    subplot(3,2,3); hold on; % Rbar subplot
    hold on;
    plot(stimPos{1,1},RL30{jj,1})
    title('RL30', 'Interpreter', 'latex')
    xline(-90, '-')
    xline(90, '-')
    xlabel('$x^\circ$', 'Interpreter', 'latex');
    ylabel('$\frac{\Delta F}{F}$ - $(\frac{\Delta F}{F})_{t = 0}$', 'Interpreter', 'latex');
    grid on;
    xlim([-95 115])
    subplot(3,2,4); hold on; % Lbar subplot
    plot(stimPos{1,2},LR30{jj,1})
    title('LR30', 'Interpreter', 'latex')
    xline(-90, '-')
    xline(90, '-')
    xlabel('$x^\circ$', 'Interpreter', 'latex');
    ylabel('$\frac{\Delta F}{F}$ - $(\frac{\Delta F}{F})_{t = 0}$', 'Interpreter', 'latex');
    grid on;
    xlim([-285 145])

    subplot(3,2,5); hold on; % Rbar subplot
    hold on;
    plot(stimPos{1,1},RL60{jj,1})
    title('RL60', 'Interpreter', 'latex')
    xline(-90, '-')
    xline(90, '-')
    xlabel('$x^\circ$', 'Interpreter', 'latex');
    ylabel('$\frac{\Delta F}{F}$ - $(\frac{\Delta F}{F})_{t = 0}$', 'Interpreter', 'latex');
    grid on;
    xlim([-95 115])
    subplot(3,2,6); hold on; % Lbar subplot
    plot(stimPos{1,2},LR60{jj,1})
    title('LR60', 'Interpreter', 'latex')
    xline(-90, '-')
    xline(90, '-')
    xlabel('$x^\circ$', 'Interpreter', 'latex');
    ylabel('$\frac{\Delta F}{F}$ - $(\frac{\Delta F}{F})_{t = 0}$', 'Interpreter', 'latex');
    grid on;
    xlim([-285 145])
end
sgtitle({[num2str(param.cellType),' > ',num2str(param.sensor),' || Flies: ', num2str(info.analysis{1,1}.numFlies),' ||  totROIs = ', num2str(numROIs)], param.stim}, 'FontSize', 14, 'FontName', 'Times New Roman', 'Interpreter', 'none');
%% Plot 'Fig_05c': v = 240 & 480
Fig_02c = figure('Units', 'normalized', 'OuterPosition', [0, 0, 0.65, 1]);
for kk = 1:length(RL15)
    subplot(2,2,1); hold on; % Rbar subplot
    hold on;
    plot(stimPos{1,1},RL240{kk,1})
    title('RL240', 'Interpreter', 'latex')
    xline(-90, '-')
    xline(90, '-')
    xlabel('$x^\circ$', 'Interpreter', 'latex');
    ylabel('$\frac{\Delta F}{F}$ - $(\frac{\Delta F}{F})_{t = 0}$', 'Interpreter', 'latex');
    grid on;
    xlim([-95 115])
    subplot(2,2,2); hold on; % Lbar subplot
    plot(stimPos{1,2},LR240{kk,1})
    title('LR240', 'Interpreter', 'latex')
    xline(-90, '-')
    xline(90, '-')
    xlabel('$x^\circ$', 'Interpreter', 'latex');
    ylabel('$\frac{\Delta F}{F}$ - $(\frac{\Delta F}{F})_{t = 0}$', 'Interpreter', 'latex');
    grid on;
    xlim([-285 145])

    subplot(2,2,3); hold on; % Rbar subplot
    hold on;
    plot(stimPos{1,1},RL480{kk,1})
    title('RL480', 'Interpreter', 'latex')
    xline(-90, '-')
    xline(90, '-')
    xlabel('$x^\circ$', 'Interpreter', 'latex');
    ylabel('$\frac{\Delta F}{F}$ - $(\frac{\Delta F}{F})_{t = 0}$', 'Interpreter', 'latex');
    grid on;
    xlim([-95 115])
    subplot(2,2,4); hold on; % Lbar subplot
    plot(stimPos{1,2},LR480{kk,1})
    title('LR480', 'Interpreter', 'latex')
    xline(-90, '-')
    xline(90, '-')
    xlabel('$x^\circ$', 'Interpreter', 'latex');
    ylabel('$\frac{\Delta F}{F}$ - $(\frac{\Delta F}{F})_{t = 0}$', 'Interpreter', 'latex');
    grid on;
    xlim([-285 145])
end
sgtitle({[num2str(param.cellType),' > ',num2str(param.sensor),' || Flies: ', num2str(info.analysis{1,1}.numFlies),' ||  totROIs = ', num2str(numROIs)], param.stim}, 'FontSize', 14, 'FontName', 'Times New Roman', 'Interpreter', 'none');
end