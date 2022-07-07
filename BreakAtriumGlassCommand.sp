#include <sourcemod>
#include <sdktools>

#pragma semicolon	1
#pragma newdecls required

bool g_bRoundProgress;
bool g_bIsCommandUsed;

public Plugin myinfo = 
{
	name = "Atrium Break Glass Command",
	author = "Gravity",
	description = "Breaks atrium glass!",
	version = "1.0",
	url = ""
};

public void OnPluginStart()
{
	RegConsoleCmd("sm_breakglass", Command_OnBreakGlass, "Breaks all glass panels on Mall Atrium.");
	
	HookEvent("survival_round_start", Event_OnSurvivalStart);
	HookEvent("round_start", Event_OnRoundInit);
	HookEvent("round_end", Event_OnRoundEnd);
	
	// Incase reload
	g_bRoundProgress = true;
	g_bIsCommandUsed = true;
}

public Action Command_OnBreakGlass(int client, int args)
{
	if (g_bRoundProgress)
	{
		ReplyToCommand(client, "[SM] Not allowed to use while round in progress.");
		return Plugin_Handled;
	}
	
	if (!IsAtrium())
	{
		ReplyToCommand(client, "[SM] Command Only allowed on Mall Atrium.");
		return Plugin_Handled;	
	}
	
	if (g_bIsCommandUsed)
	{
		ReplyToCommand(client, "[SM] Command may only be used once per round.");
		return Plugin_Handled;
	}
	
	int ent = -1;
	while ((ent = FindEntityByClassname(ent, "func_breakable")) != -1)
	{
		if (IsValidEntity(ent)) AcceptEntityInput(ent, "Break");
	}
	
	g_bIsCommandUsed = true;
	return Plugin_Handled;
}

public void Event_OnSurvivalStart(Event event, const char[] name, bool dontBroadcast)
{
	g_bRoundProgress = true;
}

public void Event_OnRoundInit(Event event, const char[] name, bool dontBroadcast)
{
	g_bRoundProgress = false;
	g_bIsCommandUsed = false;
}

public void Event_OnRoundEnd(Event event, const char[] name, bool dontBroadcast)
{
	g_bRoundProgress = false;
	g_bIsCommandUsed = false;
}

bool IsAtrium()
{
	char sMap[32];
	GetCurrentMap(sMap, sizeof(sMap));
	return (StrEqual(sMap, "c1m4_atrium"));
}