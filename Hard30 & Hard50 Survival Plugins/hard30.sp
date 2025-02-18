#include <sourcemod>
#include <sdktools>

#pragma semicolon	1
#pragma newdecls required

#define DIRECTORSCRIPT_TYPE1	"DirectorScript.MapScript.LocalScript.DirectorOptions"

bool g_bTimerActive;

#define MAX_SI	6
char specials[MAX_SI][] =
{
	"smoker",
	"boomer",
	"hunter",
	"jockey",
	"charger",
	"spitter"
};

public Plugin myinfo = 
{
	name = "Hard30 Survival",
	author = "Gravity",
	description = "",
	version = "1.0",
	url = ""
};

public void OnPluginStart()
{
	HookEvent("survival_round_start", Event_OnSurvival);
	HookEvent("round_end", Event_OnRoundEnd);
	
	SetDirectorValues();
}

public void Event_OnSurvival(Event event, const char[] name, bool dontBroadcast)
{
	CreateSpawnerDummy(true);
	g_bTimerActive = true;
	CreateTimer(1.0, Timer_OverrideDirector, _, TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);
}

public void Event_OnRoundEnd(Event event, const char[] name, bool dontBroadcast)
{
	CreateSpawnerDummy(false);
	g_bTimerActive = false;
}

public Action Timer_OverrideDirector(Handle timer)
{
	if (!g_bTimerActive) return Plugin_Stop;
	
	SpawnExtraSI();
	SetDirectorValues();
	return Plugin_Continue;
}

void SpawnExtraSI()
{
	int bot = CreateFakeClient("Infected Bot");			
	if (bot != 0)
	{
		ChangeClientTeam(bot, 3);
		CreateTimer(0.1, kickbotspawner, GetClientUserId(bot), TIMER_FLAG_NO_MAPCHANGE);
	}
	
	int dummy = GetSpawnerDummyIndex();
	if (dummy != -1) 
	{
		char special[64];
		int rndpick = GetRandomInt(0, MAX_SI-1);
		Format(special, sizeof(special), "%s auto", specials[rndpick]);
		CheatCommand(dummy, "z_spawn_old", special);
	}
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

stock void CheatCommand(int client, const char[] command, const char[] argument)
{
	int iflags = GetCommandFlags(command);
	SetCommandFlags(command, iflags & ~FCVAR_CHEAT);
	FakeClientCommand(client, "%s %s", command, argument);
	SetCommandFlags(command, iflags);
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
	SetDirectorVar("SpecialRespawnInterval", "4.0");
	SetDirectorVar("SpecialInitialSpawnDelayMax", "4.0");
	SetDirectorVar("SpecialInitialSpawnDelayMin", "4.0");
	SetDirectorVar("MaxSpecials", "100");
	SetDirectorVar("DominatorLimit", "100");
	SetDirectorVar("BoomerLimit", "5");
	//SetDirectorVar("CommonLimit", "0");
	SetDirectorVar("HunterLimit", "5");
	SetDirectorVar("SmokerLimit", "5");
	SetDirectorVar("ChargerLimit", "2");
	SetDirectorVar("JockeyLimit", "5");
	SetDirectorVar("SpitterLimit", "3");
}

void SetDirectorVar(char[] dvar, char[] dvalue)
{
	L4D2_RunScript("%s.%s <- %s;", DIRECTORSCRIPT_TYPE1, dvar, dvalue);
}

void L4D2_RunScript(const char[] sCode, any ...)
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