function rwd_time = generate_rwd_time(max_interval, min_interval, all_step, dur)

all_interval = linspace(max_interval,min_interval,all_step);

starting_time = cumsum(all_interval)-all_interval(1);
rwd_time=[];

for ii = 1:length(all_interval)
    rwd_time(ii,:) = [starting_time(ii), all_interval(ii),all_interval(ii), dur, 0];
end

end