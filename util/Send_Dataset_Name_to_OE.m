function status_now = Send_Dataset_Name_to_OE(Condition_info, zeroMQ_handle)
    zeroMQwrapper('Send',zeroMQ_handle ,['Start playing ' Condition_info.img_info.selected_dataset]);
end