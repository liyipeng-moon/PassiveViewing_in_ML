function [selected_dataset, dataset_idx, category_idx, img_path,default_params] = select_dataset(root_dir)

% xx = dir([root_dir, '\*.mat']);

% list={}; 
% image_number = [];
% for ii = 1:length(xx)
%     temp = load([root_dir '\' xx(ii).name]).image_info;
%     list{end+1}=[xx(ii).name(1:end-4) ', n = ' num2str(length(temp))];
% end
% [indx,~] = listdlg('PromptString',{'Select a mat file',''},'SelectionMode','single','ListString',list,'ListSize',[550,250]);
% selected_dataset = xx(indx).name;


ending_flag = 1;
while(ending_flag)

     [filename, ~, ~] = uigetfile(root_dir);

     if(strcmpi(filename, 'regret_file.txt'))
        break
     end
     % try to load mat file
     try
        temp = load([root_dir '\matfile_pool\'  filename]).image_info;
     catch
        warning('please select a mat file with image_info field!')
        continue
     end

     % check can we got all images
     for ii = 1:length(temp)
        if(~exist([temp{ii,2},  '\' temp{ii,1}]))
            warning([ 'image ',temp{ii,2},  '\' ,temp{ii,1},' does not exist'])
            ending_flag=1;
            break
        else
            ending_flag=0;
        end
     end

        dd = dir([root_dir, '/matfile_pool/*.mat']);
     for ii = 1:length(dd)
        if(strcmp(filename, dd(ii).name))
            dataset_idx=ii;
        end
     end
end


img_path={};
temp = load([root_dir '\matfile_pool\' filename]).image_info;
default_params = load([root_dir '\matfile_pool\' filename]).params;
for ii = 1:length(temp)
    img_path{end+1} = [temp{ii,2},  '\' temp{ii,1}];
end
selected_dataset=filename;
category_idx = load([root_dir '\matfile_pool\'  filename]).category.idx;
end