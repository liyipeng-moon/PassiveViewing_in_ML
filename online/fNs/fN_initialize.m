function [BAM_config, BAM_data, app] = fn_initialize(app)

    load('default_params.mat')
    GAM_data=[];
    Wait_interval = 1;
    app.SavingLamp.Color=BAM_config.colormap.blue;
    BAM_config.is_saving = 0;
    wrong_txt=[];
    %% check what dataset we have
    try
        all_dataset = dir([BAM_config.img_vault,'/*mat']);
        dataset_name = {};
        for ii = 1:length(all_dataset)
            dataset_name{end+1} = all_dataset(ii).name(1:end-4);
        end
        app.SelectSet.Items = dataset_name;
        app.SelectSet.Value = 'FOB';
        
        app.SavingLampLabel.Text='Load Dataset Success';
        pause(Wait_interval)
    catch
        wrong_txt = 'Load Dataset Wrong';
    end

    %% set electrode
    [BAM_config BAM_data, app] = fN_assign_electrode(BAM_config, BAM_data, app)
    
    if(isempty(wrong_txt))
        % initialize success
        app.SavingLampLabel.Text='Wait to Srart! Lets do some science!' ;
        app.SavingLamp.Color = BAM_config.colormap.blue;
    else
        % display wrong info
        app.SavingLampLabel.Text=wrong_txt;
        app.SavingLamp.Color = BAM_config.colormap.white;
    end

end