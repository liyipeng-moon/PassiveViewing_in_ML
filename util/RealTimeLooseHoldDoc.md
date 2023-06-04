## Rewrited RealTimeLooseHold
### Why we need to rewrite this adapter
##### Our Goals in passive viewing paradigm are as follows:
1. Present images regardless of whether monkey is fixating.
2. Deliver reward while monkey is fixating on images.
3. Tolerate small interruptions in fixation caused by blinking and other events.
##### Our general route to achieve such goals are:
1. Use **ImageChanger** with *null_* input to present images.
2. Use **SingleTarget** with *eye_* input to judge where the monkey is looking at.
3. Use **LooseHold** with *SingleTarget.Success* input to judge whether monkey is fixating for certain time, while loosehold can tolerate fixation break for a short time.
4. Use **RewardScheduler**, with *LooseHold.Success* as input, to develier voltage change signals to reward syetem.
5. Use **Concurrent** to combine *ImageChanger(null_)* and *RewardScheduler(LooseHold(SingleTarget(eye_)))*, so that image presentation sysyem and behavior moniter system run parallely.
##### The problem is:
LooseHold is a adapter that become Success permanently once fixation is held for a certrain time. This would lead RewardScheduler deliver reward permanently even if the first successful fixation is broken afterwards. So we need to change the state of LooseHold in real-time.

### How to Use these adapter
they are saved into **util** folder, and used in the timing script, see the example and modify it.
