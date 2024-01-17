# PassiveViewing_in_ML
apply passive viewing paradigm in monkey logic

install NIMH Monkey Logic at https://monkeylogic.nimh.nih.gov/

If you are using AO, install instrument controll toolbox and jsonlab before running
modify your image vaults in pv_userloop, load condition file in main menu and run!
if you don't have a AO or OE connected to ML PC through a network switcher, please set DeviceFreeMode=1 in userloop function\

# Update Journal
2024.01.17\
change select_dataset.m to select_xml.m, which allows adding datasets during experiment with NAS
change progress calculation, such that we can judge which image was fixated so we can select image to show in the next trial

2024.01.09\
add TTL version of OnOffMarker to tell online system about eye location info which make eventcode clear

2023.12.14\
first successful session for ePhys

2023.12.10\
replace TCP transfer to a share folder method to send message to Online system

20230918\
refine training paradigm

20230913\
add training paradigm
add example data
add movie viewing dataset
add single phonton paradigm

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
In the user loop file, you need to declare the images that will be presented during the experiment. You should tell which folders you want to use as image vault. Please see example of FOB_example.
```
root_dirs = {'Z:\Monkey\Stimuli', 'D:\Img_vault'};
[TrialRecord.User.img_info]=select_xml(root_dirs,online_folder);
```


## We rewroted some adapters, described below.
### Rewrited RealTimeLooseHold
LooseHold is an adapter that achieves a state of success permanently once fixation is maintained for a certain duration. This would lead RewardScheduler deliver reward permanently even if the first successful fixation is broken afterwards. To solve this, we have rewritten the RealTimeLooseHold adapter to allow for real-time state changes.

## Rewrited MyImagechanger
We have made modifications to the imagechanger adapter and renamed it as MyImagechanger. The purpose of this modification is to incorporate zeromq functions after the onset of any image. In the current configuration, the category information is sent to the OpenEphys GUI.

## Rewrited OnOffMarker.m
We have make a TTL version of OnOffMarker so we can send TTLs to AO once eye-signal is within or out-of fixation window. This allows online system to judge which trial should be used for analysis. TTL avoids occupying eventcodes.

### How to Use these adapter
These rewritten adapters are stored in the util folder. To utilize them, you need to include them in your timing script. Refer to the provided example and make necessary modifications accordingly.
