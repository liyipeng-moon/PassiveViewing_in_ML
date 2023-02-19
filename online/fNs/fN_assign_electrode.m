function [BAM_config,BAM_data, app] = fN_assign_electrode(BAM_config, BAM_data, app)


for ii = 1:BAM_config.MaxElectrode

    app.ChannelSetting.CheckedNodes=[];
    for jj = 1:BAM_config.MaxUnit
        field_name = ['seg' num2str(ii) num2str(jj) 'Node'];
        if(BAM_config.Electrode(ii,jj).Using=True)
            app.ChannelSetting.CheckedNodes = [app.ChannelSetting.CheckedNodes, ]
        end
%         if(BAM_config.Electrode(ii,jj).Using=True)
%         setfield
%         getfield(app,field_name)
    end
end


end