/*-----------------------------------------------------------------------------------------------
* Dependencies:

* Left4Dhooks Direct (replacement for left4downtown) - https://forums.alliedmods.net/showthread.php?t=321696
* dhooks - https://forums.alliedmods.net/showthread.php?p=2588686#post2588686
* SM 1.0
------------------------------------------------------------------------------------------------*/
#include <sourcemod>
#include <left4dhooks>

#pragma semicolon	1
#pragma newdecls required

#define DEBUG	0

Handle g_hStaggerCheck[MAXPLAYERS + 1] = null;

int g_iPreviousStagger[MAXPLAYERS + 1];

public Plugin myinfo = 
{
	name = "Stagger Fix",
	author = "Gravity",
	description = "Prevents staggering/stumbling more than 2.5 seconds.",
	version = "1.0",
	url = ""
};

public void OnMapStart()
{
	for (int i = 1; i <= MaxClients; i++)
		g_iPreviousStagger[i] = 0;
}

public Action L4D2_OnStagger(int target, int source)
{
	if (target && IsClientInGame(target) && GetClientTeam(target) == 2)
	{
		g_iPreviousStagger[target] = GetTime();
		
		if (g_hStaggerCheck[target] == null)
			g_hStaggerCheck[target] = CreateTimer(2.5, Timer_CheckStagger, GetClientUserId(target), TIMER_FLAG_NO_MAPCHANGE);
	}
}

public Action Timer_CheckStagger(Handle timer, int UserID)
{
	int client = GetClientOfUserId(UserID);
	if (client && IsClientInGame(client))
	{
		if (IsStaggering(client))
		{
			// Verify we didn't get staggered again instantly by some other source
			if (g_iPreviousStagger[client] > 0 && GetTime() - g_iPreviousStagger[client] >= 2.5)
			{
				L4D_CancelStagger(client);
			}
		}
	}
	g_iPreviousStagger[client] = 0;
	g_hStaggerCheck[client] = null;
}

// from khan
bool IsStaggering(int client)
{
	// Are they stumbling?
	float vec[3];
	GetEntPropVector(client, Prop_Send, "m_staggerStart", vec);
	if (vec[0] != 0.000000 || vec[1] != 0.000000 || vec[2] != 0.000000)
	{
		return true;
	}
	return false;
}