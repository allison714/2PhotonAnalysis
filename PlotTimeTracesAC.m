 function analysis = PlotTimeTraces(flyResp,epochs,params,stim,dataRate,dataType,interleaveEpoch,varargin)
    combOpp = 1; % logical for combining symmetic epochs such as left and right
    numIgnoreInt = interleaveEpoch; % number of epochs to ignore
    figLeg = {};
    ttSnipShift = [];
    ttDuration = [];
    imagingSelectedEpochs = {'' ''};
    fTitle = '';
    plotOnly = '';
    reassignEpochs = '';
    ttSnipShift = -2000;
    epochsForSelection = {'' ''};
    plotTime = [];
    plotTimeLabel = [];
    linescan = 0;
    epochsToPlot = [];
    plotTitles = {};
    normByEpoch = 0;
    epochToNormBy = 0;
    stimulusResponseAlignment = false;
    GetMasks = 0;

    for ii = 1:2:length(varargin)
        eval([varargin{ii} '= varargin{' num2str(ii+1) '};']);
    end
    
    if ~iscell(imagingSelectedEpochs)
        imagingSelectedEpochs = num2cell(imagingSelectedEpochs);
    end
    
    % Convert variables related to time from units of milliseconds to
    % samples
    if ~isempty(reassignEpochs) % resize params struct array to get rid of
        % merged epochs and sum the durations of
        % the merged epochs
        [newParamList,oldParamIdx,~] = unique(reassignEpochs);
        newParams(newParamList) = params{1}(oldParamIdx);
        for param = 1:newParamList
            if sumDuration
                newParams(param).duration = sum(cell2mat({params{1}(reassignEpochs == param).duration}));
            else
                newParams(param).duration = params{1}(find(reassignEpochs == param,1,'first')).duration;
            end
            if isfield(params{1}(1),'epochName')
                epochNamesToCombine = {params{1}(reassignEpochs == param).epochName};
            else
                epochNamesToCombine = {''};
            end
            numericEpochNamesSelect = cellfun(@isnumeric,epochNamesToCombine);
            numericEpochNames(numericEpochNamesSelect) = cell2mat({epochNamesToCombine{numericEpochNamesSelect}});
            numericEpochNames(~numericEpochNamesSelect) = 0; % non-Nan value
            nanEpochNamesSelect = isnan(numericEpochNames);
            epochNamesToCombine(nanEpochNamesSelect) = '';
            newParams(param).epochName = cell2mat(epochNamesToCombine);
        end
%         params = cellfun(@(fly) repmat({newParams},1, size(fly, 2)), flyResp, 'UniformOutput', false);
        params = repmat({newParams},size(params));
    end
    
    %% Grab numIgnore if it doesn't exist based on interleaveEpoch
    % interleaveEpoch (which is in numIgnoreInt) will be a cell for imaging
    % data. numIgnoreSet is a flag for later determining whether we've got
    % to change numIgnore based on the fly (basically serves as
    % exist('numIgnore', 'var') for later once we've already set numIgnore
    if ~exist('numIgnore', 'var') || isempty(numIgnore)
        if iscell(numIgnoreInt)
            numIgnore = numIgnoreInt{1};
        else
            numIgnore = numIgnoreInt;
        end
        numIgnoreSet = false;
    else
        numIgnoreSet = true;
    end
    
    %% duration and snip shift should be entered in miliseconds
    % params duration is in projector frames; divide by 60 to get it into
    % seconds (because the projector presents at 60 frames/s; multiply by
    % 1000 to get it into ms
%     try
    longestDuration = 0;
    for pp = numIgnore+1:length(params{1})
        thisDuration = params{1}(pp).duration/60*1000;
        if thisDuration>longestDuration && (isempty(epochsToPlot) || ismember(pp, epochsToPlot))
            longestDuration = thisDuration;
        end
    end
    
    % snip shift reads in ttSnipShift so that PlotTimeTraces and CombAndSep
    % do not interact
    snipShift = ttSnipShift;
    
    if isempty(ttDuration)
        duration = longestDuration + 2500;
    else
        duration = ttDuration;
    end
    
    numFlies = length(flyResp);
    averagedRois = cell(1,numFlies);
    
    %% get processed trials
    
    for ff = 1:numFlies
        % If numIgnore wasn't set, we're going to adjust based on the
        % interleaveEpoch of each stimulusPres--this might change if, for
        % example, there were a different probe for each stim file (this
        % has happened before <.< --Emilio)
        if ~numIgnoreSet
            if iscell(numIgnoreInt)
                numIgnore = numIgnoreInt{ff};
            else
                numIgnore = numIgnoreInt;
            end
        end
        
        if ~isempty(reassignEpochs)
            newEpochs = [];
            for ii = 1:length(reassignEpochs)
                newEpochs(epochs{ff} == ii) = reassignEpochs(ii);
            end
            newEpochs = reshape(newEpochs, size(epochs{ff}));
            epochs{ff} = newEpochs;
        end
        
        if exist('stimulusResponseAlignment') && stimulusResponseAlignment
            roiRespUnaligned = flyResp{ff};
            epochsUnaligned = epochs{ff};
            
            roiResponsesOut = nan(size(roiUpsamplingIndexes{ff}));
            roiUpsamplingThisFly = roiUpsamplingIndexes{ff} + size(roiRespUnaligned, 1)*(0:size(roiRespUnaligned, 2)-1);
            roiResponsesOut(~isnan(roiUpsamplingThisFly)) = roiRespUnaligned(roiUpsamplingThisFly(~isnan(roiUpsamplingThisFly)));
            
            epochsForRois = nan(size(roiUpsamplingIndexes{ff}));
            epochsForRois(~isnan(roiUpsamplingThisFly)) = epochsUnaligned(roiUpsamplingThisFly(~isnan(roiUpsamplingThisFly)));
            
            % Note that incomplete data refers to where the
            % *upsampling* doesn't exist, not to where there are NaNs
            % replacing moving data, so we're good here.
            incompData = find(sum(isnan(roiUpsamplingThisFly), 2) ~= 0);
            roiResponsesOut(incompData, :) = [];
            epochsForRois(incompData, :) = [];
            dataRate = 60; % upsampled!
            
            flyResp{ff} = roiResponsesOut;
            epochs{ff} = epochsForRois;
        end
        
        analysis.indFly{ff} = GetProcessedTrials(flyResp{ff},epochs{ff},params{ff},dataRate,...
                                                 dataType,varargin{:},'duration',duration, ...
                                                 'snipShift',snipShift);
                                      
        % Remove ignored epochs
        selectedEpochs = analysis.indFly{ff}{end}.snipMat(numIgnore+1:end,:);

        % write to output structure
        analysis.indFly{ff}{end+1}.name = 'selectedEpochs';
        analysis.indFly{ff}{end}.snipMat = selectedEpochs;

        %% average over trials
        averagedTrials = ReduceDimension(selectedEpochs,'trials');

        % write to output structure
        analysis.indFly{ff}{end+1}.name = 'averagedTrials';
        analysis.indFly{ff}{end}.snipMat = averagedTrials;

        %% combine left ward and rightward epochs
        if combOpp
            combinedOpposites = CombineOpposites(averagedTrials);
        else
            combinedOpposites = averagedTrials;
        end

        % write to output structure
        analysis.indFly{ff}{end+1}.name = 'combinedOpposites';
        analysis.indFly{ff}{end}.snipMat = combinedOpposites;
        
%         if normByEpoch == 1
%             for i = 1:size(combinedOpposites, 2)
%                 currentMax = max(combinedOpposites{epochToNormBy, i});
%                 for k = 1:size(combinedOpposites, 1)
%                     combinedOpposites{k, i} = combinedOpposites{k, i}/currentMax;
%                 end
%             end
%         end
        %% average over Rois
        averagedRois{ff} = ReduceDimension(combinedOpposites,'Rois');
        
        if ~isempty(epochsToPlot)
            averagedRois{ff} = averagedRois{ff}(epochsToPlot);
        end

        % write to output structure
        analysis.indFly{ff}{end+1}.name = 'averagedRois';
        analysis.indFly{ff}{end}.snipMat = averagedRois{ff};


        if GetMasks==1
            % Write initial mask to output structure
            analysis.indFly{ff}{end+1}.name = 'initialMask';
            analysis.indFly{ff}{end}.initialMask = roiMaskInitial{ff};

            % Write final mask to output structure
            analysis.indFly{ff}{end+1}.name = 'finalMask';
            analysis.indFly{ff}{end}.finalMask = roiMask{ff};
        end

        %% Change names of analysis structures
        analysis.indFly{ff} = MakeAnalysisReadable(analysis.indFly{ff});
    end
    
    %% convert from snipMat to matrix wtih averaged flies
    if normByEpoch == 1
        for i = 1:size(averagedRois, 2)
            currentMax = max(averagedRois{i}{epochToNormBy});
            for k = 1:size(averagedRois{i}, 1)
                averagedRois{i}{k} = averagedRois{i}{k}/currentMax;
            end
        end
    end
    averagedFlies = ReduceDimension(averagedRois,'flies',@nanmean);
    averagedFliesSem = ReduceDimension(averagedRois,'flies',@NanSem);
    
    respMat = SnipMatToMatrix(averagedFlies); % turn snipMat into a matrix
    respMatPlot = permute(respMat,[1 3 6 7 2 4 5]);

    respMatSem = SnipMatToMatrix(averagedFliesSem); % turn snipMat into a matrix
    respMatSemPlot = permute(respMatSem,[1 3 6 7 2 4 5]);
    
    analysis.respMatPlot = respMatPlot;
    analysis.respMatSemPlot = respMatSemPlot;
   
    
    %%
    if isempty(figLeg) && isfield(params{1}(1),'epochName')
        for ii = (1+numIgnore):length(params{1})
            if ischar(params{1}(ii).epochName)
                figLeg{ii-numIgnore} = params{1}(ii).epochName;
            else
                figLeg{ii-numIgnore} = '';
            end
        end
    end
            
    
    %% plot
    if linescan == 1
        dataRate = dataRate*1024;
    end  
    timeX = ((1:round(duration*dataRate/1000))'+round(snipShift*dataRate/1000))*1000/dataRate;
    analysis.timeX = timeX;
    analysis.numFlies = numFlies;
    middleTime = linspace(0,longestDuration,5);
    timeStep = middleTime(2)-middleTime(1);
    earlyTime = fliplr(0:-timeStep:snipShift);
    endTime = longestDuration:timeStep:duration+snipShift;
    plotTime = round([earlyTime(1:end-1) middleTime endTime(2:end)]*10)/10;
    %plotTime = round([earlyTime(1) middleTime(1) middleTime(end) endTime(end)]*10)/10
    switch dataType
        case 'behavioralData'
            yAxis = {'turning response (deg/sec)','walking response (fold change)'};
        case 'imagingData'
            yAxis = {'\DeltaF / F - (\DeltaF / F)_{t=0}','\DeltaF / F - (\DeltaF / F)_{t=0}','\DeltaF / F - (\DeltaF / F)_{t=0}'};
        case 'ephysData'
            yAxis = {'Neural Response (mV)'};
    end
    
    if strcmp(dataType,'imagingData')
        if ~isempty(plotTitles)
            finalTitle = plotTitles{iteration};
        else
            finalTitle = fTitle;
        end
    else
        finalTitle = fTitle;
    end
    
    
    for pp = 1:size(respMatPlot,3)
        if strcmp(plotOnly,'walking') && pp == 1
            continue;
        end
        if strcmp(plotOnly,'turning') && pp == 2
            continue;
        end
        if isempty(epochsToPlot)
            MakeFigure;
            zeroInd = find(timeX==0);
            % BA 08/18/2022 zero response curves at t=0
            PlotXvsY(timeX,respMatPlot(:,:,pp)-respMatPlot(zeroInd,:,pp),'error',respMatSemPlot(:,:,pp)); 
            hold on;
            PlotConstLine(0);
            PlotConstLine(0,2);
            PlotConstLine(longestDuration,2);
            %PlotConstLine(5000,2);


            ConfAxis('tickX',plotTime,'tickLabelX',plotTimeLabel,'labelX','time (ms)','labelY',[yAxis{pp} ' - ' num2str(numFlies) ' flies'],'fTitle', finalTitle,'figLeg',figLeg);
            hold off;
        else
            if size(respMatPlot, 3) == 1
                ttFig = MakeFigure;
                zeroInd = find(timeX==0);
                % BA 08/18/2022 zero response curves at t=0
                PlotXvsY(timeX,respMatPlot(:,:,pp)-respMatPlot(zeroInd,:,pp),'error',respMatSemPlot(:,:,pp));
                hold on;
                PlotConstLine(0);
                PlotConstLine(0,2);
                PlotConstLine(longestDuration,2);
                %PlotConstLine(5000,2);


                ConfAxis('tickX',plotTime,'tickLabelX',plotTimeLabel,'labelX','time (ms)','labelY',[yAxis{pp} ' - ' num2str(numFlies) ' flies'],'fTitle', finalTitle,'figLeg',figLeg(epochsToPlot));
                hold off;
                ttFig.Name = finalTitle;
            end
        end
    end
% catch err
%     analysis = {};
% end
 end