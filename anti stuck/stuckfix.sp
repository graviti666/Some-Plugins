/*
	// Sends an input to tell all existing nextbots to StartAssault() function | 'Dont hide etc something' 
	// Seems to fix SI not climbing ladders.
	// Bugs: smokers wont move 'run away' when they've attacked and this is fired.
	L4D2_RunScript("StartAssault()");
	
	// Tells a nextbot to target a specific player
	//L4D2_RunScript("CommandABot({cmd=0,bot=GetPlayerFromUserID(%i),target=GetPlayerFromUserID(%i)})", GetClientUserId(player), GetClientUserId(survivor));
	
	Logic:
	
	Updates SI origin every second and checks after few seconds if previous position is near last 
	also checks around the map if position is near a stuckspot which they'll be teleported out of.
	
	1st detection: Does a push attempt
	2nd detection: Tells SI to move to a nearest survivor position.
	3rd detection: Tells SI to StartAssault() function which should make them attack almost immediatly if still or hiding for some reason.
*/
#include <sourcemod>
#include <sdktools>

#pragma semicolon		1
#pragma newdecls required

#define DEBUG	0

#define SURVIVOR_TEAM		2
#define INFECTED_TEAM		3

#define ZC_TANK		8

#define CFG_PATH	"data/stuckfix_coordinates.cfg"

ConVar g_hPluginEnabled;

// Globals
float g_fLastPos[MAXPLAYERS + 1][3];

int g_iAliveTimer[MAXPLAYERS + 1];
int g_iStuckDetections[MAXPLAYERS + 1];

bool g_bRoundInProgress;
bool bStuckSpotFirstSaved;

bool g_bShouldForceMovement[MAXPLAYERS + 1];

ArrayList g_hStuckSpotsArray;

public Plugin myinfo = 
{
	name = "stuckfix",
	author = "Gravity",
	description = "Tries to free 'stuck' SI by teleporting out of spots / pushing.",
	version = "1.0",
	url = ""
};

public void OnPluginStart()
{
	g_hPluginEnabled = CreateConVar("stuckfix_enabled", "1", "Enable or disable plugin. 1 = on | 0 = off", 0, true, 0.0, true, 1.0);
	
	LoadTranslations("common.phrases.txt");
	
	HookEvent("player_spawn", Event_OnPlayerSpawn);
	HookEvent("player_death", Event_OnPlayerDeath);
	HookEvent("survival_round_start", Event_OnSurvivalStart);
	HookEvent("round_end", Event_OnRoundEnd);
	
	g_hStuckSpotsArray = CreateArray(128);
	
	RegAdminCmd("sm_stuckspots", Cmd_ManageStuckSpots, ADMFLAG_ROOT);
	
	#if DEBUG
	RegAdminCmd("sm_getallpos", Cmd_GetSavedArrayPos, ADMFLAG_ROOT);
	RegAdminCmd("sm_movetype", Cmd_TestMoveTypesOnSI, ADMFLAG_ROOT);
	#endif
}

public void OnMapStart()
{
	for (int i = 1; i <= MaxClients; i++)
	{
		g_iAliveTimer[i] = 0;
		g_iStuckDetections[i] = 0;
		g_bShouldForceMovement[i] = false;
	}
}

public void OnConfigsExecuted()
{
	char sPath[PLATFORM_MAX_PATH];
	BuildPath(Path_SM, sPath, sizeof(sPath), CFG_PATH);
	
	if(!FileExists(sPath))
	{
		KeyValues kv = new KeyValues("map_coordinates");
		kv.ExportToFile(sPath);
		delete kv;
	}
	
	// Cache stuckspots from kv file
	InitStuckSpotsFromFile();
}

// DEBUG & TEST FUNCTIONS
#if DEBUG
public Action Cmd_GetSavedArrayPos(int client, int args)
{
	float pos[3], target[3];
	
	int size = GetArraySize(g_hStuckSpotsArray);
	
	for (int i = 0; i < size; i++)
	{
		Handle hMap = GetArrayCell(g_hStuckSpotsArray, i);
		GetTrieArray(hMap, "position", pos, sizeof(pos));
		GetTrieArray(hMap, "target", target, sizeof(target));
		
		PrintToChat(client, "pos: %f %f %f", pos[0], pos[1], pos[2]);
		PrintToChat(client, "target: %f %f %f", target[0], target[1], target[2]);
	}
	
	return Plugin_Handled;
}

public Action Cmd_TestMoveTypesOnSI(int client, int args)
{
	int player;
	for (int i = 1; i <= MaxClients; i++)
	{
		if (!IsClientInGame(i))continue;
		
		if(GetClientTeam(i) == INFECTED_TEAM && IsPlayerAlive(i) && IsFakeClient(i))
		{
			player = i;
		}
	}
	
	PrintToChat(client, "Movetype on %N set!", player);
	
	int survivor = GetNearestSurvivor();
	if (survivor != 0)
	{
		PrintToChat(client, "(%N) nearest survivor is: %N", player, survivor);
		
		float dist;
		float clientOrg[3], survivorOrg[3];
		
		GetClientAbsOrigin(player, clientOrg);
		GetClientAbsOrigin(survivor, survivorOrg);
				
		dist = GetVectorDistance(clientOrg, survivorOrg);
		PrintToChat(client, "%N - %N distance = %.3f", player, survivor, dist);
		
		SetEntityMoveType(player, MOVETYPE_ISOMETRIC);
		
		// Tells a nextbot to target a specific player
		//L4D2_RunScript("CommandABot({cmd=0,bot=GetPlayerFromUserID(%i),target=GetPlayerFromUserID(%i)})", GetClientUserId(player), GetClientUserId(survivor));
		
		// CommandABot: cmd=Attack, bot=SI
		L4D2_RunScript("CommandABot({cmd=1,pos=Vector(%f, %f, %f),bot=GetPlayerFromUserID(%i)})", 
		survivorOrg[0], survivorOrg[1], survivorOrg[2], GetClientUserId(player));
		
		g_bShouldForceMovement[player] = true;
		
		CreateTimer(3.5, Timer_Jump, GetClientUserId(player), TIMER_REPEAT);
		
		CreateTimer(10.0, Timer_ForceMovement, GetClientUserId(player));
	}
	
	return Plugin_Handled;
}

public Action Timer_Jump(Handle timer, int data)
{
	int client = GetClientOfUserId(data);
	if(client && IsClientInGame(client))
	{
		if( !g_bShouldForceMovement[client] ) {
			return Plugin_Stop;
		}
		
		float vel[3];
		GetEntPropVector(client, Prop_Data, "m_vecAbsVelocity", vel);
		
		vel[2] += 260.0;
		TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, vel);
	}
	return Plugin_Continue;
}

public Action Timer_ForceMovement(Handle timer, int data)
{
	int client = GetClientOfUserId(data);
	if(client && IsClientInGame(client))
	{
		SetEntityMoveType(client, MOVETYPE_WALK);
		PrintToChatAll("Stopping view timer %N", client);
		g_bShouldForceMovement[client] = false;
	}
}
#endif
// <- END OF DEBUG ->

public Action Cmd_ManageStuckSpots(int client, int args)
{
	if(!client)
	{
		ReplyToCommand(client, "Command is in-game only.");
		return Plugin_Handled;
	}
	
	if(args == 0) {
		ReplyToCommand(client, "sm_stuckspots <add><list><wipe>");
		return Plugin_Handled;
	}
	
	if(args > 0)
	{
		char sArg[32];
		GetCmdArg(1, sArg, sizeof(sArg));
		
		if(StrEqual(sArg, "add"))
		{
			static float firstPos[3], secondPos[3];
	
			if(!bStuckSpotFirstSaved)
			{
				GetClientAbsOrigin(client, firstPos);
		
				PrintToChat(client, "\x01first location: \x04%f %f %f\x01 saved.", firstPos[0], firstPos[1], firstPos[2]);
				PrintToChat(client, "\x01Move to a target teleport position for next save.");
				bStuckSpotFirstSaved = true;
			}
			else
			{
				char sName[42];
				GetCmdArg(2, sName, sizeof(sName));
				
				GetClientAbsOrigin(client, secondPos);
				
				if(args == 2) {
					PrintToChat(client, "\x01second location: \x04%f %f %f\x01 Config name: \x04%s\x01 saved.", secondPos[0], secondPos[1], secondPos[2], sName);
					PrintToChat(client, "Reload map for changes to take effect.");
					
					SaveStuckSpotsToFile(firstPos, secondPos, sName);
		
					bStuckSpotFirstSaved = false;
				}
				else
				{
					ReplyToCommand(client, "Please enter a name for this config. sm_stuckspots add <name>");
					return Plugin_Handled;
				}
			}
		}
		else if(StrEqual(sArg, "list"))
		{
			if( GetAndDisplayConfigs(client) )
			{
				PrintToChat(client, "Check console output.");
			}
			else
			{
				PrintToChat(client, "Couldn't retrieve configs for this map.");
			}
		}
		else if(StrEqual(sArg, "wipe"))
		{
			if( bDeleteSavedConfig() )
			{
				char sMap[32];
				GetCurrentMap(sMap, sizeof(sMap));
					
				PrintToChat(client, "Deleted (%s) configs!", sMap);
			}
			else
			{
				PrintToChat(client, "Couldn't delete map configs.");
			}
		}
	}
	
	return Plugin_Handled;
}

/**************************************
	Stuck spots kv stuff
**************************************/

// dustin's
void kv_goToTop(KeyValues kv)
{
	while (kv.NodesInStack() != 0)
		kv.GoBack();
}

int kv_countSubDirectories(KeyValues kv)
{
	if (!kv.GotoFirstSubKey(false))
	{
		return 0;
	}
	
	int count = 1; // starting at first sub key
	while (kv.GotoNextKey(false))
	{
		count++;
	}
	
	kv.GoBack();
	return count;
}

// Display configs count
bool GetAndDisplayConfigs(int client)
{
	char sPath[PLATFORM_MAX_PATH];
	BuildPath(Path_SM, sPath, sizeof(sPath), CFG_PATH);
	
	KeyValues kv = new KeyValues("map_coordinates");
	
	// Import file
	kv.ImportFromFile(sPath);
	kv_goToTop(kv);
	
	char sMap[32];
	GetCurrentMap(sMap, sizeof(sMap));
	
	if(!kv.JumpToKey(sMap, false))
	{
		delete kv;
		return false;
	}
	
	if(!kv.GotoFirstSubKey(false))
	{
		delete kv;
		return false;
	}
	
	float fPos[3], fPosTarget[3];
	char sSectName[42];
	
	PrintToConsole(client, "");
	PrintToConsole(client, "Stuck Spot Configs:");
	PrintToConsole(client, "map: %s", sMap);
	PrintToConsole(client, "");
	
	do
	{
		kv.GetString("Name", sSectName, sizeof(sSectName));
		kv.GetVector("position", fPos);
		kv.GetVector("target_position", fPosTarget);
	
		PrintToConsole(client, "Name: %s", sSectName);
		PrintToConsole(client, "position: %f %f %f", fPos[0], fPos[1], fPos[2]);
		PrintToConsole(client, "target_position: %f %f %f", fPosTarget[0], fPosTarget[1], fPosTarget[2]);
		PrintToConsole(client, "");
		
	} while (kv.GotoNextKey(false));
	
	kv_goToTop(kv);
	
	delete kv;
	return true;
}

// Delete kv configs function
bool bDeleteSavedConfig()
{
	char sPath[PLATFORM_MAX_PATH];
	BuildPath(Path_SM, sPath, sizeof(sPath), CFG_PATH);
	
	KeyValues kv = new KeyValues("map_coordinates");
	
	// Import file
	kv.ImportFromFile(sPath);
	kv_goToTop(kv);
	
	char sMap[32];
	GetCurrentMap(sMap, sizeof(sMap));
	
	if(!kv.JumpToKey(sMap, false))
	{
		delete kv;
		return false;
	}
	
	kv.DeleteThis();
	
	kv_goToTop(kv);
	kv.ExportToFile(sPath);
	
	delete kv;
	
	return true;
}

bool SaveStuckSpotsToFile(float position[3], float targetposition[3], const char[] spotname)
{
	char sPath[PLATFORM_MAX_PATH];
	BuildPath(Path_SM, sPath, sizeof(sPath), CFG_PATH);
	
	KeyValues kv = new KeyValues("map_coordinates");
	
	// Import file
	kv.ImportFromFile(sPath);
	kv_goToTop(kv);
	
	// Jump to / create map key
	char sMap[32];
	GetCurrentMap(sMap, sizeof(sMap));
	
	kv.JumpToKey(sMap, true);
	
	int iName = kv_countSubDirectories(kv) + 1;
	
	char sName[12];
	IntToString(iName, sName, sizeof(sName));
	
	kv.JumpToKey(sName, true);
	
	kv.SetString("Name", spotname);
	kv.SetVector("position", position);
	kv.SetVector("target_position", targetposition);
	
	kv_goToTop(kv);
	kv.ExportToFile(sPath);
	
	delete kv;
	
	return true;
}

bool InitStuckSpotsFromFile()
{
	// Clear any pre-existing entries in the array
	ClearArray(g_hStuckSpotsArray);
	
	char sPath[PLATFORM_MAX_PATH];
	BuildPath(Path_SM, sPath, sizeof(sPath), CFG_PATH);
	
	KeyValues kv = new KeyValues("map_coordinates");
	
	// Import file
	kv.ImportFromFile(sPath);
	kv_goToTop(kv);
	
	char sMap[32];
	GetCurrentMap(sMap, sizeof(sMap));
	
	if(!kv.JumpToKey(sMap, false))
	{
		delete kv;
		return;
	}
	
	float vecPos[3], vecTarget[3];
	
	if(kv.GotoFirstSubKey(false))
	{
		do
		{
			kv.GetVector("position", vecPos);
			kv.GetVector("target_position", vecTarget);
			
			// cache the vector coordinates onto the array
			Handle hMap = CreateTrie();
			SetTrieArray(hMap, "position", vecPos, 3);
			SetTrieArray(hMap, "target", vecTarget, 3);
			PushArrayCell(g_hStuckSpotsArray, hMap);
			
		} while (kv.GotoNextKey(false));
	}
}

/**********************************************
	Events
***********************************************/

public void Event_OnSurvivalStart(Event event, const char[] name, bool dontBroadcast)
{
	g_bRoundInProgress = true;
}

public void Event_OnRoundEnd(Event event, const char[] name, bool dontBroadcast)
{
	if( g_bRoundInProgress )
	{
		g_bRoundInProgress = false;
	}
}

public void Event_OnPlayerDeath(Event event, const char[] name, bool dontBroadcast)
{
 	// Is plugin enabled ?
	if ( !GetConVarBool(g_hPluginEnabled) ) return;
	
	int userid = GetEventInt(event, "userid");
	int client = GetClientOfUserId(userid);
	
	if ( client > 0 )
	{
		// This SI user id died clear the timer for him anyway
		g_iAliveTimer[client] = 0;
		g_iStuckDetections[client] = 0;
	}
}

public void Event_OnPlayerSpawn(Event event, const char[] name, bool dontBroadcast)
{
	// Is plugin enabled ?
	if ( !GetConVarBool(g_hPluginEnabled) ) return;
	
	int client = GetClientOfUserId(GetEventInt(event, "userid"));
	
	if ( client && IsClientInGame(client) && GetClientTeam(client) == INFECTED_TEAM )
	{
		if( IsSpecialInfected(client) || IsTank(client) )
		{
			// Update SI position every few second
			CreateTimer(5.0, Timer_CheckStuckSpots, GetClientUserId(client), TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);
			
			// Start getting time alive
			g_iAliveTimer[client] = GetTime();
			
			#if DEBUG
			PrintToChatAll("starting timer for %N", client);
			#endif
		}
	}
}

public Action Timer_CheckStuckSpots(Handle timer, int data)
{
	int client = GetClientOfUserId(data);
	
	if( client && IsClientInGame(client) && IsPlayerAlive(client) )
	{
		// Update the SI origin
		GetClientAbsOrigin(client, g_fLastPos[client]);
		
		// If position what we have cached x seconds ago is close radius to this one
		CreateTimer(1.0, Timer_CheckPosition, GetClientUserId(client), TIMER_FLAG_NO_MAPCHANGE);
		
		// Slay if SI was alive for more than 2.5min
		if( (GetTime() - g_iAliveTimer[client]) >= 150 )
		{
			#if DEBUG
			int time = GetTime() - g_iAliveTimer[client];
			PrintToChatAll("%N was slayed for being alive: %i seconds", client, time);
			#endif
			
			if( !IsTank(client) )
			{
				ForcePlayerSuicide(client);
				g_iAliveTimer[client] = 0;
			}
		}
	}
}

public Action Timer_CheckPosition(Handle timer, int data)
{
	int client = GetClientOfUserId(data);
	
	if( client && IsClientInGame(client) )
	{
		// Is not moving
		if( IsNotMoving(client) )
		{
			g_iStuckDetections[client]++;
			
			#if DEBUG
			PrintToChatAll("detections: %i for %N(%i)", g_iStuckDetections[client], client, GetClientUserId(client));
			#endif
			
			// If SI not moving check if he within a radius for a 'stuckspot' and teleport him out.
			// Spots are looked up from kv file on map start.
			IsAtNotAllowedSpot(client);	
			
			if(g_iStuckDetections[client] == 1)
			{
				// Doesnt have direct line of sight or pinning someone
				if (GetSIAbilityState(client) || L4D_HasVisibleThreats(client) ) 
				{
					#if DEBUG
					PrintToChatAll("%N pinning/has los skipping..", client);
					#endif
					return Plugin_Continue;
				}
				
				TrySetMovement(client);
				TryToPush(client);
			}
			
			else if( g_iStuckDetections[client] == 2 )
			{
				int survivor = GetNearestSurvivor();
				if(survivor != 0)
				{
					float survivorOrg[3];
					GetClientAbsOrigin(survivor, survivorOrg);
		
					L4D2_RunScript("CommandABot({cmd=1,pos=Vector(%f, %f, %f),bot=GetPlayerFromUserID(%i)})", 
					survivorOrg[0], survivorOrg[1], survivorOrg[2], GetClientUserId(client));
				}
			}
			
			else if( g_iStuckDetections[client] >= 3 )
			{
				// Desperate last trick in sleeve
				L4D2_RunScript("StartAssault()");
				
				g_iStuckDetections[client] = 0;
			}
		}
	}
	
	return Plugin_Stop;
}

bool IsAtNotAllowedSpot(int client)
{
	float pos[3], target[3];
	
	int size = GetArraySize(g_hStuckSpotsArray);
	
	// iterative lookup of all items in the array
	for (int i = 0; i < size; i++)
	{
		Handle hMap = GetArrayCell(g_hStuckSpotsArray, i);
		GetTrieArray(hMap, "position", pos, sizeof(pos));
		GetTrieArray(hMap, "target", target, sizeof(target));
		
		if(GetVectorDistance(g_fLastPos[client], pos) < 100.0)
		{
			TeleportEntity(client, target, NULL_VECTOR, NULL_VECTOR);		
			
			#if DEBUG
			PrintToChatAll("%N teleported to (%f %f %f)", client, target[0], target[1], target[2]);
			#endif
			
			return true;
		}
	}
	
	return false;
}

// Add a velocity impulse to push SI
void TryToPush(int client)
{
	float temp[3];
	GetEntPropVector(client, Prop_Data, "m_vecAbsVelocity", temp);
	
	int rnd_test = GetRandomInt(1, 3);
	
	switch(rnd_test)
	{
		case 1:
		{
			float random = GetRandomFloat(350.0, 380.0);
			
			temp[0] += random;
			
			SetEntPropVector(client, Prop_Data, "m_vecAbsVelocity", temp);
		}
		case 2:
		{
			float random = GetRandomFloat(350.0, 380.0);
			
			temp[1] += random;
			
			SetEntPropVector(client, Prop_Data, "m_vecAbsVelocity", temp);
		}
		case 3:
		{
			float random = GetRandomFloat(251.0, 300.0);
			
			temp[2] += random;
			
			SetEntPropVector(client, Prop_Data, "m_vecAbsVelocity", temp);
		}
	}
}

/*********************************
	Shared stuff
*********************************/

// Makes the SI move in a low friction glide state or something
void TrySetMovement(int client)
{
	SetEntityMoveType(client, MOVETYPE_ISOMETRIC);
	CreateTimer(2.5, Timer_ResetMovement, client);
}

// Reset movetype to normal
public Action Timer_ResetMovement(Handle timer, any data)
{
	int client = data;
	if(client && IsClientInGame(client))
	{
		SetEntityMoveType(client, MOVETYPE_WALK);
	}
}

bool IsNotMoving(int client)
{
	float currentpos[3];
	GetClientAbsOrigin(client, currentpos);
	
	// still withing this radius
	if( GetVectorDistance(g_fLastPos[client], currentpos) < 30.0 )
	{
		// Not moving
		return true;
	}
	
	// Is moving
	return false;
}

// True if client is a Tank
bool IsTank(int client)
{
	if ( client > 0 && client <= MaxClients && IsClientInGame(client) && GetClientTeam(client) == INFECTED_TEAM )
	{
		int class = GetEntProp(client, Prop_Send, "m_zombieClass");
		if( class == ZC_TANK )
		{
			return true;
		}
	}
	return false;
}

// True if the client has visible threats, false otherwise
bool L4D_HasVisibleThreats(int client)
{
	if( GetEntProp(client, Prop_Send, "m_hasVisibleThreats") )
	{
		return true;
	}
	else return false;
}

//	true if the SI is using its ability ( pinning someone )
bool GetSIAbilityState( int client )
{
	bool bAbilityInUse = false;
	if( IsSpecialInfected(client) )
	{
		if( GetEntProp(client, Prop_Send, "m_tongueVictim") > 0 ) 	bAbilityInUse = true;
		if( GetEntProp(client, Prop_Send, "m_pounceVictim") > 0 ) 	bAbilityInUse = true;
		if( GetEntProp(client, Prop_Send, "m_carryVictim") > 0 ) 	bAbilityInUse = true;
		if( GetEntProp(client, Prop_Send, "m_pummelVictim") > 0 ) 	bAbilityInUse = true;
		if( GetEntProp(client, Prop_Send, "m_jockeyVictim") > 0 ) 	bAbilityInUse = true;
	}
	return bAbilityInUse;
}

bool IsSpecialInfected(int client)
{
	if( client > 0 && client <= MaxClients && IsClientInGame(client) && GetClientTeam(client) == INFECTED_TEAM )
	{
		int class = GetEntProp(client, Prop_Send, "m_zombieClass");
		if( class >= 1 && class < ZC_TANK )
		{
			return true;
		}
	}
	return false;
}

// credits: stock from timocop (alliedmodder forums)
/**
* Runs a single line of vscript code.
* NOTE: Dont use the "script" console command, it startes a new instance and leaks memory. Use this instead!
*
* @param sCode		The code to run.
* @noreturn
*/
void L4D2_RunScript(const char[] sCode, any:...)
{
	int iScriptLogic;
	if(iScriptLogic == INVALID_ENT_REFERENCE || !IsValidEntity(iScriptLogic)) {
		iScriptLogic = EntIndexToEntRef(CreateEntityByName("logic_script"));
		if(iScriptLogic == INVALID_ENT_REFERENCE || !IsValidEntity(iScriptLogic))
			SetFailState("Could not create 'logic_script'");
		
		DispatchSpawn(iScriptLogic);
	}
	
	static char sBuffer[512];
	VFormat(sBuffer, sizeof(sBuffer), sCode, 2);
	
	SetVariantString(sBuffer);
	AcceptEntityInput(iScriptLogic, "RunScriptCode");
}

// @return: nearest survivor index from an SI client's position
// credit: https://forums.alliedmods.net/showthread.php?p=1920200
int GetNearestSurvivor()
{
	// Variables to store
	float clientOrigin[3];
	float searchOrigin[3];
	float near;
	float distance;
	
	// nearest client
	int nearest;
	
	// SI search
	for (int i = 1; i <= MaxClients; i++)
	{
		if (!IsClientInGame(i))continue;
		
		nearest = 0;
		near = 0.0;
		
		if(GetClientTeam(i) == INFECTED_TEAM && IsPlayerAlive(i) && IsFakeClient(i)) {
			GetClientAbsOrigin(i, clientOrigin);
		}
		
		// Survivor search
		for (int ii = 1; ii <= MaxClients; ii++)
		{
			if (!IsClientInGame(ii) || GetClientTeam(ii) == 1 || !IsPlayerAlive(ii))continue;
			
			if(GetClientTeam(ii) == SURVIVOR_TEAM) {
				GetClientAbsOrigin(ii, searchOrigin);
			}
			
			distance = GetVectorDistance(clientOrigin, searchOrigin);
			
			// Is he more near to the player as the player before?
			if(near == 0.0) 
			{
				near = distance;
				nearest = ii;
			}
			
			if(distance < near)
			{
				near = distance;
				nearest = ii;
			}
		}
	}
	return nearest;
}