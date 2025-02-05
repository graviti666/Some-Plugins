#include <sourcemod>
#include <l4d2_devstocks>
#include <sdkhooks>
#include <sdktools>

#pragma semicolon	1
#pragma newdecls required

ConVar g_hCvarPluginEnabled;

bool g_bClientIsGod[MAXPLAYERS + 1];
bool g_bIsClientInvisible[MAXPLAYERS + 1];
bool g_bKillFeedDisabled;

int g_iNumConnection[MAXPLAYERS + 1];

char SInames[][] = {
	"hunter",
	"boomer",
	"smoker",
	"charger",
	"jockey",
	"spitter",
	"tank"
};

/* What is changed when using this plugin:
	- No detectable team change messages if using -dev launch options. (X is joining the spectators.)
	- Admins pausing/unpausing the game is hidden. Not showing in console anymore.
	- Status & Ping command is blocked for non-admins if any admin is present on the server.
	- Admins join Infected team automatically (on the first connection/map, resets after disconnect) if there is 1 or more players on the server already.
*/

public Plugin myinfo = {
	name = "Hidden Admins",
	author = "Gravity",
	description = "Allows admins to utilize various stealth features.",
	version = "1.0",
	url = ""
};

public void OnPluginStart()
{
	RegAdminCmd("sm_hide", Cmd_OnUseHiddenMenu, ADMFLAG_ROOT, "Use the hide menu.");
	RegAdminCmd("sm_hidetoggle", Cmd_OnTogglePlugin, ADMFLAG_ROOT, "Toggle plugin status.");
	
	HookEvent("player_team", Event_OnChangeTeam, EventHookMode_Pre);
	HookEvent("player_death", Event_OnPlayerDeath, EventHookMode_Pre);
	HookEvent("player_incapacitated", Event_OnPlayerDeath, EventHookMode_Pre);
	
	AddCommandListener(Command_OnPause, "setpause");
	AddCommandListener(Command_OnUnPause, "unpause");
	AddCommandListener(Command_OnStatus, "status");
	AddCommandListener(Command_OnPing, "ping");
	
	g_hCvarPluginEnabled = CreateConVar("hidden_admin_enabled", "1", "Enable or disable plugin.\n1 = enabled\n0 = disabled", 0, true, 0.0, true, 1.0);
}

public void OnClientPostAdminCheck(int client)
{
	if (client != 0 && !IsFakeClient(client) && IsClientRootAdmin(client) && g_hCvarPluginEnabled.BoolValue)
	{
		g_bClientIsGod[client] = false;
		g_bIsClientInvisible[client] = false;
		
		g_iNumConnection[client] += 1;
		
		int realplayercount = GetRealPlayerCount();
		// PrintToServer("======================== real player count = %i ============================", realplayercount);
		
		// Since if you immediatly get placed into Infected team when joining a empty server, survivor bots won't spawn. Thats why there needs to be already 1 real player or more on the server.
		if (realplayercount >= 1 && g_iNumConnection[client] <= 1)
		{
			PrintToChat(client, "\x01[AdminStealth] You were moved to \x03Infected\x01 team.");
			ChangeClientTeam(client, 3);	
		}
	}
}

public void OnClientDisconnect(int client)
{
	if (client != 0 && !IsFakeClient(client) && IsClientRootAdmin(client) && g_hCvarPluginEnabled.BoolValue)
	{
		g_iNumConnection[client] = 0;
	}
}

public Action Command_OnPause(int client, const char[] command, int argc)
{
	if (client == -1 || !IsClientInGame(client) || !IsClientRootAdmin(client) || !g_hCvarPluginEnabled.BoolValue)
		return Plugin_Continue;
	return Plugin_Handled;
}

public Action Command_OnUnPause(int client, const char[] command, int argc)
{
	if (client == -1 || !IsClientInGame(client) || !IsClientRootAdmin(client) || !g_hCvarPluginEnabled.BoolValue)
		return Plugin_Continue;
	return Plugin_Handled;
}

public Action Command_OnStatus(int client, const char[] command, int argc)
{
	if (!g_hCvarPluginEnabled.BoolValue)
		return Plugin_Continue;
	
	for (int i = 1; i <= MaxClients; i++)
	{
		if (!IsClientInGame(i))
			continue;
		
		// Admins found and caller of cmd is not a admin, block
		if (IsClientRootAdmin(i) && !IsClientRootAdmin(client))
		{
			return Plugin_Handled;
		}
	}
	return Plugin_Continue;
}

public Action Command_OnPing(int client, const char[] command, int argc)
{
	if (!g_hCvarPluginEnabled.BoolValue)
		return Plugin_Continue;
	
	for (int i = 1; i <= MaxClients; i++)
	{
		if (!IsClientInGame(i))
			continue;
		
		// Admins found and caller of cmd is not a admin, block
		if (IsClientRootAdmin(i) && !IsClientRootAdmin(client))
		{
			return Plugin_Handled;
		}
	}
	return Plugin_Continue;
}

/*
From survivalSpecHUD.sp by dustin

public Action HideEventBroadcast(Event event, const char[] strName, bool bDontBroadcast)
{
    event.BroadcastDisabled = true;
    
    for (int i = 1; i <= MaxClients; i++)
	{
		if (!IsClientInGame(i) || IsFakeClient(i) || g_bSpecHudActive[i])
			continue;
		else	
			event.FireToClient(i);
	}
	
    return Plugin_Continue;
}
*/
public Action Event_OnPlayerDeath(Event event, const char[] name, bool dontBroadcast)
{
	event.BroadcastDisabled = true;
	
	for (int i = 1; i <= MaxClients; i++)
	{
		if (!IsClientInGame(i) || IsFakeClient(i) || g_bKillFeedDisabled)
			continue;
		else
			event.FireToClient(i);
	}
	return Plugin_Continue;
}

public Action Event_OnChangeTeam(Event event, const char[] name, bool dontBroadcast)
{
	if (!g_hCvarPluginEnabled.BoolValue)
		return Plugin_Continue;
	
	int client = GetClientOfUserId(event.GetInt("userid"));
	if (client == -1 || !IsClientInGame(client) || !IsClientRootAdmin(client))
		return Plugin_Continue;

	bool becauseDC = event.GetBool("disconnect");
	if (!becauseDC)
	{
		event.SetBool("disconnect", true);
		return Plugin_Changed;
	}
	return Plugin_Continue;
}

public Action Cmd_OnTogglePlugin(int client, int args)
{
	if (!g_hCvarPluginEnabled.BoolValue)
	{
		PrintToChat(client, "\x01[AdminStealth] Plugin is now \x03Enabled.");
		SetConVarInt(g_hCvarPluginEnabled, 1);
	}
	else
	{
		PrintToChat(client, "\x01[AdminStealth] Plugin is now \x03Disabled.");
		SetConVarInt(g_hCvarPluginEnabled, 0);
	}
	return Plugin_Handled;
}

public Action Cmd_OnUseHiddenMenu(int client, int args)
{
	if (!g_hCvarPluginEnabled.BoolValue)
	{
		return Plugin_Handled;
	}
	
	DisplayHiddenMenu(client);
	return Plugin_Handled;
}

void DisplayHiddenMenu(int client)
{
	Menu menu = new Menu(Menu_Callback);
	menu.SetTitle("Admin Stealth Options:\n");
	
	if (!g_bKillFeedDisabled) {
		menu.AddItem("togglekillfeed", "Toggle Killfeed (currently: enabled)");
	}
	else {
		menu.AddItem("togglekillfeed", "Toggle Killfeed (currently: disabled)");
	}
	
	if (!g_bIsClientInvisible[client]) {
		menu.AddItem("toggleinvis", "Toggle Invisibility (currently: off)");
	} 
	else {
		menu.AddItem("toggleinvis", "Toggle Invisibility (currently: on)");
	}
	
	if (!g_bClientIsGod[client]) {
		menu.AddItem("togglegod", "Toggle God Mode (currently: off)");
	} 
	else {
		menu.AddItem("togglegod", "Toggle God Mode (currently: on)");
	}
	
	menu.AddItem("tryspawn", "Spawn as SI");
	menu.AddItem("movetype", "Set Move Type");
	menu.AddItem("die", "Suicide");
	
	menu.Display(client, MENU_TIME_FOREVER);
}

void DisplayMoveTypeMenu(int client)
{
	Menu menu = new Menu(MoveMenu_Callback);
	menu.SetTitle("Choose MoveType To Use:\n");
	
	menu.AddItem("normal", "Normal (reset)");
	menu.AddItem("ladder", "Ladder");
	menu.AddItem("fly", "Fly");
	menu.AddItem("iso", "Isometric");
	menu.AddItem("noclip", "Noclip");
	
	menu.Display(client, MENU_TIME_FOREVER);
}

void DisplaySpawnMenu(int client)
{
	Menu menu = new Menu(SpawnMenu_Callback);
	menu.SetTitle("Choose SI to Spawn as:\n");
	
	for (int i = 0; i < sizeof(SInames); i++)
	{
		menu.AddItem(SInames[i], SInames[i]);
	}
	
	menu.Display(client, MENU_TIME_FOREVER);
}

public int MoveMenu_Callback(Menu menu, MenuAction action, int param1, int param2)
{
	switch (action)
	{
		case MenuAction_Select:
		{
			char sSelection[PLATFORM_MAX_PATH];
			GetMenuItem(menu, param2, sSelection, sizeof(sSelection));
			
			if (StrEqual(sSelection, "normal")) {
				TrySetMoveType(param1, 0);
			}
			else if (StrEqual(sSelection, "ladder")) {
				TrySetMoveType(param1, 1);
			}
			else if (StrEqual(sSelection, "fly")) {
				TrySetMoveType(param1, 2);
			}
			else if (StrEqual(sSelection, "iso"))
			{
				TrySetMoveType(param1, 3);
			}
			else if (StrEqual(sSelection, "noclip"))
			{
				TrySetMoveType(param1, 4);
			}
			
			DisplayHiddenMenu(param1);
		}
		case MenuAction_End:
		{
			delete menu;
		}
	}
}

public int SpawnMenu_Callback(Menu menu, MenuAction action, int param1, int param2)
{
	switch (action)
	{
		case MenuAction_Select:
		{
			char sSelection[PLATFORM_MAX_PATH];
			GetMenuItem(menu, param2, sSelection, sizeof(sSelection));
			
			TrySpawnAsSI(param1, sSelection);
			DisplayHiddenMenu(param1);
		}
		case MenuAction_End:
		{
			delete menu;
		}
	}
}

public int Menu_Callback(Menu menu, MenuAction action, int param1, int param2)
{
	switch (action)
	{
		case MenuAction_Select:
		{
			char sSelection[PLATFORM_MAX_PATH];
			GetMenuItem(menu, param2, sSelection, sizeof(sSelection));
			
			if (StrEqual(sSelection, "toggleinvis"))
			{
				ToggleInvisibility(param1);
				DisplayHiddenMenu(param1);
			}
			else if (StrEqual(sSelection, "togglegod"))
			{
				ToggleGodMode(param1);
				DisplayHiddenMenu(param1);
			}
			else if (StrEqual(sSelection, "tryspawn"))
			{
				DisplaySpawnMenu(param1);
			}
			else if (StrEqual(sSelection, "die"))
			{
				ForcePlayerSuicide(param1);
				DisplayHiddenMenu(param1);
			}
			else if (StrEqual(sSelection, "movetype"))
			{
				DisplayMoveTypeMenu(param1);
			}
			else if (StrEqual(sSelection, "togglekillfeed"))
			{
				ToggleFeed(param1);
				DisplayHiddenMenu(param1);
			}
		}
		case MenuAction_End:
		{
			delete menu;
		}
	}
}

void TrySetMoveType(int client, int type)
{
	switch (type)
	{
		case 0:
		{
			SetEntityMoveType(client, MOVETYPE_WALK);
			PrintToChat(client, "\x01[AdminStealth] Your MoveType is now \x03WALK\x01 (normal)");
		}
		case 1:
		{
			SetEntityMoveType(client, MOVETYPE_LADDER);
			PrintToChat(client, "\x01[AdminStealth] Your MoveType is now \x03LADDER");
		}
		case 2:
		{
			SetEntityMoveType(client, MOVETYPE_FLY);
			PrintToChat(client, "\x01[AdminStealth] Your MoveType is now \x03FLY");
		}
		case 3:
		{
			SetEntityMoveType(client, MOVETYPE_ISOMETRIC);
			PrintToChat(client, "\x01[AdminStealth] Your MoveType is now \x03ISOMETRIC");
		}
		case 4:
		{
			SetEntityMoveType(client, MOVETYPE_NOCLIP);
			PrintToChat(client, "\x01[AdminStealth] Your MoveType is now \x03NOCLIP");
		}
	}
}

/*
 *	bool g_bKillFeedDisabled
 *	
 *	True: Killfeed is disabled.
 *	False: Killfeed is enabled.
*/
void ToggleFeed(int client)
{
	g_bKillFeedDisabled = !g_bKillFeedDisabled;
	PrintToChat(client, "\x01[AdminStealth] Killfeed is now %s", g_bKillFeedDisabled ? "disabled" : "enabled");
}

// TODO: Add function CreateFakeClient so can spawn regardless of Director rules.. and make it so people won't see "X bot is joining the Infected" or "Cstrike_game_titles_connected" something.
void TrySpawnAsSI(int client, char[] SI)
{
	CheatCommand(client, "z_spawn_old", SI);
}

void ToggleInvisibility(int client)
{
	if (!g_bIsClientInvisible[client]) {
		MakeInvisible(client);
	}
	else {
		RemoveInvisible(client);
	}
	
	PrintToChat(client, "\x01[AdminStealth] Your invisibility is now %s", g_bIsClientInvisible[client] ? "\x03Enabled\x01" : "\x05Disabled\x01");
}

void ToggleGodMode(int client)
{
	if (!g_bClientIsGod[client]) {
		g_bClientIsGod[client] = true;
		SDKHook(client, SDKHook_OnTakeDamage, OnTakeDamage);
	}
	else {
		g_bClientIsGod[client] = false;
		SDKUnhook(client, SDKHook_OnTakeDamage, OnTakeDamage);
	}
	
	PrintToChat(client, "\x01[AdminStealth] Your god mode is now %s", g_bClientIsGod[client] ? "\x03Enabled\x01" : "\x05Disabled\x01");
}

public Action OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3])
{
	if (victim != 0 && IsClientInGame(victim) && IsClientRootAdmin(victim) && g_bClientIsGod[victim])
	{
		damage = 0.0;
		return Plugin_Changed;
	}
	return Plugin_Continue;
}

/*
 * Makes a client invisible.
 * @client		Client index.
 * @return		no return.
*/
stock void MakeInvisible(int client)
{
	SDKHook(client, SDKHook_SetTransmit, MySetTransmit);
	g_bIsClientInvisible[client] = true;
}

/*
 * Removes client invisibility.
 * @client		Client index.
 * @return		no return.
*/
stock void RemoveInvisible(int client)
{
	SDKUnhook(client, SDKHook_SetTransmit, MySetTransmit);
	g_bIsClientInvisible[client] = false;
}

public Action MySetTransmit(int entity, int client)
{
	// Makes it so you do see your model, while others won't
	if (client == entity)
		return Plugin_Continue;
		
	return Plugin_Stop;
}