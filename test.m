% General Psycho5 iA v1.0
% A. Cairns
% 09.19.23
clc; close all; clear;
% Notes:
% - LC14 > GC7b [Ca2+] = 2.5 mM
% --> [13:15, 17:33, 35:40] sweepFullBars4d
% [8:21,23:30,32:33,35:37,41:43] sweepFullBars4d
% [13:14,16:21,23:33] vsweep15-480
% % [11:15,17:24,26:27,30:32,34:35] vsweep15-480
% [4:22] WaveFlashBarObjectLoom
% % [2:10,9:15,20:21,23:24] WaveFlashBarObjectLoom
% % [4:10,9:15,20:21] WaveFlashBarObjectLoom, 2 and 22+ don't work, try 3 and 24

%% Dialog Box
promptAns = p5input;
flyEye = ''; % Usually left blank
cellType= promptAns{1,1};
sensor = promptAns{2,1};
surgeon = promptAns{3,1};
stim = promptAns{4,1};
Nrecs = str2num(promptAns{5,1});
savetime = datestr(now, 'mmddyy');

%% Retrieve Data & ROI Selection
dataPath = GetPathsFromDatabase(cellType,stim,sensor,flyEye,surgeon);

roiExtractionFile = 'WatershedRegionRestrictedRoiExtraction'; % Watershed & Manual
%  roiExtractionFile = 'ManualRoiExtraction';

% Thresholding on correlations between multiple repetitions of probe stimuli (defaulted at r = .4).
roiSelectionFile  = 'selectROIbyProbeCorrelationGeneric'; % This will pass ROIs that were consistently responding to the probe regardless of HOey were responding
% roiSelectionFile = ''; % or don't use selection at alls
% roiSelectionFile = 'selectAnyResponsiveROIs';




%% Run Analysis
analysisFiles = 'PlotTimeTraces'; % This will create a fig and create respMatPlot and respMatSemPlot in your ws which you can use to plot later

% validRecs = [13:15, 17:33, 35:40];
% % vrecs = dataPath{Nrecs}; % delete?
%% CREATE LOOP for singular data
for zz = 1:length(Nrecs)

    args = {'analysisFile',analysisFiles,...
        'dataPath',dataPath,...
        'roiExtractionFile',roiExtractionFile,...
        'roiSelectionFile',roiSelectionFile,...
        'forceRois',0,... % if set to 1, redo ROI extraction
        'individual',1,...
        'backgroundSubtractMovie', 1,...
        'backgroundSubtractByRoi', 0,...
        'calcDFOverFByRoi',1,...
        'epochsForSelectivity',{'dummy'},...
        'combOpp',0,...
        'epochsForIdentificationForFly',1,...
        'stimulusResponseAlignment',0,...
        'noTrueInterleave',0,...
        'perRoiDfOverFCalcFunction','CalculatedDeltaFOverFByROI',...
        'numPresentationForSelection',0,...
        'legacyFitting',0};

    % info = RunAnalysis(args{:}, 'dataPath', dataPath(Nrecs());
    info = RunAnalysis(args{:}, 'dataPath', dataPath(Nrecs(zz)));

    %% Epoch information - see if code exists in P5 to make this easier
    param.stim = stim;
    param.movieChan = 1;
    param.probe_epochs = 'do it for me';

    %%% for iii = Nrecs
    iii = 1; % Do I need to change this and unblock?
    % Load in experimental parameters and raw movie
    [exp_info, raw_movie, param, exp] = getExpDetailsAC( dataPath{iii}, param);
    param.fly_num = find(iii == Nrecs);
    epoch_trace = exp_info.epochVal;
    param.interleave_epochs = mode(epoch_trace);
    %%% end

    clc;
    % Fly ID
    % for rr = 1:length(Nrecs(zz)) %added the '(zz)' didn't test 10.21.23
        flyIDnum = GetFlyIdFromDatabaseAC(dataPath);
        param.flyID = flyIDnum;
        disp(['Nrecs = ', num2str(Nrecs(zz)), ' ; FlyID: ', num2str(flyIDnum(Nrecs(zz)))])
    % end
    param.fliesTot = unique(param.flyID);

    % Last minute variables for plots
    param.cellType = cellType;
    param.sensor = sensor;
    param.Nrecs = Nrecs;

    %% Save/ Export Workspace
    % fileName = [cellType, sensor, stim, '_', savetime, '.mat'];
    fileName = [cellType, stim, '_', num2str(Nrecs(zz)), '.mat'];
    savePath1 = ['C:\Users\Lab_User\Documents\Allison Cairns\Workspaces\P5\',cellType];
    savePath2 = 'G:\My Drive\The Clark Lab\Workspaces\P5';
    if ~exist(savePath1, 'dir')
        mkdir(savePath1);
    end
    if ~exist(savePath2, 'dir')
        mkdir(savePath2);
    end
    save(fullfile(savePath1, fileName)); disp('Workspace saved');
    save(fullfile(savePath2, fileName)); disp('Workspace saved to G:/');
end
