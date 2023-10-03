clc; clear all; close all;

%% 1. Search the database for paths for data to analyze

sensor = 'GC7b';
cellType = 'LC14b';
flyEye = ''; % leave empty unless you do surgeries on both eyes
surgeon = 'Allison';
stim  = ['sweepingFullBars_4D_5reps']; 

% this should return a cell array with paths to the data (on server)
% make sure your sysConfig.csv is correctly pointing to the path of the
% database / servers
dataPath = GetPathsFromDatabase(cellType,stim,sensor,flyEye,surgeon);


%% 2. Define analysis parameters
% Use a watershed algorithm to define ROIs based on time-averaged frames
% and restrict that manually to neuropils you care etc.
roiExtractionFile = 'WatershedRegionRestrictedRoiExtraction';
roiRegion = 'lobula'; 

% Thresholding on correlations between multiple repetitions of probe
% stimuli (defaulted at r = .4). This will pass ROIs that were consistently 
% responding to the probe regardless of HOW they were responding
 roiSelectionFile  = '';


% Just plot average time traces
analysisFiles = 'PlotTimeTraces';

% input argument for analysis function
% Most of them are unused but here to make defaults explicit
args = {'analysisFile',analysisFiles,...
        'dataPath',dataPath,...
        'roiExtractionFile',roiExtractionFile,...
        'roiSelectionFile',roiSelectionFile,...
        'forceRois',0,... % set to 1 to redo ROI extraction
        'individual',1,...
        'backgroundSubtractMovie', 0,... % see manual for these
        'backgroundSubtractByRoi', 1,...
        'calcDFOverFByRoi',1,...
        'combOpp',0,...
        'epochsForIdentificationForFly',1,...
        'roiRestrictionRegion',roiRegion,...
        'epochsForSelectivity',{'dummy'},...
        'stimulusResponseAlignment',0,...
        'epochsToPlot','',...
        'reassignEpochs','',...
        'noTrueInterleave',0,...
        'perRoiDfOverFCalcFunction','CalculatedDeltaFOverFByROI',...
        'overallCorrelationThresh',0.4,... % only use pre-stimulus probe correlation for selection (usually enough)
        'corrToThirdThresh',-2};
a = RunAnalysis(args{:}); 

%% 3. Postprocessing
% "a" struct contains the results of all analysis. What it contains depends
% on the analysisFile you specify. See the manual for details

% % % figure;
% % % plot(a.analysis{:}.respMatPlot);

%% 4. Plot (HV + NBM's code editted by AC for this stimulus)
color=linspecer(10);

time_s=(a.analysis{1, 1}.timeX)/1000 ; % convert ms to s
%theta_i = [-15,-30,-60,-120,-240,15,30,60,120,240]; % initial starting point
epoch = 1:length(theta_i); % number of epochs

%%
figure

i = 1 % change this for each subplot, keeping "i" makes it easier to convert to a for loop if you want to reuse this code
subplot(5,4,i) % (Row, Column) = (1,1)


sgtitle('Velocity Sweep','FontSize',22) % Figure Title
PlotXvsY(time_s,a.analysis{1, 1}.respMatPlot(:,epoch(i)),'error',a.analysis{1, 1}.respMatSemPlot(:,epoch(i)),'color',color(i,:,:))
% title('family of curves for diff. velocities shown in D')
ConfAxis('labelY', ' \DeltaF/F' )

set(gca,'fontsize',14,'linewidth',2)

hold on
PlotConstLine(0,1)
hold on


for i=1:length(epoch)
    subplot(5,4,i)
    sgtitle('Velocity Sweep','FontSize',22)
PlotXvsY(time_s,a.analysis{1, 1}.respMatPlot(:,epoch(i)),'error',a.analysis{1, 1}.respMatSemPlot(:,epoch(i)),'color',color(i,:,:))
% title('family of curves for diff. velocities shown in D')
ConfAxis('labelY', ' \DeltaF/F' )

set(gca,'fontsize',14,'linewidth',2)

hold on
PlotConstLine(0,1)
hold on
%ylim([-0.5 1.3])
%xlim([-0.5 8])
%title('\theta_i =', theta_i(i))

end


filename = sprintf('%sP5_RawI%s%s%s_%d.png',savetime,stim,cellType,sensor,param.fly_num);
        % filename = sprintf('RT%sMeanMov_%s_%d.png',savetime,stim,param.fly_num);
        saveas( gcf,fullfile('C:\Users\Lab_User\Documents\Allison Cairns\2022-2023\Imaging\4Dsweep', filename),'png')


