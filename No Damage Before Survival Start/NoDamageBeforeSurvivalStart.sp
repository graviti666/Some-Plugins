#include <sourcemod>
#include <sdktools>
#include <sdkhooks>

#pragma semicolon	1
#pragma newdecls required

ConVar g_hAffectBots;
ConVar g_hPluginEnabled;

public Plugin myinfo = 
{
	name = "No Damage Before Survival Start",
	author = "Gravity",
	description = "",
	version = "1.0",
	url = ""
};

public void OnPluginStart()
{
	g_hAffectBots = CreateConVar("nodamage_before_start_affect_bots", "1", "Should Bots not take damage aswell before survival starts?", 0, true, 0.0, true, 1.0);
	g_hPluginEnabled = CreateConVar("nodamage_before_start_enabled", "1", "Enable or disable plugin", 0, true, 0.0, true, 1.0);
	
	AutoExecConfig(true, "nodamage_before_survival_start");
	
	HookEvent("player_spawn", Event_OnSpawn);
	HookEvent("survival_round_start", Event_OnSurvivalStart);
	HookEvent("player_ledge_grab", Event_LedgeGrab);
}

public void Event_OnSpawn(Event event, const char[] name, bool dontBroadcast)
{
	if (IsRoundInProgress() || !g_hPluginEnabled.BoolValue || !IsSurvival())
		return;
	
	int client = GetClientOfUserId(event.GetInt("userid"));
	if (!client || !IsClientInGame(client) || GetClientTeam(client) != 2)
		return;
	
	if (IsFakeClient(client) && !g_hAffectBots.BoolValue)
		return;
	
	SDKHook(client, SDKHook_OnTakeDamage, OnTakeDamageBeforeRound);
}

public void Event_LedgeGrab(Event event, const char[] name, bool dontBroadcast)
{
	if (IsRoundInProgress() || !g_hPluginEnabled.BoolValue || !IsSurvival())
		return;
	
	int client = GetClientOfUserId(event.GetInt("userid"));
	if (!client || !IsClientInGame(client) || GetClientTeam(client) != 2)
		return;
	
	if (IsFakeClient(client) && !g_hAffectBots.BoolValue)
		return;

	SetEntProp(client, Prop_Send, "m_isHangingFromLedge", 0);
	SetEntProp(client, Prop_Send, "m_isIncapacitated", 0);
	SetEntProp(client, Prop_Send, "m_currentReviveCount", 0);
	SetEntPropFloat(client, Prop_Send, "m_healthBuffer", 0.0);
}

public void Event_OnSurvivalStart(Event event, const char[] name, bool dontBroadcast)
{
	if (!g_hPluginEnabled.BoolValue || !IsSurvival())
		return;
	
	// Just make sure no hooks will remain on round-start
	for (int i = 1; i <= MaxClients; i++)
	{
		SDKUnhook(i, SDKHook_OnTakeDamage, OnTakeDamageBeforeRound);
	}
}

public Action OnTakeDamageBeforeRound(int victim, int& attacker, int& inflictor, float& damage, int& damagetype)
{
	if (victim != 0 && IsClientInGame(victim) && GetClientTeam(victim) == 2 && !IsRoundInProgress() && g_hPluginEnabled.BoolValue)
	{
		if (IsFakeClient(victim) && !g_hAffectBots.BoolValue)
			return Plugin_Continue;
		
		damage = 0.0;
		return Plugin_Changed;
	}
	return Plugin_Continue;
}

stock bool IsRoundInProgress()
{
	return GameRules_GetPropFloat("m_flRoundStartTime") > 0.0 && GameRules_GetPropFloat("m_flRoundEndTime") == 0.0;
}

stock bool IsSurvival()
{
	char sGameMode[16];
	GetConVarString(FindConVar("mp_gamemode"), sGameMode, sizeof(sGameMode));
	return (StrEqual(sGameMode, "survival"));
}