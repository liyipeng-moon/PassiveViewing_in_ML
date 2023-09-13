rr_series = [1:2:20].^2;
movie = [];
bg = 2000;
for ff = 1:length(rr_series)
    
    img = zeros([bg,bg]);
    for xx = 1:bg
        for yy = 1:bg
            if((xx-bg/2)^2+(yy-bg/2)^2<rr_series(ff)^2)
                img(xx,yy)=1;
            end
        end
    end

    for cc = 1:3
        movie(:,:,cc,ff)=img;
    end
end

figure
for ff = 1:length(rr_series)
    imshow(squeeze(movie(:,:,:,ff)));
end

