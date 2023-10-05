% Allison's General Imaging Analysis (P5)
% I. Pull workspace from G:/
% II. Imaging Analysis Plots
%    -> See TOC below
% III. Recording? ----- To Do ***

%% Ia. Directory Dialog Box
% OPTION (a) Select a specifc workspace.mat from directory - good for
% making new plots for data that has already been analyzed.
% *** Note: For opt. (a) you must MANUALLY SAVE figures.
% OPTION (b) Automatically select folder and the code will only analyze new
% workspace.mat files.
clc; clearvars; close all;
promptAns2 = iA_wsDirP5();
%% ---------------------------------------------------------------------------------------------------------------------------------------
%% --- OPTION (a) --- Select a specific workspace.mat from directory - good for troubleshooting/ creating new plots
%% ---------------------------------------------------------------------------------------------------------------------------------------
if isempty(promptAns2)
    % Select from directory
    disp('Select a Workspace.m file using the file explorer:');
    [file, path] = uigetfile(['G:\.shortcut-targets-by-id\14uKDX4lMhjd5bJ4DSGt4R7i5XHY2c-V7\The Clark Lab\Workspaces\P5\','.mat'], 'Select a .mat file in G:/');
    wsFileName = fullfile(path, file);
    load(wsFileName);
    if file == 0 % Escape prompt
        disp('File selection canceled.');
        return;
    else % Workspace was loaded
        promptAns2{1,1} = 'P5'; % needed for future code - why? 10.03.23
        wsDir = fullfile(path, file);
        disp([wsDir, ' was selected.']);
    end
    param.stim = stim;
    savePathFigs = ['G:\.shortcut-targets-by-id\14uKDX4lMhjd5bJ4DSGt4R7i5XHY2c-V7\The Clark Lab\Completed Analysis\Psycho5 CA\', cellType,'\'];
    %% II. Plot Figures [Table of Contents]
    % Fig. 01 Resp & SEM Plot for N Flies
    % Fig. 02 vsweep15_480 Subplots with pos in x-axis
    % Fig. 03 AllisonContrastBars01 Plot with pos in x-axis
    % Fig. 04 WaveFlashBarObjectLoom_x20y-20_3rep t Subplots
    % Fig. 05sweepingFullBars_4D_5reps x & y pos Subplots
    [Fig_01] = genRespSEMv2(exp, info, param);
    switch length(stim)
        case 12 % Fig. 02 vsweep15_480 Subplots with pos in x-axis
            [Fig_02] = vsweep15Xpos(exp, info, param);
        case 21 % Fig. 03 AllisonContrastBars01 Plot with pos in x-axis
            % The bars don't move in this plot
            [Fig_03, Fig_03b] = ContrastBars01(exp, info, param);
        case 35 % Fig. 04 WaveFlashBarObjectLoom_x20y-20_3rep t Subplots
            [Fig_04] = WaveFlashBarObjectLoomSubplots(exp, info, param);
        case 25 % Fig. 05sweepingFullBars_4D_5reps x & y pos Subplots
            [Fig_05] = fullBarSweep4D(exp,info,param);
        otherwise
            disp('No extra plots exist for this stim') % or display a default message
    end
    %% ---------------------------------------------------------------------------------------------------------------------------------------
    %%               --- OPTION (b) --- Automatically select folder and the code will only analyze new workspace.mat files ---
    %% ---------------------------------------------------------------------------------------------------------------------------------------
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

        % TEMP: DELETE WHEN WORKSPACES ARE OLDER THAN 10.04.23
        param.sensor = sensor;
        param.cellType = cellType;

        NrecsStr = num2str(param.Nrecs);
        % TEST II incorporate this is iA_P5_Allison.m
        cleanedString = '';
        for nn = 1:length(NrecsStr)
            charValue = double(NrecsStr(nn));
            % Include only printable characters and standard alphanumeric characters
            if isstrprop(NrecsStr(nn), 'alphanum') || isstrprop(NrecsStr(nn), 'print')
                cleanedString = [cleanedString, NrecsStr(nn)];
            end
        end
        param.Nrecs = NrecsStr;
        % -DELETE ABOVE


        % Edit the save path so if the 'cellType' folder doesn't exist one
        % is created ***
        savePathFigs = ['G:\.shortcut-targets-by-id\14uKDX4lMhjd5bJ4DSGt4R7i5XHY2c-V7\The Clark Lab\Completed Analysis\Psycho5 CA\', cellType,'\'];
        %% II. Plot Figures [Table of Contents]
        % Fig. 01 Resp & SEM Plot for N Flies
        % Fig. 02 vsweep15_480 Subplots with pos in x-axis
        % Fig. 03 AllisonContrastBars01 Plot with pos in x-axis
        % Fig. 04 WaveFlashBarObjectLoom_x20y-20_3rep t Subplots
        % Fig. 05 sweepingFullBars_4D_5reps x & y pos Subplots

        %% Fig. 01 Resp & SEM Plot for N Flies
        % Save Info
        fig01 = sprintf('%s%s%sF1_%g',cellType,sensor,stim,param.Nrecs);
        pngFileF1 = fullfile(savePathFigs, [fig01, '.png']);
        % Plot/ save if file has not been analyzed
        if ~isfile(pngFileF1)
            % Plot Function for generic delf f/f t-trace
            [Fig_01] = genRespSEMv2(exp, info, param);
            % Plot Function for Fig. 01
            [Fig_01] = genRespSEMv2(exp, info, param);
            % Save/ Export
            saveas( gcf,fullfile(savePathFigs, [fig01, '.png']),'png')
            disp('Fig. 01 Saved')
        else % Fig. 01 already exists
            disp('---')
        end
        %% Fig. 02 vsweep15_480 Subplots with pos in x-axis
        if length(stim) == 12 % check for proper stim
            fig02 = sprintf('%s%s%sF2_%g',cellType,sensor,stim,param.Nrecs);
            pngFileF2 = fullfile(savePathFigs, [fig02, '.png']);
            % Plot/ save if file has not been analyzed
            if ~isfile(pngFileF2)
                [Fig_02] = vsweep15Xpos(exp, info, param);
                if ~exist('TimeXs', 'var')
                    [Fig_01] = genRespSEMv2(exp, info, param);
                end
                [Fig_02, pos0, delPos, stimPos, stimEndPos] = vsweep15Xpos(TimeXs, data, errorBars, exp, info, param, stim, epochNames, epochDur, colors);
                % Save/ Export
                saveas( gcf,fullfile(savePathFigs, [fig02, '.png']),'png')
                disp('Fig. 02 Saved')
            else % Fig. 02 already exists
                disp('--')
            end
        else
            % disp('Skipping Fig.02 since Stim is not vsweep15-480')
            disp('--')
        end
        %% Fig. 03 AllisonContrastBars01 Plot with pos in x-axis -- ** Create subplot of white and black bars
        % The bars don't move in this plot
        if length(stim) == 21
            fig03 = sprintf('%s%s%sF2_%g',cellType,sensor,stim,param.Nrecs);
            pngFileF3 = fullfile(savePathFigs, [fig03, '.png']);
            % Plot/ save if file has not been analyzed
            if ~isfile(pngFileF3)
                if ~exist('TimeXs', 'var')
                    [Fig_01] = genRespSEMv2(exp, info, param);
                end
                [Fig_03, Fig_03b] = ContrastBars01(exp, info, param);
                saveas( gcf,fullfile(savePathFigs, [fig03, '.png']),'png')
                disp('Fig. 03 Saved')
            else % Fig. 03 already exists
                disp('-')
            end
        else
            % disp('Skipping Fig.03 since Stim is not AllisonContrastBars01')
            disp('-')
        end
        %% Fig. 04 WaveFlashBarObjectLoom_x20y-20_3rep t Subplots -*** Create another plot that has x on xaxis
        % Bar and obj R both start at x = -20
        % Bar amd obj L both start at x = 100
        % dX is either +/- 60
        if length(stim) == 35
            fig04 = sprintf('%s%s%sF2_%g',cellType,sensor,stim,param.Nrecs);
            pngFileF4 = fullfile(savePathFigs, [fig04, '.png']);
            % Plot/ save if file has not been analyzed
            if ~isfile(pngFileF4)
                if ~exist('legDur', 'var')
                    [Fig_01] = genRespSEMv2(exp, info, param);
                end
                [Fig_04] = WaveFlashBarObjectLoomSubplots(exp, info, param);
                saveas( gcf,fullfile(savePathFigs, [fig04, '.png']),'png')
                disp('Fig. 04 Saved')
            else
                disp([wsFileName, '--'])
            end
        else
            % disp('Skipping Fig.03 since Stim is not AllisonContrastBars01')
            disp('--')
        end
        %%
        if length(stim) == 25
            fig05 = sprintf('%s%s%sF2_%g',cellType,sensor,stim,param.Nrecs);
            pngFileF5 = fullfile(savePathFigs, [fig05, '.png']);
            % Plot/ save if file has not been analyzed
            if ~isfile(pngFileF5)
                [Fig_05] = fullBarSweep4D(exp,info,param);
                saveas( gcf,fullfile(savePathFigs, [fig05, '.png']),'png')
                disp('Fig. 05 Saved')
            else
                % clc % --- might want to unblock when dataset gets big
                disp([wsFileName, '-'])
            end
        else
            disp('-')
        end
    %%
    end
    disp('Analysis Completed.')
end