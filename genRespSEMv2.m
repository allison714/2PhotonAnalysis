% Fig. 01  Resp & SEM Plot for N Flies
function [Fig_01] = genRespSEMv2(data, info, param)
% % Data
% data = info.analysis{1, 1}.respMatPlot;
errorBars = info.analysis{1, 1}.respMatSemPlot;
% TimeXs = info.analysis{1, 1}.timeX / 1000;  % ms to s
nEpochs = length(data(1,:));
colors = linspecer(nEpochs,'sequential');
errorBars = info.analysis{1, 1}.respMatSemPlot;
TimeXs = info.analysis{1, 1}.timeX / 1000;  % ms to s


% Plot
Fig_01 = figure('Units', 'normalized', 'OuterPosition', [0, 0, 1, 1]);
hold on
for ii = 1: nEpochs
    plot(TimeXs, info.analysis{1, 1}.respMatPlot(:,ii), 'color', colors(ii,:), 'LineWidth', 1.5);
end
PlotErrorPatchAC(TimeXs, data(:, :, 1), errorBars(:, :, 1), colors, 'colors', 'FaceAlpha', 0.025);

% Formatting
set(gca, 'TickLabelInterpreter', 'latex','FontSize', 12);
grid on;
axis tight;
title({['LC14 > GC7b || Flies: ', num2str(info.analysis{1,1}.numFlies)], param.stim}, 'FontSize', 20, 'FontName', 'Times New Roman', 'Interpreter', 'none');
xlabel('t (s)','FontSize', 20, 'Interpreter', 'latex');
ylabel('$\frac{\Delta F}{F}$ - $(\frac{\Delta F}{F})_{t = 0}$','FontSize', 28, 'Interpreter', 'latex');


legend(legNames, 'FontSize', 16, 'FontName', 'Times New Roman', 'Interpreter', 'none', 'Location', 'best');
end