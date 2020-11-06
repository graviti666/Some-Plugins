#include <sourcemod>

#pragma semicolon 1
#pragma newdecls required

ConVar g_hPluginEnabled;

int g_iAliveTimeTank[MAXPLAYERS + 1];

public Plugin myinfo =
{
	name 		= "Tank Life Timer",
	author 		= "Gravity",
	version 	= "1.0"
};

public void OnMapStart()
{
    for (int i = 1; i <= MaxClients; i++)
    {
        g_iAliveTimeTank[i] = 0;
    }
}

public void OnPluginStart()
{
	g_hPluginEnabled = CreateConVar("tanklifetime_enabled", "0", "Enable plugin", 0, true, 0.0, true, 1.0);
	
	HookEvent("tank_killed", Event_OnTankDeath);
	HookEvent("player_spawn", Event_OnSpawned);
	HookEvent("round_end", Event_RoundEnd);
	
	RegConsoleCmd("sm_tlife", Command_toggleTankLifeTimer, "Toggles tank life timer display.");
}

public Action Command_toggleTankLifeTimer(int client, int args)
{
	if(!GetConVarBool(g_hPluginEnabled))
	{
		PrintToChatAll("\x01Tank life-time display \x05enabled\x01");
		SetConVarBool(g_hPluginEnabled, true);
	}
	else
	{
		PrintToChatAll("\x01Tank life-time display \x05disabled\x01");
		SetConVarBool(g_hPluginEnabled, false);
	}
}

public void Event_OnTankDeath(Event event, const char[] name, bool dontBroadcast)
{
	if(!GetConVarBool(g_hPluginEnabled)) return;
	
	int userid = GetEventInt(event, "userid");
	int client = GetClientOfUserId(userid);
	
	if( client != 0 && IsClientInGame(client) )
	{
		int iSec = GetTime() - g_iAliveTimeTank[client];
		float iMin = 0.0;
		
		if( g_iAliveTimeTank[client] > 0 )
		{
			if( iSec > 60 )
			{
				iMin = iSec / 60.0;
				PrintToChatAll("\x05%N\x01 Killed in \x04%.2f\x01 m", client, iMin);
				g_iAliveTimeTank[client] = 0;
			}
			else
			{
				PrintToChatAll("\x05%N\x01 Killed in \x04%i\x01 s", client, iSec);
				g_iAliveTimeTank[client] = 0;
			}
		}
	}
}

public void Event_OnSpawned(Event event, const char[] name, bool dontBroadcast)
{
	int userid = GetEventInt(event, "userid");
	int client = GetClientOfUserId(userid);
	
	if( client != 0 && IsClientInGame(client) )
	{
		int zc = GetEntProp(client, Prop_Send, "m_zombieClass");
		if( zc == 8 )
		{
			g_iAliveTimeTank[client] = GetTime();
		}
	}
}

public void Event_RoundEnd(Event event, const char[] name, bool dontBroadcast)
{
    for (int i = 1; i <= MaxClients; i++)
    {
        g_iAliveTimeTank[i] = 0;
    }
}