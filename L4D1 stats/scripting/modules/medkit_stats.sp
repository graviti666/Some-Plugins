/*======================================================
 *				Medkit stats module
=======================================================*/
/*
	* Thanks for this list jim
	Generator Room (l4d_hospital02_subway) - 8 kits/ 4 pills 
	Gas Station (l4d_hospital03_sewers) - 8 kits/ 4 pills
	Hospital (l4d_hospital04_interior) - 8 kits/ 32 pills
	Rooftop (l4d_vs_hospital05_rooftop) - 8 kits/ 8 pills
	Drains (l4d_smalltown02_drainage) - 8 kits/ 8 pills
	Church (l4d_smalltown03_ranchhouse) - 8 kits 4 pills
	Street (l4d_smalltown04_mainstreet) - 8 kits/ 8 pills
	Boathouse (l4d_vs_smalltown05_houseboat) - 8 kits/ 8 pills
	Crane (l4d_airport02_offices) - 8 kits/ 4 pills
	Construction Site (l4d_airport03_garage) - 8 kits/ 8 pills
	Terminal (l4d_airport04_terminal) - 8 kits/ 9 pills
	Runway (l4d_vs_airport05_runway) - 12 kits/ 7 pills
	Warehouse (l4d_farm02_traintunnel) - 8 kits/ 15 pills
	Bridge (Blood Harvest) (l4d_farm03_bridge) - 8 kits/ 4 pills
	Farmhouse (l4d_vs_farm05_cornfield) - 8 kits/ 4 pills
	Bridge (Crash Course) (l4d_garage01_alleys) - 8 kits/ 7 pills
	Truck Depot (l4d_garage02_lots) - 8 kits/ 4 pills
	Traincar (l4d_river01_docks) - 8 kits/ 4 pills
	Port (l4d_river03_port) - 8 kits/ 6 pills
	Lighthouse (l4d_sv_lighthouse) - 8 kits/ 12 pills
*/

void MedkitStats_CalculateKits()
{
	char sMap[64];
	GetCurrentMap(sMap, sizeof(sMap));
	
	if (StrEqual(sMap,  "l4d_hospital02_subway")) {
		g_iMedkitCount = 8;
	}
	else if (StrEqual(sMap, "l4d_hospital03_sewers")) {
		g_iMedkitCount = 8;
	}
	else if (StrEqual(sMap, "l4d_hospital04_interior")) {
		g_iMedkitCount = 8;
	}
	else if (StrEqual(sMap, "l4d_vs_hospital05_rooftop")) {
		g_iMedkitCount = 8;
	}
	else if (StrEqual(sMap, "l4d_smalltown02_drainage")) {
		g_iMedkitCount = 8;
	}
	else if (StrEqual(sMap, "l4d_smalltown03_ranchhouse")) {
		g_iMedkitCount = 8;
	}
	else if (StrEqual(sMap, "l4d_smalltown04_mainstreet")) {
		g_iMedkitCount = 8;
	}
	else if (StrEqual(sMap, "l4d_vs_smalltown05_houseboat")) {
		g_iMedkitCount = 8;
	}
	else if (StrEqual(sMap, "l4d_airport02_offices")) {
		g_iMedkitCount = 8;
	}
	else if (StrEqual(sMap, "l4d_airport03_garage")) {
		g_iMedkitCount = 8;
	}
	else if (StrEqual(sMap, "l4d_airport04_terminal")) {
		g_iMedkitCount = 8;
	}
	else if (StrEqual(sMap, "l4d_vs_airport05_runway")) {
		g_iMedkitCount = 12;
	}
	else if (StrEqual(sMap, "l4d_farm02_traintunnel")) {
		g_iMedkitCount = 8;
	}
	else if (StrEqual(sMap, "l4d_farm03_bridge")) {
		g_iMedkitCount = 8;
	}
	else if (StrEqual(sMap, "l4d_vs_farm05_cornfield")) {
		g_iMedkitCount = 8;
	}
	else if (StrEqual(sMap, "l4d_garage01_alleys")) {
		g_iMedkitCount = 8;
	}
	else if (StrEqual(sMap, "l4d_garage02_lots")) {
		g_iMedkitCount = 8;
	}
	else if (StrEqual(sMap, "l4d_river01_docks")) {
		g_iMedkitCount = 8;
	}
	else if (StrEqual(sMap, "l4d_river03_port")) {
		g_iMedkitCount = 8;
	}
	else if (StrEqual(sMap, "l4d_sv_lighthouse")) {
		g_iMedkitCount = 8;
	}
}

//	Not counting medkits automatically since on some maps items spawn outside of playable areas.
//	You can calculate items automatically by hooking 'player_first_spawn' with a second delay but you need to exclude items outside of playable areas from the count.
/* 
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
*/

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