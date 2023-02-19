function [ev_val, ev_time] = fN_sort_digital_port(datarr, datacapture)

reshaped_datarr = reshape(datarr(1:datacapture),[datarr(1),datacapture/double(datarr(1))]);
ev_val = reshaped_datarr(4,:);
ev_time = fN_translation_time(reshaped_datarr([5,6],:));

end

