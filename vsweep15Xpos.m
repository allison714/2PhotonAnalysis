function [Fig_02, pos0, delPos, stimPos, stimEndPos] = vsweep15Xpos(TimeXs, data, errorBars,  exp, info, param, stim, epochNames, legDur, colors)
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
    stimPos{1,jj} = pos0(jj) + TimeXs * delPos(jj);
    stimEndPos(jj) = pos0(jj) + (legDur(jj)/60) .* delPos(jj);
end
for jjj = 1:length(delPos)/2
    subplot(3, 2, jjj);
    hold on;
    plot(stimPos{1,jjj}, info.analysis{1, 1}.respMatPlot(:,jjj), 'color', colors(1,:), 'LineWidth', 1.5);
    PlotErrorPatchAC(stimPos{1,jjj}, data(:, jjj), errorBars(:, jjj), colors(1,:), 'colors', 'FaceAlpha', 0.25);
    xline(pos0(jjj),'-.','**','DisplayName','**: Start', 'color', colors(1,:),'LabelVerticalAlignment','top','LabelHorizontalAlignment','right');
    xline(stimEndPos(jjj),'-.','xx','DisplayName','xx: End', 'color', colors(1,:),'LabelVerticalAlignment','top','LabelHorizontalAlignment','right');

    plot(stimPos{1,jjj+6}, data(:, jjj+6), 'color', colors(2,:), 'LineWidth', 1.5);
    PlotErrorPatchAC(stimPos{1,jjj+6}, data(:, jjj+6), errorBars(:, jjj+6), colors(2,:), 'colors', 'FaceAlpha', 0.25);
    xline(pos0(jjj+6),'-.','**','DisplayName','**: Start', 'color', colors(2,:),'LabelVerticalAlignment','top','LabelHorizontalAlignment','left');
    xline(stimEndPos(jjj+6),'-.','xx','DisplayName','xx: End', 'color', colors(2,:),'LabelVerticalAlignment','top','LabelHorizontalAlignment','left');

    % Formatting
    set(gca, 'TickLabelInterpreter', 'latex','FontSize', 12);
    grid on;
    axis tight;
    title(['Stim Duration: ', num2str(legDur(jjj)),' (s)'], 'FontSize', 16, 'FontName', 'Times New Roman', 'Interpreter', 'none');
    sgtitle({['LC14 > GC7b || Flies: ', num2str(info.analysis{1,1}.numFlies)], stim}, 'FontSize', 14, 'FontName', 'Times New Roman', 'Interpreter', 'none');
    xlabel('$x^\circ$','FontSize', 16, 'Interpreter', 'latex');
    ylabel('$\frac{\Delta F}{F}$ - $(\frac{\Delta F}{F})_{t = 0}$','FontSize', 20, 'Interpreter', 'latex');
    xlim([-135,135])
    legend(epochNames{jjj},'**: Start','xx: End',epochNames{jjj+6},'**: Start','xx: End','Location','NorthEast');
end
end