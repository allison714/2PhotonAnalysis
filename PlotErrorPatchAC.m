function g = PlotErrorPatchAC(x, y, e, colors, LineWidth, varargin)
    if nargin < 5
        LineWidth = 1.5;  % Default LineWidth
    end

    % Check if the 'plotLine' flag is provided in varargin
    plotLine = true;  % Default to plotting the line
    for ii = 1:2:length(varargin)
        if strcmp(varargin{ii}, 'plotLine')
            plotLine = varargin{ii+1};
        end
    end

    if size(e, 3) == 1
        yErrorTop = y + e;
        yErrorBottom = y - e;
    else
        yErrorBottom = y - e(:, :, 1);
        yErrorTop = y + e(:, :, 2);
    end

    numPointsToPlotErrorBars = 0;

    % Make the bottom run the opposite direction to plot around the eventual
    % shape of the error patch clockwise
    yErrorBottom = yErrorBottom(end:-1:1, :);
    ye = [yErrorTop; yErrorBottom];

    % Similarly run the x back
    xe = [x; x(end:-1:1, :)];
    xe = repmat(xe, [1, size(ye, 2) / size(xe, 2)]);
    x = repmat(x, [1, size(y, 2) / size(x, 2)]);

    xe(isnan(ye)) = [];
    ye(isnan(ye)) = [];

    hStat = ishold;

    hold on;
    for colIdx = 1:size(y, 2)
        color = colors(colIdx, :);  % Get color for this column
        if ~all(e(:, colIdx) == 0)
            alpha = 0.25 / size(y, 2);  % Divide by the number of epochs
h = fill(xe, ye(:, colIdx), color, 'EdgeColor', 'none', 'FaceAlpha', alpha);
            % h = fill(xe, ye(:, colIdx), color, 'EdgeColor', 'none', 'FaceAlpha', 0.025);  % Set EdgeColor to 'none'
            hAnnotation = get(h, 'Annotation');

            if ~iscell(hAnnotation)
                hAnnotation = {hAnnotation};
            end

            for ii = 1:length(h)
                hLegendEntry = get(hAnnotation{ii}, 'LegendInformation');
                set(hLegendEntry, 'IconDisplayStyle', 'off');
            end
        end
    end

    if plotLine
        if size(x, 1) < numPointsToPlotErrorBars
            if size(e, 3) == 1
                g = errorbar(x, y, e, 'marker', 'o');
            else
                g = errorbar(x, y, e(:, :, 1), e(:, :, 2), 'marker', 'o');
            end
        else
            % g = plot(x, y, 'LineWidth', LineWidth);
            disp(' ')
        end
    end

    if hStat
        hold on;
    end
    if ~hStat
        hold off;
    end
end