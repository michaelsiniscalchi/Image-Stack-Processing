%%% truncateIMGData
%
%Purpose: To truncate calcium imaging data as needed, including:
%           -Registered stack (for ROI selection)
%           -Data from stackinfo.mat file
%           -ROI files
%
%Author: MJ Siniscalchi (Kwan Lab, Yale) 
%Last Edit: 180122

clearvars;

%Edit directory names
reg_dir = 'registered';
copy_dir = 'stitched[pre-truncation]';

%User input
%last_trial = find(cumsum(num_frames)>12000, 1, 'first'); 
%last_frame = sum(num_frames(1:last_trial));
last_frame = input('Truncate to frame number:'); %set last frame manually
truncate_ROIs = input('Truncate ROIs? [input logical]'); 

%Get data directory and load stackinfo.mat
[FileName,PathName,~] = uigetfile('C:\Users\Michael\Documents\Data & Analysis\','Load Stack Info File');
data_dir = fullfile(PathName,'../'); %(parent dir to stitched)

%Get ROI directory (if needed)
if truncate_ROIs
    roi_path = uigetdir(fullfile(data_dir,reg_dir),'Select ROI Directory For Truncation');
end

%% Truncate Data in Stack Info File

%Copy original stackinfo.mat
cd(data_dir);
mkdir(copy_dir);
copyfile(fullfile(PathName,FileName),fullfile(data_dir,copy_dir,FileName));

%Modify stackinfo file
s = load(fullfile(PathName,FileName)); %load stackinfo.mat
last_trial = find(cumsum(s.num_frames)<last_frame,1,'last'); %find last trial

fieldNames = {'stacks','trigTime','trigDelay','num_frames'};
for i = 1:numel(fieldNames)
    s.(fieldNames{i}) = s.(fieldNames{i})(1:last_trial);
end
char_idx = regexp(s.savFile_name{:},'_');
s.savFile_name{:} = [s.savFile_name{:}(1:char_idx(end)) '1-' num2str(last_trial) '.tif'];

%% Truncate Image Stack for selecting ROIs/generating timeseries
try
reg_fname = uigetfile(fullfile(data_dir,reg_dir,'*.*'),'Load Registered Stack For Truncation'); %fname for registered green tif
catch err %uigetfile does not need to open tif
    disp(err);
end
reg_path = fullfile(data_dir,reg_dir); %full path to registered green tif

%Copy registered stack
copyfile(fullfile(reg_path,reg_fname),fullfile(data_dir,copy_dir,reg_fname));

%Modify registered *.tif file
img_info = imfinfo(fullfile(reg_path,reg_fname)); %copy from registered green tif
reg_stack = loadtiffseq(reg_path,reg_fname); %load into struct

char_idx = regexp(reg_fname,'_'); %new filename...
save_name = [reg_fname(1:char_idx(end)) '1-' num2str(last_trial) '.tif'];

saveTiff(reg_stack(:,:,1:last_frame),...
    img_info(1:last_frame),...
    fullfile(data_dir,reg_dir,save_name)); %save truncated stack

delete(fullfile(reg_path,reg_fname)); %delete original

%% Truncate ROIs (if ROI folder exists)
if truncate_ROIs
    %Make a copy of original ROI dir
    [~,roi_dir,ext] = fileparts(roi_path); %get dir name
    copyfile(roi_path,fullfile(data_dir,copy_dir,[roi_dir ext])); %copy original dir to copy_dir
    
    %Truncate ROIs
    roi_files = dir(fullfile(roi_path,'*.mat'));
    for i = 1:length(roi_files)
        %Modify
        roi_i = fullfile(roi_path,roi_files(i).name); %path to each ROI file
        s = load(roi_i);
        s.cellf = s.cellf(1:last_frame); %truncate fluorescence timeseries
        save(roi_i,'-struct','s');
        
        %Rename ROI file
        char_idx = regexp(roi_i,'_'); %modify trial#s in fname e.g., 'green_NRMC_171103 M51 RuleSwitching _trials_1-782_cell001.mat'
        save_path = [roi_i(1:char_idx(end-1)),... %new filename...
            '1-' num2str(last_trial),... %new trial range
            roi_i(char_idx(end):end)]; %resume old fname from last '_'
        movefile(roi_i,save_path); %rename
        clearvars char_idx;
    end
       
    %Rename ROI directory
    char_idx = regexp(roi_path,'_'); %new filename...
    movefile(roi_path,[roi_path(1:char_idx(end)) '1-' num2str(last_trial) '.tif\']);
    
end