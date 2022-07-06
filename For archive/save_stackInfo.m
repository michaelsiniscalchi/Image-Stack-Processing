clearvars;

do.stackinfo = false;
do.check_data = true;

% Assign data directories and get experiment-specific parameters
data_dir = 'J:\Data & Analysis\Rule Switching';
% Set paths to analysis code
[data_dir,~,~] = pathlist_RuleSwitching;
% Get-experiment specific variables 
[dirs, expData] = expData_RuleSwitching_DEVO(data_dir);


if do.stackinfo
    for i = 1:numel(expData)
        expData = get_imgPathnames(dirs,expData,i);
        stackInfo = get_stackInfo(expData(i).raw_path);
        savepath = fullfile(dirs.data,expData(i).sub_dir,'stack_info');
        save(savepath,'-STRUCT','stackInfo'); %Save stack info from ScanImage
    end
end

%Check for consistency with behavior
if do.check_data
    for i = 1:numel(expData)
        load(fullfile(dirs.data,expData(i).sub_dir,'stack_info.mat'));
        load (fullfile(dirs.analysis,expData(i).sub_dir,'behavior.mat'));
        %Check if sessionData.nTrials==numel(nFrames)
        status(i) = sessionData.nTrials==numel(nFrames); %#ok<SAGROW>
    end
     sessionList = {expData(status==false).sub_dir};
end

