function [ev_val, ev_time, simple_dm] = sort_digital_port(datarr, datacapture)

reshaped_datarr = reshape(datarr(1:datacapture),[datarr(1),datacapture/double(datarr(1))]);


    subplot(2,5,5)

simple_dm = reshaped_datarr([4,5,6],:);
imagesc(simple_dm)
ev_val = reshaped_datarr(4,:);
ev_time = reshaped_datarr([5,6],:);
end

