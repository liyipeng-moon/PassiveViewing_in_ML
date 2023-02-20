function [BAM_config,BAM_data, app] = fN_advance(BAM_config, BAM_data, app)
    
for ii = 1:BAM_config.MaxElectrode
    for jj = 1:BAM_config.MaxUnit
        [BAM_config,BAM_data, app] = fN_disable_electrode(BAM_config, BAM_data, app,ii,jj);
    end
end