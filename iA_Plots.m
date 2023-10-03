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
clc; clear; close all;
promptAns2 = iA_wsDirP5();
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
    savePathFigs = ['G:\.shortcut-targets-by-id\14uKDX4lMhjd5bJ4DSGt4R7i5XHY2c-V7\The Clark Lab\Completed Analysis\Psycho5 CA\', cellType,'\'];
    %% Plot Figures
    % Fig. 01 Resp & SEM Plot for N Flies
    % Fig. 02 vsweep15_480 Subplots with pos in x-axis
    % Fig. 03 AllisonContrastBars01 Plot with pos in x-axis
    % Data
    data = struct;
    data = info.analysis{1, 1}.respMatPlot;
    nEpochs = length(data(1,:));
    param.stim = stim;
    % Legend
    epochNames = cellstr(exp.param_file(3, 3:end)); % do I want to do this like how I did epochDur instead?
    epochProbeDur = [exp.params(:).duration];
    epochDur = epochProbeDur(param.interleave_epochs+1:end);
    legNames = cell(length(epochDur), 1);
    for iv = 1:length(epochDur) % Concatenate legNames and legDur as strings
        legNames{iv} = [epochNames{iv}, ' || Dur: ', num2str(epochDur(iv))];
    end
    %% Fig. 01 Resp & SEM Plot for N Flies
    % Plot Function for Fig. 01
    % Always run this because it exports useful variables for future plots
    [Fig_01] = genRespSEMv2(exp, info, param);

    %% Fig. 02 vsweep15_480 Subplots with pos in x-axis
    if length(stim) == 12
        [Fig_02, pos0, delPos, stimPos, stimEndPos] = vsweep15Xpos(TimeXs, data, errorBars, exp, info, param, stim, epochNames, epochDur, colors);
    else
        disp('---')
    end
    %% Fig. 03 AllisonContrastBars01 Plot with pos in x-axis
    % The bars don't move in this plot
    if length(stim) == 21
        [Fig_03] = ContrastBars01(data, errorBars, epochNames, exp, info, param, stim, TimeXs, epochDur, colors);
    else
        disp('--')
    end
    %% Fig. 04 WaveFlashBarObjectLoom_x20y-20_3rep t Subplots
    if length(stim) == 35
        [Fig_04, data, errorBars, TimeXs, colors, nEpochs, epochProbeDur, epochNames] = WaveFlashBarObjectLoomSubplots(exp, info, param, stim, epochDur);
    else
        disp('-')
    end
    %% --- OPTION (b) --- Automatically select folder and the code will only analyze new workspace.mat files ---
else
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
        savePathFigs = ['G:\.shortcut-targets-by-id\14uKDX4lMhjd5bJ4DSGt4R7i5XHY2c-V7\The Clark Lab\Completed Analysis\Psycho5 CA\', cellType,'\'];
        %% Plot Figures
        % Fig. 01 Resp & SEM Plot for N Flies
        % Fig. 02 vsweep15_480 Subplots with pos in x-axis
        % Fig. 03 AllisonContrastBars01 Plot with pos in x-axis

        %% Fig. 01 Resp & SEM Plot for N Flies
        % Save Info
        fig01 = sprintf('%s%s%sF1_%s',cellType,sensor,stim,savetime);

        pngFileF1 = fullfile(savePathFigs, [fig01, '.png']);
        % Plot/ save if file has not been analyzed
        if ~isfile(pngFileF1)
            % Plot Function for Fig. 01
            [Fig_01, data, errorBars, TimeXs, colors, nEpochs, epochProbeDur, epochNames, epochDur] = genRespSEM(exp, info, param, stim);
            % Save/ Export
            saveas( gcf,fullfile(savePathFigs, [fig01, '.png']),'png')
            disp('Fig. 01 Saved')
        else
            % clc % --- might want to unblock when dataset gets big
            % disp([wsFileName, ' || Fig. 01 already exists.'])
            disp('----')
        end
        %% Fig. 02 vsweep15_480 Subplots with pos in x-axis
        if length(stim) == 12 % check for proper stim
            fig02 = sprintf('%s%s%sF2_%s',cellType,sensor,stim,savetime);
            pngFileF2 = fullfile(savePathFigs, [fig02, '.png']);
            % Plot/ save if file has not been analyzed
            if ~isfile(pngFileF2)
                if ~exist('TimeXs', 'var')
                    [Fig_01, data, errorBars, TimeXs, colors, nEpochs, epochProbeDur, epochNames, epochDur] = genRespSEM(exp, info, param, stim);
                end
                [Fig_02, pos0, delPos, stimPos, stimEndPos] = vsweep15Xpos(TimeXs, data, errorBars, exp, info, param, stim, epochNames, epochDur, colors);
                % Save/ Export
                saveas( gcf,fullfile(savePathFigs, [fig02, '.png']),'png')
                disp('Fig. 02 Saved')
            else
                % clc % --- might want to unblock when dataset gets big
                % disp([wsFileName, ' || Fig. 02 already exists.'])
                disp('---')
            end
        else
            % disp('Skipping Fig.02 since Stim is not vsweep15-480')
            disp('---')
        end
        %% Fig. 03 AllisonContrastBars01 Plot with pos in x-axis -- ** Create subplot of white and black bars
        % The bars don't move in this plot
        if length(stim) == 21
            fig03 = sprintf('%s%s%sF2_%s',cellType,sensor,stim,savetime);
            pngFileF3 = fullfile(savePathFigs, [fig03, '.png']);
            % Plot/ save if file has not been analyzed
            if ~isfile(pngFileF3)
                if ~exist('TimeXs', 'var')
                    [Fig_01, data, errorBars, TimeXs, colors, nEpochs, epochProbeDur, epochNames, epochDur] = genRespSEM(exp, info, param, stim);
                end
                [Fig_03] = ContrastBars01(data, errorBars, epochNames, exp, info, param, stim, TimeXs, epochDur, colors);
                % Save/ Export
                saveas( gcf,fullfile(savePathFigs, [fig03, '.png']),'png')
                disp('Fig. 03 Saved')
            else
                % clc % --- might want to unblock when dataset gets big
                disp([wsFileName, ' || Fig. 03 already exists.'])
            end
        else
            % disp('Skipping Fig.03 since Stim is not AllisonContrastBars01')
            disp('--')
        end
        %% Fig. 04 WaveFlashBarObjectLoom_x20y-20_3rep t Subplots -*** Create another plot that has x on xaxis
        % Bar and obj R both start at x = -20
        % Bar amd obj L both start at x = 100
        % dX is either +/- 60
        if length(stim) == 35
            fig04 = sprintf('%s%s%sF2_%s',cellType,sensor,stim,savetime);
            pngFileF3 = fullfile(savePathFigs, [fig04, '.png']);
            % Plot/ save if file has not been analyzed
            if ~isfile(pngFileF3)
                if ~exist('legDur', 'var')
                    [Fig_01, data, errorBars, TimeXs, colors, nEpochs, epochProbeDur, epochNames, epochDur] = genRespSEM(exp, info, param, stim);
                end
                [Fig_04, data, errorBars, TimeXs, colors, nEpochs, epochProbeDur, epochNames] = WaveFlashBarObjectLoomSubplots(exp, info, param, stim, epochDur);
                % Save/ Export
                saveas( gcf,fullfile(savePathFigs, [fig04, '.png']),'png')
                disp('Fig. 04 Saved')
            else
                % clc % --- might want to unblock when dataset gets big
                disp([wsFileName, '-'])
            end
        else
            % disp('Skipping Fig.03 since Stim is not AllisonContrastBars01')
            disp('-')
        end
    end
    disp('Analysis Completed.')
end