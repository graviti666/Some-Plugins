#include <sourcemod>

#pragma semicolon	1
#pragma newdecls required

ConVar g_hPluginEnabled;

#define MAXMELEE_PER_ROUND	5

bool g_bRoundInProgress;

int g_iGotMeleeCount[MAXPLAYERS + 1];

// Globals
#define ALLOWED_MAPS		6
char rngMeleeMaps[ALLOWED_MAPS][] =
{
	"c8m2_subway",		//genny
	"c6m3_port",		//port p
	"c7m3_port",		//port s
	"c7m1_docks",		//traincar
	"c6m1_riverbank",	//riverbank
	"c8m5_rooftop"		//rooftop
};

#define MAX_MELEES	3
char sMeleeList[MAX_MELEES][] =
{
	"fireaxe",
	"katana",
	"crowbar"
};

public Plugin myinfo = {
	name = "Random Melees",
	author = "Gravity",
	description = "Gives random melees on map with RNG melee.",
	version = "1.0.0",
	url = ""
};

public void OnPluginStart() 
{
	g_hPluginEnabled = CreateConVar("random_melees_enabled", "1", "Enable plugin or disable.", 0, true, 0.0, true, 1.0);
	
	HookEvent("survival_round_start", Event_OnSurvivalStart);
	HookEvent("round_end", Event_OnSurvivalEnd);
	
	RegConsoleCmd("sm_m", Command_GiveMeleeWeapon, "Gives a random melee weapon only on RNG maps.");
	RegConsoleCmd("sm_melee", Command_GiveMeleeWeapon, "Gives a random melee weapon only on RNG maps.");
}

public Action Command_GiveMeleeWeapon(int client, int args)
{
	if (!GetConVarBool(g_hPluginEnabled)) { return Plugin_Handled; }
	
	if ( !client )
	{
		ReplyToCommand(client, "[SM] Command may only be used in-game.");
		return Plugin_Handled;
	}
	
	if( !IsSurvival() )
	{
		ReplyToCommand(client, "[SM] Command only works in survival.");
		return Plugin_Handled;
	}
	
	if( GetClientTeam(client) != 2 )
	{
		ReplyToCommand(client, "[SM] Must be on the survivor team to use this command.");
		return Plugin_Handled;
	}
	
	if( g_bRoundInProgress )
	{
		ReplyToCommand(client, "[SM] Can't use command while round in progress.");
		return Plugin_Handled;
	}
	
	if( !MapsToEnableOn() )
	{
		ReplyToCommand(client, "[SM] Random melees not supported on this map.");
		return Plugin_Handled;
	}
	
	if( g_iGotMeleeCount[client] >= MAXMELEE_PER_ROUND )
	{
		ReplyToCommand(client, "[SM] Cannot get anymore melees this round ( max %i ).", MAXMELEE_PER_ROUND);
		return Plugin_Handled;
	}
	
	char melee[32];
	
	// Desired melee weapon
	if( args > 0 )
	{
		// Get the name of the melee weapon user typed in
		GetCmdArgString(melee, sizeof(melee));
		
		CheatCommand(client, "give", melee, "");
		g_iGotMeleeCount[client]++;
	}
	
	// no argument, Random melee
	if( args == 0 )
	{
		int randomPick = GetRandomInt(0, MAX_MELEES - 1);
		CheatCommand(client, "give", sMeleeList[randomPick], "");
		g_iGotMeleeCount[client]++;
	}
	
	return Plugin_Handled;
}

public void Event_OnSurvivalStart(Event event, const char[] name, bool dontBroadcast)
{
	g_bRoundInProgress = true;
	
	// Reset use count
	for (int i = 1; i <= MaxClients; i++)
	{
		g_iGotMeleeCount[i] = 0;
	}
}

public void Event_OnSurvivalEnd(Event event, const char[] name, bool dontBroadcast)
{
	if( g_bRoundInProgress )
	{
		g_bRoundInProgress = false;
	}
}

bool MapsToEnableOn()
{
	char sMap[32];
	GetCurrentMap(sMap, sizeof(sMap));
	
	for (int i = 0; i < ALLOWED_MAPS; i++)
	{
		if(StrEqual(rngMeleeMaps[i], sMap)) {
			return true;
		}
	}
	return false;
}

bool IsSurvival()
{
	char sGamemode[16];
	FindConVar("mp_gamemode").GetString(sGamemode, sizeof(sGamemode));
	return StrEqual(sGamemode, "survival");
}

void CheatCommand(int client, char[] cmd, char[] sArg1, char[] sArg2, char[] sArg3 = "")
{
	int flags = GetCommandFlags(cmd);										// Grab the original cmd flags
	SetCommandFlags(cmd, flags & ~FCVAR_CHEAT);								// Set the FCVAR_CHEAT flag to the cmd
	FakeClientCommand(client, "%s %s %s %s", cmd, sArg1, sArg2, sArg3);		// Execute the command
	SetCommandFlags(cmd, flags);												// Set flags back to default!
}