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
zz = 1; % test this should change for multiple data files 10.31.23
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
    % TEMP: DELETE WHEN WORKSPACES ARE OLDER THAN 10.04.23
    param.sensor = sensor;
    param.cellType = cellType;

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
    %% Table of total number of flies, flyIDs, recording frequency, and recording numbers
    % Is this table legit? Does it show the datapath of ALL in
    % existence or just the selected ones from the workspace 10.17.23
    % damn there is something up with this, maybe make it so it will
    % show ALL the data...figure out wassup
    % ~- temp - delete, new datasets later than 10.17.23 will have this
    param.fliesTot = unique(param.flyID);
    % ~- delete above
    if ~zz
        figTable = sprintf('%s%s%sFtable_%g',cellType,sensor,stim,param.Nrecs);
    else
        figTable = sprintf('%s%s%sFtable_%g',cellType,sensor,stim,param.Nrecs(zz));
    end
    pngFileFT = fullfile(savePathFigs, [figTable, '.png']);
    if ~isfile(pngFileFT)
        flyIDandRecInfo = ones(2, length(param.fliesTot));
        flyIDandRecInfo(1,:) = linspace(1, length(param.fliesTot), length(param.fliesTot));
        flyIDandRecInfo(2,:) = param.fliesTot;
        [uniqueValues, ~, idx] = unique(param.flyID);
        freq = histcounts(idx, 1:max(idx)+1);
        flyIDandRecInfo(3,:) = freq;
        flyIDandRecInfo(4,1) = freq(1);
        for tT = 2:length(param.fliesTot)
            flyIDandRecInfo(4,tT) = freq(tT)+flyIDandRecInfo(4,tT-1);
        end
        figure;
        sgtitle({[param.cellType, ' > ', param.sensor],stim},'Interpreter', 'none','FontSize',12)
        uitable('Data', flyIDandRecInfo', 'ColumnName', {'Index', 'FlyIDs', 'fRecs', 'NRecs'},'Position', [135 25 277 340]);
        saveas( gcf,fullfile(savePathFigs, [figTable, '.png']),'png')
        disp('Fly ID Table Saved')
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
        [A,B] = size(Nrecs);
        if size(B) > 1
            fig01 = sprintf('%s%s%sF1_%g',cellType,sensor,stim,param.Nrecs(size(1,zz)));
        else
            fig01 = sprintf('%s%s%sF1_%g',cellType,sensor,stim,'X');
        end
        %
        % fig01 = sprintf('%s%s%sF1_%g',cellType,sensor,stim,param.Nrecs(zz));
        pngFileF1 = fullfile(savePathFigs, [fig01, '.png']);
        % Plot/ save if file has not been analyzed
        if ~isfile(pngFileF1)
            % Plot Function for generic delf f/f t-trace
            [Fig_01] = genRespSEMv2(exp, info, param);
            % Save/ Export
            saveas( gcf,fullfile(savePathFigs, [fig01, '.png']),'png')
            disp('Fig. 01 Saved')
        else % Fig. 01 already exists
            disp('---')
        end
        %% Fig. 02 vsweep15_480 Subplots with pos in x-axis
        if length(stim) == 12 % check for proper stim

            if size(B) > 1
                fig02 = sprintf('%s%s%sF2_%g',cellType,sensor,stim,param.Nrecs(zz));
                fig02b = sprintf('%s%s%sF2b_%g',cellType,sensor,stim,param.Nrecs(zz));
                fig02c = sprintf('%s%s%sF2c_%g',cellType,sensor,stim,param.Nrecs(zz));
            else
                fig02 = sprintf('%s%s%sF2_%g',cellType,sensor,stim,'V');
                fig02b = sprintf('%s%s%sF2b_%g',cellType,sensor,stim,'V');
                fig02c = sprintf('%s%s%sF2c_%g',cellType,sensor,stim,'V');

            end

            % fig02 = sprintf('%s%s%sF2_%g',cellType,sensor,stim,param.Nrecs(zz));
            pngFileF2 = fullfile(savePathFigs, [fig02, '.png']);
            % Plot/ save if file has not been analyzed
            if ~isfile(pngFileF2)
                [Fig_02] = vsweep15Xpos(exp, info, param);
                if ~exist('TimeXs', 'var')
                    [Fig_01] = genRespSEMv2(exp, info, param);
                end
                [Fig_02] = vsweep15Xpos(exp, info, param);
                % Save/ Export
                saveas( gcf,fullfile(savePathFigs, [fig02, '.png']),'png')
                disp('Fig. 02 Saved')
            else % Fig. 02 already exists
                disp('--')
            end

            % fig02b = sprintf('%s%s%sF2b_%g',cellType,sensor,stim,param.Nrecs(zz));
            pngFileF2b = fullfile(savePathFigs, [fig02b, '.png']);
            pngFileF2c = fullfile(savePathFigs, [fig02c, '.png']);
            % Plot/ save if file has not been analyzed
            if ~isfile(pngFileF2b)
                % [Fig_02b,Fig_02c] = vsweep15XposIndROIs(exp, info, param);
                if ~exist('TimeXs', 'var')
                    [Fig_01] = genRespSEMv2(exp, info, param);
                end
                [Fig_02b,Fig_02c] = vsweep15XposIndROIs(exp, info, param);
                % Save/ Export
                saveas( Fig_02b,fullfile(savePathFigs, [fig02b, '.png']),'png')
                saveas( Fig_02c,fullfile(savePathFigs, [fig02c, '.png']),'png')
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
            fig03 = sprintf('%s%s%sF3_%g',cellType,sensor,stim,param.Nrecs(zz));
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
            fig04 = sprintf('%s%s%sF4_%g',cellType,sensor,stim,param.Nrecs(zz));
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
        %% Fig. 05 sweepingFullBars_4D_5reps
        if length(stim) == 25
            if size(B) > 1
                fig05 = sprintf('%s%s%sF5_%g',cellType,sensor,stim,param.Nrecs(zz));
            else
                fig05 = sprintf('%s%s%sF5_%g',cellType,sensor,stim,'X');

            end

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
            % vvv --- Implement this above 11.14.23 --- vvv
            if size(B) > 1
                fig05b = sprintf('%s%s%sF5b_%g',cellType,sensor,stim,param.Nrecs(zz));
                fig05c = sprintf('%s%s%sF5c_%g',cellType,sensor,stim,param.Nrecs(zz));
            else
                fig05b = sprintf('%s%s%sF5b_%g',cellType,sensor,stim,'Y');
                fig05c = sprintf('%s%s%sF5c_%g',cellType,sensor,stim,'Y');
            end

            pngFileF5b = fullfile(savePathFigs, [fig05b, '.png']);
            % fig05c = sprintf('%s%s%sF5c_%g',cellType,sensor,stim,param.Nrecs(zz));
            pngFileF5c = fullfile(savePathFigs, [fig05c, '.png']);
            % Plot/ save if file has not been analyzed
            if ~isfile(pngFileF5b)
                [Fig_05b, Fig_05c] = fullBarSweep4DindROIs(exp, info, param);
                saveas( Fig_05b,fullfile(savePathFigs, [fig05b, '.png']),'png')
                saveas( Fig_05c,fullfile(savePathFigs, [fig05c, '.png']),'png')
                disp('Figs. 05b, 05c Saved')
            else
                % clc % --- might want to unblock when dataset gets big
                disp([wsFileName, '-'])
            end
        else
            disp('-')
            % ^^^ --- Implement this above 11.14.23 --- ^^^
        end
        %% Table of total number of flies, flyIDs, recording frequency, and recording numbers
        % Is this table legit? Does it show the datapath of ALL in
        % existence or just the selected ones from the workspace 10.17.23
        % damn there is something up with this, maybe make it so it will
        % show ALL the data...figure out wassup
        % ~- temp - delete, new datasets later than 10.17.23 will have this
        param.fliesTot = unique(param.flyID);
        % ~- delete above

        if size(B) > 1
            figTable = sprintf('%s%s%sFtable_%g',cellType,sensor,stim,param.Nrecs(zz));
        else
            figTable = sprintf('%s%s%sFtable_%g',cellType,sensor,stim,'Z');
        end


        % figTable = sprintf('%s%s%sFtable_%g',cellType,sensor,stim,param.Nrecs(zz));
        pngFileFT = fullfile(savePathFigs, [figTable, '.png']);
        if ~isfile(pngFileFT)
            flyIDandRecInfo = ones(2, length(param.fliesTot));
            flyIDandRecInfo(1,:) = linspace(1, length(param.fliesTot), length(param.fliesTot));
            flyIDandRecInfo(2,:) = param.fliesTot;
            [uniqueValues, ~, idx] = unique(param.flyID);
            freq = histcounts(idx, 1:max(idx)+1);
            flyIDandRecInfo(3,:) = freq;
            flyIDandRecInfo(4,1) = freq(1);
            for tT = 2:length(param.fliesTot)
                flyIDandRecInfo(4,tT) = freq(tT)+flyIDandRecInfo(4,tT-1);
            end
            figure;
            sgtitle({[param.cellType, ' > ', param.sensor],stim},'Interpreter', 'none','FontSize',12)
            uitable('Data', flyIDandRecInfo', 'ColumnName', {'Index', 'FlyIDs', 'fRecs', 'NRecs'},'Position', [135 25 277 340]);
            saveas( gcf,fullfile(savePathFigs, [figTable, '.png']),'png')
            disp('Fly ID Table Saved')
        end
    end
    disp('Analysis Completed.');
end