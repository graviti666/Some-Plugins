/*===========================================================================================
	Modification of this plugin basically: https://forums.alliedmods.net/showthread.php?p=1491240
	
	This plugin prevents users from joining with illegimate convars.
	
	Some hidden convars that might be unlegit come from this guide:
	https://steamcommunity.com/sharedfiles/filedetails/?id=564185677
	
	convar values that are blocked:
	
	c_thirdpersonshoulder 1
	- Allows to see through walls basically fly around the map.
	
	cl_fov > 90 | < 90
	- Because!
	
	z_tank_footstep_shake_duration 0
	- Disables screen shake effect from the tank walking around, 2 = default value enabled | 0 = disabled
============================================================================================*/
#include <sourcemod>

#pragma semicolon	1
#pragma newdecls required

#define TEAM_SURVIVOR	2

// Actions log
char g_sDebugLog[PLATFORM_MAX_PATH];

ConVar g_hDisallowThirdPersonCvar;
ConVar g_hDisallowFOVCvar;
ConVar g_hDisallowTankFootstepShakeCvar;

public Plugin myinfo = 
{
	name = "Player Integrity Check",
	author = "Gravity",
	description = "Prevents cheating players from joining...",
	version = "1.0",
	url = ""
};

public void OnPluginStart()
{
	g_hDisallowThirdPersonCvar 			= CreateConVar("player_integrity_disallow_thirdperson", 		"1", "1 = Kick players with thirdpersonshoulder cvar turned on, 0 = disable", 0, true, 0.0, true, 1.0);
	g_hDisallowFOVCvar 					= CreateConVar("player_integrity_disallow_fov", 				"1", "1 = kick players with cl_fov higher than 90, 0 = disable", 0, true, 0.0, true, 1.0);
	g_hDisallowTankFootstepShakeCvar 	= CreateConVar("player_integrity_disallow_tankfootstepshake", 	"1", "1 = Kick players with the cvar set to 2 | 0 = disable", 0, true, 0.0, true, 1.0);
	
	CreateTimer(4.5, Timer_CheckPlayerConVars, _, TIMER_REPEAT);
	
	BuildPath(Path_SM, g_sDebugLog, sizeof(g_sDebugLog), "logs/player-integrity-check.log");
	AutoExecConfig(true, "PlayerIntegrityCheck");
}

public Action Timer_CheckPlayerConVars(Handle timer)
{
	for (int i = 1; i <= MaxClients; i++)
	{
		if (!IsClientInGame(i) || IsFakeClient(i) || GetClientTeam(i) != TEAM_SURVIVOR)continue;
		
		if (IsClientConnected(i))
		{
			if (g_hDisallowThirdPersonCvar.BoolValue)
				QueryClientConVar(i, "c_thirdpersonshoulder", Query_OnCheckThirdPerson);
		
			if (g_hDisallowFOVCvar.BoolValue)
				QueryClientConVar(i, "cl_fov", Query_OnCheckFov);
				
			if (g_hDisallowTankFootstepShakeCvar.BoolValue)
				QueryClientConVar(i, "z_tank_footstep_shake_duration", Query_OnCheckTankFootstepShake);
		}
	}
}

public void Query_OnCheckThirdPerson(QueryCookie cookie, int client, ConVarQueryResult result, const char[] cvarName, const char[] cvarValue)
{
	char steamID64[64];
	if (!GetClientAuthId(client, AuthId_SteamID64, steamID64, sizeof(steamID64)))
	{
		LogToFile(g_sDebugLog, "Error getting steamid for %N steam down.", client);
	}
	
	static char sName[100];
	GetClientName(client, sName, sizeof(sName));
	
	// Convar should always be accessible.
	if (result != ConVarQuery_Okay)
	{
		KickClient(client, "[SM] Kicked for c_thirdpersonshoulder ConVar violation");
		LogToFile(g_sDebugLog, "%s (%s) kicked for c_thirdpersonshoulder violation (convar not found).", sName, steamID64);
		PrintToChatAll("\x01[SM] \x05%s\x01 kicked for c_thirdpersonshoulder violation.", sName);
	}
	
	else if (StrEqual(cvarValue, "1"))
	{		
		KickClient(client, "[SM] In order to connect you must set c_thirdpersonshoulder to 0");
		LogToFile(g_sDebugLog, "%s (%s) kicked for c_thirdpersonshoulder violation. (cvar set to 1)", sName, steamID64);
		PrintToChatAll("\x01[SM] \x05%s\x01 was kicked for c_thirdpersonshoulder violation.", sName);
	}
}

public void Query_OnCheckFov(QueryCookie cookie, int client, ConVarQueryResult result, const char[] cvarName, const char[] cvarValue)
{
	char steamID64[64];
	if (!GetClientAuthId(client, AuthId_SteamID64, steamID64, sizeof(steamID64)))
	{
		LogToFile(g_sDebugLog, "Error getting steamid for %N steam down.", client);
	}
	
	static char sName[100];
	GetClientName(client, sName, sizeof(sName));
	
	// Convar should always be accessible.
	if (result != ConVarQuery_Okay)
	{
		KickClient(client, "[SM] Kicked for cl_fov ConVar violation");
		LogToFile(g_sDebugLog, "%s (%s) kicked for cl_fov violation. (cvar not found)", sName, steamID64);
		PrintToChatAll("\x01[SM] \x05%s\x01 was kicked for cl_fov violation.", sName);
	}
	
	if (!StrEqual(cvarValue, "90"))
	{
		KickClient(client, "[SM] In order to connect you must set cl_fov to 90");
		LogToFile(g_sDebugLog, "%s (%s) kicked for cl_fov violation. (cl_fov wasnt 90)", sName, steamID64);
		PrintToChatAll("\x01[SM] \x05%s\x01 was kicked for cl_fov violation.", sName);
	}
}

public void Query_OnCheckTankFootstepShake(QueryCookie cookie, int client, ConVarQueryResult result, const char[] cvarName, const char[] cvarValue)
{
	char steamID64[64];
	if (!GetClientAuthId(client, AuthId_SteamID64, steamID64, sizeof(steamID64)))
	{
		LogToFile(g_sDebugLog, "Error getting steamid for %N steam down.", client);
	}
	
	static char sName[100];
	GetClientName(client, sName, sizeof(sName));
	
	// Convar should always be accessible.
	if (result != ConVarQuery_Okay)
	{
		KickClient(client, "[SM] Kicked for z_tank_footstep_shake_duration ConVar violation");
		LogToFile(g_sDebugLog, "%s (%s) kicked for z_tank_footstep_shake_duration violation. (cvar not found)", sName, steamID64);
		PrintToChatAll("\x01[SM] \x05%s\x01 was kicked for z_tank_footstep_shake_duration violation.", sName);
	}
	
	if (StrEqual(cvarValue, "0"))
	{
		KickClient(client, "[SM] In order to connect you must set z_tank_footstep_shake_duration to 2");
		LogToFile(g_sDebugLog, "%s (%s) kicked for z_tank_footstep_shake_duration violation. (value wasnt 2)", sName, steamID64);
		PrintToChatAll("\x01[SM] \x05%s\x01 was kicked for z_tank_footstep_shake_duration violation.", sName);
	}
}