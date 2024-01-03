% sweepingFullBars_4D_5reps Imaging Analysis
% A. Cairns
% 11.11.23

%% Fig. 05b  Individual ROIs: delF/F(position in degrees)
function [Fig_05b, Fig_05c] = fullBarSweep4DindROIs(exp, info, param)

% Info: There are N flies and each fly has a 4x'M' double
% (the four rows are epochs: Rbar, Lbar, Ubar, Dbar.
% 'M' is ROIs per fly which varies for each fly,
% i.e. some flies have M=21 ROIs, some have M=34, etc)

% Variables
Nflies = size(info.analysis{1,1}.indFly, 2); % # flies
t_s = info.analysis{1,1}.timeX/1000; % time in sec

% Dummy Variables
totData = [];
Rbar = [];
Lbar = [];
Dbar = [];
Ubar = [];

%% I. Create Matrices: 'totData' = all the data, 'X'bar for each epoch (X=R,L,D,U)
% for loop to create a matrix, 'ROIcolEpochRow'
% totData is a cell where each col is a diff ROI, rows are epochs, and vals are delF/F
for flyfly = 1:Nflies
    ROIcolEpochRow = info.analysis{1,1}.indFly{1,flyfly}.p6_averagedTrials.snipMat;
    indflydata = reshape(ROIcolEpochRow, [], 1); % Reshape to a col vec
    % Each 'flyfly' willadd to the matrix not replace the value
    totData = [totData; indflydata]; % Concatenate: '[totData; indflydata]'
end

% EVERY: 1st element is 'Rbar', 2nd: 'Lbar', 3rd: 'Dbar', 4th: 'Ubar'
% create for loop to make a cell mats of individual epochs
numROIs = size(totData, 1);
for ii = 1:4:numROIs
    Rbar = [Rbar; totData(ii)];
    Lbar = [Lbar; totData(ii+1)];
    Dbar = [Dbar; totData(ii+2)];
    Ubar = [Ubar; totData(ii+3)];
end

%% II. Plots 'Fig_05b' and 'Fig_05c'
% Convert t (sec) -> x (degrees)
epochProbeDur = [exp.params(:).duration];
epochDur = epochProbeDur(param.interleave_epochs+1:end);
pos0 = [exp.params(:).relativeX];
pos0 = pos0(param.interleave_epochs+1:end);
delPos = [exp.params(:).dX];
delPos = delPos(param.interleave_epochs+1:end);
stimPos = cell(1, length(delPos)); % Create a cell array to store the positions
stimEndPos = ones(length(delPos),1);
for jj = 1:length(delPos)
    stimPos{1,jj} = pos0(jj) + t_s * delPos(jj);
    stimEndPos(jj) = pos0(jj) + (epochDur(jj)/60) .* delPos(jj);
end

%% Plot 'Fig_05b': Rbar and Lbar
Fig_05b = figure('Units', 'normalized', 'OuterPosition', [0, 0, 0.65, 1]);
for jj = 1:length(Rbar)
    subplot(2,1,1); hold on; % Rbar subplot
    hold on;
    plot(stimPos{1,1},Rbar{jj,1})
    title('Lbar', 'Interpreter', 'latex')
    xline(-135, '-')
    xline(135, '-')
    xlabel('$x^\circ$', 'Interpreter', 'latex');
    ylabel('$\frac{\Delta F}{F}$ - $(\frac{\Delta F}{F})_{t = 0}$', 'Interpreter', 'latex');
    grid on;
    xlim([-250 150])
    subplot(2,1,2); hold on; % Lbar subplot
    plot(stimPos{1,2},Lbar{jj,1})
    title('Rbar', 'Interpreter', 'latex')
    xline(-135, '-')
    xline(135, '-')
    xlabel('$x^\circ$', 'Interpreter', 'latex');
    ylabel('$\frac{\Delta F}{F}$ - $(\frac{\Delta F}{F})_{t = 0}$', 'Interpreter', 'latex');
    grid on;
    xlim([-150 250])
end
sgtitle({[num2str(param.cellType),' > ',num2str(param.sensor),' || Flies: ', num2str(info.analysis{1,1}.numFlies),' ||  totROIs = ', num2str(numROIs)], param.stim}, 'FontSize', 14, 'FontName', 'Times New Roman', 'Interpreter', 'none');

%% Convert t (sec) -> y (degrees)
pos0y = [exp.params(:).relativeY];
pos0y = pos0y(param.interleave_epochs+1:end);
delPosy = [exp.params(:).dY];
delPosy = delPosy(param.interleave_epochs+1:end);
stimPosy = cell(1, length(delPosy)); % Create a cell array to store the positions
stimEndPosy = ones(length(delPosy),1);
for jj = 1:length(delPosy)
    stimPosy{1,jj} = pos0y(jj) + t_s * delPosy(jj);
    stimEndPosy(jj) = pos0y(jj) + (epochDur(jj)/60) .* delPosy(jj);
end

%% Plot 'Fig_05c': Rbar and Lbar
Fig_05c = figure('Units', 'normalized', 'OuterPosition', [0, 0, 0.65, 1]);
for kk = 1:length(Rbar)
    subplot(2,1,1); hold on;% Dbar subplot
    plot(stimPosy{1,3},Dbar{kk,1})
    title('Dbar', 'Interpreter', 'latex')
    xline(-60, '-')
    xline(60, '-')
    xlabel('$x^\circ$', 'Interpreter', 'latex');
    ylabel('$\frac{\Delta F}{F}$ - $(\frac{\Delta F}{F})_{t = 0}$', 'Interpreter', 'latex');
    xlim([-175 240])
    grid on;
    subplot(2,1,2); hold on; % Ubar subplot
    plot(stimPosy{1,4},Ubar{kk,1})
    title('Ubar', 'Interpreter', 'latex')
    xline(-60, '-')
    xline(60, '-')
    xlabel('$x^\circ$', 'Interpreter', 'latex');
    ylabel('$\frac{\Delta F}{F}$ - $(\frac{\Delta F}{F})_{t = 0}$', 'Interpreter', 'latex');
    grid on;
    xlim([-240 175])
    xlabel('$x^\circ$', 'Interpreter', 'latex');
    ylabel('$\frac{\Delta F}{F}$ - $(\frac{\Delta F}{F})_{t = 0}$', 'Interpreter', 'latex');
end
sgtitle({[num2str(param.cellType),' > ',num2str(param.sensor),' || Flies: ', num2str(info.analysis{1,1}.numFlies),' ||  totROIs = ', num2str(numROIs)], param.stim}, 'FontSize', 14, 'FontName', 'Times New Roman', 'Interpreter', 'none');
end