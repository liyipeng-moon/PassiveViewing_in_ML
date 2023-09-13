cd C:\Users\DELL\Desktop\word_learning\

all_img = [];
cd word_1_drop\
all_img1 = dir('*jpg');
for ii = 1:length(all_img1)
    all_img(end+1).path = sprintf('word_1_drop/%s', all_img1(ii).name);
    all_img(end).drop = 1;
end
cd ..

cd word_1_drop_control\
all_img1c  = dir('*jpg');
for ii = 1:length(all_img1)
    all_img(end+1).path = sprintf('word_1_drop_control/%s', all_img1c(ii).name);
    all_img(end).drop = 1;
end
cd ..

cd word_2_drop\
all_img2 = dir('*jpg');
for ii = 1:length(all_img1)
    all_img(end+1).path = sprintf('word_2_drop/%s', all_img2(ii).name);
    all_img(end).drop = 2;
end
cd ..

cd word_3_drop\
all_img3 = dir('*jpg');
for ii = 1:length(all_img1)
    all_img(end+1).path = sprintf('word_3_drop/%s', all_img3(ii).name);
    all_img(end).drop = 3;
end
cd ..

save word_info.mat all_img