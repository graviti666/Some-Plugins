/***********************************************************

	Format:
	
	Friendly Fire dealt: 24
	Done 11 damage to Rochelle
	Done 5 damage to Ellis
	Done 8 damage to Nick
	Friendly Fire received: 5
	Taken 5 damage from Coach

************************************************************/
#include <sourcemod>

#pragma semicolon	1
#pragma newdecls required

// attacker, victim
int g_iDamageCache[MAXPLAYERS+1][MAXPLAYERS+1];

int g_iDmgTotal[MAXPLAYERS+1];
int g_iDmgReceivedTotal[MAXPLAYERS+1];

public Plugin myinfo =
{
	name = "Friendly Fire Report",
	author = "Gravity",
	description = "",
	version = "1.0",
	url = ""
};

public void OnPluginStart()
{
	HookEvent("player_hurt_concise", Event_OnPlayerHurtConcise);
	HookEvent("survival_round_start", Event_OnSurvivalStart);
	
	RegConsoleCmd("sm_ff", CMD_ShowFF);
}

/**************************
	Command
**************************/

public Action CMD_ShowFF(int client, int args)
{
	GetFriendlyFireStats(client);
	return Plugin_Handled;
}

void GetFriendlyFireStats(int client)
{
	PrintToChat(client, "\x01Friendly Fire dealt: \x04%i", g_iDmgTotal[client]);
	
	for (int i = 1; i <= MaxClients; i++ )
	{
		if (!IsClientInGame(i))continue;
		
		if( GetClientTeam(i) == 2 )
		{
			// Dealt dmg to someone ?
			if( g_iDamageCache[client][i] > 0 )
			{
				PrintToChat(client, "\x01Done \x03%i\x01 damage to \x05%N", g_iDamageCache[client][i], i);
			}
		}
	}
	
	PrintToChat(client, "\x01Friendly Fire received: \x04%i", g_iDmgReceivedTotal[client]);
	
	for (int i = 1; i <= MaxClients; i++ )
	{
		if (!IsClientInGame(i))continue;
		
		if( GetClientTeam(i) == 2 )
		{
			// I have received dmg ?
			if( g_iDamageCache[i][client] > 0 )
			{
				PrintToChat(client, "\x01Taken \x03%i\x01 damage from \x05%N", g_iDamageCache[i][client], i);
			}
		}
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
		g_iDmgReceivedTotal[victim] += damage;
	}
}

public void Event_OnSurvivalStart(Event event, const char[] name, bool dontBroadcast)
{
	// Reset FF
	for (int i = 1; i <= MaxClients; i++ )
	{
		g_iDamageCache[i][i] = 0;
		g_iDmgTotal[i] = 0;
		g_iDmgReceivedTotal[i] = 0;
	}
}

bool IsSurvivor(int client)
{
	return (client > 0 && client <= MaxClients && IsClientInGame(client) && GetClientTeam(client) == 2);
}