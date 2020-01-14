% Batch process 2-channel imaging stacks: stitch, red-to-green rigid correct (moco), then correct non-rigid artifacts

% Next edit: use MATLAB to kick files to next directory in processing pipeline for each step.

clearvars;
root_dir = uigetdir('C:\Users\Michael\Documents\Data & Analysis\Processing Pipeline', 'Choose Data Directory');
%root_dir = 'C:\Users\Michael\Documents\Data & Analysis\Processing Pipeline\1 Stitch';
cd(root_dir);
dataDir_list = dir('*M*'); %Edit to specify directories

for i = 1:numel(dataDir_list)
    data_dir = fullfile(root_dir, dataDir_list(i).name);
      
    StitchTiffs_greenChan(data_dir);
    clearvars -except i root_dir data_dir dataDir_list
    
    try 
        StitchTiffs_redChan(data_dir);
    catch err
        warning('Red channel could not be stitched, or does not exist. Check original stack...');
    end
    clearvars -except i root_dir dataDir_list
end
