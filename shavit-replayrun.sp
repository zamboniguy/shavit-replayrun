//Nuko: pretty much just get the record array by Shavit_GetReplayData when you finish the map and play it by Shavit_StartReplayFromFrameCache

#pragma semicolon 1
#pragma newdecls required

//#include <sourcemod>
//#include <sdktools>
//#include <cstrike>
//#include <clientprefs>
#include <shavit>

public Plugin myinfo = 
{
	name = "shavit-replayrun",
	author = "fri-end",
	description = "Replay your most recent run.",
	version = "1.0",
	url = "https://github.com/zamboniguy"
};

frame_cache_t aReplayData[MAXPLAYERS + 1];

public void OnPluginStart()
{
	RegConsoleCmd("sm_replayrun", SM_ReplayRun);
}


public void OnClientPutInServer(int client)
{
	char sReplayName[MAX_NAME_LENGTH];
	GetClientName(client, sReplayName, sizeof(sReplayName));
	Format(sReplayName, MAX_NAME_LENGTH, "*%s", sReplayName);

	char sAuthID[32];
	GetClientAuthId(client, AuthId_Steam3, sAuthID, sizeof(sAuthID));
	ReplaceString(sAuthID, 32, "[U:1:", "");
	ReplaceString(sAuthID, 32, "]", "");

	aReplayData[client].fTickrate = (1.0 / GetTickInterval());
	aReplayData[client].iPreFrames = 0;
	aReplayData[client].iPostFrames = RoundFloat(FindConVar("shavit_replay_postruntime").FloatValue * aReplayData[client].fTickrate);
	aReplayData[client].iFrameCount = 0;
	aReplayData[client].fTime = -1.0;
	aReplayData[client].bNewFormat = true;
	aReplayData[client].iReplayVersion = 0x09;
	aReplayData[client].sReplayName = sReplayName;
	aReplayData[client].aFrames = new ArrayList(aReplayData[client].iReplayVersion, 0);
	aReplayData[client].iSteamID = StringToInt(sAuthID);
}

public void OnClientDisconnect(int client)
{
	aReplayData[client].iPreFrames = 0;
	aReplayData[client].iPostFrames = 0;
	aReplayData[client].iFrameCount = 0;
	aReplayData[client].fTime = -1.0;
	aReplayData[client].bNewFormat = false;
	aReplayData[client].iReplayVersion = 0x09;
	aReplayData[client].sReplayName = "error";
	delete aReplayData[client].aFrames;
	aReplayData[client].fTickrate = -1.0;
	aReplayData[client].iSteamID = 0;
}

public Action SM_ReplayRun(int client, int args)
{
	// Check if central replay bot is idle
	if (Shavit_GetReplayStatus(Shavit_GetReplayBotIndex(-1, -1)) == Replay_Idle) {
		// Check if there are any frames to play... switch to counting aFrames instead of iFrameCount
		if (aReplayData[client].iFrameCount > 0) {
			Shavit_StartReplayFromFrameCache(Shavit_GetBhopStyle(client), Shavit_GetClientTrack(client), -1.0, client, Shavit_GetReplayBotIndex(-1, -1), Replay_Central, false, aReplayData[client]);

			PrintToChat(client, "[\x02ReplayRun\x01] Now playing \x0Cyour \x01most recent run.");
		}
		else
		{
			PrintToChat(client, "[\x02ReplayRun\x01] No replay data... \x0Cnothing to replay.");
		}
	}
	else
	{
		PrintToChat(client, "[\x02ReplayRun\x01] \x0cWait \x01for current bot replay to stop.");
	}
	
	
	return Plugin_Handled;
}

public Action Shavit_ShouldSaveReplayCopy(int client, int style, float time, int jumps, int strafes, float sync, int track, float oldtime, float perfs, float avgvel, float maxvel, int timestamp, bool isbestreplay, bool istoolong)
{
	aReplayData[client].aFrames = Shavit_GetReplayData(client, true);
	aReplayData[client].iPreFrames = Shavit_GetPlayerPreFrames(client);
	aReplayData[client].iFrameCount = aReplayData[client].aFrames.Length - aReplayData[client].iPreFrames - aReplayData[client].iPostFrames;
	aReplayData[client].fTime = time;


	//PrintToChat(client, "PreFrames: %i", aReplayData[client].iPreFrames);
	//PrintToChat(client, "PostFrames: %i", aReplayData[client].iPostFrames);
	//PrintToChat(client, "FrameCount: %i %i", Shavit_GetClientFrameCount(client), aReplayData[client].iFrameCount);
	//PrintToChat(client, "Frames.Length: %i", aReplayData[client].aFrames.Length);

	PrintToChat(client, "[\x02ReplayRun\x01] Your \x0cpersonal replay data saved. \x01Use \x0c!replayrun \x01to watch.");

	return Plugin_Continue;
}