#include <sourcemod>
#include <steamworks>

#pragma semicolon 1
#pragma newdecls required

bool g_bBhopEnabled[MAXPLAYERS + 1] = false;

public Plugin myinfo = 
{
	name = "Bhop Command",
	author = "Gravity",
	description = "Allows admins and whitelisted players to enable auto-bhop on the server.",
	version = "1.0",
	url = "no"
};

public void OnMapStart()
{
	for (int i = 1; i <= MaxClients; i++)
		g_bBhopEnabled[i] = false;
}

public void OnPluginStart()
{
	RegConsoleCmd("sm_bhop", Command_EnableBhop, "Enables autobhop plugin.");
}

public Action Command_EnableBhop(int client, int args)
{
	if (!client) { return Plugin_Handled; }
	if (IsClientRootAdmin(client) || IsWhiteListedPlayer(client))
	{
		g_bBhopEnabled[client] = !g_bBhopEnabled[client];
		PrintToChat(client, "\x01AutoBhop is \x03%s", g_bBhopEnabled[client] ? "enabled" : "disabled");	
	}
	else
	{
		PrintToChat(client, "You don't have access to this command.");
		return Plugin_Handled;
	}
	return Plugin_Handled;
}

public Action OnPlayerRunCmd(int client, int &buttons)
{
	if (IsAnyValidSurvivor(client) && IsPlayerAlive(client) && !IsFakeClient(client))
	{
		if (g_bBhopEnabled[client]) 
		{
			if (buttons & IN_JUMP)
			{
				if (GetEntPropEnt(client, Prop_Send, "m_hGroundEntity") == -1)
				{
					if (GetEntityMoveType(client) != MOVETYPE_LADDER)
					{
						buttons &= ~IN_JUMP;
					}
				}
			}	
		}
	}
	return Plugin_Continue;
}

stock bool IsClientRootAdmin(int client)
{
    return ((GetUserFlagBits(client) & ADMFLAG_ROOT) != 0);
}

bool IsWhiteListedPlayer(int client)
{
	char sSteam64ID[64];
	if (!SteamWorks_GetClientSteamID(client, sSteam64ID, sizeof(sSteam64ID))) // Could prob use GetClientAuthId too
	{
		LogError("Steam is down couldnt reserve a new slot for player.");
		return false;
	}
	
	// Sofield
	if (StrEqual(sSteam64ID, "76561198115279755"))
		return true;
	return false;
}

bool IsAnyValidSurvivor(int client)
{
	return (client > 0 && client <= MaxClients && IsClientInGame(client) && GetClientTeam(client) == 2);
}