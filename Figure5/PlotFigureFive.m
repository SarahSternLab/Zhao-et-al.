% PLOT FIGURE 5
function PlotFigureFive()
    clc
    
    % Load all data structs
    data = loadAllData('./DataForFigureFive');

    % Create maximized figure
    figure('WindowState','maximized');

    % Define subplot positions and cluster orders
    hungerFeedPos    = [1, 3, 2, 4];
    hungerLickPos    = [7, 8, 6, 5];
    clusters         = 1:4;
    timeVector       = -5:0.1:20;
    bgColor          = [0.8 0.8 0.8];
    thirstColor      = [1 0.7 0.7];
    hungerColor      = 'k';

    % Plot hunger-feed vs thirst-feed
    Thirst_Feed_Cluster = cell(numel(clusters),1); % registered
    for i = clusters
        subplot(2,4,hungerFeedPos(i))
        Thirst_Feed_Cluster{i} = plotClusterComparison( ...
            data.hungerFeed.dat_clusters{i}, ...
            data.thirstFeed.dat_tracemean, ...
            data.hungerFeed.C, ...
            i, timeVector, ...
            hungerColor, bgColor, thirstColor, ...
            sprintf('hunger feed cluster%d', i), ...
            sprintf('thirst feed same cells') ...
        );
    end

    % Plot hunger-lick vs thirst-lick
    Thirst_Lick_Cluster = cell(numel(clusters),1); % registered
    for i = clusters
        subplot(2,4,hungerLickPos(i))
        Thirst_Lick_Cluster{i} = plotClusterComparison( ...
            data.hungerLick.dat_clusters{i}, ...
            data.thirstLick.dat_tracemean, ...
            data.hungerLick.C, ...
            i, timeVector, ...
            hungerColor, bgColor, thirstColor, ...
            sprintf('hunger lick cluster%d', i), ...
            sprintf('thirst lick same cells') ...
        );
    end

    plot_clusters(data.hungerFeed, Thirst_Feed_Cluster, data.hungerLick, Thirst_Lick_Cluster )
end

%----------------------------------------------------------------------
function data = loadAllData(basePath)
    % load all .mat into a struct
    data.hungerFeed = load(fullfile(basePath, 'dat_hunger_feed_clusters.mat'));
    data.hungerLick = load(fullfile(basePath, 'dat_hunger_lick_clusters.mat'));
    data.thirstFeed = load(fullfile(basePath, 'dat_thirst_feed_clusters.mat'));
    data.thirstLick = load(fullfile(basePath, 'dat_thirst_lick_clusters.mat'));
end

%----------------------------------------------------------------------
function plot_clusters(dat_hunger_feed_clusters, Thirst_Feed_Cluster, dat_hunger_lick_clusters, Thirst_Lick_Cluster )
    % Re-tile clustered data .-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-
    tile    = @(C,seq) C(seq);          % helper: re-order a cell array by seq
    
    % define your cluster sequences
    seqFeed    = [4 2 3 1];
    seqLick    = [2 1 3 4];
    
    % apply with one-liners
    dat_hunger_feed_clusters_tile   = tile(dat_hunger_feed_clusters.dat_clusters, seqFeed);
    dat_thirst_feed_clusters_tile   = tile(Thirst_Feed_Cluster,                   seqFeed);
    dat_hunger_lick_clusters_tile   = tile(dat_hunger_lick_clusters.dat_clusters, seqLick);
    dat_thirst_lick_clusters_tile   = tile(Thirst_Lick_Cluster,                   seqLick);
    
    dat_clusters_all = {dat_hunger_feed_clusters_tile, dat_thirst_feed_clusters_tile, ...
                        dat_hunger_lick_clusters_tile, dat_thirst_lick_clusters_tile};

    titlestrings = ["hunger feed", "thirst feed", "hunger lick",  "thirst lick"];
    PlotClusterMap(dat_clusters_all, titlestrings)

end

%----------------------------------------------------------------------
function PlotClusterMap(dat_clusters_all, titlestrings, time)
    % PlotClusterMap: display cluster heatmaps in aligned columns.
    %
    % INPUTS:
    %   dat_clusters_all: cell array {nCols x 1}, each cell contains {nRows x 1} matrices
    %   titlestrings: cell array of strings, one per column
    %   time: (optional) time vector for x-axis; default is -5:0.1:20

    % --- Input defaults and validation ---
    if nargin < 3
        time = -5:0.1:20;
    end

    nCols = numel(dat_clusters_all);
    nRows = numel(dat_clusters_all{1});
    
    if numel(titlestrings) ~= nCols
        error('titlestrings must match number of columns in dat_clusters_all.');
    end

    % --- Layout Parameters ---
    gap_x = 0.05;          % Horizontal gap between columns
    gap_y = 0.002;         % Vertical gap between rows within column
    side_margin = gap_x;   % Left/right margin
    top_margin = 0.03;     % Margin from top of figure
    usable_height = 0.9;   % Total vertical space used for content
    usable_width = 1 - (nCols - 1) * gap_x - 2 * side_margin;
    col_width = usable_width / nCols;

    figure('Units', 'normalized');

    for col = 1:nCols
        left = side_margin + (col - 1) * (col_width + gap_x);

        % Compute relative height per cluster in column
        Ysizes = cellfun(@(m) size(m, 1), dat_clusters_all{col});
        Yratios = Ysizes / sum(Ysizes);
        row_heights = (usable_height - gap_y * (nRows - 1)) * Yratios;

        curr_bottom = 1 - top_margin;

        for row = 1:nRows
            h = row_heights(row);
            curr_bottom = curr_bottom - h;

            % Create axis
            ax_pos = [left, curr_bottom, col_width, h];
            axes('Position', ax_pos, 'Color', 'none');
            dat = dat_clusters_all{col}{row};
            imagesc(time, 1:size(dat, 1), dat);
            clim([-4 4]);
            ylabel(sprintf('cluster %d', row), 'FontWeight', 'bold');

            if row == 1
                title(titlestrings{col}, 'Interpreter', 'none');
            end
            if row < nRows
                set(gca, 'XTick', []);
                % Draw black separator rectangle between rows
                separator_pos = [ax_pos(1), curr_bottom - gap_y, ax_pos(3), gap_y];
                annotation('rectangle', separator_pos, ...
                           'FaceColor', 'k', 'LineStyle', 'none');
            else
                set(gca, 'XTick', []);
            end

            curr_bottom = curr_bottom - gap_y;
        end
    end
end

%----------------------------------------------------------------------
function thirstTraces = plotClusterComparison(hungerTraces, thirstTracemean, hungerC, ...
                               clusterID, timeVector, ...
                               colorHunger, bgColor, colorThirst, ...
                               legendHunger, legendThirst)
    % Plot hunger cluster
    PlotTrace(timeVector, hungerTraces, colorHunger, bgColor); hold on;
    % Extract same-cells thirst traces
    idx = (hungerC == clusterID);
    thirstTraces = thirstTracemean(:, idx)';
    % Plot thirst traces
    PlotTrace(timeVector, thirstTraces, 'r', colorThirst); hold on;

    % Statistical test
    [~, p] = kstest2(mean(hungerTraces), mean(thirstTraces));
    % Legend and p-value annotation
    legend(legendHunger, legendThirst);
    drawnow;
    xLimits = xlim();
    yLimits = ylim();
    xText = xLimits(2) - 0.05 * range(xLimits);
    yText = yLimits(1) + 0.05 * range(yLimits);
    text(xText, yText, sprintf('P = %s', num2str(p)), 'HorizontalAlignment', 'right');
    hold off;
end

%--------------------------------------------------------------------------
function PlotTrace(timeVector, TraceName, Color, Fill_Color)
    Trace_Mean = mean(TraceName);
    Std = std (TraceName);
    Trace_Num =  size (TraceName,1);
    Sem = Std/sqrt(Trace_Num);
    Trace_Upper = Trace_Mean + Sem;
    Trace_Lower = Trace_Mean - Sem;
    Trace_Lower_Flip = fliplr(Trace_Lower);
    
    timeVector_flip = fliplr(timeVector);
    plot (timeVector, Trace_Upper,Color); hold on;
    plot (timeVector, Trace_Lower',Color);
    fill([timeVector, timeVector_flip], [Trace_Upper Trace_Lower_Flip],Fill_Color);
    plot( timeVector, mean(TraceName), Color);hold off;
    
    xlabel('\fontsize{10}Time (Seconds)');
    ylabel('\fontsize{10}Z-score');
end
