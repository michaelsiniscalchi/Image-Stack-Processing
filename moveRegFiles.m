
clearvars;
%**First, make data directory the current dir**

%Move all except the registered tiffs
dir_list = dir('*M*');
for i=1:numel(dir_list)
    
    reg_dir = fullfile(dir_list(i).folder,dir_list(i).name,'registered');
    
    %Move MAT files (eg regInfo.mat)
    flist = dir(fullfile(reg_dir,'*.mat'));
    for j=1:numel(flist)
        movefile(fullfile(reg_dir,flist(j).name),...
            fullfile(dir_list(i).folder,dir_list(i).name)); %move TIF to main data dir
    end
    
    flist = dir(fullfile(reg_dir,'*.tif'));
    for j=1:numel(flist)
        if ~isempty(strfind(flist(j).name,'DS')) || isempty(strfind(flist(j).name,'NRMC'))
            status(i) = movefile(fullfile(reg_dir,flist(j).name),...
                fullfile(dir_list(i).folder,dir_list(i).name)); %move TIF to main data dir
        elseif isfolder(flist(j).name) %Any stray ROI dirs
            status_roi(i) = movefile(fullfile(reg_dir,flist(j).name),...
                fullfile(dir_list(i).folder,dir_list(i).name)); %move TIF to main data dir
        end
    end   
end