function app = fN_change_gui_color(app)
global BAM_config BAM_data;

%% about saving
if(BAM_config.is_saving)
    app.StartOnlineSavingButton.FontColor = BAM_config.colormap.white;
    app.StopOnlineSavingButton.FontColor = BAM_config.colormap.black;
    app.SavingLamp.Color=BAM_config.colormap.green;
else
    app.SavingLamp.Color=BAM_config.colormap.red;
    app.StartOnlineSavingButton.FontColor = BAM_config.colormap.black;
    app.StopOnlineSavingButton.FontColor = BAM_config.colormap.white;
end

end
