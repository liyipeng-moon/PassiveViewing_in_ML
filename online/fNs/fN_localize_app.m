function [root_dir] = fN_localize_app()

root_dir = which('Online_Loading');
xx = find(root_dir=='\');
xx = xx(end);
root_dir = root_dir(1:xx);
cd(root_dir)
