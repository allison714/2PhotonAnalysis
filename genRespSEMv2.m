% Fig. 01  Resp & SEM Plot for N Flies
function [Fig_01] = genRespSEMv2(exp, info, param)
% % Data
data = info.analysis{1, 1}.respMatPlot;
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
xline(0,'-.')

% Formatting
set(gca, 'TickLabelInterpreter', 'latex','FontSize', 12);
grid on;
axis tight;
% % % % % % miny = round(min(info.analysis{1, 1}.respMatPlot(:)) + min(info.analysis{1, 1}.respMatPlot(:))/4, 1);
% % % % % % maxy = round((round(max(info.analysis{1, 1}.respMatPlot(:)) + max(info.analysis{1, 1}.respMatPlot(:)/4)) * 2) / 2);
% % miny = round(round(min(info.analysis{1, 1}.respMatPlot(:)),1 )* 2) / 2;
% % maxy = round(max(info.analysis{1, 1}.respMatPlot(:)) * 2) / 2;
% % % ylim([rounded_value = round(min(info.analysis{1, 1}.respMatPlot(:)) + min(info.analysis{1, 1}.respMatPlot(:))/4, 1) round((round(max(info.analysis{1, 1}.respMatPlot(:)) + max(info.analysis{1, 1}.respMatPlot(:)/4)) * 2) / 2)])
% % ylim([miny maxy])
title({['LC14 > GC7b || Flies: ', num2str(info.analysis{1,1}.numFlies)], param.stim}, 'FontSize', 20, 'FontName', 'Times New Roman', 'Interpreter', 'none');
xlabel('t (s)','FontSize', 20, 'Interpreter', 'latex');
ylabel('$\frac{\Delta F}{F}$ - $(\frac{\Delta F}{F})_{t = 0}$','FontSize', 28, 'Interpreter', 'latex');

% Legend
epochNames = cellstr(exp.param_file(3, 3:end)); % do I want to do this like how I did epochDur instead?
epochProbeDur = [exp.params(:).duration];
epochDur = epochProbeDur(param.interleave_epochs+1:end);
legNames = cell(length(epochDur), 1);
for iv = 1:length(epochDur) % Concatenate legNames and epochDur as strings
    legNames{iv} = [epochNames{iv}, ' || Dur: ', num2str(epochDur(iv)/60), ' (s)'];
    xline(epochDur(iv)/60, '-.');
end
legend(legNames, 'FontSize', 16, 'FontName', 'Times New Roman', 'Interpreter', 'none', 'Location', 'northeast');
end