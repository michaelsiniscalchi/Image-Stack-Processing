% Purpose: To delete redundant/extraneous Tiff stacks from data directory. 
% Author: MJ Siniscalchi

%%
clearvars;
warning('on');
filter = '*M*'; %use to select for specific data directories
root_dir = uigetdir('C:\Users\Michael\Documents\Data & Analysis\Processing Pipeline\'); %batch dir containing data dirs
data_dirs = dir(fullfile(root_dir,filter));
data_dirs = data_dirs(cell2mat({data_dirs.isdir}));

%AFTER COPYING PROCESSED DATA TO NETWORK DRIVE
%Data to DELETE (be careful!)
del.rawDir          = true; %Delete DIR: 'raw'
del.redDir          = false; %Delete DIR: 'stitched_redChan'
del.mocoDir         = false; %Delete DIR: 'moco_R2G'

del.stitchedFile    = false; %Delete FILE: '<data_dir>/stitched/<stitchedRaw>.tif'
del.regFile         = false; %Delete FILE: '<data_dir>/registered/green_NRMC*.tif
del.regRedFile      = false; %Delete FILE: '<data_dir>/registered/red_NRMC*.tif

dlgTitle    = 'BATCH DELETE';
dlgQuestion = ['Permanently delete indicated files or directories in ' root_dir '?'];
choice = questdlg(dlgQuestion,dlgTitle,'Yes','No', 'Yes');

if strcmp(choice,'Yes')

    for i = 1:numel(data_dirs)
        data_main = fullfile(root_dir,data_dirs(i).name);
        dir_list = dir(data_main);
        cd(data_main);
        
        for j=1:numel(dir_list)
            if strcmp(dir_list(j).name,'raw') && del.rawDir
                rmdir('raw','s');
            elseif strcmp(dir_list(j).name,'stitched') && del.stitchedFile
                cd(fullfile(data_main,'stitched'));
                delete *.tif; %keep stackinfo.mat
                cd(data_main);
            elseif strcmp(dir_list(j).name,'stitched_redChan') && del.redDir
                rmdir('stitched_redChan','s');
            elseif strcmp(dir_list(j).name,'moco_R2G') && del.mocoDir
                movefile(fullfile(data_main,'moco_R2G','ref_img.tif'),data.main); %move ref_img to main data dir
                rmdir('moco_R2G','s');
            elseif strcmp(dir_list(j).name,'registered') && del.regFile
                cd(fullfile(data_main,'registered'));
                %>>>exclude z-projections<<<
                %>>>write code to delete red_reg independently<<<
                delete *.tif; %keep ROIs and RegData
                cd(data_main);
            end
        end
    end
end