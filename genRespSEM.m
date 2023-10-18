% Fig. 01  Resp & SEM Plot for N Flies
function [Fig_01] = genRespSEM(exp, info, param)
% % Data
data = info.analysis{1, 1}.respMatPlot;
errorBars = info.analysis{1, 1}.respMatSemPlot;
TimeXs = info.analysis{1, 1}.timeX / 1000;  % ms to s
nEpochs = length(data(1,:));
colors = linspecer(nEpochs,'sequential');

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
title({[param.cellType, ' > GC7b || Flies: ', num2str(info.analysis{1,1}.numFlies)], param.stim}, 'FontSize', 20, 'FontName', 'Times New Roman', 'Interpreter', 'none');
xlabel('t (s)','FontSize', 20, 'Interpreter', 'latex');
ylabel('$\frac{\Delta F}{F}$ - $(\frac{\Delta F}{F})_{t = 0}$','FontSize', 28, 'Interpreter', 'latex');

% Legend
epochNames = cellstr(exp.param_file(3, 3:end)); % do I want to do this like how I did epochDur instead?
epochProbeDur = [exp.params(:).duration];
epochDur = epochProbeDur(param.interleave_epochs+1:end);
legNames = cell(length(epochDur), 1);
for iv = 1:length(epochDur) % Concatenate legNames and legDur as strings
    legNames{iv} = [epochNames{iv}, ' || Dur: ', num2str(epochDur(iv))];
end
legend(legNames, 'FontSize', 16, 'FontName', 'Times New Roman', 'Interpreter', 'none', 'Location', 'best');
end