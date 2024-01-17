function [img_info] = select_dataset(root_dir, Localizer_set, BAM_folder)

ending_flag = 1;
while(ending_flag)
    if(~Localizer_set)
        [filename, ~, ~] = uigetfile([root_dir, '\datasets\*png']);
    else
        filename = [Localizer_set, '.png'];
    end
     example_img = imread([root_dir, '\datasets\', filename]);
     if(strcmpi(filename, 'Noise.png'))
        break
     end
     filename = filename(1:end-4);
     % try to load mat file
     try
        temp = load([root_dir '\matfile_pool\'  filename '.mat']).image_info;
     catch
        warning('please select a mat file with image_info field!')
        continue
     end

     % check can we got all images
     for ii = 1:length(temp)
        if(~exist([root_dir '\' temp{ii,2},  '\' temp{ii,1}]))
            warning([ 'image ',temp{ii,2},  '\' ,temp{ii,1},' does not exist'])
            ending_flag=1;
            break
        else
            ending_flag=0;
        end
     end

        dd = dir([root_dir, '/matfile_pool/*.mat']);
     for ii = 1:length(dd)
        if(strcmp([filename '.mat'], dd(ii).name))
            dataset_idx=ii;
        end
     end
end


img_path={};
temp = load([root_dir '\matfile_pool\' filename]).image_info;
default_params = load([root_dir '\matfile_pool\' filename]).params;
for ii = 1:length(temp)
    img_path{end+1} = [root_dir '\' temp{ii,2},  '\' temp{ii,1}];
end
selected_dataset=filename;
category_idx = load([root_dir '\matfile_pool\'  filename]).category.idx;
category_color = load([root_dir '\matfile_pool\'  filename]).category.color_category;
category_nm = load([root_dir '\matfile_pool\'  filename]).category.name;

category_info = [];
for ii = 1:length(category_nm)
    category_info = [category_info, num2str(ii), '-' category_nm{ii}, '; '];
end

img_info.selected_dataset = selected_dataset;
img_info.dataset_idx = dataset_idx;
img_info.category_idx = category_idx;
img_info.img_path = img_path;
img_info.default_params = default_params;
img_info.category_info = category_info;
img_info.example_img = example_img;
img_info.condition_nm = category_nm;
img_info.category_color = category_color;

save([BAM_folder,'\DM.mat'], "img_info")
end