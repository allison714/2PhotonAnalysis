%% Shaded Error Bars

data = info.analysis{1, 1}.respMatPlot;
errorBars = info.analysis{1, 1}.respMatSemPlot;
TimeXs = info.analysis{1, 1}.timeX / 1000;  % ms to s
nEpochs = length(data(1,:));
colors = linspecer(nEpochs,'sequential');

% Resp & SEM Plot for N Flies
Fig_01 = figure('Units', 'normalized', 'OuterPosition', [0, 0, 1, 1]);
hold on
for ii = 1: nEpochs
    plot(TimeXs, info.analysis{1, 1}.respMatPlot(:,ii), 'color', colors(ii,:), 'LineWidth', 1.5);
end
PlotErrorPatchAC(TimeXs, data(:, :, 1), errorBars(:, :, 1), colors, 'colors', 'FaceAlpha', 0.5);

% Set the title and axis labels with LaTeX formatting
set(gca, 'TickLabelInterpreter', 'latex','FontSize', 12);
grid on;
title({['LC14 > GC7b || Flies: ', num2str(info.analysis{1,1}.numFlies)], [stim]}, 'FontSize', 20, 'FontName', 'Times New Roman', 'Interpreter', 'none');
xlabel('t (s)','FontSize', 20, 'Interpreter', 'latex');
ylabel('$\frac{\Delta F}{F}$ - $(\frac{\Delta F}{F})_{t = 0}$','FontSize', 28, 'Interpreter', 'latex');

% Legend
Nlegend = exp.param_file(3, 3:end);
epochDur = [exp.params(:).duration];
legDur = epochDur(param.interleave_epochs+1:end);
legend(Nlegend, 'FontSize', 16, 'Interpreter', 'latex');

% Save/ Export Fig. 01
fig01 = sprintf('%s%s%s_%sF1',cellType,sensor,stim,savetime);
savePathFigs = ['G:\.shortcut-targets-by-id\14uKDX4lMhjd5bJ4DSGt4R7i5XHY2c-V7\The Clark Lab\Completed Analysis\', cellType];
saveas( gcf,fullfile(savePathFigs, fig01),'png')