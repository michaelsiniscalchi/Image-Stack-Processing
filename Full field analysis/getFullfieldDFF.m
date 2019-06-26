function [ dFF_mat, t ] = getFullfieldDFF( f_mat, stackInfo, logfileTimes )
%%% getFullfieldDFF
%PURPOSE:   Calculate pixel-by-pixel dF/F from raw, movement-corrected fluorescence stack
%AUTHORS:   MJ Siniscalchi, 180503
%
%INPUT ARGUMENTS
%   f_mat:          An X x Y x t matrix derived from fluorescence imagaing stack
%   stackInfo:      Structure loaded from stackInfo.mat file for this imaging session
%   logfileTimes:   The time at which Presentation sends TTL pulse to ScanImage
%                   to trigger a new .tiff file
%   timeLastEvent:  the time of the last event logged by Presentation
%
%OUTPUTS
%   dFF_mat:        an X x Y x t matrix of per-pixel dF/F
%
%EDITS


%% CALCULATE dF/F

%dF/F = (F(t)-Fo)/Fo
%to estimate Fo (baseline fluorescence), set moving window for smoothing

win = 10*60*stackInfo.frameRate;  %window duration = 10 minutes

disp(['Calculating dF/F (may take several minutes)...']);

f = f_mat;
baseline = zeros(size(f),class(f_mat));

for j = 1:length(f)
    idx1 = max(1,round(j-win/2));
    idx2 = min(length(f),round(j+win/2));
    baseline(:,:,j) = prctile(f(:,:,idx1:idx2),10,3); %10th percentile of F(t) for each pixel
end

dFF_mat = (f-baseline)./ baseline;

%% CREATE TIME VECTOR FOR ALIGNMENT WITH BEHAVIORAL/PHYSIOLOGICAL DATA


for i = 1:numel(stackInfo.num_frames)   %for each .tiff
    trialFrameTimes{i} = [0:dt:dt*(nFrames(i)-1)];
end

trialTimes = logfileTimes' - stackInfo.trigDelay;
for i = 1:numel(trialTimes)
    frameTimes{i} = trialTimes(i)+trialFrameTimes{i};
end
t = [frameTimes{:}]'; %Column vector

end