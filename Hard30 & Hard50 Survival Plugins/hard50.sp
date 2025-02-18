#include <sourcemod>
#include <l4d2_devstocks>

#pragma semicolon	1
#pragma newdecls required

#define DEBUG	0

#define DIRECTORSCRIPT_TYPE1	"DirectorScript.MapScript.LocalScript.DirectorOptions"

#define SI_SPAWN_INTERVAL	1.0

#define MAX_SI		6
char sSpecialInfected[MAX_SI][] =
{
	"boomer",
	"jockey",
	"hunter",
	"smoker",
	"spitter",
	"charger"
};

public Plugin myinfo = {
	name = "Hard50 Survival",
	author = "Gravity",
	description = "Shortened SI spawning intervals.",
	version = "1.0",
	url = ""
};

public void OnPluginStart()
{
	HookEvent("survival_round_start", Event_OnSurvivalStart);
	HookEvent("player_death", Event_OnDeath);
}

public void OnMapStart()
{
	SetDirectorValues();
}

public void Event_OnSurvivalStart(Event event, const char[] name, bool dontBroadcast)
{
	// Spawn range has to be reset
	// ResetConVar(FindConVar("z_spawn_range"));
	
	CreateSpawnerDummy(true);
	CreateTimer(SI_SPAWN_INTERVAL, Timer_SpawnExtraSI, _, TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);
}

public void Event_OnDeath(Event event, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(event.GetInt("userid"));
	if (client > 0 && GetClientTeam(client) == TEAM_INFECTED && IsFakeClient(client) && GetEntProp(client, Prop_Send, "m_zombieClass") != ZC_TANK)
	{
		// Kick this SI on death so the next one can spawn bit faster
		KickClient(client);
	}
}

public Action Timer_SpawnExtraSI(Handle timer)
{
	if (!IsRoundInProgress()) {
		CreateSpawnerDummy(false);
		return Plugin_Stop;
	}
	
	SetDirectorValues();
	L4D2_StartAssault();
	
	int bot = CreateFakeClient("Infected Bot");
	if (bot != 0)
	{
		ChangeClientTeam(bot, 3);
		CreateTimer(0.1, kickbotspawner, GetClientUserId(bot));
	}
	
	int randomPick = GetRandomInt(0, MAX_SI - 1);
	
	int dummy = GetSpawnerDummyIndex();
	if (dummy != -1)
	{
		char result[64];
		Format(result, sizeof(result), "%s auto", sSpecialInfected[randomPick]);
		
		CheatCommand(dummy, "z_spawn_old", result);
	}
	
	return Plugin_Continue;
}

public Action kickbotspawner(Handle timer, int UserID)
{
	int client = GetClientOfUserId(UserID);
	
	if( client && IsClientInGame(client) && (!IsClientInKickQueue(client)))
	{
		if (IsFakeClient(client)) KickClient(client);
	}
}

void SetDirectorValues()
{
	SetDirectorVar("SpecialRespawnInterval", "1.0");
	SetDirectorVar("SpecialInitialSpawnDelayMin", "1.0");
	SetDirectorVar("SpecialInitialSpawnDelayMax", "1.0");
	SetDirectorVar("MaxSpecials", "100");
	SetDirectorVar("DominatorLimit", "100");
	SetDirectorVar("BoomerLimit", "20");
	SetDirectorVar("HunterLimit", "20");
	SetDirectorVar("SmokerLimit", "20");
	SetDirectorVar("ChargerLimit", "20");
	SetDirectorVar("JockeyLimit", "20");
	SetDirectorVar("SpitterLimit", "20");
	//SetDirectorVar("CommonLimit", "0");
}

void SetDirectorVar(char[] dvar, char[] dvalue)
{
	L4D2_RunScript2("%s.%s <- %s;", DIRECTORSCRIPT_TYPE1, dvar, dvalue);
}

/** credits: stock from timocop
* Runs a single line of vscript code.
* NOTE: Dont use the "script" console command, it startes a new instance and leaks memory. Use this instead!
*
* @param sCode		The code to run.
* @noreturn
*/
void L4D2_RunScript2(const char[] sCode, any ...)
{
	static int iScriptLogic = INVALID_ENT_REFERENCE;
	
	if(!IsValidEnt(EntRefToEntIndex(iScriptLogic))) {
		iScriptLogic = FindEntityByClassname(MaxClients+1, "info_director");	
	}
	
	if(!IsValidEnt(EntRefToEntIndex(iScriptLogic))) {
		iScriptLogic = EntIndexToEntRef(CreateEntityByName("logic_script"));
		if(!IsValidEnt(EntRefToEntIndex(iScriptLogic)))
			SetFailState("Could not create 'logic_script'");
		
		DispatchSpawn(iScriptLogic);
	}

	char sBuffer[512];
	VFormat(sBuffer, sizeof(sBuffer), sCode, 2);
	SetVariantString(sBuffer);
	AcceptEntityInput(iScriptLogic, "RunScriptCode");
}

bool IsValidEnt(int entity)
{
	return (entity > MaxClients && IsValidEntity(entity) && entity != INVALID_ENT_REFERENCE);
}

/*
 * Spawn dummy client which through we call commands.
 * create - true to create a dummy client, false to kick the client if it exists.
*/
void CreateSpawnerDummy(bool create = true)
{
	if (create)
	{
		int botdummy = CreateFakeClient("[SI Controller]");
		if (botdummy != 0)
		{
			ChangeClientTeam(botdummy, 1);
		}
	}
	else
	{
		int dummy = GetSpawnerDummyIndex();
		if (dummy != -1)
			KickClient(dummy);
	}
}

/*
 * Returns index to dummy client in spec.
 * -1 on failure
*/
int GetSpawnerDummyIndex()
{
	for (int i = 1; i <= MaxClients; i++)
	{
		if (!IsClientInGame(i))continue;
		
		if (GetClientTeam(i) == 1 && IsFakeClient(i))
		{
			char sName[64];
			GetClientName(i, sName, sizeof(sName));
			
			if (StrEqual(sName, "[SI Controller]"))
			{
				// Found
				return i;
			}
		}
	}
	return -1;
}