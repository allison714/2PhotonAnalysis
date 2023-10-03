%% Export Imaging Analysis Workspace
% A. Cairns || 08.08.2023
% Based on GS's BaseTemplateAnalysis.m
% Modified for Dialog Box and Exporting Workspace
% I. Dialog Box II. Data Analysis
% III. Run Analysis IV. Save/ Export Workspace
clc; clearvars; clear all;
%% I. Dialog Box
promptAns = iAParametersDB();
% Dialog Box Output Paramete
flyEye = ''; % Usually left blank
cellType= promptAns{1,1};
sensor = promptAns{2,1};
surgeon = promptAns{3,1};
stim = promptAns{4,1};
% param.interleave_epochs = promptAns{5,1};
flies = str2num(promptAns{5,1});
% Paths from Database/ Save Time
dataPath = GetPathsFromDatabase(cellType,stim,sensor,flyEye,surgeon);
savetime = datestr(now, 'mmddyy');
%% II. Data Analysis
param.stim = stim; % don't change this line
param.movieChan = 1; % channel
param.probe_epochs = 'do it for me';
param.analyze_these = flies;
resp = cell( length(param.analyze_these), 1 );
% a. ROI selection
param.corr_thresh = 10^-100; % correlation threshold [0.2]
param.probe_correlation = true;
param.probe_correlation_type = 'probe indices'; % gets ROI corr. from the 1st and 2nd probes
param.mean_amplification_thresh = 10^75; % gets rid of ROIs with bad F0 fits when computing delta F over F
% b. What code will compute
param.force_alignment = false;
param.force_roi_selection = true;
if length(promptAns{6,1}) == length('false')
    param.manual_roi = 'false';
    param.manual_roi_name = 'NoThreshold';
else
    param.manual_roi = 'true';
    param.manual_roi_name = 'ManualROI';
end
param.group_method = 'none';
param.frac_interleave = 0.4; % fraction used for computing F0 for DF/F ** why does psy5 use 0.4?
%% III. Run Analysis
for i_ex = param.analyze_these
    % a. Load in experimental parameters and raw movie
    [exp_info, raw_movie, param] = get_exp_details( dataPath{i_ex}, param);
    param.fly_num = find(i_ex == param.analyze_these);
    epoch_trace = exp_info.epochVal; % new
    param.interleave_epochs = mode(epoch_trace); % new
    % aa. Change to speed things up
    fileName = [cellType, sensor, stim, '_', num2str(i_ex), '.mat'];
    savePath = ['C:\Users\Lab_User\Documents\Allison Cairns\2022-2023\Imaging\Workspace\',param.manual_roi_name];
    savePath2 = ['G:\My Drive\The Clark Lab\Workspaces\',param.manual_roi_name];
    foldfile = fullfile(savePath2,fileName);
    if exist(foldfile, 'file') == 0
        % b. Register the relaxed mean image with each frame for alignment info
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
            for i_t = 1 : n_t % iterate through time
                aligned_movie(:,:,i_t) = raw_movie(good_rows - dy_filt(i_t) , good_cols + dx_filt(i_t) , i_t);
            end
        else % do the alignment
            neuron_hist_thresh = 0.95;
            init_tissue_prob = linear_tissue_prob_HighNeuronThresh(mean(raw_movie,3), neuron_hist_thresh);
            % init_tissue_prob = linear_tissue_prob(mean(raw_movie,3)); % try this if not many pixels are responding
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
        % c. Subtract the background from 'aligned_movie'
        filtered_movie = zeros(size(aligned_movie)); % initiliaze
        % define background as below median, temporal mean intensity of the 0 pixels in
        mean_movie = mean(aligned_movie, 3); % tissue_mask. recalculate mean movie on the aligned movie
        bkg_mask = (mean_movie < median(mean_movie(~tissue_mask))) & ~tissue_mask;
        for i = 1 : n_t % loop through time
            this_frame = aligned_movie(:,:,i);
            filtered_movie(:,:,i) = aligned_movie(:,:,i) - mean(this_frame(bkg_mask));
        end
        mean_movie = mean(filtered_movie, 3); % recalculate mean movie on the fully filtered movie
        disp('Finished Processing Raw Movie')
        % d. Compute correlation image from filtered movie
        corr_img = neighboring_pixel_correlation( filtered_movie );
        disp('Finished Calculating Correlation Image')
        % e. Get ROIs from correlation image
        roi_mask_file = fullfile(storage_folder, 'roi_masks.mat');
        if ~param.force_roi_selection && isfile( roi_mask_file )
            load( roi_mask_file )
        else
            if length(param.manual_roi) ~= length('false')
                % manually define the ROIs
                roi_extract = draw_rois(mean_movie);
            else
                % try to programmatically define the ROIs
                roi_extract = WatershedImage(corr_img); % psycho5 fxn that uses watershed, then tries to fill in the borders
            end
            probe_idxs = get_probe_idxs(exp_info.epochVal, param);
            % -- Original Code has more info here --
            roi_select = roi_extract;
            save(roi_mask_file, 'roi_extract', 'roi_select');
        end
        roi_raw_intensity = zeros( n_t, max(roi_select,[],'all') );
        % compute mean intensity temporal trace of each ROI
        for i_roi = 1 : max(roi_select,[],'all') % loop through each ROI
            num_pixels = sum(roi_select == i_roi, 'all'); % size of ROI
            % intensity of this ROI over time
            roi_raw_intensity(:,i_roi) = (sum(sum((roi_select == i_roi) .* filtered_movie, 1), 2)) ./ (num_pixels);
        end
        % --- epoch_trace = exp_info.epochVal; % rename this to make it easier to remember
        % --- param.interleave_epochs = mode(epoch_trace); % -------------- ?
        resp{param.fly_num}.epoch_trace = epoch_trace;
        epoch_change = find( diff( epoch_trace( probe_idxs{1} ) ) );
        % f. Get the response of each ROI over time
        % roi_dff_method = 'mean_resp'; % sets F0 to the mean interleave response
        roi_dff_method = 'exponential'; % fits exponential to each ROI
        [roi_dff, roi_final, mean_inter] = roi_dff_calc( param, exp_info, roi_select, filtered_movie, roi_dff_method);
        num_rois = max(roi_final,[],'all');
        % epoch_trace = exp_info.epochVal; % rename this to make it easier to remember
        disp('Finished Calculating ROIs')
        % g. Save important output to resp cell array
        resp{param.fly_num}.dff = roi_dff; % delta F over F for each "good" ROI
        resp{param.fly_num}.epoch_trace = epoch_trace; % epochs presented over time
        resp{param.fly_num}.roi_final = roi_final; % final ROI mask
        resp{param.fly_num}.time = exp_info.time; % time in seconds each frame was grabbed
        %% IV. Save/ Export Workspace
        save(fullfile(savePath, fileName)); disp('Workspace saved');
        save(fullfile(savePath2, fileName)); disp('Workspace saved to G:/');
        clc; % This clears within the loop but not outside
        disp([cellType, ' > ', sensor, ' ', stim]) % new 08.17.23
        disp(['Finished Processing Rec. ', num2str(i_ex), ' / ', num2str(length(param.analyze_these)) ]);

    else
    %     disp(['Workspace ', num2str(i_ex), ' exists. If this is a manual ROI remove previous file from path.'])
    end
clc;
disp(['Workspace ', num2str(i_ex), ' exists. If this is a manual ROI remove previous file from path.'])
end
msgbox(['Workspace [1:', num2str(i_ex), '] completed. If this is a manual ROI remove previous file from path.'], 'Operation Complete', 'modal');
   