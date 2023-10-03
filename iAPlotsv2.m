% Allison's General Imaging Analysis (P5)
% I. Pull workspace from G:/
%   - No Thresholding
%   - Manual ROI Selection
% II. Save Movie
%   - Title changes as epoch changes
% III. Imaging Analysis
%   - Four Subplots
%   - Large raw I plot
clc; clearvars; close all;
%% Ia. Directory Dialog Box
% Two options:
% (a) Select a specifc workspace.mat from directory - good for
% making new plots for data that has already been analyzed.
% *** Note: For opt. (a) you must MANUALLY SAVE figures.
% (b) Automatically select folder and the code will only analyze new
% workspace.mat files.
promptAns2 = iA_wsDir();
if isempty(promptAns2) % --- OPTION (a) --- Select a specifc workspace.mat from directory - good for making new plots for data that has already been analyzed
    % Select from directory
    disp('Select a Workspace.m file using the file explorer:');
    [file, path] = uigetfile(['G:\.shortcut-targets-by-id\14uKDX4lMhjd5bJ4DSGt4R7i5XHY2c-V7\The Clark Lab\Workspaces\P5\','.mat'], 'Select a .mat file in G:/');
    wsFileName = fullfile(path, file);
    load(wsFileName); % do I rename specificWS -> wsDir? ****
    if file == 0 % Escape prompt
        disp('File selection canceled.');
        return;
    else % Workspace was loaded
        promptAns2{1,1} = 'P5'; % needed for future code
        wsDir = fullfile(path, file); % change to specific WS? ****
        disp([wsDir, ' was selected.']);
    end
    %% Plot Figures
    % Fig. 01 Resp & SEM Plot for N Flies
    % Fig. 02 vsweep15_480 Subplots with pos in x-axis

    %% Fig. 01 Resp & SEM Plot for N Flies
    % Plot Function for Fig. 01
    % Always run this because it exports useful variables for future plots
    [Fig_01, data, errorBars, TimeXs, colors, nEpochs, epochDur, epochNames, legDur] = genRespSEM(exp, info, param, stim);

    %% Fig. 02 vsweep15_480 Subplots with pos in x-axis
    if length(stim) == 12
        [Fig_02, pos0, delPos, stimPos, stimEndPos] = vsweep15Xpos(TimeXs, data, errorBars, exp, info, param, stim, epochNames, legDur, colors);
    else
        disp('Skipping Fig.02 since Stim is not vsweep16-480')
    end
else % --- OPTION (b) --- Automatically select folder and the code will only analyze new workspace.mat files ---

    % Ib. Load in workspace
    wsDir = ['G:\.shortcut-targets-by-id\14uKDX4lMhjd5bJ4DSGt4R7i5XHY2c-V7\The Clark Lab\Workspaces\', char(promptAns2{1,1})];
    disp([char(promptAns2{1,1}), ' was selected.']);
    disp([wsDir, ' was loaded.']);
    % Load list of completed analysis
    completedAnalysis = {};  % Initialize
    P5AnalysisDir = fullfile(wsDir, 'P5wsAnalysis.txt');
    if exist(P5AnalysisDir, 'file')
        completedAnalysis = importdata(P5AnalysisDir);  % Load the list
    end
    disp('List of completed analysis (cAnalysisDir.txt) was loaded.');
    recordings = dir(fullfile(wsDir, '*.mat'));
    % Ic. Loop through dataset
    for zz = 1:length(recordings)
        wsFileName = recordings(zz).name;  % Get the file name
        % Id. Skip any repeats/ ones that have been done before
        % % % if ~ismember(wsFileName, completedAnalysis) % Block this when adding new figs
        wsPath = fullfile(wsDir, wsFileName);
        load(wsPath)

        %% Plot Figures
        % Fig. 01 Resp & SEM Plot for N Flies
        % Fig. 02 vsweep15_480 Subplots with pos in x-axis

        %% Fig. 01 Resp & SEM Plot for N Flies
        % Save Info
        fig01 = sprintf('%s%s%sF1_%s',cellType,sensor,stim,savetime);
        savePathFigs = ['G:\.shortcut-targets-by-id\14uKDX4lMhjd5bJ4DSGt4R7i5XHY2c-V7\The Clark Lab\Completed Analysis\Psycho5 CA\', cellType,'\'];
        pngFileF1 = fullfile(savePathFigs, [fig01, '.png']);
        % Plot/ save if file has not been analyzed
        if ~isfile(pngFileF1)
            % Plot Function for Fig. 01
            [Fig_01, data, errorBars, TimeXs, colors, nEpochs, epochDur, epochNames, legDur] = genRespSEM(exp, info, param, stim);
            % Save/ Export
            saveas( gcf,fullfile(savePathFigs, [fig01, '.png']),'png')
            disp('Fig. 01 Saved')
        else
            % clc % --- might want to unblock when dataset gets big
            disp([wsFileName, ' || Fig. 01 already exists.'])
        end
        %% Fig. 02 vsweep15_480 Subplots with pos in x-axis
        if length(stim) == 12 % check for proper stim
            fig02 = sprintf('%s%s%sF2_%s',cellType,sensor,stim,savetime);
            pngFileF2 = fullfile(savePathFigs, [fig02, '.png']);
            % Plot/ save if file has not been analyzed
            if ~isfile(pngFileF2)
                [Fig_02, pos0, delPos, stimPos, stimEndPos] = vsweep15Xpos(TimeXs, data, errorBars, exp, info, param, stim, epochNames, legDur, colors);

                % Save/ Export
                saveas( gcf,fullfile(savePathFigs, [fig02, '.png']),'png')
                disp('Fig. 02 Saved')
            else
                % clc % --- might want to unblock when dataset gets big
                disp([wsFileName, ' || Fig. 02 already exists.'])
            end
        else
            disp('Skipping Fig.02 since Stim is not vsweep16-480')
        end
    end
    disp('Analysis Completed.')
end