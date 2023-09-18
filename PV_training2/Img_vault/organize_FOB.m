clear
close all
cd C:\Users\PC\Desktop\Img_vault
cd FOB\
all_img = dir('*tif');
image_info = {};
for ii = 1:length(all_img)
    image_info{ii,1} = all_img(ii).name;
    image_info{ii,2} = 'FOB';
end
cd ..
params.onset_time=150;
params.offset_time=150;
params.img_size = 224;
category.name = {'body', 'face', 'fruit','hand','tech','scram'};
category.idx = ones([1, length(image_info)]);
category.idx(17:32)=2;
category.idx(33:48)=3;
category.idx(49:64)=4;
category.idx([65,66:2:78,81:2:96])=5;
category.idx(setdiff(65:96, [65,66:2:78,81:2:96]))=6;

colmap=colormap(hsv);
color_idx = colmap([2,38,65,120,150,195],:);
category.color_category = color_idx;

single_img = imread([image_info{1,2}, '\' image_info{1,1}]);
example_img = [];
for cc = 1:length(category.name)
    ii_idx = find(category.idx==cc,1);
    temp_img = imread([image_info{ii_idx,2}, '\' image_info{ii_idx,1}]);
    rgb_img(:,:,1)=temp_img;rgb_img(:,:,2)=temp_img;rgb_img(:,:,3)=temp_img;
    for ppx = 1:10
        for ppy = 1:length(single_img) 
            rgb_img(end-ppx+1 ,ppy,:)=uint8(255*color_idx(cc,:));
            rgb_img(ppx ,ppy,:)=uint8(255*color_idx(cc,:));
            rgb_img(ppy,ppx,:)=uint8(255*color_idx(cc,:));
            rgb_img(ppy,end-ppx+1,:)=uint8(255*color_idx(cc,:));
        end
    end
    example_img = [example_img, rgb_img];
end
imshow(example_img)

save('matfile_pool\FOB.mat', 'image_info','params','category')
imwrite(example_img, 'datasets\FOB.png')