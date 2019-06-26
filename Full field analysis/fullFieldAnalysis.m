%Get full-field trial-averaged dFF and difference stacks

clearvars;
learning_setPathList;
[dirs,expData] = expData_learning_spontAct(data_dir);

%example file with spontaneous activity: 
% expData(i).sub_dir = '180428 M53 Post-Discrim60'; 
% expData(i).logfile = 'M53-image_SPONTANEOUS.log';
% expData(i).reg_tif = 'green_NRMC_180428 M53 Discrim60 _trials_1-20.tif';
i=1;

f_mat = loadtiffseq(fullfile(dirs.data,expData.sub_dir,'registered'), expData.reg_tif);
stackInfo = load(fullfile(dirs.data,expData.sub_dir,'stitched','stackinfo.mat'));

% parse NBS Presentation log file
[ logData ] = parseLogfile(fullfile(dirs.data,expData(i).sub_dir), expData(i).logfile );

% break the parsed data into trials
[ sessionData ] = spont_getSessionData( logData ); 

%
nFrames = 100; %for development
[dFF_mat,baseline,t] = getFullfieldDFF(f_mat(:,:,1:nFrames),stackInfo,sessionData.imgTrigTimes);

%% Save processed data
% Write to tif
tic;
img_info = imfinfo(fullfile(dirs.data,expData.sub_dir,'registered',expData.reg_tif)); %copy from raw green tif
    save_path = fullfile(dirs.data,expData.sub_dir,'registered',['dFF_' expData.reg_tif]);
    saveTiff(dFF_mat,img_info,save_path);
toc;

% Save to .mat file
save(fullfile(dirs.data,expData.sub_dir,'registered','fullFieldAnalysis'),'dFF_mat'); %save parameters


%% Plots
map = [linspace(0,1,128), ones(1,128);...
       linspace(0,1,128), linspace(1,0,128);...
       ones(1,128), linspace(1,0,128)]'; %256 color: b (-inf) : w(0) : r(inf)
clims = [-1 3];

%Get frames

figure;
imagesc(median(dFF_mat,3),clims);
colormap(map);
colorbar;
