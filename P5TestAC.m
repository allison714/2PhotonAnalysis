% General Psycho5 iA v1.0
% A. Cairns
% 09.19.23
clc; close all; clear;
% Notes:
% - LC14 > GC7b [Ca2+] = 2.5 mM
% --> [13:15, 17:33, 35:40] sweepFullBars4d
% [13:14,16:21,23:33] vsweep15-480
% [4:22] WaveFlashBarObjectLoom

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
roiExtractionFile = 'watershedROIExtraction';
% roiExtractionFile = 'WatershedRegionRestrictedRoiExtraction'; % Watershed & Manual
%  roiExtractionFile = 'ManualRoiExtraction';

% Thresholding on correlations between multiple repetitions of probe stimuli (defaulted at r = .4).
roiSelectionFile  = 'selectROIbyProbeCorrelationGeneric'; % This will pass ROIs that were consistently responding to the probe regardless of HOW they were responding
% roiSelectionFile = ''; % or don't use selection at alls
% roiSelectionFile = 'selectAnyResponsiveROIs';

%% Run Analysis
analysisFiles = 'PlotTimeTraces'; % This will create a fig and create respMatPlot and respMatSemPlot in your ws which you can use to plot later

% validRecs = [13:15, 17:33, 35:40];
vrecs = dataPath{Nrecs};

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

info = RunAnalysis(args{:}, 'dataPath', dataPath(Nrecs));


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

%% Fly ID
flyID = cell(1, length(Nrecs));
for rr = 1:length(Nrecs)
    flyIDnum = GetFlyIdFromDatabaseAC(dataPath);
    param.flyID = flyIDnum;
    
    % Save param.flyID in the cell array
    flyID{rr} = param.flyID;
    
    disp(['Nrecs = ', num2str(Nrecs(rr)), ' ; FlyID: ', num2str(flyIDnum(rr))])
end