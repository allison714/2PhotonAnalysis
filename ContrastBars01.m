function [Fig_03, Fig_03b] = ContrastBars01(exp, info, param)
% Variables used in all my functions
data = info.analysis{1, 1}.respMatPlot;
errorBars = info.analysis{1, 1}.respMatSemPlot;
TimeXs = info.analysis{1, 1}.timeX / 1000;  % ms to s
nEpochs = length(data(1,:));
colors = linspecer(nEpochs,'sequential');
epochNames = cellstr(exp.param_file(3, 3:end)); % do I want to do this like how I did epochDur instead?
epochProbeDur = [exp.params(:).duration];
epochDur = epochProbeDur(param.interleave_epochs+1:end);

pos0 = [exp.params(:).relativeX];
pos0 = pos0(param.interleave_epochs+1:end);
stimPos = cell(1, length(pos0));
stimEndPos = ones(length(pos0),1);

for jj = 1:length(pos0)
    stimPos{1,jj} = pos0(jj) + TimeXs;
    stimEndPos(jj) = pos0(jj) + (epochDur(jj)/60);
end

Fig_03 = figure('Units', 'normalized', 'OuterPosition', [0, 0, 1, 1]);
hold on;
% Loop through the columns of data
for mm = 1:size(data, 2)
    plot(stimPos{1,mm}, data(:, mm), 'color', colors(mm,:), 'LineWidth', 1.5);
    PlotErrorPatchAC(stimPos{1,mm}, data(:, mm), errorBars(:, mm), colors(mm,:), 'colors', 'FaceAlpha', 0.25);
end
for mm = 1:size(data, 2)/2
    xline(pos0(mm), '-.', char(epochNames(mm)), 'DisplayName', char(epochNames(mm)), 'color', colors(mm,:), 'LabelVerticalAlignment', 'top', 'LabelHorizontalAlignment', 'Left');
end
for oo = size(data, 2)/2:size(data, 2)
    xline(pos0(oo), '-.', char(epochNames(oo)), 'DisplayName', char(epochNames(oo)), 'color', colors(oo,:), 'LabelVerticalAlignment', 'top', 'LabelHorizontalAlignment', 'right');
end
% Formatting
xline(0,'-')
xline(-45,'-')
xline(45,'-')
yline(0,'-')
set(gca, 'TickLabelInterpreter', 'latex', 'FontSize', 12);
grid on;
axis tight;
sgtitle({['LC14 > GC7b || Flies: ', num2str(info.analysis{1,1}.numFlies)], param.stim}, 'FontSize', 16, 'FontName', 'Times New Roman', 'Interpreter', 'none');
xlabel('$x^\circ$', 'FontSize', 20, 'Interpreter', 'latex');
xticks(-90:10:90);  % Set the x-ticks from -90 to 90 in increments of 10
xticklabels(-90:10:90);  % Use the same values for x-tick labels
ylabel('$\frac{\Delta F}{F}$ - $(\frac{\Delta F}{F})_{t = 0}$', 'FontSize', 28, 'Interpreter', 'latex');
legend(['Stim Duration: ', num2str(epochDur(mm)), ' (s)'],'Location','southeast', 'FontName', 'Times New Roman', 'FontSize', 12)
xlim([-95,95]);

%------------------------------------------------------------------------------------------------------------------------------
Fig_03b = figure('Units', 'normalized', 'OuterPosition', [0, 0, 1, 1]);
dd = data(26:40, :);
tt = TimeXs(26:40,:);
hold on;
subplot(2,1,1) % FIRST SUBPLOT
hold on;
% Loop through the columns of data
for mm = 1:size(data, 2)/2
    plot(stimPos{1,mm}, data(:, mm), 'color', colors(mm,:), 'LineWidth', 1.5);
    PlotErrorPatchAC(stimPos{1,mm}, data(:, mm), errorBars(:, mm), colors(mm,:), 'colors', 'FaceAlpha', 0.25);
    xline(pos0(mm), '-.', char(epochNames(mm)), 'DisplayName', char(epochNames(mm)), 'color', colors(mm,:), 'LabelVerticalAlignment', 'top', 'LabelHorizontalAlignment', 'Left');
end
% Formatting
xline(0,'-')
xline(-45,'-')
xline(45,'-')
yline(0,'-')
set(gca, 'TickLabelInterpreter', 'latex', 'FontSize', 12);
grid on;
axis tight;
sgtitle({['LC14 > GC7b || Flies: ', num2str(info.analysis{1,1}.numFlies)], param.stim}, 'FontSize', 16, 'FontName', 'Times New Roman', 'Interpreter', 'none');
xlabel('$x^\circ$', 'FontSize', 20, 'Interpreter', 'latex');
xticks(-90:10:90);  % Set the x-ticks from -90 to 90 in increments of 10
xticklabels(-90:10:90);  % Use the same values for x-tick labels
ylabel('$\frac{\Delta F}{F}$ - $(\frac{\Delta F}{F})_{t = 0}$', 'FontSize', 28, 'Interpreter', 'latex');
legend(['Stim Duration: ', num2str(epochDur(mm)), ' (s)'],'Location','southeast', 'FontName', 'Times New Roman', 'FontSize', 12)
xlim([-95,95]);
subplot(2,1,2) % SECOND SUBPLOT
hold on;
for nn = size(data, 2)/2:size(data, 2)
    plot(stimPos{1,nn}, data(:, nn), 'color', colors(nn,:), 'LineWidth', 1.5);
    PlotErrorPatchAC(stimPos{1,nn}, data(:, nn), errorBars(:, nn), colors(nn,:), 'colors', 'FaceAlpha', 0.25);
    xline(pos0(nn), '-.', char(epochNames(nn)), 'DisplayName', char(epochNames(nn)), 'color', colors(nn,:), 'LabelVerticalAlignment', 'top', 'LabelHorizontalAlignment', 'right');
end
% Formatting
xline(0,'-')
xline(-45,'-')
xline(45,'-')
yline(0,'-')
set(gca, 'TickLabelInterpreter', 'latex', 'FontSize', 12);
grid on;
axis tight;
sgtitle({['LC14 > GC7b || Flies: ', num2str(info.analysis{1,1}.numFlies)], param.stim}, 'FontSize', 16, 'FontName', 'Times New Roman', 'Interpreter', 'none');
xlabel('$x^\circ$', 'FontSize', 20, 'Interpreter', 'latex');
xticks(-90:10:90);  % Set the x-ticks from -90 to 90 in increments of 10
xticklabels(-90:10:90);  % Use the same values for x-tick labels
ylabel('$\frac{\Delta F}{F}$ - $(\frac{\Delta F}{F})_{t = 0}$', 'FontSize', 28, 'Interpreter', 'latex');
legend(['Stim Duration: ', num2str(epochDur(mm)), ' (s)'],'Location','southeast', 'FontName', 'Times New Roman', 'FontSize', 12)
xlim([-95,95]);
end