/* ================================================
 *			Friendly Fire module
==================================================*/

void FriendlyFire_ShowReport(int client)
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

void FriendlyFire_ShowReportExtra(int client)
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

void ResetFFArrays()
{
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

public int SortByDamage(int elem1, int elem2, const array[], Handle hndl)
{
	// By damage, then by client index, descending
    if (g_iDmgTotal[elem1] > g_iDmgTotal[elem2]) return -1;
    else if (g_iDmgTotal[elem2] > g_iDmgTotal[elem1]) return 1;
    else if (elem1 > elem2) return -1;
    else if (elem2 > elem1) return 1;
    return 0;
}