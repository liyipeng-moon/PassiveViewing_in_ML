function [img_info] = select_xml(root_dirs,  BAM_folder)

options = {};
dirs_pool = {};
for rr = 1:length(root_dirs)
    dir_now = root_dirs{rr};
    all_folders_in_dir = dir(dir_now);
    for ff = 3:length(all_folders_in_dir)
        if(all_folders_in_dir(ff).isdir)
            nm = all_folders_in_dir(ff).name;
            if(exist(fullfile(dir_now, nm, [nm,'.tsv'])))
                options{end+1} = fullfile(dir_now, nm, [nm,'.tsv']);
                dirs_pool{end+1} = fullfile(dir_now, nm);
            end
        end
    end
end

[dataset_idx] = listdlg('PromptString','SelectDataSet','ListString',options,'ListSize',[1500,900]);
selected_dataset = options{dataset_idx};
selected_dir = dirs_pool{dataset_idx};
imported_tsv = readtable(selected_dataset,"FileType","text",'Delimiter','\t');


image_info = cell(height(imported_tsv),2);
for ii = 1:height(imported_tsv)
    image_info{ii,1} = imported_tsv{ii,1}{1};
    image_info{ii,2} = selected_dir;
end

%% check tsv good?
for ii = 1:length(image_info)
    if(~exist((fullfile(selected_dir,image_info{ii,1}))))
        warning([fullfile(selected_dir,image_info{ii,1}) ' does not exist'])
            return
    end
end

category.idx = zeros([1, length(image_info)]);
category.name = unique(imported_tsv{:,2});
for img = 1:height(imported_tsv)
    category.idx(img)=find(strcmp(imported_tsv{img,2},category.name));
end


colmap=colormap(turbo);
color_idx = colmap(floor(linspace(20,230,length(category.name))),:);
category.color_category = color_idx;


%% generate example img
example_img = [];
for cc = 1:length(category.name)
    ii_idx = find(category.idx==cc,1);
    temp_img = imread(fullfile(selected_dir,image_info{ii_idx,1}));
    
    if(length(size(temp_img))==2)
        rgb_img = uint8([]);
        for channel = 1:3
            rgb_img(:,:,channel)=temp_img;
        end
    else
        rgb_img = temp_img;
    end
    rgb_img = imresize(rgb_img,[100,100]);
    for ppx = 1:5
        for ppy = 1:size(rgb_img,1)
            rgb_img(end-ppx+1 ,ppy,:)=uint8(255*color_idx(cc,:));
            rgb_img(ppx ,ppy,:)=uint8(255*color_idx(cc,:));
            rgb_img(ppy,ppx,:)=uint8(255*color_idx(cc,:));
            rgb_img(ppy,end-ppx+1,:)=uint8(255*color_idx(cc,:));
        end
    end
    example_img = [example_img, rgb_img];
end
imshow(example_img)

img_path=cell(length(image_info),1);
for ii = 1:length(image_info)
    img_path{ii} = (fullfile(selected_dir,image_info{ii,1}));
end

category_idx = category.idx;
category_color = category.color_category;
category_nm = category.name;

category_info = [];
for ii = 1:length(category_nm)
    category_info = [category_info, num2str(ii), '-' category_nm{ii}, '; '];
end

img_info.selected_dataset = selected_dataset;
img_info.dataset_idx = dataset_idx;
img_info.category_idx = category.idx;
img_info.img_path = img_path;

img_info.category_info = category_info;
img_info.example_img = example_img;
img_info.condition_nm = category_nm;
img_info.category_color = category_color;

save([BAM_folder,'\DM.mat'], "img_info")
imwrite(example_img, [BAM_folder,'\example.png'])
end