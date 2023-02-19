function time_arr = fN_translation_time(timing_matrix_16)
%% why this function
% the time from AO is hex16(?) format, and we need to translate 
% it into actual time, so I did experiment to test its meaning,
% 1. the starting time of this format is when AO power up
% 2. the range of the first line is about [-32757, 32767], when it
%    runs out, the second line += 1
% 3. once the second line += 1, the actual time pass 1458ms
%    and that is 2^16/44kHz
% given these observation, we can calculate the time since AO start
% recording today.

samplerate = 44;
line1 = int64(timing_matrix_16(1,:));
line1(line1<0) = line1(line1<0) + 2^16;

line2 = int64(timing_matrix_16(2,:)+1);
line2_interval = (2^16)/samplerate;
base_time = line2_interval .* line2;

time_arr = base_time + (line1)/samplerate;

end