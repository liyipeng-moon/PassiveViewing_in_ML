# PassiveViewing_in_ML
apply passive viewing paradigm in monkey logic

install NIMH Monkey Logic at https://monkeylogic.nimh.nih.gov/

If you are using AO, install instrument controll toolbox and jsonlab before running
modify your image vault in pv_userloop, load condition file in main menu and run!
if you don't have a AO or OE connected to ML PC through a network switcher, please set DeviceFreeMode=1 in userloop function\

# Update Journal
20230604\
add fmri localizer dataset
add trigger val and example design matrix

20230601\
Separated the experiments (AO or OE) into different folders.
Implemented the use of relative paths for images.

20230524\
Add a network example for WKS, add movie viewing function

20230520\
add zeromq functions

20230519\
Implemented the webwrite function for OE 


20230516\
show example image categories

20230504\
add category info for OE

20230426\
Introduced a new paradigm where images are presented only when the monkey is fixating.

20230329\
Add eye info and eye correction

20230301\
Fixed dataset index and on-off marker.

20230220\
Removed the online app.


# Image vault setting
In the user loop file, you need to declare the images that will be presented during the experiment. You should select a mat file (or the corresponding example PNG file) that contains the 'img_info' field. This field provides information about the image, including the image name, saving path, and image category. This category information will be used during online analysis.
See https://github.com/liyipeng-moon/Img_vault for example file.
```
imginfo_valut='G:\Img_vault\';
```


## We rewroted some adapters, described below.
### Rewrited RealTimeLooseHold
LooseHold is an adapter that achieves a state of success permanently once fixation is maintained for a certain duration. This would lead RewardScheduler deliver reward permanently even if the first successful fixation is broken afterwards. To solve this, we have rewritten the RealTimeLooseHold adapter to allow for real-time state changes.

## Rewrited MyImagechanger
We have made modifications to the imagechanger adapter and renamed it as MyImagechanger. The purpose of this modification is to incorporate zeromq functions after the onset of any image. In the current configuration, the category information is sent to the OpenEphys GUI.

### How to Use these adapter
These rewritten adapters are stored in the util folder. To utilize them, you need to include them in your timing script. Refer to the provided example and make necessary modifications accordingly.
