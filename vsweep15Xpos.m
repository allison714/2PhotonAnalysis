function [Fig_02] = vsweep15Xpos(exp, info, param)
% Data
t_s = info.analysis{1, 1}.timeX / 1000;  % ms to s
data = info.analysis{1, 1}.respMatPlot;
errorBars = info.analysis{1, 1}.respMatSemPlot;
nEpochs = length(data(1,:));
epochNames = cellstr(exp.param_file(3, 3:end)); % do I want to do this like how I did epochDur instead
epochProbeDur = [exp.params(:).duration];
epochDur = epochProbeDur(param.interleave_epochs+1:end);
colors = linspecer(nEpochs,'sequential');

pos0 = [exp.params(:).relativeX];
pos0 = pos0(param.interleave_epochs+1:end);
delPos = [exp.params(:).dX];
delPos = delPos(param.interleave_epochs+1:end);

% Create a cell array to store the positions
stimPos = cell(1, length(delPos));
stimEndPos = ones(length(delPos),1);

% Create subplots
Fig_02 = figure('Units', 'normalized', 'OuterPosition', [0, 0, 1, 1]);

for jj = 1:length(delPos)
    stimPos{1,jj} = pos0(jj) + t_s * delPos(jj);
    stimEndPos(jj) = pos0(jj) + (epochDur(jj)/60) .* delPos(jj);
end
for jjj = 1:length(delPos)/2
    subplot(3, 2, jjj);
    hold on;
    plot(stimPos{1,jjj}, info.analysis{1, 1}.respMatPlot(:,jjj), 'color', colors(1,:), 'LineWidth', 1.5);
    PlotErrorPatchAC(stimPos{1,jjj}, data(:, jjj), errorBars(:, jjj), colors(1,:), 'colors', 'FaceAlpha', 0.25);

    plot(stimPos{1,jjj+6}, data(:, jjj+6), 'color', colors(2,:), 'LineWidth', 1.5);
    PlotErrorPatchAC(stimPos{1,jjj+6}, data(:, jjj+6), errorBars(:, jjj+6), colors(2,:), 'colors', 'FaceAlpha', 0.25);

    xline(pos0(jjj),'-.','**','DisplayName','**: Start', 'color', colors(1,:),'LabelVerticalAlignment','top','LabelHorizontalAlignment','right');
    xline(stimEndPos(jjj),'-.','xx','DisplayName','xx: End', 'color', colors(1,:),'LabelVerticalAlignment','top','LabelHorizontalAlignment','right');

    plot(stimPos{1,jjj+6}, data(:, jjj+6), 'color', colors(2,:), 'LineWidth', 1.5);
    PlotErrorPatchAC(stimPos{1,jjj+6}, data(:, jjj+6), errorBars(:, jjj+6), colors(2,:), 'colors', 'FaceAlpha', 0.25);
    xline(pos0(jjj+6),'-.','**','DisplayName','**: Start', 'color', colors(2,:),'LabelVerticalAlignment','top','LabelHorizontalAlignment','left');
    xline(stimEndPos(jjj+6),'-.','xx','DisplayName','xx: End', 'color', colors(2,:),'LabelVerticalAlignment','top','LabelHorizontalAlignment','left');

    % Formatting
    set(gca, 'TickLabelInterpreter', 'latex','FontSize', 12);
    grid on;
    % axis tight;
    title({[char(epochNames(jjj)), ' || Dur: ', num2str(epochDur(jjj))],['Velocity: ',num2str(delPos(jjj))]}, 'FontSize', 16, 'FontName', 'Times New Roman', 'Interpreter', 'none');
    sgtitle({[num2str(param.cellType),' > ',num2str(param.sensor),' || Flies: ', num2str(info.analysis{1,1}.numFlies)], param.stim}, 'FontSize', 18, 'FontName', 'Times New Roman', 'Interpreter', 'none');
    xlabel('$x^\circ$','FontSize', 16, 'Interpreter', 'latex');
    ylabel('$\frac{\Delta F}{F}$ - $(\frac{\Delta F}{F})_{t = 0}$','FontSize', 20, 'Interpreter', 'latex');
    xlim([-135,135])
    miny = round(round(min(info.analysis{1, 1}.respMatPlot(:)),1 )* 2) / 2; % this is rounding up, it should round down (negative)
    maxy = round(max(info.analysis{1, 1}.respMatPlot(:)) * 2) / 2;
    ylim([miny-0.3 maxy]) % quick fix for problem on line 54
    legend(epochNames{jjj},epochNames{jjj+6},'**: Start','xx: End','Location','NorthEast');
end
end