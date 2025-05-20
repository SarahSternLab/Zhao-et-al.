% clc
% Load the dataset
load('DataFigure7.mat')

% Plot temporal PCA for each condition
figure;
plotPcaOverTime(dat_hunger_DPBS_feed,   1, 'HungerDPBS Feed');
plotPcaOverTime(dat_hunger_DPBS_lick,   2, 'HungerDPBS Lick');
plotPcaOverTime(dat_hunger_Leptin_feed, 3, 'HungerLeptin Feed');
plotPcaOverTime(dat_hunger_Leptin_lick, 4, 'HungerLeptin Lick');

% Compare PCA spaces between groups
comparePcaSpaces(dat_hunger_DPBS_feed,   dat_hunger_Leptin_feed, 'DPBS Feed vs. Leptin Feed');
comparePcaSpaces(dat_hunger_DPBS_lick,   dat_hunger_Leptin_lick, 'DPBS Lick vs. Leptin Lick');
comparePcaSpaces(dat_hunger_DPBS_feed,   dat_hunger_DPBS_lick,   'DPBS Feed vs. DPBS Lick');
comparePcaSpaces(dat_hunger_Leptin_feed, dat_hunger_Leptin_lick, 'Leptin Feed vs. Leptin Lick');

% =========================================================================
function plotPcaOverTime(dataMatrix, subplotIndex, taskLabel)
% plotPcaOverTime - Plots PCA trajectory over time in 3D
%
% Inputs:
%   dataMatrix
%   subplotIndex - Position in 2x2 subplot grid
%   taskLabel    - Title and console label

    % Create time vector matching number of timepoints
    numTimepoints = size(dataMatrix, 1);
    t = linspace(-5, 20, numTimepoints);

    % Compute PCA
    [coeff, ~, ~, ~, explained] = pca(dataMatrix');

    % Print explained variance
    fprintf('%s: ', taskLabel);
    for i = 1:3
        fprintf('PC%d %.2f%% ', i, explained(i));
    end
    fprintf('| Total: %.2f%%\n', sum(explained(1:3)));

    % Plotting
    subplot(2, 2, subplotIndex);
    plot3(coeff(:,1), coeff(:,2), coeff(:,3), 'Color', [0.2 0.2 0.2]); hold on;
    scatter3(coeff(:,1), coeff(:,2), coeff(:,3), 20, t, 'filled');
    title(taskLabel);
    xlabel('PC1'); ylabel('PC2'); zlabel('PC3');
    colormap jet;
    grid on; axis tight;
end

% -------------------------------------------------------------------------
function comparePcaSpaces(dataA, dataB, label)
% comparePcaSpaces - Compare PCA subspaces of two datasets
%
% Inputs:
%   dataA, dataB
%   label        - Description of the comparison

    % PCA for both datasets
    [coeffA, ~] = pca(dataA');
    [coeffB, ~] = pca(dataB');

    % Compute Procrustes alignment distance and subspace angle
    procrustesDistance = procrustes(coeffA(:,1:3), coeffB(:,1:3));
    angleBetween = subspace(coeffA(:,1:3), coeffB(:,1:3));

    % Output results
    fprintf('%s\tProcrustes Distance: %.4f\tSubspace Angle: %.4f\n', ...
            label, procrustesDistance, angleBetween);
end
