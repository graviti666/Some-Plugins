#include <sourcemod>
#include <sdktools>

#pragma semicolon	1
#pragma newdecls required

#define DIRECTORSCRIPT_TYPE1	"DirectorScript.MapScript.LocalScript.DirectorOptions"
#define PLUGIN_TAG	"\x01[\x03Hard 30 Coop\x01]"

Handle g_hOverrideTimer;
Handle g_hStatsTimer;

bool g_bModeEnabled;

bool g_bEventsHooked;

int g_iMapTime;
int g_iSIKills;

#define COLOR_RED		999
#define COLOR_BLUE		200000000
#define COLOR_YELLOW	1238947
#define COLOR_WHITE		9999999

public Plugin myinfo = 
{
	name = "Hard 30 Coop",
	author = "Gravity",
	description = "Coop mode with 30 SI spawn waves with around 5-6 seconds grace period or more so while progressing through.",
	version = "1.0",
	url = ""
}

public void OnPluginStart()
{
	RegAdminCmd("sm_hard30", Cmd_LoadHard30CoopMode, ADMFLAG_ROOT, "Toggle hard30 coop on/off.");
}

public void OnConfigsExecuted()
{
	if (g_bModeEnabled && !g_bEventsHooked)
	{
		HookEvents();
		
		if (g_hOverrideTimer != null)
			g_hOverrideTimer = null;
			
		if (g_hStatsTimer != null)
			g_hStatsTimer = null;
	}
	else
	{
		if (g_bEventsHooked && !g_bModeEnabled)
		{
			RemoveEvents();
			
			if (g_hOverrideTimer != null)
				g_hOverrideTimer = null;
				
			if (g_hStatsTimer != null)
				g_hStatsTimer = null;
		}
	}
}

void HookEvents()
{
	HookEvent("player_first_spawn", Event_OnPlayerLeftStartArea);
	HookEvent("player_hurt", Event_OnPlayerHurt);
	HookEvent("player_death", Event_OnPlayerDeath);
	HookEvent("round_end", Event_OnRoundEnd);
	
	g_bEventsHooked = true;
}

void RemoveEvents()
{
	UnhookEvent("player_first_spawn", Event_OnPlayerLeftStartArea);
	UnhookEvent("player_hurt", Event_OnPlayerHurt);
	UnhookEvent("player_death", Event_OnPlayerDeath);
	UnhookEvent("round_end", Event_OnRoundEnd);
	
	g_bEventsHooked = false;
}

public void OnMapStart()
{
	if (g_bModeEnabled)
		SetDirectorValues();
}

public Action Cmd_LoadHard30CoopMode(int client, int args)
{
	g_bModeEnabled = !g_bModeEnabled;
	PrintToChatAll("%s is \x05%s", PLUGIN_TAG, g_bModeEnabled ? "Enabled" : "Disabled");
	
	// Because events need to get hooked
	if (g_bModeEnabled)
	{
		char sMap[42];
		GetCurrentMap(sMap, sizeof(sMap));
		ForceChangeLevel(sMap, "Reloading level..."); // CBA to use l4d2_changelevel for this only.
	}
	return Plugin_Handled;
}

public void Event_OnPlayerDeath(Event event, const char[] name, bool dontBroadcast)
{
	int victim = GetClientOfUserId(event.GetInt("userid"));
	int attacker = GetClientOfUserId(event.GetInt("attacker"));
	
	if (victim && attacker && IsClientInGame(victim) && IsClientInGame(attacker))
	{
		if (GetClientTeam(victim) == 3 && GetClientTeam(attacker) == 2 && victim != attacker)
		{
			g_iSIKills++;
		}
	}
}

public void Event_OnRoundEnd(Event event, const char[] name, bool dontBroadcast)
{
	ToggleShowKillRateHud(false);
}

public void Event_OnPlayerLeftStartArea(Event event, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(event.GetInt("userid"));
	bool IsBot = event.GetBool("isbot");
	
	if (g_bModeEnabled)
	{
		if (client > 0 && IsClientInGame(client) && GetClientTeam(client) == 2 && !IsBot)
		{
			PrintToChatAll("%s initialized.", PLUGIN_TAG);
			
			if (g_hOverrideTimer == null)
				g_hOverrideTimer = CreateTimer(1.0, Timer_OverrideDirector, _, TIMER_REPEAT);
		
			ToggleShowKillRateHud(true);
		
			// Start timing cycle
			ToggleMapTiming();
			g_iSIKills = 0;	
		}
	}
}

public void Event_OnPlayerHurt(Event event, const char[] name, bool dontBroadcast)
{
	if (g_bModeEnabled)
	{
		int client = GetClientOfUserId(event.GetInt("userid"));
		
		if (client && IsClientInGame(client) && GetClientTeam(client) == 3 && IsPlayerAlive(client))
		{
			int max_hp = GetEntProp(client, Prop_Send, "m_iMaxHealth");
			int hp = event.GetInt("health");
			
			// Check if at half hp or lower then apply temp glow effect
			if (hp <= (max_hp / 2))
			{
				ApplyLowHealthGlow(client, COLOR_RED);
			}
		}
	}
}

void ApplyLowHealthGlow(int client, int color)
{
	SetColor(client, color);
	CreateTimer(0.5, Timer_GlearGlowEffect, GetClientUserId(client), TIMER_FLAG_NO_MAPCHANGE);
}

public Action Timer_GlearGlowEffect(Handle timer, int user)
{
	int client = GetClientOfUserId(user);
	if (client > 0 && IsClientInGame(client))
	{
		ClearGlow(client);
	}
}

public Action Timer_OverrideDirector(Handle timer)
{	
	L4D2_RunScript("StartAssault()");
	SetDirectorValues();
	CheckForCapped();
	return Plugin_Continue;
}

void CheckForCapped()
{
	for (int i = 1; i <= MaxClients; i++)
	{
		if (!IsClientInGame(i))continue;
		
		if (GetClientTeam(i) == 3 && IsPlayerAlive(i))
		{
			if (IsPinningASurvivor(i))
				ForcePlayerSuicide(i);
		}			
	}
}

// From hardcoop autoslayer plugin
bool IsPinningASurvivor(int client) {
	bool isPinning = false;
	if( GetEntPropEnt(client, Prop_Send, "m_tongueVictim") > 0 ) isPinning = true; // smoker
	if( GetEntPropEnt(client, Prop_Send, "m_pounceVictim") > 0 ) isPinning = true; // hunter
	if( GetEntPropEnt(client, Prop_Send, "m_carryVictim") > 0 ) isPinning = true; // charger carrying
	if( GetEntPropEnt(client, Prop_Send, "m_pummelVictim") > 0 ) isPinning = true; // charger pounding
	if( GetEntPropEnt(client, Prop_Send, "m_jockeyVictim") > 0 ) isPinning = true; // jockey
	return isPinning;
}

void SetDirectorValues()
{
	SetDirectorVar("SpecialRespawnInterval", "5.0");
	SetDirectorVar("SpecialInitialSpawnDelayMin", "5.0");
	SetDirectorVar("SpecialInitialSpawnDelayMax", "5.0");
	SetDirectorVar("MaxSpecials", "32");
	SetDirectorVar("DominatorLimit", "32");
	SetDirectorVar("BoomerLimit", "6");
	SetDirectorVar("CommonLimit", "6");
	SetDirectorVar("HunterLimit", "6");
	SetDirectorVar("SmokerLimit", "6");
	SetDirectorVar("ChargerLimit", "5");
	SetDirectorVar("JockeyLimit", "5");
	SetDirectorVar("SpitterLimit", "4");
}

void SetDirectorVar(char[] dvar, char[] dvalue)
{
	L4D2_RunScript("%s.%s <- %s;", DIRECTORSCRIPT_TYPE1, dvar, dvalue);
}

/** credits: stock from timocop
* Runs a single line of vscript code.
* NOTE: Dont use the "script" console command, it startes a new instance and leaks memory. Use this instead!
*
* @param sCode		The code to run.
* @noreturn
*/
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

void SetColor(int ent, int color)
{
	SetEntProp(ent, Prop_Send, "m_iGlowType", 3);
	SetEntProp(ent, Prop_Send, "m_glowColorOverride", color);
}

void ClearGlow(int ent)
{
	SetEntProp(ent, Prop_Send, "m_iGlowType", 0);
	SetEntProp(ent, Prop_Send, "m_glowColorOverride", 0);
}

void ToggleMapTiming()
{
	g_iMapTime = GetTime();
}

float SIRate()
{
	float rate, min, sec;
	
	sec = float(GetTime() - g_iMapTime);
	
	min = (sec / 60.0);
	if (min == 0)
	{
		rate = 0.0;
	}
	else
	{
		rate = (g_iSIKills / min);
	}
	return rate;
}

void ToggleShowKillRateHud(bool enable)
{
	if (enable)
	{
		if (g_hStatsTimer == null)
			g_hStatsTimer = CreateTimer(1.0, Timer_ShowRate, _, TIMER_REPEAT);
	}
	else
	{
		if (g_hStatsTimer != null)
			g_hStatsTimer = null;
	}
}

public Action Timer_ShowRate(Handle timer)
{	
	// Show this hud only to survivors
	for (int i = 1; i <= MaxClients; i++)
	{
		if (!IsClientInGame(i))continue;
		
		if (GetClientTeam(i) == 2 && IsPlayerAlive(i))
		{
			PrintHintText(i, "SI/min: %.2f - %i Killed", SIRate(), g_iSIKills);
		}
	}
	return Plugin_Continue;
}