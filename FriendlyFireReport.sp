/***********************************************************
*	Format & Commands:

	!ff
	Friendly Fire dealt: 24
	Done 11 damage to Rochelle
	Done 5 damage to Ellis
	Done 8 damage to Nick
	Friendly Fire received: 5
	Taken 5 damage from Coach

	!ffe
	Most FF dealt: 
	#1 KrankZ [100 dmg] (100% of total FF) 
	#2 tom [0 dmg] (0% of total FF)
	#3 grav [0 dmg] (0% of total FF)
	#4 flow [0 dmg] (0% of total FF)
************************************************************/
#include <sourcemod>

#pragma semicolon	1
#pragma newdecls required

// attacker, victim
int g_iDamageCache[MAXPLAYERS+1][MAXPLAYERS+1];

int g_iDmgTotal[MAXPLAYERS+1];
int g_iDmgReceivedTotal[MAXPLAYERS+1];
int g_iDmgTotalCache;

public Plugin myinfo =
{
	name = "Friendly Fire Report",
	author = "Gravity",
	description = "Self explanatory",
	version = "1.1",
	url = ""
};

public void OnPluginStart()
{
	HookEvent("player_hurt_concise", Event_OnPlayerHurtConcise);
	HookEvent("survival_round_start", Event_OnSurvivalStart);
	
	RegConsoleCmd("sm_ff", CMD_ShowFF);
	RegConsoleCmd("sm_ffe", Cmd_ShowFFExtra);
}

/**************************
	Commands
**************************/

public Action Cmd_ShowFFExtra(int client, int args)
{
	DisplayExtraFriendlyFireStats(client);
	return Plugin_Handled;
}

public Action CMD_ShowFF(int client, int args)
{
	GetFriendlyFireStats(client);
	return Plugin_Handled;
}

void GetFriendlyFireStats(int client)
{
	PrintToChat(client, "\x01Friendly Fire dealt: \x04%i", g_iDmgTotal[client]);
	
	for (int i = 1; i <= MaxClients; i++)
	{
		if (!IsClientInGame(i))continue;
		
		if( GetClientTeam(i) == 2 )
		{
			// Dealt dmg to someone ?
			if (g_iDamageCache[client][i] > 0)
			{
				PrintToChat(client, "\x01Done \x03%i\x01 damage to \x05%N", g_iDamageCache[client][i], i);
			}
		}
	}
	
	PrintToChat(client, "\x01Friendly Fire received: \x04%i", g_iDmgReceivedTotal[client]);
	
	for (int i = 1; i <= MaxClients; i++)
	{
		if (!IsClientInGame(i))continue;
		
		if (GetClientTeam(i) == 2)
		{
			// I have received dmg ?
			if( g_iDamageCache[i][client] > 0 )
			{
				PrintToChat(client, "\x01Taken \x03%i\x01 damage from \x05%N", g_iDamageCache[i][client], i);
			}
		}
	}
}

void DisplayExtraFriendlyFireStats(int client)
{
	PrintToChat(client, "Most FF dealt:");
	
	// Variables for sorting the list
	int player;
	int survivor_index = -1;
	int survivor_clients[MAXPLAYERS];
	int	FFDamage;
	
	for(player = 1; player <= MaxClients; player++)
	{
		if (!IsClientInGame(player) || GetClientTeam(player) != 2) continue;
	
		survivor_index++;
		survivor_clients[survivor_index] = player;
		FFDamage = g_iDmgTotal[player];
	}
	
	SortCustom1D(survivor_clients, sizeof(survivor_clients), SortByDamage);
	
	for (int i = 0; i <= survivor_index; i++)
	{
		player = survivor_clients[i];
		FFDamage = g_iDmgTotal[player];
		
		float pctFromFFtotal = ((g_iDmgTotal[player] == 0) ? 0.0 : float(g_iDmgTotal[player]) / float(g_iDmgTotalCache)) * 100;
		
		// Gravity [5 dmg] (100% of total FF)
		PrintToChat(client, "\x05%N\x01 [\x04%i\x01 dmg] (\x03%.0f%%\x01 of total FF)", player, FFDamage, pctFromFFtotal);
	}
}

/**************************
	Events
**************************/

public void Event_OnPlayerHurtConcise(Event event, const char[] name, bool dontBroadcast)
{
	int attacker = event.GetInt("attackerentid");
	int victim = GetClientOfUserId(event.GetInt("userid"));
	
	// Isnt valid survivors or ingame.
	if (!IsSurvivor(attacker) || !IsSurvivor(victim))
	{
		return;
	}
	
	// Damage done to health
	int damage = event.GetInt("dmg_health");
	
	// Time to cache damage dealt by attacker to victim user, if the dmg isnt self-inflicted
	if( victim != attacker )
	{
		g_iDamageCache[attacker][victim] += damage;
		g_iDmgTotal[attacker] += damage;
		g_iDmgTotalCache += damage;
		g_iDmgReceivedTotal[victim] += damage;
	}
}

public void Event_OnSurvivalStart(Event event, const char[] name, bool dontBroadcast)
{
	// Reset FF
	for (int i = 1; i <= MaxClients; i++)
	{
		for(int j = 1; j <= MaxClients; j++)
		{
			g_iDamageCache[i][j] = 0;
		}
		
		g_iDmgTotal[i] = 0;
		g_iDmgReceivedTotal[i] = 0;
	}
	g_iDmgTotalCache = 0;
}

bool IsSurvivor(int client)
{
	return (client > 0 && client <= MaxClients && IsClientInGame(client) && GetClientTeam(client) == 2);
}

public int SortByDamage(int elem1, int elem2, const array[], Handle hndl)
{
	// By damage, then by client index, descending
    if (g_iDmgTotal[elem1] > g_iDmgTotal[elem2]) return -1;
    else if (g_iDmgTotal[elem2] > g_iDmgTotal[elem1]) return 1;
    else if (elem1 > elem2) return -1;
    else if (elem2 > elem1) return 1;
    return 0;
}