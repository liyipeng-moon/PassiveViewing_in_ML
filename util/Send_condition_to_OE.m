function status_now = Send_condition_to_OE(Condition_info, OE_config)

for cc = 1:length(Condition_info.condition_nm)
    condition_name = Condition_info.condition_nm{cc};
    meg_to_send = ['{"condition_index" : ' num2str(cc-1) ',"name" : "' condition_name '","ttl_line" : 9,"trigger_type" : 2}'];
    out = webwrite(OE_config.psth_url, struct('text',meg_to_send), weboptions('RequestMethod','put','MediaType','application/json'));
    if(strcmp(out.info, 'Message received.'))
        continue
    else
        warning('Fail to add category!! Do you have enough condition in your OE GUI?')
    end
end


end