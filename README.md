# shavit-replayrun
 - Replay your last run.
 - Tested with version [bhoptimer version 3.1.0](https://github.com/shavitush/bhoptimer/releases/tag/v3.1.0).
    - Occasionally errors due to ArrayList.GetArray invalid index and makes the replay skip.
 - No errors in [bhoptimer version 3.0.8](https://github.com/shavitush/bhoptimer/releases/tag/v3.0.8).
 - Thanks to Nuko#9726 for the idea ("pretty much just get the record array by Shavit_GetReplayData when you finish the map and play it by Shavit_StartReplayFromFrameCache")
## Available Commands
- sm_replayrun - Activates a replay (using the central bot) of your most recent run if the bot is idle.
