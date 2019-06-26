%% Sketchpad for assessing neuropil contamination, etc... 

CV_dFF = squeeze(sqrt(var(corrDFF,0)) ./ mean(corrDFF));

figure;
negDFF = sum(corrDFF(:,:,5) < 0);
plot(negDFF);

figure;
plot(CV_dFF(:,3));
min_CV = min(CV_dFF,[],2);
max_CV = squeeze(find(max(CV_dFF,[],2)));


figure;
plot(S.neuropilf{2}(6500:7000)); hold on
plot(500*corrDFF(6500:7000,1,2));

%%
figure; imagesc(roiData.masks.exclude);