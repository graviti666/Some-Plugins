#include <sourcemod>
#include <sdktools>
//#include <survivalrecorder.inc> // log slayings as misc event

#pragma semicolon 1
#pragma newdecls required

// debug values - TODO make sure these are disabled
#define DEBUG	0
#define DEBUG_NOTANKS	0

#define PLUGIN_HEADER	"\x01<\x04Stuck SI Despawner\x01>"

#define IS_VALID_CLIENT(%1)		(%1 > 0 && %1 <= MaxClients)
#define IS_SURVIVOR(%1)			(GetClientTeam(%1) == 2)
#define IS_INFECTED(%1)			(GetClientTeam(%1) == 3)
#define IS_SPECTATOR(%1)			(GetClientTeam(%1) == 1)
#define IS_VALID_INGAME(%1)		(IS_VALID_CLIENT(%1) && IsClientInGame(%1))
#define IS_VALID_SURVIVOR(%1)		(IS_VALID_INGAME(%1) && IS_SURVIVOR(%1))
#define IS_VALID_SPEC(%1)			(IS_VALID_INGAME(%1) && IS_SPECTATOR(%1))
#define IS_VALID_INFECTED(%1)		(IS_VALID_INGAME(%1) && IS_INFECTED(%1))
#define IS_SURVIVOR_ALIVE(%1)		(IS_VALID_SURVIVOR(%1) && IsPlayerAlive(%1))
#define IS_INFECTED_ALIVE(%1)		(IS_VALID_INFECTED(%1) && IsPlayerAlive(%1))

#define ZC_SMOKER	1
#define ZC_BOOMER	2
#define ZC_HUNTER	3
#define ZC_SPITTER	4
#define ZC_JOCKEY	5
#define ZC_CHARGER	6
#define ZC_TANK		8

#define COLOR_RED					999
#define COLOR_BLUE					200000000
#define COLOR_YELLOW				1238947
#define COLOR_WHITE				9999999

enum	// Movement tolerance levels when considering if an infected is stuck
{
	INDEX_MOVEMENT_LOW = 0,
	INDEX_MOVEMENT_MID,
	INDEX_MOVEMENT_HIGH,
	INDEX_MOVEMENT_MAX
}

float g_fStillLimit[INDEX_MOVEMENT_MAX] =	 // How many seconds to wait until considering an SI stuck if they're not moving at each movement tolerance level
{
	2.0,		// Low movement	   - wait 2 seconds
	3.0,		// Medium movement - wait 3 seconds
	4.0			// High movement   - wait 4 seconds
};

float g_fMovementTolerance[INDEX_MOVEMENT_MAX] = 							// How much movement is allowed at each tolerance level
{
	5.0,	// Low movement if the infected has moved 5 units or less
	20.0,	// Medium movement if the infected has moved 20 units or less
	100.0	// High movement if the infected has moved 100 units or less
};

ConVar g_cvStuckTimer;

int g_iSpawnTime[MAXPLAYERS + 1];
float g_fStuckTime[MAXPLAYERS + 1];
int g_iSeconds;

bool g_bAliveTooLong[MAXPLAYERS + 1];
bool g_bStuckSI[MAXPLAYERS + 1];
bool g_bUsedAbility[MAXPLAYERS + 1];
bool g_bRoundEnd;

float g_fStillLength[MAXPLAYERS + 1][INDEX_MOVEMENT_MAX];
float g_vLastPos[MAXPLAYERS + 1][INDEX_MOVEMENT_MAX][3];	// Tracks the vector position the infected was located last time we checked for movement

const float g_fCheckStuckTimer = 0.5;
const float g_fCheckSIforSlaying = 4.0;
float g_vZeroVec[3] = { 0.0, 0.0, 0.0 };

public Plugin myinfo = {
	name		= "Stuck SI Despawner",
	author		= "khan, Dustin",
	description = "Despawns stuck SI",
	version		= "1.0",
	url			= ""
};

public void OnMapStart()
{
	for (int i = 1; i <= MaxClients; i++)
	{
		g_iSpawnTime[i] = 0;
	}
	g_bRoundEnd = true;
}

public void OnPluginStart()
{
	g_cvStuckTimer = CreateConVar("sm_stuck_SI_Despawner_timer", "30.0", "How many seconds shall we wait until we despawn a stuck SI?");

	HookEvent("player_spawn", Event_OnPlayerSpawn);
	HookEvent("player_death", Event_OnPlayerDeath);
	HookEvent("round_end", Event_RoundEnd, EventHookMode_Post);
	HookEvent("survival_round_start", Event_SurvivalRoundStart, EventHookMode_Post);
	HookEvent("ability_use", Event_AbilityUsed, EventHookMode_Post);
	
	//RegAdminCmd("sm_testtt", Command_TestIsReadyToSlay, ADMFLAG_GENERIC);
}

public void OnConfigsExecuted()
{
	g_iSeconds = g_cvStuckTimer.IntValue;
}

public Action Command_TestIsReadyToSlay(int client, int args)
{
	for (int i = 1; i <= MaxClients; i++)
	{
		if (!IS_INFECTED_ALIVE(i))
		{
			continue;
		}
		
		//g_bAliveTooLong[i] = view_as<bool>(iTime - g_iSpawnTime[i] >= g_iSeconds);
		g_bAliveTooLong[i] = view_as<bool>(g_fStuckTime[i] >= float(g_iSeconds));
		
		PrintToConsole(client, "\n%N", i);
		PrintToConsole(client, "g_bAliveTooLong = %b | g_fStuckTime[i] = %f | float(g_iSeconds) = %f | int g_iseconds = %i (convar value: %i) | g_bStuckSI[i] = %b", g_bAliveTooLong[i], g_fStuckTime[i], float(g_iSeconds), g_iSeconds, g_cvStuckTimer.IntValue, g_bStuckSI[i]);

	}
	
	return Plugin_Handled;
}


public void Event_OnPlayerSpawn(Event event, const char[] name, bool dontBroadcast)
{
	int userid = GetEventInt(event, "userid");
	int client = GetClientOfUserId(userid);
	
	if (!IS_VALID_INFECTED(client))
	{
		return;
	}

	#if DEBUG_NOTANKS
	if (IsTank(client))
	{
		ForcePlayerSuicide(client);
		return;
	}
	#endif
	
	char ClientName[32];
	GetClientName(client, ClientName, sizeof(ClientName));
	if (StrContains(ClientName, "Infected Bot", false) != -1)
	{
		// Ignore "Infected Bot" from admin manually spawning an infected
		return;
	}
	
	ResetLastPos(client, g_vZeroVec);
	
	if (!IsTank(client))
	{
		g_iSpawnTime[client] = GetTime();
		g_fStuckTime[client] = 0.0;
		g_bStuckSI[client] = false;
		g_bUsedAbility[client] = false;
		CreateTimer(g_fCheckStuckTimer, Timer_CheckForStuck, GetClientUserId(client), TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);

		#if DEBUG
		SetColor(client, COLOR_WHITE);
		#endif
	}
	
	return;
}

public Action Timer_CheckForStuck(Handle hTimer, int userID)
{
	int client = GetClientOfUserId(userID);
	
	if (g_bRoundEnd || !IS_INFECTED_ALIVE(client))
	{
		KillTimer(hTimer);
		hTimer = INVALID_HANDLE;
		return Plugin_Handled;
	}

	float fPos[3];
	GetClientAbsOrigin(client, fPos);

	if (!g_bUsedAbility[client])
	{	
		bool bInTolerance;
		for (int i = 0; i < INDEX_MOVEMENT_MAX; i++)
		{
			float fDist = GetVectorDistance(fPos, g_vLastPos[client][i]);
			if (fDist < g_fMovementTolerance[i])
			{
				// Update the movement status for this tolerance range
				// If the infected has been staying below this tolerance range for too long then this will mark it as stuck
				UpdateMovementStatus(client, i);
				bInTolerance = true;
				break;
			}
			else
			{
				g_vLastPos[client][i] = fPos;
			}
			
			// TODO needed ?
			if (!bInTolerance)
			{
				ResetLastPos(client, fPos);
			}
		}

		if (g_bStuckSI[client])
		{
			g_fStuckTime[client] += g_fCheckStuckTimer;
		}
		else
		{
			g_fStuckTime[client] = 0.0;
		}

	}
	else
	{
		#if DEBUG
		PrintToChatAll("[debug] %N recently used ability!", client);
		#endif
		// Just reset the last known position of the infected.
		ResetLastPos(client, fPos);
	}
	
	return Plugin_Continue;
}

public Action Timer_MarkSIReadyForSlaying(Handle Timer)
{
	if (g_bRoundEnd)
	{
		return Plugin_Stop;
	}
	
	//int iTime = GetTime();
	for (int i = 1; i <= MaxClients; i++)
	{
		if (!IS_INFECTED_ALIVE(i))
		{
			continue;
		}
		
		g_bAliveTooLong[i] = view_as<bool>(g_fStuckTime[i] >= float(g_iSeconds));
		
		if (g_bAliveTooLong[i] && g_bStuckSI[i])
		{
			
			#if DEBUG
			SetColor(i, COLOR_YELLOW);
			#endif
			
			char sBuffer[256];
			Format(sBuffer, sizeof(sBuffer), "%s \x03%N\x01 in stuck position too long. Slaying...", PLUGIN_HEADER, i);
			PrintToAllRealClients(sBuffer);

			Format(sBuffer, sizeof(sBuffer), "%s \x03%N\x01 stuck for \x04%i\x01 seconds. Slaying...", PLUGIN_HEADER, i, g_iSeconds);
			//survRecorder_LogMiscEvent(sBuffer);
			ForcePlayerSuicide(i);
		}
	}
	
	return Plugin_Continue;
}

public void Event_SurvivalRoundStart(Event event, const char[] name, bool dontBroadcast)
{
	g_bRoundEnd = false;
	CreateTimer(g_fCheckSIforSlaying, Timer_MarkSIReadyForSlaying, _, TIMER_REPEAT);
}


public void Event_RoundEnd(Event event, const char[] name, bool dontBroadcast)
{
	for (int i = 1; i <= MaxClients; i++)
	{
		g_iSpawnTime[i] = 0;
	}
	g_bRoundEnd = true;
}

public void Event_OnPlayerDeath(Event event, const char[] name, bool dontBroadcast)
{
	int userid = GetEventInt(event, "userid");
	int client = GetClientOfUserId(userid);
   
	if (client > 0)
	{
		g_iSpawnTime[client] = 0;
		g_fStuckTime[client] = 0.0;
		g_bStuckSI[client] = false;
	}
}


/*
 * Update the tracking data on how much the infected is moving for a given movement size
 * If the infected hasn't moved enough then this will mark them as stuck
 */
public void UpdateMovementStatus(int client, int iMovementSize)
{
	bool bMarkInfectedAsStuck;
	for (int i = 0; i < INDEX_MOVEMENT_MAX; i++)
	{
		if (i < iMovementSize)
		{
			g_fStillLength[client][i] = 0.0;
		}
		else
		{
			g_fStillLength[client][i] += g_fCheckStuckTimer;
			
			if (!IsTank(client) && g_fStillLength[client][i] >= g_fStillLimit[i])
			{
				bMarkInfectedAsStuck = true;
				break;
			}
		}
	}
	
	#if DEBUG
	if (!g_bStuckSI[client] && bMarkInfectedAsStuck)
	{
		SetColor(client, COLOR_RED);
	}

	// if SI just now got marked as unstuck change to blue (then white after 7 seconds if still unstuck)
	if (g_bStuckSI[client] && !bMarkInfectedAsStuck)
	{
		SetColor(client, COLOR_BLUE);
		CreateTimer(7.0, Timer_ChangeBackToWhite, GetClientUserId(client));
	}
	
	#endif

	g_bStuckSI[client] = bMarkInfectedAsStuck;
}

public Action Timer_RemoveColor(Handle timer, int UserID)
{
	int client = GetClientOfUserId(UserID);
	if (IS_INFECTED_ALIVE(client))
	{
		ClearGlow(client);
	}
	return Plugin_Handled;
}

public Action Timer_ChangeBackToWhite(Handle timer, int UserID)
{
	int client = GetClientOfUserId(UserID);
	// final check to make sure it didn't get changed back to stuck
	if (IS_INFECTED_ALIVE(client) && !g_bStuckSI[client])
	{
		SetColor(client, COLOR_WHITE);
	}
	return Plugin_Handled;
}

void ResetLastPos(int client, float fPos[3])
{
	// Update the last position of the SI
	for (int i = 0; i < INDEX_MOVEMENT_MAX; i++)
	{
		g_vLastPos[client][i] = fPos;
		g_fStillLength[client][i] = 0.0;
	}
}

bool IsTank(int client)
{
	int zInfectedClass = GetEntProp(client, Prop_Send, "m_zombieClass");
	return zInfectedClass == ZC_TANK;
}

void SetColor(int client, int color)
{
	if (IS_VALID_INGAME(client))
	{
		SetEntProp(client, Prop_Send, "m_iGlowType", 3);
		SetEntProp(client, Prop_Send, "m_glowColorOverride", color);
	}
}

void ClearGlow(int client)
{
	if (IS_VALID_INGAME(client))
	{
		SetEntProp(client, Prop_Send, "m_iGlowType", 0);
		SetEntProp(client, Prop_Send, "m_glowColorOverride", 0);
	}
}

public Action Event_AbilityUsed(Event event, const char[] name, bool dontBroadcast)
{
	// Track that the infected has used it's ability. Will stop control of the infected if in this case.
	int client = GetClientOfUserId(GetEventInt(event, "userid"));
	g_bUsedAbility[client] = true;
	
	// Wait a second to reset g_bUsedAbility to false - infected can't be considered stuck until this is back to false
	// Note: this might not actually work as intended for hunters since they can use their ability in quick succession but I think it's unlikely that a
	// 		 hunter is constantly jumping and gets detected as stuck, so whatever.. TODO: fix this if it becomes a problem
	float fTimerDelay = 2.0;	// wait 2 seconds for most SI
	int zClass = GetEntProp(client, Prop_Send, "m_zombieClass");
	switch (zClass)
	{
		case ZC_SMOKER:
		{
			// Wait until smoker tongue is recharged
			fTimerDelay = 15.0;
		}
		case ZC_CHARGER:
		{
			// Wait for charger to finish his charge - This isn't an exact number but is probably close enough..
			fTimerDelay = 5.0;
		}
		case ZC_TANK:
		{
			// Delay after throwing a rock
			fTimerDelay = 2.0;
		}
	}
	
	CreateTimer(fTimerDelay, Timer_ResetIsUsingAbility, client);
}

public Action Timer_ResetIsUsingAbility(Handle timer, any client)
{
	// Infected should be finished using it's ability by now. Reset it. 
	g_bUsedAbility[client] = false;
}

// just used cause logging misc event and printing to all would cause a double printout on sourceTV demo recordings
void PrintToAllRealClients(const char[] sBuffer)
{
	for (int i = 1; i <= MaxClients; i++)
	{
		if (!IsClientInGame(i) || IsFakeClient(i)) continue;
		PrintToChat(i, sBuffer);
	}
}