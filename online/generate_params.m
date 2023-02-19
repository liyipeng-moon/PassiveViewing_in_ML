BAM_config.img_vault = 'G:\Img_vault\matfile_pool';

BAM_data=[];

%% color parameters
BAM_config.colormap.red = [1,0,0];
BAM_config.colormap.green = [0,1,0];
BAM_config.colormap.blue = [0,0,1];
BAM_config.colormap.white = [1,1,1];
BAM_config.colormap.black = [0,0,0];
BAM_config.colormap.grey = [0.3,0.3,0.3];


%% Electrode Setting
BAM_config.MaxElectrode = 2;
BAM_config.MaxUnit = 4;
for cc = 1:BAM_config.MaxElectrode
    for uu = 1:BAM_config.MaxUnit
        BAM_config.Electrode(cc,uu).Using = false;
        BAM_config.Electrode(cc,uu).UID = 0;
    end
end
BAM_config.Electrode(1,1).Using = true;
BAM_config.Electrode(1,1).UID = 1;
BAM_config.Electrode(1,2).Using = true;
BAM_config.Electrode(1,2).UID = 2;

BAM_config.num_electrode = 2;

save('default_params.mat',"BAM_config","BAM_data");