#include <SteamWorks>

public Plugin myinfo =
{
	name = "Survival Time Fixes",
	author = "khan",
	description = "Allows disconnected players to still get the time. Prevents spectators from receiving the time",
	version = "1.0"
};

#define SPECTATOR_TEAM 	1
#define SURVIVOR_TEAM 	2

StringMap g_hSurvivorList;

public void OnPluginStart()
{
	HookEvent("survival_round_start", Event_SurvivalStart, EventHookMode_Post);
	HookEvent("bot_player_replace", Event_BotPlayerReplace, EventHookMode_Post);
	
	g_hSurvivorList = CreateTrie();
}

public Action Event_SurvivalStart(Event hEvent, const char[] name, bool dontBroadcast)
{
	ClearTrie(g_hSurvivorList);
	
	for (int i = 1; i <= MaxClients; i++)
	{
		if (!IsClientInGame(i) || IsFakeClient(i))
			continue;
		
		if (GetClientTeam(i) == SPECTATOR_TEAM)
		{
			SetEntProp(i, Prop_Send, "m_bWasPresentAtSurvivalStart", 0)
		}
		else if (GetClientTeam(i) == SURVIVOR_TEAM)
		{
			char sID[64];
			SteamWorks_GetClientSteamID(i, sID, sizeof(sID));
			SetTrieValue(g_hSurvivorList, sID, i);
		}
	}
}

public Action Event_BotPlayerReplace(Event hEvent, const char[] name, bool dontBroadcast)
{
	int player = GetClientOfUserId(hEvent.GetInt("player"));
	char sID[64];
	SteamWorks_GetClientSteamID(player, sID, sizeof(sID));
	
	int value;
	if (GetTrieValue(g_hSurvivorList, sID, value))
	{
		bool bWasPresent = view_as<bool>(GetEntProp(player, Prop_Send, "m_bWasPresentAtSurvivalStart"));
		if (!bWasPresent)
		{
			SetEntProp(player, Prop_Send, "m_bWasPresentAtSurvivalStart", 1);
		}
	}
}
