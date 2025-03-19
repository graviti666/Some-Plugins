#include <sourcemod>
#include <sdkhooks>
#include <sdktools>

#define IS_VALID_CLIENT(%1)     (%1 > 0 && %1 <= MaxClients)
#define IS_SURVIVOR(%1)         (GetClientTeam(%1) == 2)
#define IS_VALID_INGAME(%1)     (IS_VALID_CLIENT(%1) && IsClientInGame(%1))
#define IS_VALID_SURVIVOR(%1)   (IS_VALID_INGAME(%1) && IS_SURVIVOR(%1))

ArrayList g_iGascans;
ArrayList g_iLasthits; 
ArrayList g_iPropanes;
ArrayList g_iLasthitProp;

char lastFire[128];
char lastExplosion[128];

float g_fLastUse[MAXPLAYERS + 1];

bool g_bGasVoteInProgress;
bool g_bPropaneVoteInProgress;

#define TEAM_SURVIVORS		2

ConVar hVotingTime, hCommandDelay;

/* Converted to new syntax
 * Command delay added 5.0 seconds, to prevent annoying spammers
 * Previous gas/propane shooter isn't tracked anymore incase a vote is in-progress
*/

public Plugin myinfo =
{
	name = "Who shot the gas??",
	author = "khan",
	description = "Tracks who shot the gas cans - started with gas plugin by vk.com/id7558918, just modified it for this",
	version = "2.0"
};


public void OnPluginStart()
{
	// Register Console Commands
	RegConsoleCmd("gas", Cmd_WhoShotTheGas);
	RegConsoleCmd("propane", Cmd_WhoShotThePropane);
	
	hVotingTime = CreateConVar("gasvote_command_delay", "5.0", "Delay for the !gas and !propane commands to prevent spam", FCVAR_NOTIFY, true, 1.0, true, 30.0);
	hCommandDelay = CreateConVar("gasvote_voting_time", "8", "Time for the !gas / !propane votes to stay active", FCVAR_NOTIFY, true, 1.0, true, 20.0);
	
	// Hook Events
	HookEvent("round_start", Event_RoundStart, EventHookMode_PostNoCopy);
	HookEvent("round_end", Event_RoundEnd, EventHookMode_Pre);
	
	// Initialize Data
	g_iGascans = new ArrayList();
	g_iLasthits = new ArrayList();
	
	g_iPropanes = new ArrayList();
	g_iLasthitProp = new ArrayList();
	
	RefreshGascans( );
	RefreshPropanes( );
	
	lastFire = "";
	lastExplosion = "";
}

public void OnMapStart()
{
	g_bGasVoteInProgress = false;
	g_bPropaneVoteInProgress = false;
}

//======================
// Commands
//======================

public Action Cmd_WhoShotTheGas(int client, int args)
{
	if (!client)
		return Plugin_Handled;
		
	if (!StrEqual(lastFire, ""))
	{
		float time = GetGameTime();
		if (time < g_fLastUse[client] + hCommandDelay.FloatValue)
		{
			float remain = (g_fLastUse[client] + hCommandDelay.FloatValue) - time;
			PrintToChat(client, "\x01Please wait \x03%.1f\x01 seconds before using this command again..", remain);
			return Plugin_Handled;
		}
		
		g_fLastUse[client] = time;
		DoVoteMenu();
		return Plugin_Handled;
	}
	
	PrintToChat(client, "No one has shot any gas yet");
	return Plugin_Handled;
}

public Action Cmd_WhoShotThePropane(int client, int args)
{
	if (!client)
		return Plugin_Handled;
		
	if (!StrEqual(lastExplosion, ""))
	{
		float time = GetGameTime();
		if (time < g_fLastUse[client] + hCommandDelay.FloatValue)
		{
			float remain = (g_fLastUse[client] + hCommandDelay.FloatValue) - time;
			PrintToChat(client, "\x01Please wait \x03%.1f\x01 seconds before using this command again..", remain);
			return Plugin_Handled;
		}
		
		g_fLastUse[client] = time;
		DoVoteMenuExp();
		return Plugin_Handled;
	}

	PrintToChat(client, "No one has shot any propane yet");
	return Plugin_Handled;
}

//=====================
// Events and hooks
//=====================

public void Event_RoundEnd(Event event, const char[] name, bool dontBroadcast)
{
	lastFire = "";
	lastExplosion = "";
	
	g_bGasVoteInProgress = false;
	g_bPropaneVoteInProgress = false;
}

public void Event_RoundStart(Event event, const char[] name, bool dontBroadcast)
{
	lastFire = "";
	lastExplosion = "";
	
	RefreshGascans();
	RefreshPropanes();
}

public void OnEntityCreated(int entity, const char[] classname)
{
	//PrintToChatAll("Entity created: %s", classname);

	if (!IsValidEdict(entity))
		return;

	if (strcmp(classname, "weapon_gascan") == 0)
	{
		RefreshGascans();
	}
	
	static char model[128];
	GetEntPropString(entity, Prop_Data, "m_ModelName", model, sizeof(model)); 
	if (strcmp(model, "models/props_junk/propanecanister001a.mdl", false) == 0)
	{
		RefreshPropanes();
	}
} 

public void OnEntityDestroyed(int entity)
{
	//PrintToChatAll("Entity destroyed");
	int killer = -1;
	int index = -1;
	
	if (IsValidEdict(entity))
	{
		index = g_iGascans.FindValue(entity);
		if (index > -1)
		{
			killer = g_iLasthits.Get(index);
			
			// they can be destroyed at mapchange and if no one touched them, killer will be -1
			// also it will be -1 if it was picked up (after spitter or inferno)
			if (IsClientAndInGame(killer))
			{
				
				char PlayerName[32];
				GetClientName(killer, PlayerName, sizeof(PlayerName));
				
				//PrintToChatAll( "\x04[Fire]\x01 " );
				lastFire = PlayerName;
			}
					
			SDKUnhook(entity, SDKHook_OnTakeDamage, OnTakeDamageGascan);
						
			// set to -1 for @UnhookGascans to know that it was already unhooked
			g_iGascans.Set(index, -1);
			
		}
		else
		{
			index = g_iPropanes.FindValue(entity);
			if( index > -1 )
			{
				killer = g_iLasthitProp.Get(index);
				
				// they can be destroyed at mapchange and if no one touched them, killer will be -1
				// also it will be -1 if it was picked up (after spitter or inferno)
				if (IsClientAndInGame(killer))
				{
					char PlayerName[32];
					GetClientName(killer, PlayerName, sizeof(PlayerName));
					
					lastExplosion = PlayerName;
				}
						
				SDKUnhook( entity, SDKHook_OnTakeDamage, OnTakeDamagePropane );
							
				// set to -1 for @UnhookGascans to know that it was already unhooked
				g_iPropanes.Set(index, -1);
				
			}
		}
	
	}
	
}
public Action OnTakeDamageGascan(int victim, int& attacker, int& inflictor, float& damage, int& damagetype)
{
	int index = -1;
	
	// save lasthit. when first inferno fired by player burns second gascan there are MANY ontakedamage calls from first inferno and player. we need only real player.
	// we need hits only from spitter or survivors.
	if (IsValidEdict(victim) && IsClientAndInGame(attacker) && (GetClientTeam(attacker) == TEAM_SURVIVORS))
	{
		index = g_iGascans.FindValue(victim);
		if (index > -1 && !g_bGasVoteInProgress)
		{
			g_iLasthits.Set(index, attacker);	
		}

	}
	return Plugin_Continue;
}  

public Action OnTakeDamagePropane(int victim, int& attacker, int& inflictor, float& damage, int& damagetype)
{
	int index = -1;
	
	// save lasthit. when first inferno fired by player burns second gascan there are MANY ontakedamage calls from first inferno and player. we need only real player.
	// we need hits only from spitter or survivors.
	if (IsValidEdict(victim) && IsClientAndInGame(attacker) && (GetClientTeam(attacker) == TEAM_SURVIVORS))
	{
		index = g_iPropanes.FindValue(victim);
		if (index > -1 && !g_bPropaneVoteInProgress)
		{
			g_iLasthitProp.Set(index, attacker);	
		}

	}	
	return Plugin_Continue;
}  

void UnhookGascans()
{
	// unhook previous if they are still hooked
	int entity = -1;
	for (int i = 0; i < g_iGascans.Length; i++ )
	{
		entity = g_iGascans.Get(i);
		if (entity != -1)
		{
			SDKUnhook(entity, SDKHook_OnTakeDamage, OnTakeDamageGascan);
		}
	}
}

void UnhookPropane()
{
	// unhook previous if they are still hooked
	int entity = -1;
	for (int i = 0; i < g_iPropanes.Length; i++)
	{
		entity = g_iPropanes.Get(i);
		if(entity != -1)
		{
			SDKUnhook( entity, SDKHook_OnTakeDamage, OnTakeDamagePropane );
		}
	}
}

void RefreshGascans()
{	
	UnhookGascans();

	// reset arrays
	g_iGascans.Clear();
	g_iLasthits.Clear();
		
	int iEnt;
	char EdictClassName[32];
	while ((iEnt = FindEntityByClassname(iEnt, "weapon_gascan")) != -1) 
	{
		if (!IsValidEdict(iEnt) || !IsValidEntity(iEnt)) {
			continue;
		}
		
		GetEntPropString(iEnt, Prop_Data, "m_iClassname", EdictClassName, sizeof(EdictClassName));
		
		if (strcmp(EdictClassName, "weapon_gascan") != 0)
			continue;
		
		SDKHook(iEnt, SDKHook_OnTakeDamage, OnTakeDamageGascan);
		
		g_iGascans.Push(iEnt);
		g_iLasthits.Push(-1);
	}
}

void RefreshPropanes()
{	
	UnhookPropane();

	// reset arrays
	g_iPropanes.Clear();
	g_iLasthitProp.Clear();
	
	int iEnt;
	char sEntModel[128];
	while ((iEnt = FindEntityByClassname(iEnt, "prop_physics")) != -1) 
	{
		if (!IsValidEdict(iEnt) || !IsValidEntity(iEnt)) {
			continue;
		}
		
		GetEntPropString(iEnt, Prop_Data, "m_ModelName", sEntModel, sizeof(sEntModel)); 
		if (StrContains(sEntModel, "/props_junk/propanecanister001.mdl", false) != -1) 
		{
			if (view_as<bool>(GetEntProp(iEnt, Prop_Send, "m_isCarryable", 1))) 
			{
				PrintToChatAll("Found propane %i [%s] and hooking it..", iEnt, sEntModel);
				
				SDKHook(iEnt, SDKHook_OnTakeDamage, OnTakeDamagePropane);
					
				g_iPropanes.Push(iEnt);
				g_iLasthitProp.Push(-1);
			}
		}	
	}
}


bool IsClientAndInGame(index)
{
	if (index > 0 && index <= MaxClients)
	{
		return IsClientInGame(index);
	}
	return false;
}
 
void DoVoteMenu()
{
	if (IsVoteInProgress())
		return;
		
	g_bGasVoteInProgress = true;
	
	Menu menu = new Menu(Handle_VoteMenu);
	menu.VoteResultCallback = Handle_VoteResults;
	menu.SetTitle("Who shot the gas?");
	char player[128];
	for (int i = 1; i <= MaxClients; i++)
	{
		if (IS_VALID_SURVIVOR(i))
		{
			Format(player, sizeof(player), "%N", i)
			menu.AddItem(player, player);
		}
	}
	menu.ExitBackButton = false;
	
	int vote_time = hVotingTime.IntValue;
	menu.DisplayVoteToAll(vote_time);
}


void DoVoteMenuExp()
{
	if (IsVoteInProgress())
		return;
 
 	g_bPropaneVoteInProgress = true;
 
	Menu menu = new Menu(Handle_VoteMenu);
	menu.VoteResultCallback = Handle_VotePropResults;
	menu.SetTitle("Who shot the Propane?");
	char player[128];
	for (int i = 1; i <= MaxClients; i++)
	{
		if (IS_VALID_SURVIVOR(i))
		{
			Format(player, sizeof(player), "%N", i)
			AddMenuItem(menu, player, player);
		}
	}
	
	menu.ExitBackButton = false;
	
	int vote_time = hVotingTime.IntValue;
	menu.DisplayVoteToAll(vote_time);
}

public int Handle_VoteMenu(Menu menu, MenuAction action, int param1, int param2)
{
	if (action == MenuAction_End)
	{
		/* This is called after VoteEnd */
		delete menu;
	}
	return 0;
}

public void Handle_VoteResults(Menu menu, int num_votes, int num_clients, const int[][] client_info, int num_items, const int[][] item_info)
{
	int percentage;
	char player[128];
	PrintToChatAll(">> Vote Result <<")

	for (int i = 0; i < num_items; i++)
	{
		int numVotes = item_info[i][VOTEINFO_ITEM_VOTES];
		menu.GetItem(item_info[i][VOTEINFO_ITEM_INDEX], player, sizeof(player));
		percentage = RoundToFloor(((numVotes * 1.0)/num_votes) * 100);
		PrintToChatAll("\x01[\x05%i%s\x01]\x04 %s\x01", percentage, "%", player);
	}
	
	CreateTimer(2.0, GasTimer1);
}

public Action GasTimer1(Handle timer)
{
	PrintToChatAll("\x01Player who actually shot the gas was...")
	CreateTimer(3.0, GasTimer);
	return Plugin_Continue;
}

public Action GasTimer(Handle timer)
{
	PrintToChatAll("\x04  %s", lastFire);
	g_bGasVoteInProgress = false;
	return Plugin_Continue;
}

public Handle_VotePropResults(Menu menu, int num_votes, int num_clients, const int[][] client_info, int num_items, const int[][] item_info)
{
	int percentage;
	char player[128];
	PrintToChatAll("== Vote Result ==")

	for (int i = 0; i < num_items; i++)
	{
		int numVotes = item_info[i][VOTEINFO_ITEM_VOTES];
		menu.GetItem(item_info[i][VOTEINFO_ITEM_INDEX], player, sizeof(player));
		percentage = RoundToFloor(((numVotes * 1.0)/num_votes) * 100);
		PrintToChatAll("\x01[\x05%i%s\x01]\x04 %s\x01", percentage, "%", player);
	}
	
	CreateTimer(2.0, PropaneTimer1);
}

public Action PropaneTimer1(Handle timer)
{
	PrintToChatAll("\x01Player who actually shot the propane was...")
	CreateTimer(3.0, PropaneTimer);
	return Plugin_Continue;
}

public Action PropaneTimer(Handle timer)
{
	PrintToChatAll("\x04  %s", lastExplosion);
	g_bPropaneVoteInProgress = false;
	return Plugin_Continue;
}