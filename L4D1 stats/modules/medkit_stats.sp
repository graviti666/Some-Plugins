/*======================================================
 *				Medkit stats module
=======================================================*/

void MedkitStats_CalculateKits()
{
	g_iMedkitCount = ItemCount("weapon_first_aid_kit_spawn") + ItemCount("weapon_first_aid_kit");
}

int ItemCount(const char[] sClassname)
{
    int count;
    int entity = -1;
    while ((entity = FindEntityByClassname(entity, sClassname)) != -1)
    {
        if (!IsValidEdict(entity) || !IsValidEntity(entity))
            continue;
       
        if (StrContains(sClassname, "_spawn", false) != -1)
        {
            // if someone picked it up already ignore it
			int value = GetEntProp(entity, Prop_Data, "m_itemCount");
			if (value == 0)
                continue;
		}
        count++;
	}
    return count;
}

void MedkitStats(int client)
{
	int iUnusedMedkits = g_iMedkitCount - g_iKitsTotalUsed;
	float pctUnused = ( ( FloatDiv( float(iUnusedMedkits), float(g_iMedkitCount) ) * 100 ));
	
	PrintToChat(client, "\x01Medkits Used (\x04%i\x01/\x04%i\x01):", g_iKitsTotalUsed, g_iMedkitCount);
	PrintToChat(client, "\x01Unused Medkits: \x03%i\x01 (\x04%.0f%%\x01)", iUnusedMedkits, pctUnused);
	
	// Variables for sorting the list
	int player;
	int survivor_index = -1;
	int survivor_clients[MAXPLAYERS+1];
	int	kits;
	
	for (player = 1; player <= MaxClients; player++)
	{
		if (!IsClientInGame(player)) continue;
		
		if (GetClientTeam(player) == 2)
		{
			survivor_index++;
			survivor_clients[survivor_index] = player;
			kits = g_iKitsUsedClient[player];
		}
	}
	
	SortCustom1D(survivor_clients, sizeof(survivor_clients), SortByKitsUsed);
	
	for (int i; i <= survivor_index; i++)
	{
		player = survivor_clients[i];
		kits = g_iKitsUsedClient[player];
		
		float pctKitsUsed = ( (g_iKitsUsedClient[player] == 0) ? 0.0 : FloatDiv( float(g_iKitsUsedClient[player]), float(g_iMedkitCount) ) * 100 );
		PrintToChat(client, "\x05%N\x01: \x03%i\x01 (\x04%.0f%%\x01)", player, kits, pctKitsUsed);
	}
}

public int SortByKitsUsed(int elem1, int elem2, const array[], Handle hndl)
{
    if (g_iKitsUsedClient[elem1] > g_iKitsUsedClient[elem2]) return -1;
    else if (g_iKitsUsedClient[elem2] > g_iKitsUsedClient[elem1]) return 1;
    else if (elem1 > elem2) return -1;
    else if (elem2 > elem1) return 1;
    return 0;
}

void ResetHealthArrays()
{
	for (int i = 1; i <= MaxClients; i++)
	{
		g_iKitsUsedClient[i] = 0;
	}
	g_iKitsTotalUsed = 0;
}