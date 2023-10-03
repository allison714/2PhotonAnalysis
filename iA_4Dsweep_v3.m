%% load in the experimental details
clear; clc; close all;

%% Parameters about your experiment
 cellType='LC17';
% cellType='LC14b';
% cellType='LC23male';
% sensor='GC6f';
sensor='GC7b';
flyEye='';
surgeon='Allison';
% surgeon='Braedyn';
% stim='Looming_3speeds_6locsMR_BW';
% stim='MovingBar_10deg_90degs_UDLR_BW';
%  stim='MovingSpot_15radius__90degs_MBLR_RUD';


% stim=['vsweep_02'];
 stim=['vsweep15_480'];
% param.interleave_epochs = 5; % vsweep_02 || vsweep15_480

% stim=['sweepingFullBars_4D_5reps1'];
% stim=['WaveFlashBarObjectLoom_x20y-20_3rep'];
param.interleave_epochs = 13; % sweepingFullBars_4D_5reps1 || WaveFlashBarObjectLoom_x20y-20_3rep
flies = [3:30];

% %% Dialog Box
% prompt = {'Cell Type ', 'Sensor ', 'Surgeon ', 'Param Name ', 'Interleave Epoch # ', 'Recordings '};
% dlgtitle = 'Imaging Analysis v. 1.0'; % change this when new params are added
% boxDims = [1 50; 1 50; 1 50; 1 50; 1 50; 1 50];
% % presetInput = {'LC?', 'sweep?', '#', '#'};
% presetInput = {'LC14b', 'GC7b', 'Allison', 'sweepingFullBars_4D_5reps', '13', '1:12,14:17'}; % LC14: [1,3:4,6:15,17] LC14b [1:12,14:17,18...]
% promptAns = inputdlg(prompt,dlgtitle,boxDims, presetInput);
% % promptAns = char(cellfun(@strdouble,promptAns));
% cellType= promptAns{1,1};
% sensor = promptAns{2,1};
% flyEye = ''; % Usually left blank
% surgeon = promptAns{3,1};
% stim = promptAns{4,1};
% param.interleave_epochs = promptAns{5,1};
% flies = promptAns{6,1};

% fig = figure('Name', 'Custom Dialog', 'Position', [200, 200, 300, 200]);
% ddOpts = {'LC14','LC14b','LC23','LC19','LC17'};
% ddMenu = uicontrol('Style', 'popupmenu','String', ddOpts, 'Position', [50, 100, 200, 30]);
% fieldInput = uicontrol('Style', 'edit', 'Position', [50, 60, 200, 30]);
% okay = uicontrol('Style', 'pushbutton','String', 'Okay', 'Position', [50, 20, 200, 30], 'Callback', @okButtonCallback);
% function okButtonCallback(~,~)
% chosenValIdx = get(ddMenu, 'Value');
% chosenVal = ddOpts{chosenValIdx};
% inputVal = get(fieldInput, 'String');
% disp(['Chosen Value: ', chosenVal]);
% disp(['Input Value: ', inputVal])
% delete(fig);
% end

% save path for figures
dataPath = GetPathsFromDatabase(cellType,stim,sensor,flyEye,surgeon);
savetime = datestr(now, 'mmddyy');

%% PARAMETERS YOU NEED TO SPECIFY
param.stim = stim; % don't change this line
param.movieChan = 1; % which channels do you want to analyze in the movie
param.probe_epochs = 'do it for me';

% what flies do you want to analyze?
param.analyze_these = flies;
resp = cell( length(param.analyze_these), 1 );

% parameters for the ROI selection
param.corr_thresh = 10^-100; % correlation threshold [0.2]
param.probe_correlation = true; % do you want to use probe correlations for ROI selection
param.probe_correlation_type = 'probe indices'; % how to roi correlations from the 1st and 2nd probes
param.mean_amplification_thresh = 10^75; % this gets rid of ROIs with bad F0 fits when computing delta F over F

% parameters for what code will compute
param.force_alignment = false; % force alignment calculation?
param.force_roi_selection = true; % force calculation of ROIs?
param.manual_roi = false;
param.group_method = 'none'; % how to group selected ROIs
param.frac_interleave = 0.5; % fraction of the interleave to use for computing F0 for DF/F ** why does psy5 use 0.4?

%% --- II. Run Analysis ---
for i_ex = param.analyze_these

    %% a. Load in experimental parameters and raw movie
    [exp_info, raw_movie, param] = get_exp_details( dataPath{i_ex}, param);
    % number of fly I'm on

    param.fly_num = find(i_ex == param.analyze_these);
    %     clc;

    % in case you want to plot the epochs...
    % figure; plot( exp_info.epochVal ); ylabel('epoch index'); xlabel('time index'); title(['Fly', num2str(param.fly_num)])

    %% b. Register the relaxed mean image with each frame to get alignment information
    [n_rows, n_cols, n_t] = size(raw_movie);

    storage_folder = fullfile(dataPath{i_ex}, 'psycho6');
    medfilt_size = 5;

    if isfolder(storage_folder) && ~param.force_alignment
        % download what you need to do alignment from your last calculation
        load( fullfile( storage_folder, 'alignment_info.mat' ) );

        dx_filt = medfilt1(dx,medfilt_size);
        dy_filt = medfilt1(dy,medfilt_size);

        % only save the the rows and columns that stayed in frame
        good_cols = [abs(min(dx_filt)) + 1 : n_cols - max(dx_filt)]; % columns that stayed in frame
        good_rows = [max(dy_filt) + 1 : n_rows - abs(min(dy_filt))]; % rows that stayed in frame
        tissue_mask = tissue_mask(good_rows, good_cols);

        % initialize the aligned_movie
        aligned_movie = zeros( length(good_rows), length(good_cols), n_t);

        % iterate through time
        for i_t = 1 : n_t
            aligned_movie(:,:,i_t) = raw_movie(good_rows - dy_filt(i_t) , good_cols + dx_filt(i_t) , i_t);
        end
    else
        % do the alignment
        neuron_hist_thresh = 0.95;
        init_tissue_prob = linear_tissue_prob_HighNeuronThresh(mean(raw_movie,3), neuron_hist_thresh);

        %init_tissue_prob = linear_tissue_prob(mean(raw_movie,3)); % try this if not many pixels are responding
        init_tissue_prob = sqrt(init_tissue_prob); % I've found adding this nonlinearity usually helps out
        tissue_mask = ~RelaxationNetworkSimulation(init_tissue_prob);

        [dx, dy, aligned_movie, tissue_mask] = movie_alignment_registration( raw_movie, tissue_mask );

        % save the displacement in x and y
        mkdir(fullfile(dataPath{i_ex}, 'psycho6'));
        save(fullfile(dataPath{i_ex}, 'psycho6', 'alignment_info.mat'), 'dx', 'dy', 'tissue_mask');

        dx_filt = medfilt1(dx,medfilt_size);
        dy_filt = medfilt1(dy,medfilt_size);

        % only save the the rows and columns that stayed in frame
        good_cols = [abs(min(dx_filt)) + 1 : n_cols - max(dx_filt)]; % columns that stayed in frame
        good_rows = [max(dy_filt) + 1 : n_rows - abs(min(dy_filt))]; % rows that stayed in frame

        aligned_movie = aligned_movie(good_rows, good_cols, :);
        tissue_mask = tissue_mask(good_rows, good_cols);
    end

    % redefine n_rows and n_cols to be size of cropped movie
    [n_rows, n_cols, ~] = size(aligned_movie);

    %% c. Subtract the background from 'aligned_movie'

    % initiliaze the filtered movie
    filtered_movie = zeros(size(aligned_movie));

    % define background as below median, temporal mean intensity of the 0 pixels in
    % tissue_mask
    mean_movie = mean(aligned_movie, 3); % recalculate mean movie on the aligned movie
    bkg_mask = (mean_movie < median(mean_movie(~tissue_mask))) & ~tissue_mask;

    % loop through time
    for i = 1 : n_t
        this_frame = aligned_movie(:,:,i);
        filtered_movie(:,:,i) = aligned_movie(:,:,i) - mean(this_frame(bkg_mask));
    end
    mean_movie = mean(filtered_movie, 3); % recalculate mean movie on the fully filtered movie

    disp('Finished Processing Raw Movie')
    %% d. Compute correlation image from filtered movie

    corr_img = neighboring_pixel_correlation( filtered_movie );

    disp('Finished Calculating Correlation Image')
    %% e. Get ROIs from correlation image

    roi_mask_file = fullfile(storage_folder, 'roi_masks.mat');
    if ~param.force_roi_selection && isfile( roi_mask_file )
        load( roi_mask_file )
    else
        if param.manual_roi
            % manually define the ROIs
            %             roi_extract = draw_rois( corr_img );
            roi_extract = draw_rois( mean_movie );
        else
            % try to programmatically define the ROIs
            %             roi_extract = WatershedImage(corr_img); % psycho5 function that uses watershed, then tries to fill in the borders
            roi_extract = WatershedImage(corr_img); % psycho5 function that uses watershed, then tries to fill in the borders
        end
        probe_idxs = get_probe_idxs(exp_info.epochVal, param);
        %         roi_select = probe_correlation( filtered_movie, param, roi_extract, corr_img, probe_idxs );
        %
        %         if strcmp(param.group_method, 'none')
        %             % do nothing
        %         elseif strcmp(param.group_method, 'touching')
        %             % group rois that are touching
        %             roi_select = bwlabel( roi_select>0 );
        %         elseif strcmp(param.group_method, 'manual')
        %             % allow user to manually group ROIs
        %             roi_select = manually_group_rois(roi_select, mean_movie);
        %         end
        roi_select = roi_extract;
        save(roi_mask_file, 'roi_extract', 'roi_select');
    end

    roi_raw_intensity = zeros( n_t, max(roi_select,[],'all') );
    % compute mean intensity temporal trace of each ROI
    % loop through each ROI
    for i_roi = 1 : max(roi_select,[],'all')
        num_pixels = sum(roi_select == i_roi, 'all'); % size of ROI
        % intensity of this ROI over time
        roi_raw_intensity(:,i_roi) = (sum(sum((roi_select == i_roi) .* filtered_movie, 1), 2)) ./ (num_pixels);
    end
    epoch_trace = exp_info.epochVal; % rename this to make it easier to remember
    resp{param.fly_num}.epoch_trace = epoch_trace;
    epoch_change = find( diff( epoch_trace( probe_idxs{1} ) ) );

    %% f. Get the response of each ROI over time

    %roi_dff_method = 'mean_resp'; % sets F0 to the mean interleave response
    roi_dff_method = 'exponential'; % fits exponential to each ROI
    [roi_dff, roi_final, mean_inter] = roi_dff_calc( param, exp_info, roi_select, filtered_movie, roi_dff_method);
    num_rois = max(roi_final,[],'all');
    epoch_trace = exp_info.epochVal; % rename this to make it easier to remember
    disp('Finished Calculating ROIs')
    %% g. Save important output to resp cell array
    resp{param.fly_num}.dff = roi_dff; % delta F over F for each "good" ROI
    resp{param.fly_num}.epoch_trace = epoch_trace; % epochs presented over time
    resp{param.fly_num}.roi_final = roi_final; % final ROI mask
    resp{param.fly_num}.time = exp_info.time; % time in seconds each frame was grabbed

    %% h. Plot Stuff That Every User Probably Wants

    if num_rois > 0

        % plot the dx and dy
        MakeFigure; hold on
        subplot(2, 1, 1)
        % subplot of dx change
        plot(exp_info.time ./ 60, dx_filt, 'linewidth', 1)
        xlabel('time (minutes)')
        ylabel('dx (pixels)')
        title(['Rec. ', num2str( i_ex ), '; Median Filtered Displacement in "x" direction'])
        set(gca, 'fontsize', 20)

        subplot(2, 1, 2)
        % subplot of dy change
        plot(exp_info.time ./ 60, dy_filt, 'linewidth', 1)
        xlabel('time (minutes)')
        ylabel('dy (pixels)')
        title(['Rec. ', num2str( i_ex ), '; Median Filtered Displacement in "y" direction'])
        set(gca, 'fontsize', 20)

        % plot responses during 1st and 2nd probe
        MakeFigure;
        y_max = max(roi_dff( [probe_idxs{1}, probe_idxs{2}] , :), [], 'all') * 1.1; % 10% bigger than largest response
        y_min = min(roi_dff( [probe_idxs{1}, probe_idxs{2}] , :), [], 'all');
        y_min = y_min * (1 - sign(y_min)*0.1);
        for i_p = 1 : 2
            % find where there's an epoch change
            epoch_change = find( diff( epoch_trace( probe_idxs{i_p} ) ) );

            % loop through both probes
            subplot(1,2,i_p)
            plot( exp_info.time(probe_idxs{i_p}) ./ 60, roi_dff( probe_idxs{i_p} , :) ); hold on;
            for i_epoch = 1 : length(epoch_change)
                plot( ones(2,1).* exp_info.time( epoch_change(i_epoch) + probe_idxs{i_p}(1) )  ./ 60, [y_min; y_max], '--', 'color', 0.5 * ones(1,3) )
            end
            xlabel('time (minutes)')
            ylabel('$\Delta F / F$', 'interpreter', 'latex')
            title(['Rec. ', num2str(i_ex), ' Probe ', num2str(i_p)])
            subtitle('temporal trace used for ROI selection')
            set(gca, 'FontSize', 25)
            ylim( [ y_min, y_max] )
            x_min = min(exp_info.time( probe_idxs{i_p} )  ./ 60);
            x_max = max(exp_info.time( probe_idxs{i_p} )  ./ 60);
            xlim([x_min, x_max])
        end

        % plot response over entire recording
        MakeFigure; hold on;
        plot(exp_info.time ./ 60, roi_dff);

        y_max = max(roi_dff, [], 'all') * 1.1; % 10% bigger than largest response
        y_min = min(roi_dff, [], 'all');
        y_min = y_min * (1 - sign(y_min)*0.1);

        epoch_change = find( diff( epoch_trace ) );
        for i_epoch = 1 : length(epoch_change)
            plot( ones(2,1).* exp_info.time( epoch_change(i_epoch) ) ./ 60, [y_min; y_max], '--', 'color', 0.5 * ones(1,3) )
        end
        xlabel('time (minutes)');
        ylabel('$\Delta F / F$', 'interpreter', 'latex')
        title(['Rec. ', num2str( i_ex ) ,' Response'])
        ylim([y_min, y_max])
        xlim([0, exp_info.time(end)./60])
        set(gca, 'FontSize', 25)

        % plot the mean movie with labeled ROIs
        MakeFigure;
        imagesc(mean_movie); hold on;
        colormap(gray)
        axis off
        for i_roi = 1 : num_rois
            visboundaries(bwboundaries(roi_final==i_roi), 'LineStyle', '--','LineWidth', 0.1, 'color', 'red');
        end
        title(['Rec. ', num2str(i_ex) ,' Mean Movie with ROIs'])
        set(gca, 'FontSize', 25)

        % plot the region circling neural tissue
        MakeFigure;
        imagesc(mean_movie); hold on;
        colormap(gray)
        axis off
        visboundaries(bwboundaries(tissue_mask), 'LineStyle', '--','LineWidth', 0.1, 'color', 'red');
        title(['Rec. ', num2str(i_ex) ,' Tissue Mask Over Mean Movie'])
        set(gca, 'FontSize', 25)

        % plot interleave fit divided by interleave response (mean)
        figure; hold on;
        plot(mean_inter.times / 60, mean_inter.fit ./ mean_inter.resp, 'LineWidth', 1)
        h = plot(mean_inter.times / 60, 1, 'LineWidth', 1);
        legend(h, 'Ideal Case')
        xlabel('Time (minutes)')
        ylabel('Factor Enhancement')
        title(['Fly ', num2str(param.fly_num) ,' Interleave Fit / Interleave Response'])
        set(gca, 'FontSize', 25)
    end
    disp(['Finished Processing Rec. ', num2str(i_ex), ' / ', num2str(length(param.analyze_these)) ])

    %% Figure 1 ------------------------------------------------------
    % ---Upsample data
    frRate = 8; % Hz | fps
    upSample = 60; % Hz - this gets multiplied by num of frames
    t8 = linspace(0, length(exp_info.time)/frRate, length(exp_info.time));
    t30 = linspace(0, length(exp_info.time)/frRate, round(length(exp_info.time)*upSample/frRate));
    % interp1() to upsample
    exp_info.newt = interp1(t8, exp_info.time, t30);
    % exp_info.time = exp_info.newt;
    exp_info.newEpochVal = interp1(t8, exp_info.epochVal, t30);
    % exp_info.epochVal = exp_info.newepochVal;

    % for mm = 1:length(flies)
    plotH = figure('units','normalized','outerposition',[0 0 1 1]);

    % meanMov subplot
    subplot(5,10,[1,2,11,12])
    imagesc(mean_movie); hold on;
    %         colormap(gray)
    axis off
    for i_roi = 1 : num_rois
        visboundaries(bwboundaries(roi_final==i_roi), 'LineStyle', '--','LineWidth', 0.1, 'color', 'red');
    end
    title(['Mean Movie & ROIs'])
    set(gca, 'FontSize', 20)

    sgtitle([num2str(cellType), ' > ', num2str(sensor), ' || Rec. ', num2str( i_ex )],'fontsize', 24)

    % Neural tissue subplot
    subplot(5,10,[31,32,41,42])
    imagesc(mean_movie); hold on;
    %         colormap(gray)
    axis off
    visboundaries(bwboundaries(tissue_mask), 'LineStyle', '--','LineWidth', 0.1, 'color', 'red');
    title(['Tissue Mask'])
    set(gca, 'FontSize', 20)

    % Epoch subplot
    subplot(5,10,[3:10,13:20])
    plot(exp_info.newt / 60, exp_info.newEpochVal)
    % % plot(exp_info.time / 60, exp_info.epochVal,'-*')
    % xticks([1 2 3 4])
    yyaxis left

    yyaxis right
    set(gca, 'Ytick', [])
    ylabel('Epoch Index')
    title(['Epochs for Probe and Stimulus ', num2str(stim)], 'fontsize', 20, 'Interpreter', "None")
    grid on
    axis('tight')

    % ROI raw intensity subplot
    subplot(5,10,[23:30,33:40,43:50])
    imagesc(roi_raw_intensity')
    xticks([509 1016 1524 2032])
    xticklabels({'1','2','3','4'})
    yyaxis left
    yyaxis right
    set(gca, 'Ytick', [])
    xlabel('t (min)')
    ylabel('ROI')
    title(['Raw Intensity Over Time || ', 'min / max = ', num2str( min(roi_raw_intensity(:))) ' / ' num2str(max(roi_raw_intensity(:)))], 'fontsize', 20)
    indx.p = [];
    % plot epoch lines + text
    %     figure; hold on
    colors = lines(length(unique(epoch_trace)));
    prev = epoch_trace(1);
    for j = 1:length(epoch_trace)
        idx.p{:,j} = find(epoch_trace == j);

        % stim duration
        % sequential order of idx, try to generalize this code
        if epoch_trace(j) ~= prev
            prev = epoch_trace(j);
            %             stimTiming.tStart =
            color_id = find(unique(epoch_trace) == epoch_trace(j));
            color_j = colors(color_id, :);
            line([j j],[0 size(roi_raw_intensity, 1)], 'LineWidth', 1, 'Color', color_j)
            text(j+5, 17, num2str(epoch_trace(j)), 'Color', color_j, 'FontSize', 8)
        end
    end
    hold off
    c = colorbar;
    c.Location = 'northoutside';

    % Save fig as .png
    filename = sprintf('%s_%s%s%s_%d.png',savetime,stim,cellType,sensor,i_ex);

    % --- If you use a new stim create new save paths ---
    if length(cellType) == length('LC14') % and LC19
        disp(['The save path is C:\Users\Lab_User\Documents\Allison Cairns\2022-2023\Imaging\LC14\'])
        if length(stim) == length('vsweep15_480')
            saveas( gcf,fullfile('C:\Users\Lab_User\Documents\Allison Cairns\2022-2023\Imaging\LC14\vsweep15_480', filename),'png')
        end
        if length(stim) == length('sweepingFullBars_4D_5reps1')
            saveas( gcf,fullfile('C:\Users\Lab_User\Documents\Allison Cairns\2022-2023\Imaging\LC14\sweepingFullBars_4D_5reps1', filename),'png')
        end
        if length(stim) == length('vsweep_02')
            saveas( gcf,fullfile('C:\Users\Lab_User\Documents\Allison Cairns\2022-2023\Imaging\LC14\vsweep_02', filename),'png')
        end
        if length(stim) == length('WaveFlashBarObjectLoom_x20y-20_3rep')
            saveas( gcf,fullfile('C:\Users\Lab_User\Documents\Allison Cairns\2022-2023\Imaging\LC19\WaveFlashBarObjectLoom_x20y-20_3rep', filename),'png')
        end
        if length(stim) == length('probe_TargetProbe_fullBars')
            saveas( gcf,fullfile('C:\Users\Lab_User\Documents\Allison Cairns\2022-2023\Imaging\LC19\WaveFlashBarObjectLoom_x20y-20_3rep', filename),'png')
        end
    elseif length(cellType) == length('LC14b')
        disp(['The save path is C:\Users\Lab_User\Documents\Allison Cairns\2022-2023\Imaging\LC14b\'])
        if length(stim) == length('vsweep15_480')
            saveas( gcf,fullfile('C:\Users\Lab_User\Documents\Allison Cairns\2022-2023\Imaging\LC14b\vsweep15_480', filename),'png')
        end
        if length(stim) == length('sweepingFullBars_4D_5reps1')
            saveas( gcf,fullfile('C:\Users\Lab_User\Documents\Allison Cairns\2022-2023\Imaging\LC14b\sweepingFullBars_4D_5reps1', filename),'png')
        end
        if length(stim) == length('vsweep_02')
            saveas( gcf,fullfile('C:\Users\Lab_User\Documents\Allison Cairns\2022-2023\Imaging\LC14b\vsweep_02', filename),'png')
        end
    else
        disp('This is not an LC14 or LC14b fly OR you need to hardcode the folder path')
        saveas( gcf,fullfile('C:\Users\Lab_User\Documents\Allison Cairns\2022-2023\Imaging', filename),'png')
    end

    %% Large Subplot
    figure;
    subplot(4,1,1)
    plot(exp_info.newt / 60, exp_info.newEpochVal)
    % % plot(exp_info.time / 60, exp_info.epochVal,'-*')
    xticks([1 2 3 4])
    ylabel('Epoch Index')
    title(['Rec. ', num2str( i_ex ), ' Probe and Stimulus Epoch'])
    set(gca, 'fontsize', 20)
    axis('tight')
    grid on

    subplot(4,1,[2:4])
    imagesc(roi_raw_intensity')
    xticks([509 1016 1524 2032])
    xticklabels({'1','2','3','4'})
    xlabel('t (min)')
    ylabel('ROI')
    title(['Raw Intensity Over Time || ', 'min / max = ', num2str( min(roi_raw_intensity(:))) ' / ' num2str(max(roi_raw_intensity(:)))])
    set(gca, 'fontsize', 20)
    indx.p = [];
    % plot epoch lines + text
    %     figure; hold on
    colors = lines(length(unique(epoch_trace)));
    prev = epoch_trace(1);
    for j = 1:length(epoch_trace)
        idx.p{:,j} = find(epoch_trace == j);

        % stim duration
        % sequential order of idx, try to generalize this code
        if epoch_trace(j) ~= prev
            prev = epoch_trace(j);
            %             stimTiming.tStart =
            color_id = find(unique(epoch_trace) == epoch_trace(j));
            color_j = colors(color_id, :);
            line([j j],[0 size(roi_raw_intensity, 1)], 'LineWidth', 1, 'Color', color_j)
            text(j+5, 17, num2str(epoch_trace(j)), 'Color', color_j, 'FontSize', 8)
        end
    end

    hold off

    filename = sprintf('%sRawROI%s%s%s_%d.png',savetime,stim,cellType,sensor,i_ex);
    % --- If you use a new stim create new save paths ---
 if length(cellType) == length('LC14') % and LC19
        disp(['The save path is C:\Users\Lab_User\Documents\Allison Cairns\2022-2023\Imaging\LC14\'])
        if length(stim) == length('vsweep15_480')
            saveas( gcf,fullfile('C:\Users\Lab_User\Documents\Allison Cairns\2022-2023\Imaging\LC14\vsweep15_480', filename),'png')
        end
        if length(stim) == length('sweepingFullBars_4D_5reps1')
            saveas( gcf,fullfile('C:\Users\Lab_User\Documents\Allison Cairns\2022-2023\Imaging\LC14\sweepingFullBars_4D_5reps1', filename),'png')
        end
        if length(stim) == length('vsweep_02')
            saveas( gcf,fullfile('C:\Users\Lab_User\Documents\Allison Cairns\2022-2023\Imaging\LC14\vsweep_02', filename),'png')
        end
        if length(stim) == length('WaveFlashBarObjectLoom_x20y-20_3rep')
            saveas( gcf,fullfile('C:\Users\Lab_User\Documents\Allison Cairns\2022-2023\Imaging\LC19\WaveFlashBarObjectLoom_x20y-20_3rep', filename),'png')
        end
        if length(stim) == length('probe_TargetProbe_fullBars')
            saveas( gcf,fullfile('C:\Users\Lab_User\Documents\Allison Cairns\2022-2023\Imaging\LC19\WaveFlashBarObjectLoom_x20y-20_3rep', filename),'png')
        end
    elseif length(cellType) == length('LC14b')
        disp(['The save path is C:\Users\Lab_User\Documents\Allison Cairns\2022-2023\Imaging\LC14b\'])
        if length(stim) == length('vsweep15_480')
            saveas( gcf,fullfile('C:\Users\Lab_User\Documents\Allison Cairns\2022-2023\Imaging\LC14b\vsweep15_480', filename),'png')
        end
        if length(stim) == length('sweepingFullBars_4D_5reps1')
            saveas( gcf,fullfile('C:\Users\Lab_User\Documents\Allison Cairns\2022-2023\Imaging\LC14b\sweepingFullBars_4D_5reps1', filename),'png')
        end
        if length(stim) == length('vsweep_02')
            saveas( gcf,fullfile('C:\Users\Lab_User\Documents\Allison Cairns\2022-2023\Imaging\LC14b\vsweep_02', filename),'png')
        end
    else
        disp('This is not an LC14 or LC14b fly OR you need to hardcode the folder path')
        saveas( gcf,fullfile('C:\Users\Lab_User\Documents\Allison Cairns\2022-2023\Imaging', filename),'png')
        
    end

%     %% Movie
%     smooth_movie = movmean(filtered_movie,11,3);
%     figure, clf, hold on, box on;
%     savePathMov = '';
%     vidName = [cellType, sensor, stim, '_', num2str(i_ex)];
%     fullVidName= fullfile(savePathMov,[vidName '.mp4']);
%     vidfile = VideoWriter(fullVidName,'MPEG-4');
%     open(vidfile);
%     plth = imagesc(flipud(smooth_movie(:,:,1)), [10,100]);
%     % set color limits or whatever you want
%     ax=gca;
%     set(gca, 'Xtick', [], 'Ytick', [])
%     xlim([0,size(smooth_movie,2)])
%     ylim([0,size(smooth_movie,1)])
%     xlabel(sprintf('%s || rec. 0%d',stim, i_ex),'Interpreter', "Latex", 'FontSize', 14);
%     title(sprintf('%s < %s',cellType, sensor), 'FontSize', 18);
%     writeVideo(vidfile,getframe(gcf));
%     for i=2:size(smooth_movie,3)
%         % loop through entire simulation
%         set(plth,'CData',flipud(smooth_movie(:,:,i)))
%         %     pause(0.2)
%         writeVideo(vidfile,getframe(gcf));
%     end
%     close(vidfile)
    %%
    %     figure;
    %     subplot(2,1,1)
    %     %     plot(exp_info.newt / 60, exp_info.newEpochVal)
    %     % % plot(exp_info.time / 60, exp_info.epochVal,'-*')
    %     xticks([1 2 3 4])
    %     ylabel('Epoch Index')
    %     title(['Fly ', num2str( param.fly_num ), ' Probe and Stimulus Epoch'])
    %     set(gca, 'fontsize', 20)
    %     axis('tight')
    %     hold on
    %
    %     barPos = 0;
    %     for i = 1:length(epoch_trace)
    %         plot(exp_info.newt / 60, exp_info.newEpochVal) %
    % %         while barPos < length(epoch_trace/1000)
    %             barPos = barPos + length(epoch_trace(i))/1000;
    %
    %             xline(barPos, 'r');
    %
    % %         end
    %          pause(0.0075*6);
    %         cla;
    %     end
    %
    %     xlim([0 length(epoch_trace)])
    %
    %     subplot(2,1,2)
    %     imagesc(roi_raw_intensity')
    %     xticks([509 1016 1524 2032])
    %     xticklabels({,'1','2','3','4'})
    %     xlabel('t (min)')
    %     ylabel('ROI')
    %     title(['Raw Intensity Over Time || ', 'min / max = ', num2str( min(roi_raw_intensity(:))) ' / ' num2str(max(roi_raw_intensity(:)))])
    %     set(gca, 'fontsize', 20)
    %% Epoch Subplots
    color = linspecer(7);

%     savetime = datestr(now, 'mmddyy');

    %
    %     for stim = 'vsweep_02'
    %         epNames = ["RL15" "RL30" "RL60" "RL120" "RL240" "LR15" "LR30" "LR60" "LR120" "LR240"];
    %     end
    %     for stim = 'vsweep15_480'
    %         epNames = ["RL15" "RL30" "RL60" "RL120" "RL240" "RL480" "LR15" "LR30" "LR60" "LR120" "LR240" "LR480"];
    %
    %     end

    figure('units','normalized','outerposition',[0 0 1 1]);
    epNames = ["RL15" "RL30" "RL60" "RL120" "RL240" "RL480" "LR15" "LR30" "LR60" "LR120" "LR240" "LR480"];
    for jj = 1:length(resp)
        for ep = [6:length(epNames)+5]
            %         if     stim == 'vsweep_02'
            %             epNames = epNames([1:5,7:11]);
            %         els
            %             epNames = epNames;
            %         end


            ids = bwlabel( resp{jj,1}.epoch_trace == ep );
            xq = resp{1,1}.time( ids == 1 );
            xq = xq - xq(1);

            vq = zeros(length(xq), size(resp{1,1}.dff,2), max(ids));
            for id = 1 : max(ids)
                x = resp{1,1}.time( ids == id );
                v = resp{1,1}.dff(ids == id,:);
                vq(:,:,id) = interp1(x - x(1),v,xq);
                %vq = vq + (interp1(x - x(1),v,xq) / max(ids));
            end
            std_error = std(vq,0,3)/sqrt(max(ids));

            hold on;
            colors = linspecer(size(resp{1}.dff,2));
            for i_roi = [1:size(resp{1,1}.dff,2)]
                this_mean = mean(vq(:,i_roi,:),3);
                this_sem = std_error(:,i_roi);
                subplot(2,floor((length(epNames)/2)),ep-5)
                hold on
                plot( xq, this_mean , 'Color', colors(i_roi,:))
                patch([xq, fliplr(xq)], [this_mean-this_sem; flipud(this_mean + this_sem)]', colors(i_roi,:),'LineStyle','none', 'FaceAlpha',.1)

            end

            % plot(xq, vq)

            title(['Ep: ', num2str(epNames(ep-5))])
            xlabel('t (s)')
            ylabel('$\Delta$ F/F', 'Interpreter', "Latex")
            sgtitle([cellType, ' < ', sensor, ' || ', 'Fly: ', num2str(i_ex), ' || ', stim], 'Interpreter', "None")

        end

    end

    filename = sprintf('%s_allEp%s%s%s_Fly%d.png',savetime,stim,cellType,sensor,i_ex);
    saveas( gcf,fullfile('C:\','Users\','Lab_User\','Allison Cairns\','2022-2023\','Imaging', cellType,stim,filename),'png')

%     % --- If you use a new stim create new save paths ---
%  if length(cellType) == length('LC14') % and LC19
%         disp(['The save path is C:\Users\Lab_User\Documents\Allison Cairns\2022-2023\Imaging\LC14\'])
%         if length(stim) == length('vsweep15_480')
%             saveas( gcf,fullfile('C:\Users\Lab_User\Documents\Allison Cairns\2022-2023\Imaging\LC14\vsweep15_480', filename),'png')
%         end
%         if length(stim) == length('sweepingFullBars_4D_5reps1')
%             saveas( gcf,fullfile('C:\Users\Lab_User\Documents\Allison Cairns\2022-2023\Imaging\LC14\sweepingFullBars_4D_5reps1', filename),'png')
%         end
%         if length(stim) == length('vsweep_02')
%             saveas( gcf,fullfile('C:\Users\Lab_User\Documents\Allison Cairns\2022-2023\Imaging\LC14\vsweep_02', filename),'png')
%         end
%         if length(stim) == length('WaveFlashBarObjectLoom_x20y-20_3rep')
%             saveas( gcf,fullfile('C:\Users\Lab_User\Documents\Allison Cairns\2022-2023\Imaging\LC19\WaveFlashBarObjectLoom_x20y-20_3rep', filename),'png')
%         end
%         if length(stim) == length('probe_TargetProbe_fullBars')
%             saveas( gcf,fullfile('C:\Users\Lab_User\Documents\Allison Cairns\2022-2023\Imaging\LC19\WaveFlashBarObjectLoom_x20y-20_3rep', filename),'png')
%         end
%     elseif length(cellType) == length('LC14b')
%         disp(['The save path is C:\Users\Lab_User\Documents\Allison Cairns\2022-2023\Imaging\LC14b\'])
%         if length(stim) == length('vsweep15_480')
%             saveas( gcf,fullfile('C:\Users\Lab_User\Documents\Allison Cairns\2022-2023\Imaging\LC14b\vsweep15_480', filename),'png')
%         end
%         if length(stim) == length('sweepingFullBars_4D_5reps1')
%             saveas( gcf,fullfile('C:\Users\Lab_User\Documents\Allison Cairns\2022-2023\Imaging\LC14b\sweepingFullBars_4D_5reps1', filename),'png')
%         end
%         if length(stim) == length('vsweep_02')
%             saveas( gcf,fullfile('C:\Users\Lab_User\Documents\Allison Cairns\2022-2023\Imaging\LC14b\vsweep_02', filename),'png')
%         end
%     else
%         disp('This is not an LC14 or LC14b fly OR you need to hardcode the folder path')
%         saveas( gcf,fullfile('C:\Users\Lab_User\Documents\Allison Cairns\2022-2023\Imaging', filename),'png')
%         
%     end
end
close all;