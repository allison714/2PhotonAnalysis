% sweepingFullBars_4D_5reps Imaging Analysis
% A. Cairns
% 10.03.23

% Fig. 05  Resp & SEM Plot for N Flies
function [Fig_05] = fullBarSweep4D(exp, info, param)
% Data
t_s = info.analysis{1, 1}.timeX / 1000;  % ms to s
data = info.analysis{1, 1}.respMatPlot;
errorBars = info.analysis{1, 1}.respMatSemPlot;
nEpochs = length(data(1,:));
epochProbeDur = [exp.params(:).duration];
epochDur = epochProbeDur(param.interleave_epochs+1:end);
colors = linspecer(nEpochs,'sequential');


% Convert t -> x (Not sure if this will work with y...) ********
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

% Create Figure handle to be exported
Fig_05 = figure('Units', 'normalized', 'OuterPosition', [0, 0, 1, 1]);

% Legend
epochNames = cellstr(exp.param_file(3, 3:end)); % do I want to do this like how I did epochDur instead?
legNames = cell(length(epochDur), 1);
for iv = 1:length(epochDur) % Concatenate legNames and legDur as strings
    legNames{iv} = [epochNames{iv}, ' || Dur: ', num2str(epochDur(iv)/60), ' (s)'];
    xline(epochDur(iv)/60, '-.');
end
legend(legNames, 'FontSize', 16, 'FontName', 'Times New Roman', 'Interpreter', 'none', 'Location', 'northeast');


%% SUBPLOT (a) x position on x axis

jjj = 1; % x position
subplot(1, 2, jjj);
hold on;
plot(stimPos{1,jjj}, info.analysis{1, 1}.respMatPlot(:,jjj), 'color', colors(1,:), 'LineWidth', 1.5);
PlotErrorPatchAC(stimPos{1,jjj}, data(:, jjj), errorBars(:, jjj), colors(1,:), 'colors', 'FaceAlpha', 0.25);

plot(stimPos{1,jjj+1}, info.analysis{1, 1}.respMatPlot(:,jjj+1), 'color', colors(2,:), 'LineWidth', 1.5);
PlotErrorPatchAC(stimPos{1,jjj+1}, data(:, jjj+1), errorBars(:, jjj+1), colors(2,:), 'colors', 'FaceAlpha', 0.25);

xline(pos0(jjj),'-.','**','DisplayName','**: Start', 'color', colors(1,:),'LabelVerticalAlignment','bottom','LabelHorizontalAlignment','right');
xline(stimEndPos(jjj),'-.','xx','DisplayName','xx: End', 'color', colors(1,:),'LabelVerticalAlignment','bottom','LabelHorizontalAlignment','left');

xline(pos0(jjj+1),'-.','**','DisplayName','**: Start', 'color', colors(2,:),'LabelVerticalAlignment','bottom','LabelHorizontalAlignment','right');
xline(stimEndPos(jjj+1),'-.','xx','DisplayName','xx: End', 'color', colors(2,:),'LabelVerticalAlignment','bottom','LabelHorizontalAlignment','left');

% Formatting
set(gca, 'TickLabelInterpreter', 'latex','FontSize', 12);
grid on;
xlim([-150 150])

miny = round(round(min(info.analysis{1, 1}.respMatPlot(:)),1 )* 5) / 4;
maxy = round(max(info.analysis{1, 1}.respMatPlot(:)) * 5) / 4;
ylim([miny maxy])
title(['Stim Duration: ', num2str(epochDur(jjj)),' (s)'], 'FontSize', 16, 'FontName', 'Times New Roman', 'Interpreter', 'none');
sgtitle({['LC14 > GC7b || Flies: ', num2str(info.analysis{1,1}.numFlies)], param.stim}, 'FontSize', 14, 'FontName', 'Times New Roman', 'Interpreter', 'none');
xlabel('$x^\circ$','FontSize', 16, 'Interpreter', 'latex');
ylabel('$\frac{\Delta F}{F}$ - $(\frac{\Delta F}{F})_{t = 0}$','FontSize', 20, 'Interpreter', 'latex');
legend(epochNames{jjj},epochNames{jjj+1},'**: Start','xx: End','Location','NorthEast')

%% SUBPLOT (b) y position on x axis
% Convert t -> y
pos0 = [exp.params(:).relativeY];
pos0 = pos0(param.interleave_epochs+1:end);
delPos = [exp.params(:).dY];
delPos = delPos(param.interleave_epochs+1:end);
stimPos = cell(1, length(delPos)); % Create a cell array to store the positions
stimEndPos = ones(length(delPos),1);
for jj = 1:length(delPos)
    stimPos{1,jj} = pos0(jj) + t_s * delPos(jj);
    stimEndPos(jj) = pos0(jj) + (epochDur(jj)/60) .* delPos(jj);
end

jjj = 3; % we are now using y position data
subplot(1, 2, jjj-1); % this had to be changed to jjj-1
hold on;
plot(stimPos{1,jjj}, info.analysis{1, 1}.respMatPlot(:,jjj), 'color', colors(1,:), 'LineWidth', 1.5);
PlotErrorPatchAC(stimPos{1,jjj}, data(:, jjj), errorBars(:, jjj), colors(1,:), 'colors', 'FaceAlpha', 0.25);

plot(stimPos{1,jjj+1}, info.analysis{1, 1}.respMatPlot(:,jjj+1), 'color', colors(2,:), 'LineWidth', 1.5);
PlotErrorPatchAC(stimPos{1,jjj+1}, data(:, jjj+1), errorBars(:, jjj+1), colors(2,:), 'colors', 'FaceAlpha', 0.25);

xline(pos0(jjj),'-.','**','DisplayName','**: Start', 'color', colors(1,:),'LabelVerticalAlignment','bottom','LabelHorizontalAlignment','right');
xline(stimEndPos(jjj),'-.','xx','DisplayName','xx: End', 'color', colors(1,:),'LabelVerticalAlignment','bottom','LabelHorizontalAlignment','left');

xline(pos0(jjj+1),'-.','**','DisplayName','**: Start', 'color', colors(2,:),'LabelVerticalAlignment','bottom','LabelHorizontalAlignment','right');
xline(stimEndPos(jjj+1),'-.','xx','DisplayName','xx: End', 'color', colors(2,:),'LabelVerticalAlignment','bottom','LabelHorizontalAlignment','left');

% Formatting
set(gca, 'TickLabelInterpreter', 'latex','FontSize', 12);
grid on;
% axis tight;
xlim([-150 150])
% miny = round(round(min(info.analysis{1, 1}.respMatPlot(:)),1 )* 5) / 4;
% maxy = round(max(info.analysis{1, 1}.respMatPlot(:)) * 5) / 4;
ylim([miny maxy])
title({['Stim Duration: ', num2str(epochDur(jjj)),' (s)'],['Velocity: ',num2str(delPos(jjj))]}, 'FontSize', 16, 'FontName', 'Times New Roman', 'Interpreter', 'none');
sgtitle({[num2str(param.cellType),' > ',num2str(param.sensor),' || Flies: ', num2str(info.analysis{1,1}.numFlies)], param.stim}, 'FontSize', 14, 'FontName', 'Times New Roman', 'Interpreter', 'none');
xlabel('$y^\circ$','FontSize', 16, 'Interpreter', 'latex');
ylabel('$\frac{\Delta F}{F}$ - $(\frac{\Delta F}{F})_{t = 0}$','FontSize', 20, 'Interpreter', 'latex');
legend(epochNames{jjj},epochNames{jjj+1},'**: Start','xx: End','Location','NorthEast')
