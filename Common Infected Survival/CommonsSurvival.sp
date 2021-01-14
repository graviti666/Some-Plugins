#include <sourcemod>
#include <sdktools>

#pragma semicolon	1
#pragma newdecls required

#define DIRECTORSCRIPT_TYPE1	"DirectorScript.MapScript.LocalScript.DirectorOptions"
#define PLUGIN_TAG	"\x01[\x03Hard 30 Coop\x01]"

ConVar g_hCommonsRate;

int g_iCommonRate;

bool g_bPluginEnabled;
bool g_bSurvivalInProgress;

public Plugin myinfo = 
{
	name = "Common Infected Survival",
	author = "Gravity",
	description = "Survival with nothing but some extra common infected.",
	version = "1.0",
	url = ""
};

public void OnPluginStart()
{
	g_bPluginEnabled = false;
	
	g_hCommonsRate = CreateConVar("commons_survival_rate", "60", "The maximum of CI alive at once. \nDefault survival is maybe like 15");
	g_hCommonsRate.AddChangeHook(CommonsRateOnChanged);
	
	g_iCommonRate = GetConVarInt(g_hCommonsRate);
	
	HookEvent("survival_round_start", Event_OnSurvivalStart);
	HookEvent("round_end", Event_OnSurvivalEnd);
	
	RegConsoleCmd("sm_commonsurvival", Cmd_ToggleMode, "Toggle Commons only survival");
}

public Action Cmd_ToggleMode(int client, int args)
{
	if (g_bSurvivalInProgress)
	{
		PrintToChat(client, "Not allowed to use cmd while survival in progress.");
		return Plugin_Handled;
	}
	
	// Toggle
	if (!g_bPluginEnabled)
	{
		g_bPluginEnabled = true;
		PrintToChatAll("\x05Commons Survival\x01 is loaded.");
		PrintToChatAll("\x01Map will reload in \x043\x01 seconds.");
	
		CreateTimer(3.0, Timer_Reload, TIMER_FLAG_NO_MAPCHANGE);		
	}
	else
	{
		g_bPluginEnabled = false;
		PrintToChatAll("\x05Commons Survival\x01 is unloaded.");
		PrintToChatAll("\x01Map will reload in \x043\x01 seconds.");
	
		CreateTimer(3.0, Timer_Reload, TIMER_FLAG_NO_MAPCHANGE);
	}
	return Plugin_Handled;
}

public Action Timer_Reload(Handle timer)
{
	char map[64];
	GetCurrentMap(map, sizeof(map));
	ForceChangeLevel(map, "reloading for custom mode");
}

public void OnConfigsExecuted()
{
	if (g_bPluginEnabled)
		SetDirectorValues();
}

public void CommonsRateOnChanged(ConVar convar, const char[] oldValue, const char[] newValue)
{
	g_iCommonRate = StringToInt(newValue);
}

public void Event_OnSurvivalStart(Event event, const char[] name, bool dontBroadcast)
{
	g_bSurvivalInProgress = true;
	
	if (g_bPluginEnabled)
	{
		CreateTimer(1.0, Timer_OverrideDirector, TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);
	}
}

public void Event_OnSurvivalEnd(Event event, const char[] name, bool dontBroadcast)
{
	g_bSurvivalInProgress = false;
}

public Action Timer_OverrideDirector(Handle timer)
{
	if (!g_bSurvivalInProgress)
	{
		return Plugin_Stop;
	}
	
	SetDirectorValues();
	return Plugin_Continue;
}

void SetDirectorValues()
{
	// Set custom CI limit
	char sRate[20];
	IntToString(g_iCommonRate, sRate, sizeof(sRate));
	SetDirectorVar("CommonLimit", sRate);
	
	// Disallow SI spawning, could use director_no_specials convar but testing this for now
	SetDirectorVar("BoomerLimit", "0");
	SetDirectorVar("HunterLimit", "0");
	SetDirectorVar("SmokerLimit", "0");
	SetDirectorVar("ChargerLimit", "0");
	SetDirectorVar("JockeyLimit", "0");
	SetDirectorVar("SpitterLimit", "0");
	SetDirectorVar("TankLimit", "0");
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
	
	if (!IsValidEnt(EntRefToEntIndex(iScriptLogic))) {
		iScriptLogic = FindEntityByClassname(MaxClients+1, "info_director");	
	}
	
	if (!IsValidEnt(EntRefToEntIndex(iScriptLogic))) {
		iScriptLogic = EntIndexToEntRef(CreateEntityByName("logic_script"));
		
		if (!IsValidEnt(EntRefToEntIndex(iScriptLogic)))
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