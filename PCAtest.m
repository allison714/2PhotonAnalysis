EPxROI = info.analysis{1,1}.indFly{1,flyfly}.p6_averagedTrials.snipMat;
ROIxEP = transpose(EPxROI)
dataMatrix = cell2mat(EPxROI)
normalizedData = zscore(dataMatrix)
[coeff, score, latent, ~, explained] = pca(normalizedData)
%%
cumulativeExplained = cumsum(explained);
plot(cumulativeExplained, '-o');
xlabel('Number of Principal Components');
ylabel('Cumulative Explained Variance (%)');


%%
numComponentsToKeep = 3; % Adjust based on your analysis
dataInPCSpace = normalizedData * coeff(:, 1:numComponentsToKeep);