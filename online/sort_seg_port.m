function [ev_val, ev_time, simple_dm] = sort_digital_port(datarr, datacapture)

reshaped_datarr = reshape(datarr(1:datacapture),[datarr(1),datacapture/double(datarr(1))]);

for ii = 2:size(reshaped_datarr,2)
    subplot(2,5,5+double(reshaped_datarr(4,ii)))
    hold on
    plot(reshaped_datarr(8:end,ii))
end

for ii = 1:4
    subplot(2,5,5+ii)
    spikes = length(find(reshaped_datarr(4,:)==ii));
    title(['unit', num2str(ii)])
end
simple_dm = reshaped_datarr([4,5,6],:);
ev_val = reshaped_datarr(4,:);
ev_time = reshaped_datarr([5,6],:);
end

