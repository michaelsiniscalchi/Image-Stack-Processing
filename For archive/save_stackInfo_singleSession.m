clearvars;
data_dir = 'J:\Data & Analysis\Rule Switching\_Specialized processing\171101 M49 RuleSwitching';
filter = fullfile(data_dir,'*.tif');
[fname,fpath] = uigetfile(filter,'MultiSelect','on');

for i=1:numel(fname)
    raw_path{i} = fullfile(fpath,fname{i});
end

stackInfo = get_stackInfo(raw_path);
savepath = fullfile(data_dir,'stack_info');
save(savepath,'-STRUCT','stackInfo'); %Save stack info from ScanImage
