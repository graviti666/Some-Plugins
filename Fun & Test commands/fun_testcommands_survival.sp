#include <sourcemod>
#include <sdktools>
#include <adminmenu>
#include <colors>
#include <sdkhooks>

#pragma semicolon	1
#pragma newdecls required

/*
Address TheNavAreas;
int TheCount;
*/

char g_sChatColor[MAXPLAYERS + 1][42];
bool g_bHasChatColor[MAXPLAYERS + 1];

bool g_bListenForGlowColorTarget[MAXPLAYERS + 1];
StringMap g_hGlowMap;

bool g_bGascansOnBacks;

// Rock settings, default
bool g_bRockFly;

float g_fRockStartHeight 	= 15.0;
float g_fRockSpeed 			= 600.0;
float g_fRockUpVel 			= 0.0;
float g_fRockDamage 		= 24.0;

float g_fDelay[MAXPLAYERS + 1] = 0.0;

char g_CoachAnims[][] = 
{
	"Idle_Rescue_01c",
	"Heal_Incap_Crouching",
	"GetUpFrom_Incap",
	"Idle_Incap_Pounced",
	"Death_10ab",
	"namvet_gesture_wave",
	"namvet_gesture_pointLeft",
	"use_cola",
	"bat_swing_ne_w_idle",
	"Heal_Incap_Above_Standing",
	"Heal_Incap_Above_Crouching"
};

/* TODO: add this
char g_survivors[][] = 
{
	"models/survivors/survivor_coach.mdl",		// coach
	"models/survivors/survivor_gambler.mdl",		// nick
	"models/survivors/survivor_mechanic.mdl",	// ellis
	"models/survivors/survivor_producer.mdl",	// rochelle
	"models/survivors/survivor_biker.mdl",		// francis
	"models/survivors/survivor_namvet.mdl",		// bill
	"models/survivors/survivor_teenangst.mdl",	// zoey
	"models/survivors/survivor_manager.mdl"		// louis
};
*/

#define MAX_EXPLOSION_SOUNDS	3
char sExplosionSounds[MAX_EXPLOSION_SOUNDS][] = {
	"ambient/explosions/explode_1.wav", "ambient/explosions/explode_2.wav", "ambient/explosions/explode_3.wav"
};

#define MAX_DRONE_SOUND		2
char sDroneFlySounds[MAX_DRONE_SOUND][] = {
	"animation/jets/jet_by_01_lr.wav", "animation/jets/jet_by_02_lr.wav"
};

public Plugin myinfo = {
	name = "Fun & test commands survival",
	author = "Gravity",
	description = "",
	version = "1.0",
	url = ""
};

public void OnPluginStart()
{
	RegConsoleCmd("sm_chatcolor", Cmd_ChatColorMenu, "Opens up a menu to select a chat color.");

	RegAdminCmd("sm_abot", Cmd_SpawnAnimProp, ADMFLAG_ROOT, "Creates a survivor prop with random animation.");
	RegAdminCmd("sm_rock", Cmd_ThrowRock, ADMFLAG_ROOT, "Creates and throws a rock.");
	RegAdminCmd("sm_dummy", Cmd_SpawnNamedDummy, ADMFLAG_ROOT, "Spawns a dummy bot then moves it to desired team.");
	RegAdminCmd("sm_path", Cmd_OnPathPlayerCommand, ADMFLAG_ROOT, "Tries to make player scan nearby area for a valid navmesh spot.");
	RegAdminCmd("sm_move", Cmd_OnForceAIMoveCommand, ADMFLAG_ROOT, "Tries to force the selected player to move to your position.");
	RegAdminCmd("sm_spit", Cmd_OnDropSpitCommand, ADMFLAG_ROOT, "Drops spit puddles on the selected player.");
	RegAdminCmd("sm_fire", Cmd_OnDropFireCommand, ADMFLAG_ROOT, "Drops molotov's on the selected player.");
	RegAdminCmd("sm_stagger", Cmd_OnStaggerCommand, ADMFLAG_ROOT, "Staggers a selected player.");
	RegAdminCmd("sm_ledgehang", Cmd_OnLedgeHangCommand, ADMFLAG_ROOT, "Sets a selected player to ledge hang.");
	RegAdminCmd("sm_defib", Cmd_OnDefibCommand, ADMFLAG_ROOT, "Defibs (respawns) a selected player.");
	RegAdminCmd("sm_explode", Cmd_OnExplodeCommand, ADMFLAG_ROOT, "Sets an explosion on a specific player.");
	RegAdminCmd("sm_gascansonbacks", Cmd_GasOnBacks, ADMFLAG_ROOT, "Toggle gascans on backs of players.");
	RegAdminCmd("sm_deathfall", Cmd_DeathFall, ADMFLAG_ROOT, "Deathfall");
	//RegAdminCmd("sm_dronestrike", Cmd_OnDroneStrikeCommand, ADMFLAG_ROOT, "Starts a drone strike.");
	
	LoadTranslations("common.phrases");
	
	Handle topmenu = GetAdminTopMenu();
	if (LibraryExists("adminmenu") && (topmenu != INVALID_HANDLE))
	{
		OnAdminMenuReady(topmenu);
	}
	
	AddCommandListener(OnSay, "say");
	
	g_hGlowMap = new StringMap();
}

public void OnMapStart()
{
	for (int i = 0; i < MAX_EXPLOSION_SOUNDS; i++)
	{
		PrefetchSound(sExplosionSounds[i]);
		PrecacheSound(sExplosionSounds[i], true);
	}
	
	for (int i = 0; i < MAX_DRONE_SOUND; i++)
	{
		PrefetchSound(sDroneFlySounds[i]);
		PrecacheSound(sDroneFlySounds[i], true);
	}
	
	for (int i = 1; i <= MaxClients; i++)
	{
		g_bListenForGlowColorTarget[i] = false;
		g_bHasChatColor[i] = false;
		strcopy(g_sChatColor[i], sizeof(g_sChatColor[]), "default");
	}
	
	for (int i = 1; i <= MaxClients; i++)
	{
		g_fDelay[i] = 0.0;
	}
	
	/*
	GameData hData = LoadGameConfigFile("l4d2_nav_loot");
	TheNavAreas = hData.GetAddress("TheNavAreas");
	TheCount = LoadFromAddress(hData.GetAddress("TheCount"), NumberType_Int32);
	delete hData;
	
	if (TheNavAreas == Address_Null)
		SetFailState("TheNavAreas address failed. Check gamedata file 'l4d2_nav_loot'");
	*/
}

public Action OnSay(int client, const char[] command, int argc)
{
	if (client == -1 || !IsClientInGame(client))
		return Plugin_Continue;
	
	if (g_bHasChatColor[client])
	{
		// Prevent spam
		if (GetGameTime() < g_fDelay[client])
			return Plugin_Handled;
		
		// Khan's
		char text[128];
		int startidx = 0;
		char dest[128];
	
		if (GetCmdArgString(text, sizeof(text)) < 1)
			return Plugin_Continue;
	
		StripQuotes(text);
	
		if (text[strlen(text)-1] == '"')
		{
			text[strlen(text)-1] = '\0';
			startidx = 1;
		}
		Format(dest, sizeof(dest), text[startidx]);
		
		// Don't display the command iterators when using a chat color
		if ((dest[0] == '/') || (dest[0] == '!'))
			return Plugin_Continue;
		
		if (StrEqual(g_sChatColor[client], "gold")) 
		{
			PrintToChatAll("\x04%N \x01:  %s", client, text);
			g_fDelay[client] = GetGameTime() + 1.0;
		}
		else
		{
			CPrintToChatAll("%s%N {default}:  %s", g_sChatColor[client], client, text);
			g_fDelay[client] = GetGameTime() + 1.0;
		}
		// Don't output the original text
		return Plugin_Handled;
	}
	else if (g_bListenForGlowColorTarget[client])
	{
		char text[128];
		int startidx = 0;
		char dest[128];
	
		if (GetCmdArgString(text, sizeof(text)) < 1)
			return Plugin_Continue;
	
		StripQuotes(text);
	
		if (text[strlen(text)-1] == '"')
		{
			text[strlen(text)-1] = '\0';
			startidx = 1;
		}
		Format(dest, sizeof(dest), text[startidx]);
		
		int text_int = StringToInt(dest);
		
		//PrintToChat(client, "Debug output of text: %i", text_int);
		
		int userid = -1;
		g_hGlowMap.GetValue("target_id", userid);
		
		int target = GetClientOfUserId(userid);
		if (target && IsClientInGame(target)) 
		{
			SetEntProp(target, Prop_Send, "m_iGlowType", 3);
			SetEntProp(target, Prop_Send, "m_glowColorOverride", text_int);
			
			PrintToChat(client, "\x01Setting Glow Color \x04%s\x01 on \x05%N", text, target);
		}
		
		g_bListenForGlowColorTarget[client] = false;
		
		// Don't output the original text
		return Plugin_Handled;
	}
	
	return Plugin_Continue;
}

/***************************************
				Commands
****************************************/

/*
public Action Cmd_OnDroneStrikeCommand(int client, int args)
{
	if (!client) { return Plugin_Handled; }
	StartDroneStrike(client);
	return Plugin_Handled;
}
*/

public Action Cmd_DeathFall(int client, int args)
{
	if (!client) {
		return Plugin_Handled;
	}
	
	char map[32];
	GetCurrentMap(map, sizeof(map));
	
	// Camera pos
	float coord[3], ang[3];
	if (strcmp(map, "c1m4_atrium") == 0)
	{
		int random = GetRandomInt(0, 1);
		switch (random)
		{
			case 0:
			{
				coord =  { -4566.485352, -4112.074219, 807.747131 };
				ang =  { 42.966412, 159.349060, 0.000000 };		
			}
			case 1:
			{
				coord =  { -4290.582520, -3264.315918, 803.209961 };
				ang =  { 41.184063, -135.016983, 0.000000 };		
			}
		}
	}
	
	int ent = CreateEntityByName("point_deathfall_camera");
	if (ent == -1) { 
		PrintToChat(client, "Couldn't create fall camera'"); 
		return Plugin_Handled; 
	}
	
	TeleportEntity(ent, coord, ang, NULL_VECTOR);
	DispatchKeyValue(ent, "fov", "45");
	DispatchKeyValue(ent, "fov_rate", "1.0");
	DispatchSpawn(ent);

	float distance = 80.0; // Adjust for how far away you want the position

	// Convert yaw to radians
	float yaw = DegToRad(ang[1]);

	// Compute new position
	float newCoord[3];
	newCoord[0] = coord[0] + Cosine(yaw) * distance;
	newCoord[1] = coord[1] + Sine(yaw) * distance;
	newCoord[2] = coord[2] + 40.0; // Keep the height the same
	
	SpawnAndSetTimeScale("0.7");
	CreateTimer(3.0, Timer_ResetTimeScale);

	for (int i = 1; i <= MaxClients; i++)
	{
		if (!IsClientInGame(i))continue;
		if (GetClientTeam(i) == 2 || GetClientTeam(i) == 3)
		{
			TeleportEntity(i, newCoord, NULL_VECTOR, NULL_VECTOR);
			FacePlayerToCamera(i, coord);
		}
	}
	
	return Plugin_Handled;
}

void SpawnAndSetTimeScale(const char[] desiredscale)
{
	int eTime = CreateEntityByName("func_timescale");
	if (eTime != -1)
	{
		DispatchKeyValue(eTime, "desiredTimescale", desiredscale);
		DispatchSpawn(eTime);
		AcceptEntityInput(eTime, "Start");
		AcceptEntityInput(eTime, "Kill");	
	}
}

public Action Timer_ResetTimeScale(Handle timer)
{
	SpawnAndSetTimeScale("1.0");
}

void FacePlayerToCamera(int player, float cameraPos[3])
{
    float playerPos[3], direction[3];
    
    // Get player's current position
    GetClientAbsOrigin(player, playerPos);
    
    // Calculate the direction vector (Camera - Player)
    direction[0] = cameraPos[0] - playerPos[0];
    direction[1] = cameraPos[1] - playerPos[1];
    direction[2] = cameraPos[2] - playerPos[2]; // Used for pitch calculation
    
    // Compute yaw and pitch
    float angles[3];
    angles[1] = ArcTangent2(direction[1], direction[0]); // Yaw (left/right)
    angles[0] = -ArcTangent2(direction[2], SquareRoot(direction[0] * direction[0] + direction[1] * direction[1])); // Pitch (up/down)

    // Apply new angles
    TeleportEntity(player, NULL_VECTOR, angles, NULL_VECTOR);
}

#define DIRECTORSCRIPT_TYPE1	"DirectorScript.MapScript.LocalScript.DirectorOptions"
public Action Cmd_GasOnBacks(int client, int args)
{
	if (!client) {
		return Plugin_Handled;
	}
	
	g_bGascansOnBacks = !g_bGascansOnBacks;
	
	L4D2_RunScript("%s.GasCansOnBacks <- %s", DIRECTORSCRIPT_TYPE1, g_bGascansOnBacks ? "true;" : "false;");
	PrintToChat(client, "\x01Gascans on backs is now \x05%s", g_bGascansOnBacks ? "Enabled" : "Disabled");
	return Plugin_Handled;
}

public Action Cmd_SpawnAnimProp(int client, int args)
{
	if (!client) { return Plugin_Handled; }
	
	float vAimPos[3];
	GetDirectionEndPoint(client, vAimPos);
	
	vAimPos[2] += 0.1;
	
	int ent = CreateEntityByName("prop_dynamic");
	if (ent == -1) {
		return Plugin_Handled;
	}
	
	PrecacheModel("models/survivors/survivor_coach.mdl");
	DispatchKeyValue(ent, "model", "models/survivors/survivor_coach.mdl");
	
	// enable solidity because its the only way to delete it afterwards
	DispatchKeyValue(ent, "solid", "6");
	DispatchKeyValue(ent, "disableshadows", "1");
	
	TeleportEntity(ent, vAimPos, NULL_VECTOR, NULL_VECTOR);
	DispatchSpawn(ent);
	
	char sRandom[128];
	int rnd = GetRandomInt(0, sizeof(g_CoachAnims) - 1);
	Format(sRandom, sizeof(sRandom), g_CoachAnims[rnd]);
	
	SetPropAnimation(ent, sRandom);
	return Plugin_Handled;
}

void SetPropAnimation(int entity, const char[] anim)
{
	SetVariantString(anim);
	AcceptEntityInput(entity, "SetAnimation");
}

public Action Cmd_ThrowRock(int client, int args)
{
	if (!client) { return Plugin_Handled; }
	ShowRockMenu(client);
	return Plugin_Handled;
}

void Rock_Shoot(int client)
{
	int rock = CreateEntityByName("tank_rock");
	if (rock == -1)
	{
		PrintToChat(client, "[SM] Error! Couldn't create rock entity..");
		return;
	}
	
	float vEyePos[3];
	GetClientEyePosition(client, vEyePos);
	
	vEyePos[2] += g_fRockStartHeight;
	
	// Create the rock at players eye pos
	TeleportEntity(rock, vEyePos, NULL_VECTOR, NULL_VECTOR);
	DispatchSpawn(rock);
	
	SDKHook(rock, SDKHook_TouchPost, OnRockImpact);
	
	if (g_bRockFly)
		SetEntityMoveType(rock, MOVETYPE_FLY);
	
	float vEyeAng[3], vFWD[3], result[3], vCurrent[3];
	GetClientEyeAngles(client, vEyeAng);
	GetAngleVectors(vEyeAng, vFWD, NULL_VECTOR, NULL_VECTOR);
	
	GetEntPropVector(rock, Prop_Data, "m_vecVelocity", vCurrent);
	
	ScaleVector(vFWD, g_fRockSpeed);
	
	result[0] = vCurrent[0] + vFWD[0];
	result[1] = vCurrent[1] + vFWD[1];
	
	float z = g_fRockUpVel;
	if (z > 0.0)
		result[2] = vCurrent[2] + z;
	else
		result[2] = vCurrent[2];
		
	TeleportEntity(rock, NULL_VECTOR, NULL_VECTOR, result);
}

void ShowRockMenu(int client)
{
	if (!client)
		return;
	
	Menu menu = new Menu(RockMenu_Callback);
	menu.SetTitle("Spawn Rocks:");
	
	menu.AddItem("srock", "Shoot Rock");
	
	char sHeight[32], sFly[32], sSpeed[32], sUpVel[42], sDamage[32];
	Format(sHeight, sizeof(sHeight), "Start Height (%.1f)", g_fRockStartHeight);
	Format(sFly, sizeof(sFly), "Flying Rock (%s)", g_bRockFly ? "enabled" : "disabled");
	Format(sSpeed, sizeof(sSpeed), "Rock Speed (%.1f)", g_fRockSpeed);
	Format(sUpVel, sizeof(sUpVel), "Rock Up Velocity (%.1f)", g_fRockUpVel);
	Format(sDamage, sizeof(sDamage), "Rock Damage (%.1f)", g_fRockDamage);
	
	menu.AddItem("eheight", sHeight);
	menu.AddItem("efly", sFly);
	menu.AddItem("espeed", sSpeed);
	menu.AddItem("eupvel", sUpVel);
	menu.AddItem("edmg", sDamage);
	
	menu.Display(client, MENU_TIME_FOREVER);
	menu.ExitBackButton = false;
}

public void OnRockImpact(int entity, int other)
{
	if (IsValidEdict(entity))
	{
		if (ValidClient(other)) {
			CTankRock_Detonate(entity);
			
			PrecacheSound("player/tank/hit/thrown_projectile_hit_01.wav");
			EmitSoundToAll("player/tank/hit/thrown_projectile_hit_01.wav", entity, SNDCHAN_WEAPON);
			
			float fDMG = g_fRockDamage;
			SDKHooks_TakeDamage(other, entity, entity, fDMG, DMG_CRUSH);
		}
		else {
			CTankRock_Detonate(entity);
			
			PrecacheSound("player/tank/hit/thrown_projectile_hit_01.wav");
			EmitSoundToAll("player/tank/hit/thrown_projectile_hit_01.wav", entity, SNDCHAN_WEAPON);
		}
	}
	SDKUnhook(entity, SDKHook_TouchPost, OnRockImpact);
	AcceptEntityInput(entity, "kill");
}

// Credits to Visor
void CTankRock_Detonate(int rock)
{
	Handle call = INVALID_HANDLE;
	StartPrepSDKCall(SDKCall_Entity);
	if (!PrepSDKCall_SetSignature(SDKLibrary_Server, "@_ZN9CTankRock8DetonateEv", 0)) {
		PrintToServer("CTankRock_Detonate failed on Shoot rock CMD");
		return;
	}
	
	call = EndPrepSDKCall();
	if (call == INVALID_HANDLE) {
			PrintToServer("CTankRock_Detonate failed on Shoot rock CMD");
			return;
	}
	SDKCall(call, rock);
}

bool ValidClient(int index)
{
	return (index > 0 && index <= MaxClients && IsClientInGame(index));
}

public int RockMenu_Callback(Handle menu, MenuAction action, int param1, int param2)
{
	switch (action)
	{
		case MenuAction_Select:
		{
			char select[PLATFORM_MAX_PATH];
			GetMenuItem(menu, param2, select, sizeof(select));
			
			// Shoot a rock
			if (StrEqual(select, "srock")) {
				Rock_Shoot(param1);
			}
			else if (StrEqual(select, "eheight")) {
				Rock_AdjustSettings(0);
			}
			else if (StrEqual(select, "efly")) {
				if (!g_bRockFly)
					g_bRockFly = true;
				else
					g_bRockFly = false;
			}
			else if (StrEqual(select, "espeed"))
			{
				Rock_AdjustSettings(1);
			}
			else if (StrEqual(select, "eupvel"))
			{
				Rock_AdjustSettings(2);
			}
			else if (StrEqual(select, "edmg"))
			{
				Rock_AdjustSettings(3);
			}
			
			ShowRockMenu(param1);
		}
		case MenuAction_End:
		{
			delete menu;
		}
	}
}

void Rock_AdjustSettings(int setting)
{	
	static int call;
	call += 1;
	
	if (setting == 0) // Rock start height
	{
		switch (call)
		{
			case 1:
			{
				g_fRockStartHeight = 15.0;
			}
			case 2:
			{
				g_fRockStartHeight = 20.0;
			}
			case 3:
			{
				g_fRockStartHeight = 25.0;
			}
			case 4:
			{
				g_fRockStartHeight = 30.0;
			}
			case 5:
			{
				g_fRockStartHeight = 40.0;
				call = 0;
			}
		}
	}
	else if (setting == 1) // Rock speed
	{
		switch (call)
		{
			case 1:
			{
				g_fRockSpeed = 100.0;
			}
			case 2:
			{
				g_fRockSpeed = 200.0;
			}
			case 3:
			{
				g_fRockSpeed = 300.0;
			}
			case 4:
			{
				g_fRockSpeed = 400.0;
			}
			case 5:
			{
				g_fRockSpeed = 500.0;
			}
			case 6:
			{
				g_fRockSpeed = 600.0;
			}
			case 7:
			{
				g_fRockSpeed = 700.0;
			}
			case 8:
			{
				g_fRockSpeed = 800.0;
			}
			case 9:
			{
				g_fRockSpeed = 900.0;
			}
			case 10:
			{
				g_fRockSpeed = 1000.0;
				call = 0;
			}
		}
	}
	else if (setting == 2) // Rock up velocity
	{
		switch (call)
		{
			case 1:
			{
				g_fRockUpVel = 0.0;
			}
			case 2:
			{
				g_fRockUpVel = 50.0;
			}
			case 3:
			{
				g_fRockUpVel = 100.0;
			}
			case 4:
			{
				g_fRockUpVel = 200.0;
			}
			case 5:
			{
				g_fRockUpVel = 300.0;
			}
			case 6:
			{
				g_fRockUpVel = 400.0;
			}
			case 7:
			{
				g_fRockUpVel = 500.0;
			}
			case 8:
			{
				g_fRockUpVel = 600.0;
			}
			case 9:
			{
				g_fRockUpVel = 700.0;
			}
			case 10:
			{
				g_fRockUpVel = 800.0;
				call = 0;
			}
		}
	}
	else if (setting == 3) // Rock damage
	{
		switch (call)
		{
			case 1:
			{
				g_fRockDamage = 0.0;
			}
			case 2:
			{
				g_fRockDamage = 24.0;
			}
			case 3:
			{
				g_fRockDamage = 50.0;
			}
			case 4:
			{
				g_fRockDamage = 100.0;
			}
			case 5:
			{
				g_fRockDamage = 200.0;
			}
			case 6:
			{
				g_fRockDamage = 1000.0;
			}
			case 7:
			{
				// lol
				g_fRockDamage = 9000.0;
				call = 0;
			}
		}
	}
}

stock bool GetDirectionEndPoint(int client, float vEndPos[3])
{
	float vDir[3], vPos[3];
	GetClientEyePosition(client, vPos);
	GetClientEyeAngles(client, vDir);
	
	Handle hTrace = TR_TraceRayFilterEx(vPos, vDir, MASK_PLAYERSOLID, RayType_Infinite, TraceRayNoPlayers, client);
	if (hTrace != INVALID_HANDLE) {
		if (TR_DidHit(hTrace)) {
			TR_GetEndPosition(vEndPos, hTrace);
			CloseHandle(hTrace);
			return true;
		}
		delete hTrace;
	}
	return false;
}

public bool TraceRayNoPlayers(int entity, int mask, any data)
{
	if (entity == data || (entity >= 1 && entity <= MaxClients))
	{
		return false;
	}
	return true;
}

public Action Cmd_SpawnNamedDummy(int client, int args)
{
	if (!client) { return Plugin_Handled; }
	
	if (args < 2) 
	{
		PrintToChat(client, "[SM] Usage: sm_dummy <name> <team_number>\n1 = Spectator | 2 = survivor");
		return Plugin_Handled;
	}

	char arg1[128], arg2[12];
	GetCmdArg(1, arg1, sizeof(arg1));
	GetCmdArg(2, arg2, sizeof(arg2));
	
	int teamval = StringToInt(arg2);
	if (teamval < 1 || teamval > 3) {
		PrintToChat(client, "[SM] Team value must be between 1-3\n1 = spec | 2 = survivor | 3 = infected");
		return Plugin_Handled;
	}
	
	int bot = CreateFakeClient(arg1);
	if (bot != 0)
	{
		ChangeClientTeam(bot, teamval);
	}
	else
	{
		PrintToChat(client, "[SM] Something went wrong couldnt spawn bot dummy.\nargument1 = %s | argument2 = %s", arg1, arg2);
		return Plugin_Handled;
	}
	return Plugin_Handled;
}

public Action Cmd_ChatColorMenu(int client, int args)
{
	if (!client) { return Plugin_Handled; }
	DrawChatColorMenu(client);
	return Plugin_Handled;
}

/*
	Monkey : test
	{green}Monkey{default} : test
*/
void DrawChatColorMenu(int client)
{
	Menu menu = new Menu(Menu_ChatCallback);
	menu.SetTitle("Choose a Chat Color to use:\n");
	
	menu.AddItem("def", "Default");
	menu.AddItem("{green}", "Green");
	menu.AddItem("{lightgreen}", "Light Green");
	menu.AddItem("{red}", "Red");
	menu.AddItem("{blue}", "Blue");
	menu.AddItem("{olive}", "Olive");
	menu.AddItem("gold", "Gold");
	
	menu.Display(client, MENU_TIME_FOREVER);
	menu.ExitBackButton = false;
}

public int Menu_ChatCallback(Handle menu, MenuAction action, int param1, int param2)
{
	switch (action)
	{
		case MenuAction_Select:
		{
			char select[PLATFORM_MAX_PATH];
			GetMenuItem(menu, param2, select, sizeof(select));
			
			bool draw;
			
			if (StrEqual(select, "def")) {
				g_bHasChatColor[param1] = false;
				draw = true;
			}
			else if (StrEqual(select, "gold"))
			{
				g_bHasChatColor[param1] = true;
				strcopy(g_sChatColor[param1], sizeof(g_sChatColor[]), "gold");
				draw = true;
			}
			else
			{
				//PrintToChatAll("%N selected color string = %s", param1, select);
				
				g_bHasChatColor[param1] = true;
				strcopy(g_sChatColor[param1], sizeof(g_sChatColor[]), select);
				draw = true;
			}
			
			if (draw)
			{
				DrawChatColorMenu(param1);
				draw = false;
			}
		}
		case MenuAction_End:
		{
			delete menu;
		}
	}
}

public Action Cmd_OnPathPlayerCommand(int client, int args)
{
	if (!client) { return Plugin_Handled; }
	
	char sPlayer[128];
	if (args < 1)
	{
		ReplyToCommand(client, "[SM] Usage: sm_path <#userid|name>");
		return Plugin_Handled;
	}
	
	GetCmdArg(1, sPlayer, sizeof(sPlayer));
	
	char target_name[MAX_TARGET_LENGTH];
	int target_list[MAXPLAYERS];
	int target_count;
	bool tn_is_ml;
	
	if ((target_count = ProcessTargetString(sPlayer, client, target_list, MAXPLAYERS, COMMAND_FILTER_ALIVE, target_name, sizeof(target_name), tn_is_ml)) <= 0)
	{
		ReplyToTargetError(client, target_count);
		return Plugin_Handled;
	}
	
	for (int i = 0; i < target_count; i++)
	{
		TryGetPathableLocation(target_list[i]);
	}
	
	PrintToChat(client, "[SM] %s will scan nearby for a valid position to move.", sPlayer);
	
	return Plugin_Handled;
}

public Action Cmd_OnForceAIMoveCommand(int client, int args)
{
	if (!client) { return Plugin_Handled; }
	
	char sPlayer[128];
	if (args < 1)
	{
		ReplyToCommand(client, "[SM] Usage: sm_move <#userid|name>");
		return Plugin_Handled;
	}
	
	GetCmdArg(1, sPlayer, sizeof(sPlayer));
	
	char target_name[MAX_TARGET_LENGTH];
	int target_list[MAXPLAYERS];
	int target_count;
	bool tn_is_ml;
	
	if ((target_count = ProcessTargetString(sPlayer, client, target_list, MAXPLAYERS, COMMAND_FILTER_ALIVE, target_name, sizeof(target_name), tn_is_ml)) <= 0)
	{
		ReplyToTargetError(client, target_count);
		return Plugin_Handled;
	}
	
	for (int i = 0; i < target_count; i++)
	{
		TryMovePlayerToPosition(client, target_list[i]);
	}
	
	PrintToChat(client, "[SM] %s Will be moved to your location.", sPlayer);
	
	return Plugin_Handled;
}

public Action Cmd_OnDropSpitCommand(int client, int args)
{
	if (!client) { return Plugin_Handled; }
	
	char sPlayer[128];
	if (args < 1)
	{
		ReplyToCommand(client, "[SM] Usage: sm_spit <#userid|name>");
		return Plugin_Handled;
	}
	
	GetCmdArg(1, sPlayer, sizeof(sPlayer));
	
	char target_name[MAX_TARGET_LENGTH];
	int target_list[MAXPLAYERS];
	int target_count;
	bool tn_is_ml;
	
	if ((target_count = ProcessTargetString(sPlayer, client, target_list, MAXPLAYERS, COMMAND_FILTER_ALIVE, target_name, sizeof(target_name), tn_is_ml)) <= 0)
	{
		ReplyToTargetError(client, target_count);
		return Plugin_Handled;
	}
	
	for (int i = 0; i < target_count; i++)
	{
		DropSpitOnPlayer(target_list[i]);
	}
	
	PrintToChat(client, "[SM] Dropped spit on %s.", sPlayer);
	
	return Plugin_Handled;
}

public Action Cmd_OnDropFireCommand(int client, int args)
{
	if (!client) { return Plugin_Handled; }
	
	char sPlayer[128];
	if (args < 1)
	{
		ReplyToCommand(client, "[SM] Usage: sm_fire <#userid|name>");
		return Plugin_Handled;
	}
	
	GetCmdArg(1, sPlayer, sizeof(sPlayer));
	
	char target_name[MAX_TARGET_LENGTH];
	int target_list[MAXPLAYERS];
	int target_count;
	bool tn_is_ml;
	
	if ((target_count = ProcessTargetString(sPlayer, client, target_list, MAXPLAYERS, COMMAND_FILTER_ALIVE, target_name, sizeof(target_name), tn_is_ml)) <= 0)
	{
		ReplyToTargetError(client, target_count);
		return Plugin_Handled;
	}
	
	for (int i = 0; i < target_count; i++)
	{
		DropFireOnPlayer(target_list[i]);
	}
	
	PrintToChat(client, "[SM] Dropped fire on %s.", sPlayer);
	
	return Plugin_Handled;
}

public Action Cmd_OnStaggerCommand(int client, int args)
{
	if (!client) { return Plugin_Handled; }
	
	char sPlayer[128];
	if (args < 1)
	{
		ReplyToCommand(client, "[SM] Usage: sm_stagger <#userid|name>");
		return Plugin_Handled;
	}
	
	GetCmdArg(1, sPlayer, sizeof(sPlayer));
	
	char target_name[MAX_TARGET_LENGTH];
	int target_list[MAXPLAYERS];
	int target_count;
	bool tn_is_ml;
	
	if ((target_count = ProcessTargetString(sPlayer, client, target_list, MAXPLAYERS, COMMAND_FILTER_ALIVE, target_name, sizeof(target_name), tn_is_ml)) <= 0)
	{
		ReplyToTargetError(client, target_count);
		return Plugin_Handled;
	}
	
	for (int i = 0; i < target_count; i++)
	{
		StaggerPlayer(target_list[i]);
	}
	
	PrintToChat(client, "[SM] Staggered %s.", sPlayer);
	
	return Plugin_Handled;
}

public Action Cmd_OnLedgeHangCommand(int client, int args)
{
	if (!client) { return Plugin_Handled; }
	
	char sPlayer[128];
	if (args < 1)
	{
		ReplyToCommand(client, "[SM] Usage: sm_ledgehang <#userid|name>");
		return Plugin_Handled;
	}
	
	GetCmdArg(1, sPlayer, sizeof(sPlayer));
	
	char target_name[MAX_TARGET_LENGTH];
	int target_list[MAXPLAYERS];
	int target_count;
	bool tn_is_ml;
	
	if ((target_count = ProcessTargetString(sPlayer, client, target_list, MAXPLAYERS, COMMAND_FILTER_ALIVE, target_name, sizeof(target_name), tn_is_ml)) <= 0)
	{
		ReplyToTargetError(client, target_count);
		return Plugin_Handled;
	}
	
	for (int i = 0; i < target_count; i++)
	{
		SetPlayerLedgeHanging(target_list[i]);
	}
	
	PrintToChat(client, "[SM] ledgehang set on %s.", sPlayer);
	
	return Plugin_Handled;
}

public Action Cmd_OnDefibCommand(int client, int args)
{
	if (!client) { return Plugin_Handled; }
	
	char sPlayer[128];
	if (args < 1)
	{
		ReplyToCommand(client, "[SM] Usage: sm_defib <#userid|name>");
		return Plugin_Handled;
	}
	
	GetCmdArg(1, sPlayer, sizeof(sPlayer));
	
	char target_name[MAX_TARGET_LENGTH];
	int target_list[MAXPLAYERS];
	int target_count;
	bool tn_is_ml;
	
	if ((target_count = ProcessTargetString(sPlayer, client, target_list, MAXPLAYERS, COMMAND_FILTER_CONNECTED, target_name, sizeof(target_name), tn_is_ml)) <= 0)
	{
		ReplyToTargetError(client, target_count);
		return Plugin_Handled;
	}
	
	for (int i = 0; i < target_count; i++)
	{
		DefibPlayer(target_list[i]);
	}
	
	PrintToChat(client, "[SM] defibbed %s.", sPlayer);
	
	return Plugin_Handled;
}

public Action Cmd_OnExplodeCommand(int client, int args)
{
	if (!client) { return Plugin_Handled; }
	
	char sPlayer[128];
	if (args < 1)
	{
		ReplyToCommand(client, "[SM] Usage: sm_explode <#userid|name>");
		return Plugin_Handled;
	}
	
	GetCmdArg(1, sPlayer, sizeof(sPlayer));
	
	char target_name[MAX_TARGET_LENGTH];
	int target_list[MAXPLAYERS];
	int target_count;
	bool tn_is_ml;
	
	if ((target_count = ProcessTargetString(sPlayer, client, target_list, MAXPLAYERS, COMMAND_FILTER_ALIVE, target_name, sizeof(target_name), tn_is_ml)) <= 0)
	{
		ReplyToTargetError(client, target_count);
		return Plugin_Handled;
	}
	
	for (int i = 0; i < target_count; i++)
	{
		ExplodePlayer(target_list[i]);
	}
	
	PrintToChat(client, "[SM] exploded %s.", sPlayer);
	
	return Plugin_Handled;
}

/*********************************
	Adding commands to adminmenu
*********************************/

public void OnAdminMenuReady(Handle topmenu)
{
	if(topmenu == INVALID_HANDLE) 
	{
		LogError("Unable to add commands to admin menu. invalid handle.");
		return;
	}
	
	// Adding to default adminmenu categories
	TopMenuObject players_commands = FindTopMenuCategory(topmenu, ADMINMENU_PLAYERCOMMANDS);
	if (players_commands != INVALID_TOPMENUOBJECT) 
	{
		AddToTopMenu(topmenu, "l4dpathplayer", TopMenuObject_Item, MenuItem_PathPlayer, players_commands, "l4dpathplayer");
		AddToTopMenu(topmenu, "l4dmoveplayer", TopMenuObject_Item, MenuItem_MovePlayer, players_commands, "l4dmoveplayer");
		AddToTopMenu(topmenu, "l4dspitplayer", TopMenuObject_Item, MenuItem_SpitPlayer, players_commands, "l4dspitplayer");
		AddToTopMenu(topmenu, "l4dfireplayer", TopMenuObject_Item, MenuItem_FirePlayer, players_commands, "l4dfireplayer");
		AddToTopMenu(topmenu, "l4dstaggerplayer", TopMenuObject_Item, MenuItem_StaggerPlayer, players_commands, "l4dstaggerplayer");
		AddToTopMenu(topmenu, "l4dledgehangplayer", TopMenuObject_Item, MenuItem_LedgehangPlayer, players_commands, "l4dledgehangplayer");
		AddToTopMenu(topmenu, "l4drespawnplayer", TopMenuObject_Item, MenuItem_RespawnPlayer, players_commands, "l4drespawnplayer");
		AddToTopMenu(topmenu, "l4d2explodeplayer", TopMenuObject_Item, MenuItem_ExplodePlayer, players_commands, "l4d2explodeplayer");
		AddToTopMenu(topmenu, "l4d2glowplayer", TopMenuObject_Item, MenuItem_GlowPlayer, players_commands, "l4d2glowplayer");
	}
}

public void MenuItem_GlowPlayer(Handle topmenu, TopMenuAction action, TopMenuObject object_id, int param, char[] buffer, int maxlength)
{
	if (action == TopMenuAction_DisplayOption)
	{
		Format(buffer, maxlength, "Glow Player", "", param);
	}
	if(action == TopMenuAction_SelectOption)
	{
		DisplayGlowPlayerMenu(param);
	}
}

public void MenuItem_PathPlayer(Handle topmenu, TopMenuAction action, TopMenuObject object_id, int param, char[] buffer, int maxlength)
{
	if (action == TopMenuAction_DisplayOption)
	{
		Format(buffer, maxlength, "Path Player", "", param);
	}
	if(action == TopMenuAction_SelectOption)
	{
		DisplayPathPlayerMenu(param);
	}
}

public void MenuItem_MovePlayer(Handle topmenu, TopMenuAction action, TopMenuObject object_id, int param, char[] buffer, int maxlength)
{
	if (action == TopMenuAction_DisplayOption)
	{
		Format(buffer, maxlength, "Move Player", "", param);
	}
	if(action == TopMenuAction_SelectOption)
	{
		DisplayMovePlayerMenu(param);
	}
}

public void MenuItem_SpitPlayer(Handle topmenu, TopMenuAction action, TopMenuObject object_id, int param, char[] buffer, int maxlength)
{
	if (action == TopMenuAction_DisplayOption)
	{
		Format(buffer, maxlength, "Spit Player", "", param);
	}
	if(action == TopMenuAction_SelectOption)
	{
		DisplaySpitPlayerMenu(param);
	}
}

public void MenuItem_FirePlayer(Handle topmenu, TopMenuAction action, TopMenuObject object_id, int param, char[] buffer, int maxlength)
{
	if (action == TopMenuAction_DisplayOption)
	{
		Format(buffer, maxlength, "Drop Fire on Player", "", param);
	}
	if(action == TopMenuAction_SelectOption)
	{
		DisplayDropfireMenu(param);
	}
}

public void MenuItem_StaggerPlayer(Handle topmenu, TopMenuAction action, TopMenuObject object_id, int param, char[] buffer, int maxlength)
{
	if (action == TopMenuAction_DisplayOption)
	{
		Format(buffer, maxlength, "Stagger Player", "", param);
	}
	if(action == TopMenuAction_SelectOption)
	{
		DisplayStaggerPlayerMenu(param);
	}
}

public void MenuItem_LedgehangPlayer(Handle topmenu, TopMenuAction action, TopMenuObject object_id, int param, char[] buffer, int maxlength)
{
	if (action == TopMenuAction_DisplayOption)
	{
		Format(buffer, maxlength, "Ledgehang Player", "", param);
	}
	if(action == TopMenuAction_SelectOption)
	{
		DisplayLedgeHangPlayerMenu(param);
	}
}

public void MenuItem_RespawnPlayer(Handle topmenu, TopMenuAction action, TopMenuObject object_id, int param, char[] buffer, int maxlength)
{
	if (action == TopMenuAction_DisplayOption)
	{
		Format(buffer, maxlength, "Respawn Player(defib)", "", param);
	}
	if(action == TopMenuAction_SelectOption)
	{
		DisplayRespawnPlayerMenu(param);
	}
}

public void MenuItem_ExplodePlayer(Handle topmenu, TopMenuAction action, TopMenuObject object_id, int param, char[] buffer, int maxlength)
{
	if (action == TopMenuAction_DisplayOption)
	{
		Format(buffer, maxlength, "Explode Player", "", param);
	}
	if(action == TopMenuAction_SelectOption)
	{
		DisplayExplodePlayerMenu(param);
	}
}

/****************************
	Display menus' select player
*****************************/

void DisplayGlowPlayerMenu(int client)
{
	Menu menu2 = CreateMenu(MenuHandler_GlowPlayer);
	SetMenuTitle(menu2, "Player to Glow:");
	SetMenuExitBackButton(menu2, true);
	AddTargetsToMenu2(menu2, client, COMMAND_FILTER_CONNECTED);
	DisplayMenu(menu2, client, MENU_TIME_FOREVER);
}

void DisplayPathPlayerMenu(int client)
{
	Menu menu2 = CreateMenu(MenuHandler_PathPlayer);
	SetMenuTitle(menu2, "Path Player:");
	SetMenuExitBackButton(menu2, true);
	AddTargetsToMenu2(menu2, client, COMMAND_FILTER_CONNECTED);
	DisplayMenu(menu2, client, MENU_TIME_FOREVER);
}

void DisplayMovePlayerMenu(int client)
{
	Menu menu2 = CreateMenu(MenuHandler_moveplayer);
	SetMenuTitle(menu2, "Move Player:");
	SetMenuExitBackButton(menu2, true);
	AddTargetsToMenu2(menu2, client, COMMAND_FILTER_CONNECTED);
	DisplayMenu(menu2, client, MENU_TIME_FOREVER);
}

void DisplaySpitPlayerMenu(int client)
{
	Menu menu2 = CreateMenu(MenuHandler_spitplayer);
	SetMenuTitle(menu2, "Spit Player:");
	SetMenuExitBackButton(menu2, true);
	AddTargetsToMenu2(menu2, client, COMMAND_FILTER_CONNECTED);
	DisplayMenu(menu2, client, MENU_TIME_FOREVER);
}

void DisplayDropfireMenu(int client)
{
	Menu menu2 = CreateMenu(MenuHandler_dropfireplayer);
	SetMenuTitle(menu2, "Drop Fire on Player:");
	SetMenuExitBackButton(menu2, true);
	AddTargetsToMenu2(menu2, client, COMMAND_FILTER_CONNECTED);
	DisplayMenu(menu2, client, MENU_TIME_FOREVER);
}

void DisplayStaggerPlayerMenu(int client)
{
	Menu menu2 = CreateMenu(MenuHandler_staggerplayer);
	SetMenuTitle(menu2, "Stagger Player:");
	SetMenuExitBackButton(menu2, true);
	AddTargetsToMenu2(menu2, client, COMMAND_FILTER_CONNECTED);
	DisplayMenu(menu2, client, MENU_TIME_FOREVER);
}

void DisplayLedgeHangPlayerMenu(int client)
{
	Menu menu2 = CreateMenu(MenuHandler_ledgehangplayer);
	SetMenuTitle(menu2, "Ledgehang Player:");
	SetMenuExitBackButton(menu2, true);
	AddTargetsToMenu2(menu2, client, COMMAND_FILTER_CONNECTED);
	DisplayMenu(menu2, client, MENU_TIME_FOREVER);
}

void DisplayRespawnPlayerMenu(int client)
{
	Menu menu2 = CreateMenu(MenuHandler_respawnplayer);
	SetMenuTitle(menu2, "Respawn Player(defib):");
	SetMenuExitBackButton(menu2, true);
	AddTargetsToMenu2(menu2, client, COMMAND_FILTER_CONNECTED);
	DisplayMenu(menu2, client, MENU_TIME_FOREVER);
}

void DisplayExplodePlayerMenu(int client)
{
	Menu menu2 = CreateMenu(MenuHandler_explodeplayer);
	SetMenuTitle(menu2, "Explode Player:");
	SetMenuExitBackButton(menu2, true);
	AddTargetsToMenu2(menu2, client, COMMAND_FILTER_CONNECTED);
	DisplayMenu(menu2, client, MENU_TIME_FOREVER);
}

public int MenuHandler_GlowPlayer(Handle menu2, MenuAction action, int param1, int param2)
{
	if (action == MenuAction_End)
	{
		CloseHandle(menu2);
	}
	else if (action == MenuAction_Cancel)
	{
		// Redraw previous menu position if cancelled
		if (param2 == MenuCancel_ExitBack && GetAdminTopMenu() != INVALID_HANDLE)
		{
			DisplayTopMenu(GetAdminTopMenu(), param1, TopMenuPosition_LastCategory);
		}
	}
	else if (action == MenuAction_Select)
	{
		char info[32];
		GetMenuItem(menu2, param2, info, sizeof(info));
		
		int userid = StringToInt(info);
		WaitTypeToChatAndApplyGlow(param1, userid);
	}
}

void WaitTypeToChatAndApplyGlow(int client, int target_id)
{
	g_hGlowMap.SetValue("target_id", target_id, true);
	g_bListenForGlowColorTarget[client] = true;
	
	PrintToChat(client, "Type to chat the RGB value for selected target.");
}

public int MenuHandler_PathPlayer(Handle menu2, MenuAction action, int param1, int param2)
{
	if (action == MenuAction_End)
	{
		CloseHandle(menu2);
	}
	else if (action == MenuAction_Cancel)
	{
		// Redraw previous menu position if cancelled
		if (param2 == MenuCancel_ExitBack && GetAdminTopMenu() != INVALID_HANDLE)
		{
			DisplayTopMenu(GetAdminTopMenu(), param1, TopMenuPosition_LastCategory);
		}
	}
	else if (action == MenuAction_Select)
	{
		char info[32];
		int userid, target;
		GetMenuItem(menu2, param2, info, sizeof(info));
		userid = StringToInt(info);
		target = GetClientOfUserId(userid);
		TryGetPathableLocation(target);
		DisplayPathPlayerMenu(param1);
	}
}

public int MenuHandler_moveplayer(Handle menu2, MenuAction action, int param1, int param2)
{
	if (action == MenuAction_End)
	{
		CloseHandle(menu2);
	}
	else if (action == MenuAction_Cancel)
	{
		// Redraw previous menu position if cancelled
		if (param2 == MenuCancel_ExitBack && GetAdminTopMenu() != INVALID_HANDLE)
		{
			DisplayTopMenu(GetAdminTopMenu(), param1, TopMenuPosition_LastCategory);
		}
	}
	else if (action == MenuAction_Select)
	{
		char info[32];
		int userid, target;
		GetMenuItem(menu2, param2, info, sizeof(info));
		userid = StringToInt(info);
		target = GetClientOfUserId(userid);
		TryMovePlayerToPosition(param1, target);
		DisplayMovePlayerMenu(param1);
	}
}

public int MenuHandler_spitplayer(Handle menu2, MenuAction action, int param1, int param2)
{
	if (action == MenuAction_End)
	{
		CloseHandle(menu2);
	}
	else if (action == MenuAction_Cancel)
	{
		// Redraw previous menu position if cancelled
		if (param2 == MenuCancel_ExitBack && GetAdminTopMenu() != INVALID_HANDLE)
		{
			DisplayTopMenu(GetAdminTopMenu(), param1, TopMenuPosition_LastCategory);
		}
	}
	else if (action == MenuAction_Select)
	{
		char info[32];
		int userid, target;
		GetMenuItem(menu2, param2, info, sizeof(info));
		userid = StringToInt(info);
		target = GetClientOfUserId(userid);
		DropSpitOnPlayer(target);
		DisplaySpitPlayerMenu(param1);
	}
}

public int MenuHandler_dropfireplayer(Handle menu2, MenuAction action, int param1, int param2)
{
	if (action == MenuAction_End)
	{
		CloseHandle(menu2);
	}
	else if (action == MenuAction_Cancel)
	{
		// Redraw previous menu position if cancelled
		if (param2 == MenuCancel_ExitBack && GetAdminTopMenu() != INVALID_HANDLE)
		{
			DisplayTopMenu(GetAdminTopMenu(), param1, TopMenuPosition_LastCategory);
		}
	}
	else if (action == MenuAction_Select)
	{
		char info[32];
		int userid, target;
		GetMenuItem(menu2, param2, info, sizeof(info));
		userid = StringToInt(info);
		target = GetClientOfUserId(userid);
		DropFireOnPlayer(target);
		DisplayDropfireMenu(param1);
	}
}

public int MenuHandler_staggerplayer(Handle menu2, MenuAction action, int param1, int param2)
{
	if (action == MenuAction_End)
	{
		CloseHandle(menu2);
	}
	else if (action == MenuAction_Cancel)
	{
		// Redraw previous menu position if cancelled
		if (param2 == MenuCancel_ExitBack && GetAdminTopMenu() != INVALID_HANDLE)
		{
			DisplayTopMenu(GetAdminTopMenu(), param1, TopMenuPosition_LastCategory);
		}
	}
	else if (action == MenuAction_Select)
	{
		char info[32];
		int userid, target;
		GetMenuItem(menu2, param2, info, sizeof(info));
		userid = StringToInt(info);
		target = GetClientOfUserId(userid);
		StaggerPlayer(target);
		DisplayStaggerPlayerMenu(param1);
	}
}

public int MenuHandler_ledgehangplayer(Handle menu2, MenuAction action, int param1, int param2)
{
	if (action == MenuAction_End)
	{
		CloseHandle(menu2);
	}
	else if (action == MenuAction_Cancel)
	{
		// Redraw previous menu position if cancelled
		if (param2 == MenuCancel_ExitBack && GetAdminTopMenu() != INVALID_HANDLE)
		{
			DisplayTopMenu(GetAdminTopMenu(), param1, TopMenuPosition_LastCategory);
		}
	}
	else if (action == MenuAction_Select)
	{
		char info[32];
		int userid, target;
		GetMenuItem(menu2, param2, info, sizeof(info));
		userid = StringToInt(info);
		target = GetClientOfUserId(userid);
		SetPlayerLedgeHanging(target);
		DisplayLedgeHangPlayerMenu(param1);
	}
}

public int MenuHandler_respawnplayer(Handle menu2, MenuAction action, int param1, int param2)
{
	if (action == MenuAction_End)
	{
		CloseHandle(menu2);
	}
	else if (action == MenuAction_Cancel)
	{
		// Redraw previous menu position if cancelled
		if (param2 == MenuCancel_ExitBack && GetAdminTopMenu() != INVALID_HANDLE)
		{
			DisplayTopMenu(GetAdminTopMenu(), param1, TopMenuPosition_LastCategory);
		}
	}
	else if (action == MenuAction_Select)
	{
		char info[32];
		int userid, target;
		GetMenuItem(menu2, param2, info, sizeof(info));
		userid = StringToInt(info);
		target = GetClientOfUserId(userid);
		DefibPlayer(target);
		DisplayRespawnPlayerMenu(param1);
	}
}

public int MenuHandler_explodeplayer(Handle menu2, MenuAction action, int param1, int param2)
{
	if (action == MenuAction_End)
	{
		CloseHandle(menu2);
	}
	else if (action == MenuAction_Cancel)
	{
		// Redraw previous menu position if cancelled
		if (param2 == MenuCancel_ExitBack && GetAdminTopMenu() != INVALID_HANDLE)
		{
			DisplayTopMenu(GetAdminTopMenu(), param1, TopMenuPosition_LastCategory);
		}
	}
	else if (action == MenuAction_Select)
	{
		char info[32];
		int userid, target;
		GetMenuItem(menu2, param2, info, sizeof(info));
		userid = StringToInt(info);
		target = GetClientOfUserId(userid);
		ExplodePlayer(target);
		DisplayExplodePlayerMenu(param1);
	}
}

/*********************
	Shared stuff
**********************/

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

/*
void StartDroneStrike(int client)
{
	int iRandomInt = GetRandomInt(10, 20);
	PrintToChat(client, "\x01[SM] Starting drone strike. Strike lasts for \x04%i\x01 seconds.", iRandomInt);
	
	TryBeginDroneStrike(iRandomInt);
}

void TryBeginDroneStrike(int time)
{
	CreateTimer(0.8, Timer_DroneDelay, time, TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);
}

public Action Timer_DroneDelay(Handle timer, int time_data)
{
	static int count = 0;
	// PrintToChatAll("[DroneStrike] Timer ticking, %i", count);
	
	if (count > time_data)
	{
		// PrintToChatAll("[DroneStrike] Stopping timer, time expired.");
		count = 0;
		return Plugin_Stop;
	}
	
	Address iRandomArea;
	float vMins[3], vMaxs[3], vOrigin[3];
	
	iRandomArea = view_as<Address>(LoadFromAddress(TheNavAreas + view_as<Address>(4 * GetRandomInt(0, TheCount)), NumberType_Int32));
		
	if (iRandomArea == Address_Null || (LoadFromAddress(iRandomArea + view_as<Address>(84), NumberType_Int32) != 0x20000000))
	{
		// PrintToConsoleAll("[DroneStrike] Failed to find valid position, re-trying...");
		return Plugin_Continue;
	}
		
	vMins[0] = view_as<float>(LoadFromAddress(iRandomArea + view_as<Address>(4), NumberType_Int32));
	vMins[1] = view_as<float>(LoadFromAddress(iRandomArea + view_as<Address>(8), NumberType_Int32));
	vMins[2] = view_as<float>(LoadFromAddress(iRandomArea + view_as<Address>(12), NumberType_Int32));
		
	vMaxs[0] = view_as<float>(LoadFromAddress(iRandomArea + view_as<Address>(16), NumberType_Int32));
	vMaxs[1] = view_as<float>(LoadFromAddress(iRandomArea + view_as<Address>(20), NumberType_Int32));
	vMaxs[2] = view_as<float>(LoadFromAddress(iRandomArea + view_as<Address>(24), NumberType_Int32));

	AddVectors(vMins, vMaxs, vOrigin);
	ScaleVector(vOrigin, 0.5);
	
	int rnd = GetRandomInt(0, MAX_DRONE_SOUND - 1);
	EmitSoundToAll(sDroneFlySounds[rnd], SOUND_FROM_PLAYER, SNDCHAN_AUTO);
	
	ExplodeOrigin(vOrigin);
	count++;
	
	return Plugin_Continue;
}
*/

stock void ExplodeOrigin(float vPos[3])
{
	int ent = CreateEntityByName("env_explosion");
	if (IsValidEdict(ent))
	{
		DispatchKeyValue(ent, "fireballsprite", "sprites/zerogxplode.spr");		// Sprite material used by the explosion
		DispatchKeyValue(ent, "iMagnitude", "360");							// The amount of damage done by this explosion
		DispatchKeyValue(ent, "iRadiusOverride", "950"); 						// If specified, the radius in which the explosion damages entities. If unspecified, the radius will be based on the magnitude.
		DispatchKeyValue(ent, "targetname", "explosion_entity");
		DispatchKeyValue(ent, "rendermode", "5");
		DispatchSpawn(ent);
		
		TeleportEntity(ent, vPos, NULL_VECTOR, NULL_VECTOR);
		
		// Output: FireUser1
		// Target: !self
		// Via input: Explode
		// Delay: 0.1
		SetVariantString("OnUser1 !self:Explode:0.1");
		AcceptEntityInput(ent, "AddOutput");
		AcceptEntityInput(ent, "FireUser1");
		
		int rnd = GetRandomInt(0, MAX_EXPLOSION_SOUNDS - 1);
		EmitSoundToAll(sExplosionSounds[rnd], SOUND_FROM_PLAYER, SNDCHAN_AUTO);
	}
	
	vPos[2] += 25.0;
	L4D2_RunScript("DropFire(Vector(%f,%f,%f))", vPos[0], vPos[1], vPos[2]);
}

void TryGetPathableLocation(int target) 
{
	L4D2_RunScript("EntIndexToHScript(%i).TryGetPathableLocationWithin(%i)", target, 600);
}

void TryMovePlayerToPosition(int client, int target)
{
	float fOrigin[3];
	GetClientAbsOrigin(client, fOrigin);
	L4D2_RunScript("CommandABot({cmd=1,pos=Vector(%f,%f,%f),bot=GetPlayerFromUserID(%i)})",
	fOrigin[0], fOrigin[1], fOrigin[2], GetClientUserId(target));
}

void DropSpitOnPlayer(int target)
{
	float fOrg[3];
	GetClientAbsOrigin(target, fOrg);
	fOrg[2] += 30.0;
	L4D2_RunScript("DropSpit(Vector(%f,%f,%f))", fOrg[0], fOrg[1], fOrg[2]);
}

void DropFireOnPlayer(int target)
{
	float fOrg[3];
	GetClientAbsOrigin(target, fOrg);
	fOrg[2] += 30.0;
	L4D2_RunScript("DropFire(Vector(%f,%f,%f))", fOrg[0], fOrg[1], fOrg[2]);
}

void StaggerPlayer(int target)
{
	L4D2_RunScript("EntIndexToHScript(%i).Stagger(Vector(0.0,0.0,0.0))", target);
}

void SetPlayerLedgeHanging(int target)
{
	SetEntProp(target, Prop_Send, "m_isFallingFromLedge", 1);
	CreateTimer(5.0, Timer_ResetProps, GetClientUserId(target));
}

void DefibPlayer(int target)
{
	L4D2_RunScript("EntIndexToHScript(%i).ReviveByDefib()", target);
	HealPlayer(target);
}

// khan's
void HealPlayer(int client)
{
	// Heal player to 100 permanent health
	int iflags = GetCommandFlags("give");
	SetCommandFlags("give", iflags & ~FCVAR_CHEAT);
	FakeClientCommand(client, "give health");
	SetCommandFlags("give", iflags);
	
	// Remove temp health and reset revive count
	SetEntPropFloat(client, Prop_Send, "m_healthBuffer", 0.0);
	SetEntProp(client, Prop_Send, "m_currentReviveCount", 0);
}

public Action Timer_ResetProps(Handle timer, int data)
{
	int client = GetClientOfUserId(data);
	if(client && IsClientInGame(client))
	{
		SetEntProp(client, Prop_Send, "m_isFallingFromLedge", 0);
		HealPlayer(client);
	}
}

void ExplodePlayer(int target)
{
	float fClientOrigin[3];
	GetClientAbsOrigin(target, fClientOrigin);
	
	int ent = CreateEntityByName("env_explosion");
	if(IsValidEdict(ent))
	{
		DispatchKeyValue(ent, "fireballsprite", "sprites/zerogxplode.spr");		// Sprite material used by the explosion
		DispatchKeyValue(ent, "iMagnitude", "3000");							// The amount of damage done by this explosion
		DispatchKeyValue(ent, "iRadiusOverride", "500"); 						// If specified, the radius in which the explosion damages entities. If unspecified, the radius will be based on the magnitude.
		DispatchKeyValue(ent, "targetname", "explosion_entity");
		DispatchKeyValue(ent, "rendermode", "5");
		DispatchSpawn(ent);
		
		TeleportEntity(ent, fClientOrigin, NULL_VECTOR, NULL_VECTOR);
		
		// Output: FireUser1
		// Target: !self
		// Via input: Explode
		// Delay: 0.1
		SetVariantString("OnUser1 !self:Explode:0.1");
		AcceptEntityInput(ent, "AddOutput");
		AcceptEntityInput(ent, "FireUser1");
		
		int rnd = GetRandomInt(0, MAX_EXPLOSION_SOUNDS - 1);
		EmitSoundToAll(sExplosionSounds[rnd], target, SNDCHAN_AUTO);
	}
}