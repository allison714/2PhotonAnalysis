% Fig. 01  Resp & SEM Plot for N Flies
function [Fig_04] = WaveFlashBarObjectLoomSubplots(exp, info, param)
% Data
data = info.analysis{1, 1}.respMatPlot;
errorBars = info.analysis{1, 1}.respMatSemPlot;
t_s = info.analysis{1, 1}.timeX / 1000;  % ms to s
nEpochs = length(data(1,:));
colors = linspecer(nEpochs,'sequential');
delPos = [exp.params(:).dX];
delPos = delPos(param.interleave_epochs+1:end);

% Plot
Fig_04 = figure('Units', 'normalized', 'OuterPosition', [0, 0, 1, 1]);
hold on

% Subplot 1, all epochs in one plot
subplot(4,3,1)
for ii = 1: nEpochs
    plot(t_s, info.analysis{1, 1}.respMatPlot(:,ii), 'color', colors(ii,:), 'LineWidth', 1.5);
end
PlotErrorPatchAC(t_s, data(:, :, 1), errorBars(:, :, 1), colors, 'colors', 'FaceAlpha', 0.025);
xline(0,'-.')
xline(2,'-.')
yline(0,'-.')

% Legend
epochNames = cellstr(exp.param_file(3, 3:end)); % do I want to do this like how I did epochDur instead?
epochDur = [exp.params(:).duration];
epochDur = epochDur(param.interleave_epochs+1:end);

% Formatting
set(gca, 'TickLabelInterpreter', 'latex','FontSize', 12);
grid on;
axis tight;
sgtitle({['LC14 > GC7b || Flies: ', num2str(info.analysis{1,1}.numFlies)], [param.stim, ' || Dur: ', num2str(epochDur(1))]}, 'FontSize', 20, 'FontName', 'Times New Roman', 'Interpreter', 'none');
title('All Epochs', 'FontSize', 16, 'FontName', 'Times New Roman', 'Interpreter', 'none');
xlabel('t (s)','FontSize', 12, 'Interpreter', 'latex');
ylabel('$\frac{\Delta F}{F}$ - $(\frac{\Delta F}{F})_{t = 0}$','FontSize', 18, 'Interpreter', 'latex');

%% Subplots 2-12, single epochs
for ii = 1: nEpochs
    subplot(4,3,ii+1)
    plot(t_s, info.analysis{1, 1}.respMatPlot(:,ii), 'color', colors(ii,:), 'LineWidth', 1.5);
    PlotErrorPatchAC(t_s, data(:, ii), errorBars(:, ii), colors(ii,:), 'colors', 'FaceAlpha', 0.025);
    xline(0,'-.')
    xline(2,'-.')
    yline(0,'-.')
    set(gca, 'TickLabelInterpreter', 'latex','FontSize', 12);
    grid on;
    axis tight;
    title({[char(epochNames(ii))],['Velocity: ',num2str(delPos(ii))]}, 'FontSize', 16, 'FontName', 'Times New Roman', 'Interpreter', 'none');
    xlabel('t (s)','FontSize', 12, 'Interpreter', 'latex');
    ylabel('$\frac{\Delta F}{F}$ - $(\frac{\Delta F}{F})_{t = 0}$','FontSize', 18, 'Interpreter', 'latex');
end

end