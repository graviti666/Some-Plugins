#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <adminmenu>
#include <weapons>

#define DEBUG		0
#define DEBUGLOG 	0
#define PLUGIN_VERSION "1.0"

#define L4D_TEAM_SPECTATE 1
#define L4D_TEAM_SURVIVORS 2
#define L4D_TEAM_INFECTED 3

#define MODELID_NICK 194
#define MODELID_ROCHELLE 195
#define MODELID_COACH 196
#define MODELID_ELLIS 197
#define MODELID_BILL 90
#define MODELID_ZOEY 91
#define MODELID_FRANCIS 92
#define MODELID_LOUIS 93

#define HIGHLIGHT_TIMER	6.0
#define COLOR_RED			999
#define COLOR_BLUE		200000000
#define COLOR_YELLOW		1238947
#define COLOR_WHITE		9999999

/*
 * TODO:
 * * Fix bug where it puts back the players gun if they're standing next to the gun spawn when loading the gas
 */

public Plugin:myinfo =
{
	name = "Gas Configs",
	author = "khan",
	description = "Save and load gas configs",
	version = PLUGIN_VERSION
}

#define IS_VALID_CLIENT(%1)     (%1 > 0 && %1 <= MaxClients)
#define IS_SURVIVOR(%1)         (GetClientTeam(%1) == 2)
#define IS_VALID_INGAME(%1)     (IS_VALID_CLIENT(%1) && IsClientInGame(%1))
#define IS_VALID_SURVIVOR(%1)   (IS_VALID_INGAME(%1) && IS_SURVIVOR(%1))
#define IS_SURVIVOR_ALIVE(%1)   (IS_VALID_SURVIVOR(%1) && IsPlayerAlive(%1))

#define WEAPON_NOT_CARRIED				0       // Weapon is not with survivor
#define WEAPON_IS_CARRIED_BY_PLAYER		1       // Survivor is carrying weapon
#define WEAPON_IS_ACTIVE					2   	// Survivor has weapon equipped

new const String:WeaponSpawnNames[WeaponId][] =
{
	"weapon_none_spawn", "weapon_pistol_spawn", "weapon_smg_spawn",                                            // 0
	"weapon_pumpshotgun_spawn", "weapon_autoshotgun_spawn", "weapon_rifle_spawn",                              // 3
	"weapon_hunting_rifle_spawn", "weapon_smg_silenced_spawn", "weapon_shotgun_chrome_spawn",                  // 6
	"weapon_rifle_desert_spawn", "weapon_sniper_military_spawn", "weapon_shotgun_spas_spawn",                  // 9
	"weapon_first_aid_kit_spawn", "weapon_molotov_spawn", "weapon_pipe_bomb_spawn",                            // 12
	"weapon_pain_pills_spawn", "prop_physics", "prop_physics",                             					   // 15
	"prop_physics", "", "weapon_chainsaw_spawn",                                 			   // 18 weapon_melee_spawn
	"weapon_grenade_launcher_spawn", "weapon_ammo_pack_spawn", "weapon_adrenaline_spawn",                      // 21
	"weapon_defibrillator_spawn", "weapon_vomitjar_spawn", "weapon_rifle_ak47_spawn",                          // 24
	"", "", "prop_physics",                           			   // 27
	"weapon_upgradepack_incendiary_spawn", "weapon_upgradepack_explosive_spawn", "weapon_pistol_magnum_spawn", // 30
	"weapon_smg_mp5_spawn", "weapon_rifle_sg552_spawn", "weapon_sniper_awp_spawn",                             // 33
	"weapon_sniper_scout_spawn", "weapon_rifle_m60_spawn", "",                           // 36
	"", "", "",                       // 39
	"", "", "",                       // 42
	"", "", "",                                                   // 45
	"", "", "",                                                              // 48
	"", "", "",                                                              // 51
	"weapon_ammo_spawn", ""        
}

new const String:FireworkModel[] = "models/props_junk/explosive_box001.mdl";
new const String:PropaneModel[] = "models/props_junk/propanecanister001a.mdl";

new String:g_sMapName[128];
new String:g_sDirPath[PLATFORM_MAX_PATH];
new String:g_sConfigFilePath[PLATFORM_MAX_PATH];

new g_iMaxSetups;

new Float:g_fHighlightTime;

new Handle:g_hSetupLimit = INVALID_HANDLE;
new Handle:g_hLegitCan = INVALID_HANDLE;
new Handle:g_hAdminMenu = INVALID_HANDLE;
new bool:g_bAdminMenu[MAXPLAYERS];

new g_iGasCount;

new bool:g_bListen[MAXPLAYERS];
new g_iListenStart[MAXPLAYERS];

new String:g_sDefaultConfig[128];

new bool:g_bRoundStart;
new bool:g_bLegitCans;

new g_iOwnerEntity;

new Handle:g_hDeletedEnts = INVALID_HANDLE;

#define NUM_MODEL_TYPES 5
new const String:ModelNames[NUM_MODEL_TYPES][128] = 
{
	"models/props_junk/gascan001a.mdl",
	"models/props_junk/propanecanister001a.mdl",
	"/props_junk/propanecanister001.mdl",
	"models/props_junk/explosive_box001a.mdl",
	"models/props_junk/explosive_box001.mdl"
}
new const String:ClassNames[NUM_MODEL_TYPES][128] =
{
	"weapon_gascan",
	"weapon_propanetank",
	"weapon_propanetank",
	"weapon_fireworkcrate",
	"weapon_fireworkcrate"
}

#define NUM_CANS_TYPES 7
new String:UniqueClassNames[NUM_CANS_TYPES][128] = 
{
	"weapon_gascan",
	"weapon_propanetank",
	"weapon_fireworkcrate",
	"upgrade_ammo_incendiary",
	"upgrade_ammo_explosive",
	"weapon_upgradepack_incendiary_spawn",
	"weapon_upgradepack_explosive_spawn"
}

new bool:g_bMovingCans;

public OnPluginStart()
{
	// Commands
	RegConsoleCmd("sm_gasmenu", Command_GasMenu, "Loads the gas menu");
	RegConsoleCmd("sm_gashere", Command_MoveGasToClient, "Moves all the gascans to the player");
	
	// Add listeners for setting config names
	AddCommandListener(Command_Say, "say");
	AddCommandListener(Command_Say, "say_team");
	
	// Hook Events
	HookEvent("round_start", Event_RoundStart, EventHookMode_Pre);
	HookEvent("round_end", Event_RoundEnd, EventHookMode_Pre);
	HookEvent("survival_round_start", Event_SurvivalStart, EventHookMode_Pre);
	
	// Convar gas setup limit
	g_hSetupLimit = CreateConVar("l4d2_gasmenu_limit", "20", "Max number of gas setups to allow per map", 0, true, 0.0, true, 99.0);
	g_hLegitCan = CreateConVar("l4d2_gasmenu_legitcan", "1", "Whether or not to spawn cans that have correct movement properties", 0, true, 0.0, true, 1.0);
	
	HookConVarChange(g_hSetupLimit, OnSetupLimitChange);
	HookConVarChange(g_hLegitCan, OnLegitCanChange);
	
	g_iMaxSetups = GetConVarInt(g_hSetupLimit);
	g_bLegitCans = GetConVarBool(g_hLegitCan);
	
	g_hDeletedEnts = CreateTrie(); // Would be better if this was a HashSet type list since I don't actually care about the value but whatever..
	
	Initialize();
	
	L4D2Weapons_Init();	// this needs to be called on plugin load when using weapons.inc
}

Initialize()
{
	for (new i = 0; i < MAXPLAYERS; i++)
	{
		g_bListen[i] = false;
	}
	g_bRoundStart = false;
	g_bMovingCans = false;
	
	SetListFile();
	
	// Reset the g_iOwnerEntity when the plugin loads. Will happen on map switch which is when this needs to be cleared out...
	g_iOwnerEntity = -1;
	
	#if DEBUGLOG
	LogMessage("GasConfig: Map Switched or plugin loaded");
	#endif
}


public Action:Command_MoveGasToClient(client, args)
{
	if (!IS_VALID_SURVIVOR(client))
	{
		PrintToChat(client, "You must be on the survivor team to use this command.");
		return Plugin_Handled;
	}
	else if (g_bRoundStart)
	{
		PrintToChat(client, "You cannot use this command while the round is active.");
		return Plugin_Handled;
	}
	
	MoveCansToClient(client);
	
	return Plugin_Handled;
}

public Action:Command_GasMenu(client, args)
{
	g_bAdminMenu[client] = false;
	ShowGasConfigMenu(client);
	return Plugin_Handled;
}

public OnSetupLimitChange(Handle:cvar, const String:oldVal[], const String:newVal[])
{
	g_iMaxSetups = GetConVarInt(g_hSetupLimit);
}

public OnLegitCanChange(Handle:cvar, const String:oldVal[], const String:newVal[])
{
	g_bLegitCans = GetConVarBool(g_hLegitCan);
}

//=================================
// Move gas cans to player
//=================================

MoveCansToClient(client)
{
	if (g_bMovingCans)
	{
		PrintToChat(client, "\x04Cans are currently being moved. Wait a sec.");
		return;
	}
	g_bMovingCans = true;
	
	new Handle:hDataPack;
	
	CreateDataTimer(0.1, Timer_MoveGas, hDataPack, TIMER_REPEAT);
	FindAllGas(hDataPack, client);
	ResetPack(hDataPack);
}

FindAllGas(Handle:hDataPack, client)
{
	new entity = -1;
	while ((entity = FindEntityByClassname(entity, "prop_physics")) != -1)
	{
		decl String:sModel[PLATFORM_MAX_PATH];
		GetEntPropString(entity, Prop_Data, "m_ModelName", sModel, sizeof(sModel));
		
		if (StrContains(sModel, "gascan") != -1 || StrContains(sModel, FireworkModel) != -1)
		{
			WritePackCell(hDataPack, client);
			WritePackCell(hDataPack, entity);
		}
	}
	
	entity = -1;
	while ((entity = FindEntityByClassname(entity, "weapon_gascan")) != -1)
	{
		if (IsValidEntity(entity))
		{
			WritePackCell(hDataPack, client);
			WritePackCell(hDataPack, entity);
		}
	}
}

public Action:Timer_MoveGas(Handle:hTimer, Handle:hDataPack)
{
	if (!IsPackReadable(hDataPack, 16))
	{
		KillTimer(hTimer);
		g_bMovingCans = false;
		return Plugin_Handled;
	}
	
	new client = ReadPackCell(hDataPack);
	new iEnt = ReadPackCell(hDataPack);
	
	new Float:vPos[3];
	GetClientEyePosition(client, vPos);
	
	if (IsValidEntity(iEnt))
	{
		new Float:vVel[3] = { 0.0, 0.0, 0.0}
		TeleportEntity(iEnt, vPos, NULL_VECTOR, vVel);	// Overwriting velocity b/c using NULL_VECTOR for the velocity causes gas cans to float in the air for some reason..
	}
	
	return Plugin_Continue;
}


//=================================
// Listen commands
//=================================
public Action:Command_Say(client, const String:command[], argc)
{
	if (g_bListen[client])
	{
		g_bListen[client] = false;
		if ((GetTime() - g_iListenStart[client]) >=10)
		{
			return Plugin_Continue;
		}
		
		decl String:text[128];
		new startidx = 0;
		new String:dest[128];
		if (GetCmdArgString(text, sizeof(text)) < 1)
		{
			return Plugin_Continue;
		}
		if (text[strlen(text)-1] == '"')
		{
			text[strlen(text)-1] = '\0';
			startidx = 1;
		}
		Format(dest, sizeof(dest), text[startidx]);
		
		SaveGasSetupHandle(client, dest);
		
		return Plugin_Handled;
	}
	
	return Plugin_Continue;
}

//=================================
// Helper Methods
//=================================

public CreateConfigDir()
{
	new String:path[PLATFORM_MAX_PATH] = "addons/sourcemod/data/GasConfigs";
	
	if (!DirExists(path))
	{
		CreateDirectory(path, 3);
	}
	
	StrCat(path, sizeof(path), "/");
	StrCat(path, sizeof(path), g_sMapName);
	if (!DirExists(path))
	{
		CreateDirectory(path, 3);
	}
	g_sDirPath = path;
}


public SetKVPath(String:fileName[128], String:sCfgPath[PLATFORM_MAX_PATH])
{
	BuildPath(Path_SM, sCfgPath, sizeof(sCfgPath), "data/GasConfigs/%s/%s.cfg", g_sMapName, fileName);
}

public SetListFile()
{
	// Create the GasConfigs directory if necessary
	new String:path[PLATFORM_MAX_PATH] = "addons/sourcemod/data/GasConfigs";	
	if (!DirExists(path))
	{
		CreateDirectory(path, 3);
	}
	
	BuildPath(Path_SM, g_sConfigFilePath, sizeof(g_sConfigFilePath), "data/GasConfigs/CfgList.cfg");
}

public AddToCurrentlyBeingDeletedList(iEnt)
{
	decl String:sEnt[64];
	
	IntToString(iEnt, sEnt, sizeof(sEnt));
	new val;
	if (!GetTrieValue(g_hDeletedEnts, sEnt, val))
	{
		SetTrieValue(g_hDeletedEnts, sEnt, 1);
	}
}

public RemoveItem(WeaponId:wID)
{
	new iEnt;
	// Find and kill any matching entities.
	while ((iEnt = FindEntityByClassname(iEnt, WeaponNames[wID])) != -1) 
	{
		if (!IsValidEdict(iEnt) || !IsValidEntity(iEnt)) {
			continue;
		}
		
		AcceptEntityInput(iEnt, "kill");
		AddToCurrentlyBeingDeletedList(iEnt);
	}
	
	// Kill the spawns for the weapon as well
	if (StrEqual(WeaponSpawnNames[wID], "prop_physics", false)) 
	{
		// Gas, propane, and fireworks are all prop_physics. Need to verify that we're killing the correct entity by checking the model. Properly could just kill all prop_physics if we don't care about oxygen tanks...
		KillItemByModel(wID);
	}
	else
	{
		// Look up all spawns for special ammo and kill them.
		KillItemBySpawn(wID);
	} 
}

public KillItemByModel(WeaponId:wID)
{
	new iEnt;
	new String:sEntModel[128];
	while ((iEnt = FindEntityByClassname(iEnt, WeaponSpawnNames[wID])) != -1) 
	{
		if (!IsValidEdict(iEnt) || !IsValidEntity(iEnt)) {
			continue;
		}
		
		GetEntPropString(iEnt, Prop_Data, "m_ModelName", sEntModel, sizeof(sEntModel)); 
		if (StrContains(sEntModel, WeaponModels[wID], false) != -1) 
		{
			if (bool:GetEntProp(iEnt, Prop_Send, "m_isCarryable", 1)) 
			{
				AcceptEntityInput(iEnt, "kill");
				AddToCurrentlyBeingDeletedList(iEnt);
			}
		}
		else if (wID == WeaponId:WEPID_FIREWORKS_BOX && StrEqual(sEntModel, FireworkModel, false)) // fireworks use a different model then what the weapons.inc lists... at least in concert survival.
		{
			if (bool:GetEntProp(iEnt, Prop_Send, "m_isCarryable", 1)) 
			{
				AcceptEntityInput(iEnt, "kill");
				AddToCurrentlyBeingDeletedList(iEnt);
			}			
		}
		else if (wID == WeaponId:WEPID_PROPANE_TANK && StrEqual(sEntModel, PropaneModel, false))
		{
			if (bool:GetEntProp(iEnt, Prop_Send, "m_isCarryable", 1))
			{
				AcceptEntityInput(iEnt, "kill");
				AddToCurrentlyBeingDeletedList(iEnt);
			}
		}
	}
}

public KillItemBySpawn(WeaponId:wID)
{
	new iEnt;
	while ((iEnt = FindEntityByClassname(iEnt, WeaponSpawnNames[wID])) != -1) 
	{
		if (!IsValidEdict(iEnt) || !IsValidEntity(iEnt)) {
			continue;
		}
		AcceptEntityInput(iEnt, "kill");
		AddToCurrentlyBeingDeletedList(iEnt);
	}
}

public IsWeaponEquipped(weapon)
{
	new state = GetEntProp(weapon, Prop_Data, "m_iState");
	
	if (state == WEAPON_IS_ACTIVE)
	{
		return true;
	}
	
	return false;
}

public ChangeSpawnType(client, bool:bUseLegitCans)
{
	if (bUseLegitCans)
	{
		SetConVarBool(g_hLegitCan, true);
		PrintToChat(client, "\x04Will place cans with the correct movement settings.");
	}
	else
	{
		SetConVarBool(g_hLegitCan, false);
		PrintToChat(client, "\x04Will use default incorrect movement settings when moving cans.");
	}
	g_bLegitCans = GetConVarBool(g_hLegitCan);
}

public Action:Timer_RetakePlayer(Handle:timer, any:client)
{
	RetakePlayer(client);
}

RetakePlayer(client)
{
	new model = GetEntProp(client, Prop_Send, "m_nModelIndex");
	new String:bot[32];
	
	switch (model)
	{
		case MODELID_NICK:
		{
			bot = "Nick";
		}
		case MODELID_ROCHELLE:
		{
			bot = "Rochelle";
		}
		case MODELID_COACH:
		{
			bot = "Coach";
		}
		case MODELID_ELLIS:
		{
			bot = "Ellis";
		}
		case MODELID_BILL:
		{
			bot = "Bill";
		}
		case MODELID_ZOEY:
		{
			bot = "Zoey";
		}
		case MODELID_LOUIS:
		{
			bot = "Louis";
		}
		case MODELID_FRANCIS:
		{
			bot = "Francis";
		}
	}
	
	if (!StrEqual(bot, ""))
	{
		ChangePlayerTeam(client, L4D_TEAM_SPECTATE, "");
		ChangePlayerTeam(client, L4D_TEAM_SURVIVORS, bot);	
	}
}

ChangePlayerTeam(client, team, const String:player[])
{
	if(GetClientTeam(client) == team) return;
	
	// For spectate or infected, simply move the player over
	if(team != L4D_TEAM_SURVIVORS)
	{
		ChangeClientTeam(client, team);
		return;
	}
	
	//for survivors its more tricky...
	new String:command[] = "sb_takecontrol";
	new flags = GetCommandFlags(command);
	SetCommandFlags(command, flags & ~FCVAR_CHEAT);
	
	new String:botNames[][128] = { "ellis", "nick", "coach", "rochelle", "zoey", "louis", "bill", "francis" };
	
	new cTeam;
	cTeam = GetClientTeam(client);
	
	new String:dest[128];
	new i = 0;
	while(cTeam != L4D_TEAM_SURVIVORS && i < 8) // while player isn't on survivor, max retry of 8 times just in case...
	{
		// Check if they selected a specific survivor to play as
		if (player[0] != EOS)
		{
			// Loook for specific survivor
			dest = botNames[i];
			if (strlen(player) < strlen(botNames[i]))
			{
				ReplaceString(dest, sizeof(dest), botNames[i][strlen(player)], "");
			}
			
			if (!StrEqual(dest, player, false))
			{
				// Not the bot that they want, continue looking
				i++;
				continue;
			}
		}
		
		// Have player take over the bot
		FakeClientCommand(client, "sb_takecontrol %s", botNames[i]);
		cTeam = GetClientTeam(client);
		i++;	//this shouldn't be needed but just in case...
	}
}

//=================================
// Save methods
//=================================
public StartListenForSave(client)
{
	PrintToChat(client, "You have 10 seconds to type the config name in chat");
	g_bListen[client] = true;
	g_iListenStart[client] = GetTime();		
}

public SaveGasSetupHandle(client, String:name[128])
{
	GetCurrentMap(g_sMapName, sizeof(g_sMapName));
	
	// Verify that the directory for this map exists
	CreateConfigDir();
	
	if (SaveGasSetup(client, name))
	{
		PrintToChatAll("\x05New gas config saved [\x04%s\x05]", name);
	}
}



public SaveGasSetup(client, String:name[128])
{
	if (!CheckListCount(client, name))
	{
		return false;
	}

	new String:sCfgPath[PLATFORM_MAX_PATH];
	SetKVPath(name, sCfgPath);
	
	// Find all the gas and save the setup
	new Handle:kv = CreateKeyValues("GasConfig");
	FindGas(kv);
	KeyValuesToFile(kv, sCfgPath);
	CloseHandle(kv);
	
	return true;
}

public FindGas(Handle:kv)
{
	g_iGasCount = 0;
	new iEnt;
	
	// Look for any gas cans that have been moved around the map
	for (new i = 0; i < NUM_CANS_TYPES; i++)
	{
		while ((iEnt = FindEntityByClassname(iEnt, UniqueClassNames[i])) != -1) 
		{
			if (!IsValidEdict(iEnt) || !IsValidEntity(iEnt)) {
				continue;
			}
			
			ProcessGasCan(iEnt, UniqueClassNames[i], kv);
		}
	}
	
	new String:sEntModel[128];
	// Second loop for prop_physics objects since we need to look at the model name
	while ((iEnt = FindEntityByClassname(iEnt, "prop_physics")) != -1) 
	{
		if (!IsValidEdict(iEnt) || !IsValidEntity(iEnt)) {
			continue;
		}
		
		GetEntPropString(iEnt, Prop_Data, "m_ModelName", sEntModel, sizeof(sEntModel)); 
		for (new i = 0; i < NUM_MODEL_TYPES; i++)
		{
			if (StrEqual(sEntModel, ModelNames[i], false)) 
			{
				if (bool:GetEntProp(iEnt, Prop_Send, "m_isCarryable", 1)) 
				{
					ProcessGasCan(iEnt, ClassNames[i], kv);
					continue;
				}	
			}
		}
	}
}


public ProcessGasCan(iEnt, String:class[128], Handle:kv)
{
	new Float:position[3];
	new Float:angle[3];
	GetEntPropVector(iEnt, Prop_Send, "m_vecOrigin", position);
	GetEntPropVector(iEnt, Prop_Send, "m_angRotation", angle);
	
	// Create unique key
	new String:key[128] = "explosive";
	new String:name[128];
	IntToString(g_iGasCount, name, sizeof(name));
	StrCat(key, sizeof(key), name);

	// Add gascan as keyvalue
	KvJumpToKey(kv, key, true);
	KvSetString(kv, "class", class);
	KvSetVector(kv, "position", position);
	KvSetVector(kv, "angle", angle);
	KvRewind(kv);
	
	g_iGasCount++;
}


//===========================
// Load Methods
//===========================

public LoadGasSetupHandle(String:fileName[128], client)
{	
	GetCurrentMap(g_sMapName, sizeof(g_sMapName));
	
	new String:sCfgPath[PLATFORM_MAX_PATH];
	SetKVPath(fileName, sCfgPath);
	
	if (!FileExists(sCfgPath)) 
	{
		#if DEBUG
		PrintToChatAll("[LoadGasSetupHandle] File doesn't exist: %s", sCfgPath);
		#endif
		return;
	}
	
	LoadGasConfig(sCfgPath, client);
}

public LoadGasConfig(String:sCfgPath[PLATFORM_MAX_PATH], client)
{
	new Handle:kv = CreateKeyValues("GasConfig");
	if (!FileToKeyValues(kv, sCfgPath))
	{
		#if DEBUG
		PrintToChatAll("[LoadGasConfig] Couldn't process file: %s", sCfgPath);
		#endif
		return;
	}
	
	if (!KvGotoFirstSubKey(kv))
	{
		#if DEBUG
		PrintToChatAll("[LoadGasConfig] GotoFirstSubKey failed");
		#endif
		return;
	}
	
	// Reset our tracking of which entities are in the middle of being killed
	ClearTrie(g_hDeletedEnts);
	
	// Always remove existing special ammo and let the plugin re-place them in the "correct" location
	RemoveNonGasSpawns();
	
	// Reset the g_iOwnerEntity property value. Plugin will look it up.
	//g_iOwnerEntity = -1;
	
	// Initialize some stuff
	new Handle:hGasList = CreateStack(6);
	new Handle:hPropaneList = CreateStack(6);
	new Handle:hFireworkList = CreateStack(6);
	
	new numGas = 0;
	new numPropane = 0;
	new numFireworks = 0;
	
	new String:buffer[255];
	new String:class[64];
	new Float:position[3];
	new Float:angle[3];
	
	// Look up the setup information from the config file
	do
	{
		KvGetSectionName(kv, buffer, sizeof(buffer));
		KvGetString(kv, "class", class, sizeof(class));
		KvGetVector(kv, "position", position);
		KvGetVector(kv, "angle", angle);
		
		// Track the gas/propane/fireworks in a stack. Need special handling to spawn these out with the correct settings.
		if (StrEqual(class, WeaponNames[WeaponId:WEPID_GASCAN]))
		{
			AddToStack(hGasList, position, angle);
			numGas++;
		}
		else if (StrEqual(class, WeaponNames[WeaponId:WEPID_PROPANE_TANK]))
		{
			AddToStack(hPropaneList, position, angle);
			numPropane++;
		}
		else if (StrEqual(class, WeaponNames[WeaponId:WEPID_FIREWORKS_BOX]))
		{
			AddToStack(hFireworkList, position, angle);
			numFireworks++;
		}
		else
		{
			// Non-gas related items (ie. special ammo) can be spawned out right away
			SpawnItem(class, position, angle);
		}
	
	} while (KvGotoNextKey(kv, false));
	
	CloseHandle(kv);
	
	
	/* 
	 * Spawn gas cans, propane, fireworks into map by giving to player then forcing them to drop the can so that the gas cans move as they're supposed to (e.g. gas cans should move if a boomer explodes next to them)
	 * Note: if this is done within the first few seconds of a round then it will cause the players pills/kit to stick to them when they die and be unusable to others. Forcing the player to quickly spec/rejoin will fix this which is what the plugin does now.
	 */
	
	new bool:bRetakeSurvivor = false;
	// First find a client to give the gas to if needed
	if (client == -1)
	{
		new playerSurvivor = -1;
		// Client didn't run this command - ie. beginning of round or map transition
		for (new i = 0; i < MAXPLAYERS; i++)
		{
			if (IS_SURVIVOR_ALIVE(i))
			{
				if (IsFakeClient(i))
				{
					// Prefer using a bot survivor for this
					client = i;
					break;
				}
				else if (playerSurvivor == -1)
				{
					playerSurvivor = i;
				}
			}
		}
		
		if (client == -1 && playerSurvivor != -1)
		{
			// This is the start of the round and we're using a player. Need to make sure we force the player to retake control of the bot to avoid stupid issues..
			client = playerSurvivor;
			bRetakeSurvivor = true;
		}
	}
	
	// Determine how to spawn out the gas
	if (client == -1 || !UseLegitCanSetup())
	{
		#if DEBUGLOG
		LogMessage("Spawning gas the old way");
		#endif
		/* Don't have a valid survivor or admin wanted to spawn it the old way. Spawn the gas normally. The movement of the gas will be off but whatever... */
		
		// Remove the existing gas from the map
		RemoveGasSpawns();
		
		// Spawn out the gas to the correct location
		while (!IsStackEmpty(hGasList))
		{
			PopStackAndSpawn(hGasList, WeaponId:WEPID_GASCAN);
		}
		while (!IsStackEmpty(hPropaneList))
		{
			PopStackAndSpawn(hPropaneList, WeaponId:WEPID_PROPANE_TANK);
		}
		while (!IsStackEmpty(hFireworkList))
		{
			PopStackAndSpawn(hFireworkList, WeaponId:WEPID_FIREWORKS_BOX);
		}
	}
	else
	{
		/* Spawn out the gas in a way that will cause it to have the correct movement settings */
		#if DEBUGLOG
		LogMessage("Spawning gas cans with the correct movement settings");
		#endif
		
		/*
		PrintToChatAll("Gas: %i - %i", NumSpawns(WeaponId:WEPID_GASCAN), numGas);
		PrintToChatAll("Propane: %i - %i", NumSpawns(WeaponId:WEPID_PROPANE_TANK), numPropane);
		PrintToChatAll("Fireworks: %i - %i", NumSpawns(WeaponId:WEPID_FIREWORKS_BOX), numFireworks);
		*/
		
		new bool:bNewCans = false;
		if (NumSpawns(WeaponId:WEPID_GASCAN) != numGas ||
			NumSpawns(WeaponId:WEPID_PROPANE_TANK) != numPropane ||
			NumSpawns(WeaponId:WEPID_FIREWORKS_BOX) != numFireworks)
		{
			// Don't have enough cans on the map to use. Will need to spawn new cans which means special handling in order to spawn cans with the correct movements.
			bNewCans = true;
			#if DEBUGLOG
			LogMessage("  Using new cans because numbers don't match up");
			#endif
		}
		else if (g_iOwnerEntity == -1 && (numPropane > 0 || numFireworks > 0))
		{
			// Don't have a valid g_iOwnerEntity property for this map yet. Need to spawn a propane to find one.
			// *TODO* Shouldn't need to remove the gascans if they're already correct
			bNewCans = true;
			#if DEBUGLOG
			LogMessage("  Using new cans becuase g_iOwnerEntity is -1");
			#endif
		}
		else
		{
			// Already have enough cans on the map. Just move them around instead of spawning new ones.
			bNewCans = false;
		}
		
		if (bNewCans)
		{
			/* Give cans to players and force them to drop it to create a can with the correct movement properties */
			#if DEBUGLOG
			LogMessage("Spawning new gas cans");
			#endif
			
			// Get rid of any existing cans
			RemoveGasSpawns();
			
			new weapon	= GetPlayerWeaponSlot(client, 0); // Need to use primary or secondary. Equiping pills or throwables won't work to create proper gascans...
			if (weapon != -1)
			{
				/* Always use primary for now...
				new secondary = GetPlayerWeaponSlot(client, 1);
				if (secondary != -1 && IsWeaponEquipped(secondary))
				{
					bSecondary = true;
					weapon = secondary;
				} */
			}
			
			new iClip = 0;
			new ammo = 0;
			new iPrimType = -1;
			new bool:bSpawnedSMG = false;
			
			if (weapon == -1)
			{
				bSpawnedSMG = true;
				// give player an smg temporarily because we need to re-equip a primary or secondary for this to work. When a map loads, the player will only have pistols and re-equiping those causes them to duplicate a bunch - at least the way I was doing things...
				new index = CreateEntityByName("weapon_smg");
				DispatchSpawn(index);
				
				EquipPlayerWeapon(client, index);
				
				weapon = index;
			}
			else
			{
				// Track how much ammo the player had
				iClip = GetEntProp(weapon, Prop_Send, "m_iClip1");
				iPrimType = GetEntProp(weapon, Prop_Send, "m_iPrimaryAmmoType");
				ammo = GetEntProp(client, Prop_Send, "m_iAmmo", _, iPrimType);
			}
			
			for (new i = 0; i < numGas; i++)
			{
				GiveItem(client, "weapon_gascan");
				
				// Force player to drop the gascan. Need to do this after every gas can otherwise the movement settings aren't correct. (ie. dropping gas by giving a new gascan isn't the same as dropping gascan from switching weapons).
				EquipPlayerWeapon(client, weapon);	
			}
			GiveItem(client, "weapon_propanetank");
			
			if (bSpawnedSMG)
			{
				// Kill the SMG now that we're done spawning gas
				AcceptEntityInput(weapon, "kill");
			}
			else
			{
				// Used the players gun, so we don't need to kill it but we do need to correct the ammo for it.
				SetEntProp(weapon, Prop_Send, "m_iClip1", iClip, sizeof(iClip));
				if (iPrimType != -1 && ammo > 0)
				{
					SetEntProp(client, Prop_Send, "m_iAmmo", ammo, _, iPrimType);
				}
			}
			
			// Find the m_hOwnerEntity property of the propane that was spawned. Then kill the entity so that we can spawn in new propane and correctly set that property.
			new iEnt;
			while ((iEnt = FindEntityByClassname(iEnt, WeaponNames[WeaponId:WEPID_PROPANE_TANK])) != -1) 
			{
				if (!IsValidEdict(iEnt) || !IsValidEntity(iEnt)) {
					continue;
				}
				
				// retrieve the m_hOwnerEntity property...
				g_iOwnerEntity = GetEntProp(iEnt, Prop_Send, "m_hOwnerEntity");
				AcceptEntityInput(iEnt, "kill");	// kill it now that we have the owner entity... 
			}
		}
		
		if (bRetakeSurvivor)
		{
			/* 
			 * Force the player used to create gas cans to join spectators and back to survivor in order to avoid having kit/pills stick to them when they die.
			 * This is only needed if the cans are loaded within the first few seconds of the round restarting. I'm assuming if the client was passed in (i.e. someone is manually loading a setup) that they aren't doing it within the first few seconds and we can skip this.
			 * Waiting a full second because this conflicts with the AutoSetup plugin if this runs before that's finished giving out weapons.
			 */
			CreateTimer(1.0, Timer_RetakePlayer, client);
		}
		
		// Move the gas cans into place
		FindAndMoveGas(WeaponId:WEPID_GASCAN, hGasList);
		
		if (bNewCans)
		{
			// Spawn out all the propane - Propane will not be movable for the player that "spawns" them. The other players can still bump the propane. That's just how things work..
			while (!IsStackEmpty(hPropaneList))
			{
				PopStackAndSpawn(hPropaneList, WeaponId:WEPID_PROPANE_TANK);
			}
			
			// Spawn out the fireworks
			while (!IsStackEmpty(hFireworkList))
			{
				PopStackAndSpawn(hFireworkList, WeaponId:WEPID_FIREWORKS_BOX);
			}
		}
		else
		{
			#if DEBUGLOG
			LogMessage("Moving around existing cans");
			#endif
			// Find and move the existing propane and fireworks
			FindAndMoveGas(WeaponId:WEPID_PROPANE_TANK, hPropaneList);
			FindAndMoveGas(WeaponId:WEPID_FIREWORKS_BOX, hFireworkList);
		}
	}
	
}

public bool:UseLegitCanSetup()
{
	// The steps for spawning cans with normal movement settings causes weird behavior on
	// rooftop where the kit/pills can stick to one of the survivors when they die. Always
	// have the plugin use the normal cans for this map for now...
	decl String:sMapName[256];
	GetCurrentMap(sMapName, sizeof(sMapName));
	if (StrEqual(sMapName, "c8m5_rooftop"))
	{
		return false;
	}
	
	return g_bLegitCans;
}

/* Find existing spawns and move them to the new location */
public FindAndMoveGas(WeaponId:WEPID, Handle:hStack)
{
	new iEnt;
	while ((iEnt = FindEntityByClassname(iEnt, WeaponNames[WEPID])) != -1) 
	{
		if (!IsValidEdict(iEnt) || !IsValidEntity(iEnt)) {
			continue;
		}
		
		decl String:sEnt[64];
		IntToString(iEnt, sEnt, sizeof(sEnt));
		new val;
		if (GetTrieValue(g_hDeletedEnts, sEnt, val))
		{
			// This is one of the gascan entities that are currently being killed. Killing the entity
			// doesn't occur immediately after running the command to kill it, so we have to check here.
			// Skip this entity.
			continue;
		}
		
		// Move the gas can into position
		PopStackAndMove(hStack, iEnt);
	}
	
	if (!IsStackEmpty(hStack))
	{
		// Try to look up item by model name if the stack isn't empty
		iEnt = -1;
		new String:sEntModel[128];
		while ((iEnt = FindEntityByClassname(iEnt, WeaponSpawnNames[WEPID])) != -1) 
		{
			if (!IsValidEdict(iEnt) || !IsValidEntity(iEnt)) {
				continue;
			}
			
			GetEntPropString(iEnt, Prop_Data, "m_ModelName", sEntModel, sizeof(sEntModel));
			if (StrEqual(sEntModel, WeaponModels[WEPID], false)) 
			{
				PopStackAndMove(hStack, iEnt);
			}
			else if (WEPID == WeaponId:WEPID_FIREWORKS_BOX && StrEqual(sEntModel, FireworkModel, false))
			{
				PopStackAndMove(hStack, iEnt);			
			}
			else if (WEPID == WeaponId:WEPID_PROPANE_TANK && StrEqual(sEntModel, PropaneModel, false))
			{
				PopStackAndMove(hStack, iEnt);
			}
		}
	}
}

public NumSpawns(WeaponId:WEPID)
{
	new iEnt;
	new iCount = 0;
	// Look up spawns by classname. Think this only works for gas..
	while ((iEnt = FindEntityByClassname(iEnt, WeaponNames[WeaponId:WEPID])) != -1) 
	{
		if (!IsValidEdict(iEnt) || !IsValidEntity(iEnt)) {
			continue;
		}
		
		iCount++;
	}
	
	// Try to look for prop_physics spawns by the model name
	iEnt = -1;
	decl String:sEntModel[128];
	while ((iEnt = FindEntityByClassname(iEnt, WeaponSpawnNames[WEPID])) != -1) 
	{
		if (!IsValidEdict(iEnt) || !IsValidEntity(iEnt)) {
			continue;
		}
		
		GetEntPropString(iEnt, Prop_Data, "m_ModelName", sEntModel, sizeof(sEntModel)); 
		if (StrEqual(sEntModel, WeaponModels[WEPID], false)) 
		{
			if (bool:GetEntProp(iEnt, Prop_Send, "m_isCarryable", 1)) // *TODO* why was I doing this check? is this needed?
			{
				iCount++;
			}
		}
		else if (WEPID == WeaponId:WEPID_FIREWORKS_BOX && StrEqual(sEntModel, FireworkModel, false)) // fireworks use a different model then what the weapons.inc lists... at least in concert survival.
		{
			if (bool:GetEntProp(iEnt, Prop_Send, "m_isCarryable", 1)) 
			{
				iCount++;
			}			
		}
		else if (WEPID == WeaponId:WEPID_PROPANE_TANK && StrEqual(sEntModel, PropaneModel, false))
		{
			if (bool:GetEntProp(iEnt, Prop_Send, "m_isCarryable", 1))
			{
				iCount++;
			}
		}
	}
	
	
	return iCount;
}

public RemoveNonGasSpawns()
{
	// Remove special ammo spawns
	RemoveItem(WeaponId:WEPID_INCENDIARY_AMMO);
	RemoveItem(WeaponId:WEPID_FRAG_AMMO);
	
	// Handling to remove already deployed special ammo
	RemoveDeployedSpecialAmmo();
}

public RemoveDeployedSpecialAmmo()
{
	new iEnt;
	while ((iEnt = FindEntityByClassname(iEnt, "upgrade_ammo_incendiary")) != -1) 
	{
		if (!IsValidEdict(iEnt) || !IsValidEntity(iEnt)) {
			continue;
		}
		AcceptEntityInput(iEnt, "kill");
	}
	
	while ((iEnt = FindEntityByClassname(iEnt, "upgrade_ammo_explosive")) != -1) 
	{
		if (!IsValidEdict(iEnt) || !IsValidEntity(iEnt)) {
			continue;
		}
		AcceptEntityInput(iEnt, "kill");
	}
}

public RemoveGasSpawns()
{
	RemoveItem(WeaponId:WEPID_GASCAN);
	RemoveItem(WeaponId:WEPID_PROPANE_TANK);
	RemoveItem(WeaponId:WEPID_FIREWORKS_BOX);
}

AddToStack(Handle:hStack, Float:position[3], Float:angle[3])
{
	new Float:val[6];
	val[0] = position[0];
	val[1] = position[1];
	val[2] = position[2];
	
	val[3] = angle[0];
	val[4] = angle[1];
	val[5] = angle[2];
	
	PushStackArray(hStack, val, sizeof(val));
}

public PopStackAndSpawn(Handle:hStack, WeaponId:wID)
{
	new Float:temp[6];
	new Float:position[3];
	new Float:angle[3];
	
	PopStackArray(hStack, temp, sizeof(temp));
	position[0] = temp[0];
	position[1] = temp[1];
	position[2] = temp[2];
	
	angle[0] = temp[3];
	angle[1] = temp[4];
	angle[2] = temp[5];
	
	SpawnItem(WeaponNames[wID], position, angle);
}

public PopStackAndMove(Handle:hStack, entity)
{
	if (!IsStackEmpty(hStack))
	{
		
		new Float:val[6];
		PopStackArray(hStack, val, sizeof(val));
		
		new Float:pos[3];
		new Float:ang[3];
		new Float:vel[3] = {0.0, 0.0, 0.0};
		pos[0] = val[0];
		pos[1] = val[1];
		pos[2] = val[2];
		
		ang[0] = val[3];
		ang[1] = val[4];
		ang[2] = val[5];
		
		TeleportEntity(entity, pos, ang, vel);
	}
	else
	{
		#if DEBUG
		PrintToChatAll("[PopStackAndMove] Stack is empty...");
		#endif
	}
}


GiveItem(client, String:weapon[128]) 
{
	new flagsgive = GetCommandFlags("give");
	SetCommandFlags("give", flagsgive & ~FCVAR_CHEAT);
	if (IsClientInGame(client)) FakeClientCommand(client, "give %s", weapon);
	SetCommandFlags("give", flagsgive|FCVAR_CHEAT);
} 

public SpawnItem(String:class[], Float:position[3], Float:angle[3])
{
	if (StrEqual(class, "weapon_propanetank"))
	{
		new entity = CreateEntityByName("prop_physics");
		SetEntityModel(entity, "models/props_junk/propanecanister001a.mdl");
		DispatchKeyValue(entity, "CanObstructNav", "0"); // Should remove the entity from blocking navigation?
		TeleportEntity(entity, position, angle, NULL_VECTOR);
		DispatchSpawn(entity);
		
		// Set the m_hOwnerEntity for propane/fireworks. Setting this seems to create propane that move around as their supposed to (e.g. don't slide around whenever a survivor touches them).
		SetEntProp(entity, Prop_Send, "m_hOwnerEntity", g_iOwnerEntity);
	}
	else if (StrEqual(class, "weapon_gascan"))
	{
		new index = CreateEntityByName(class);
		TeleportEntity(index, position, angle, NULL_VECTOR);
		DispatchKeyValue(index, "CanObstructNav", "0"); // Should remove the entity from blocking navigation?
		DispatchSpawn(index);
	}
	else if (StrEqual(class, "weapon_fireworkcrate"))
	{
		new entity = CreateEntityByName("prop_physics");
		SetEntityModel(entity, "models/props_junk/explosive_box001.mdl");
		DispatchKeyValue(entity, "CanObstructNav", "0"); // Should remove the entity from blocking navigation?
		TeleportEntity(entity, position, angle, NULL_VECTOR);
		DispatchSpawn(entity);
		
		// Set the m_hOwnerEntity for propane/fireworks. Setting this seems to create firework crates that move around as their supposed to (e.g. don't slide around whenever a survivor touches them).
		SetEntProp(entity, Prop_Send, "m_hOwnerEntity", g_iOwnerEntity);
	}
	else if (StrEqual(class, "upgrade_ammo_incendiary"))
	{
		new entity = CreateEntityByName("upgrade_ammo_incendiary");
		SetEntityModel(entity, "models/props/terror/incendiary_ammo.mdl");
		DispatchKeyValue(entity, "CanObstructNav", "0"); // Should remove the entity from blocking navigation?
		TeleportEntity(entity, position, angle, NULL_VECTOR);
		DispatchSpawn(entity);
	}
	else if (StrEqual(class, "upgrade_ammo_explosive"))
	{
		new entity = CreateEntityByName("upgrade_ammo_explosive");
		SetEntityModel(entity, "models/props/terror/exploding_ammo.mdl");
		DispatchKeyValue(entity, "CanObstructNav", "0"); // Should remove the entity from blocking navigation?
		TeleportEntity(entity, position, angle, NULL_VECTOR);
		DispatchSpawn(entity);
	}
}

//=============================
// Methods for removing a gas configs
//=============================

public RemoveGasSetupHandle(client, String:sConfigName[128])
{
	GetCurrentMap(g_sMapName, sizeof(g_sMapName));
	
	new String:sCfgPath[PLATFORM_MAX_PATH];
	SetKVPath(sConfigName, sCfgPath);
	
	if (FileExists(sCfgPath))
	{
		DeleteFile(sCfgPath);
	}
	else
	{
		PrintToChat(client, "File does not exist");
	}
}

//================================
// Methods for tracking cfg files
//================================

public bool:HasConfigs()
{
	GetCurrentMap(g_sMapName, sizeof(g_sMapName));
	
	new String:path[PLATFORM_MAX_PATH];
	new FileType:type;
	
	Format(path, sizeof(path), "/addons/sourcemod/data/GasConfigs/%s", g_sMapName);
	
	new Handle:dir = OpenDirectory(path);
	if (dir == INVALID_HANDLE)
	{
		// Directory doesn't exist, return false
		return false;
	}
	
	new String:file[PLATFORM_MAX_PATH];
	while (ReadDirEntry(dir, file, sizeof(file), type))
	{
		if (type == FileType_File)
		{
			return true;
		}
	}
	return false;
}

public bool:CheckListCount(client, String:sName[128])
{
	new String:path[PLATFORM_MAX_PATH];
	new FileType:type;
	new count = 0;

	Format(path, sizeof(path), "/addons/sourcemod/data/GasConfigs/%s", g_sMapName);
	
	new Handle:dir = OpenDirectory(path);
	if (dir == INVALID_HANDLE)
	{
		// Directory doesn't exist, return false
		PrintToChat(client, "Can't find directory for this map...");
		return false;
	}
	
	new String:file[128];
	while (ReadDirEntry(dir, file, sizeof(file), type))
	{
		if (type == FileType_File)
		{
			new String:cfgName[128];
			SplitString(file, ".", cfgName, sizeof(cfgName));
			if (StrEqual(cfgName, sName))
			{
				PrintToChat(client, "\x05Gas config \x04%s\x05 already exists.", sName);
				return false;
			}
			count++;
		}
	}
		
	if (count >= g_iMaxSetups)
	{
		PrintToChat(client, "\x03Already have %i configs for this map. Need to delete one before creating a new one.", g_iMaxSetups);
		return false;
	}
	
	return true;
}
//=============================
// Set Default Config
//=============================

public Action:Event_RoundEnd(Handle:hEvent, const String:name[], bool:dontBroadcast)
{
	g_bRoundStart = false;
}

public Action:Event_SurvivalStart(Handle:hEvent, const String:name[], bool:dontBroadcast)
{
	g_bRoundStart = true;
	
	// disable highlight if it's in progress
	HighlightGasCans("", false);
}

public Action:Event_RoundStart(Handle:hEvent, const String:name[], bool:dontBroadcast)
{
	decl String:GameName[16];
	GetConVarString(FindConVar("mp_gamemode"), GameName, sizeof(GameName));
	if (StrContains(GameName, "survival", false) != -1)
	{
		SetDefault();
		
		if (!StrEqual(g_sDefaultConfig, ""))
		{
			//Delay so that everything can load before loading the config
			CreateTimer(0.1, DefaultGasHandle);
		}
	}
}

public Action:DefaultGasHandle(Handle:timer)
{
	if (!StrEqual(g_sDefaultConfig, ""))
	{
		if (g_bLegitCans)
		{
			new bool:bFoundSurvivor = false;
			for (new i = 0; i < MAXPLAYERS; i++)
			{
				if (IS_SURVIVOR_ALIVE(i))
				{
					bFoundSurvivor = true;
				}
			}
			
			if (bFoundSurvivor)
			{
				LoadGasSetupHandle(g_sDefaultConfig, -1);
			}
			else
			{
				// Wait 0.1 seconds and try again
				CreateTimer(0.1, DefaultGasHandle);
			}
		}
		else
		{
			LoadGasSetupHandle(g_sDefaultConfig, -1);
		}
	}
	return Plugin_Handled;
}

public SetDefault()
{
	new Handle:kv = CreateKeyValues("CfgList");
	
	if (!FileToKeyValues(kv, g_sConfigFilePath))
	{
		#if DEBUG
		PrintToChatAll("Couldn't load the CfgList file");
		#endif
		return;
	}
	
	if (!KvJumpToKey(kv, "Default", true))
	{
		#if DEBUG
		PrintToChatAll("Couldn't create keyvalue for this map...");
		#endif
		return;
	}
	
	GetCurrentMap(g_sMapName, sizeof(g_sMapName));
	KvGetString(kv, g_sMapName, g_sDefaultConfig, sizeof(g_sDefaultConfig), "");
	
	CloseHandle(kv);
}

public SaveDefault(client, String:sConfig[128])
{
	new Handle:kv = CreateKeyValues("CfgList");
	
	if (!FileToKeyValues(kv, g_sConfigFilePath))
	{
		PrintToChat(client, "Couldn't load the CfgList file");
		return;
	}
	
	if (!KvJumpToKey(kv, "Default", true))
	{
		PrintToChat(client, "Couldn't create keyvalue for this map...");
		return;
	}
	
	PrintToChatAll("\x04%s\x05 set as default gas setup", sConfig);
	KvSetString(kv, g_sMapName, sConfig);
	
	KvRewind(kv);
	
	KeyValuesToFile(kv, g_sConfigFilePath);
	CloseHandle(kv);
}

public ClearDefault(client)
{
	new Handle:kv = CreateKeyValues("CfgList");
	
	if (!FileToKeyValues(kv, g_sConfigFilePath))
	{
		PrintToChat(client, "Couldn't load the CfgList file");
		return;
	}
	
	if (!KvJumpToKey(kv, "Default", true))
	{
		PrintToChat(client, "Couldn't create keyvalue for this map...");
		return;
	}
	
	KvDeleteKey(kv, g_sMapName);
	KvRewind(kv);
	KeyValuesToFile(kv, g_sConfigFilePath);
	CloseHandle(kv);

	PrintToChat(client, "\x05Default gas setup removed");
}

//============================
// Native Functions - I just use this to add the GasMenu as an option in my admin menu
//============================

public APLRes:AskPluginLoad2(Handle:myself, bool:late, String:error[], err_max)
{
   CreateNative("GasConfigMenu", Native_GasConfigMenu);
   return APLRes_Success;
}

public Native_GasConfigMenu(Handle:plugin, numParams)
{
	new client;
	client = GetNativeCell(1);
	g_hAdminMenu = GetNativeCell(2);
	g_bAdminMenu[client] = true;
	
	ShowGasConfigMenu(client)
}

//============================
// Menu system
//============================

ShowGasConfigMenu(client)
{
	new Handle:menu = CreateMenu(mh_GasConfig, MENU_ACTIONS_DEFAULT);
	SetMenuTitle(menu, "Gas Menu");
	
	if (IsClientRootAdmin(client) || IsClientWhiteListed(client))
	{
		// Only show back button if this menu was accessed through the admin menu
		if (g_bAdminMenu[client])
		{
			SetMenuExitBackButton(menu, true);
		}
		
		AddMenuItem(menu, "Create Gas Config", "Create Gas Config");
		// Only show the rest of the options if there are already gas setups created for the current map
		if (HasConfigs())
		{
			AddMenuItem(menu, "Load Gas Config", "Load Gas Config");
			AddMenuItem(menu, "Set Default Config", "Set Default Config");
			AddMenuItem(menu, "Delete Gas Config", "Delete Gas Config");
		}
		
		AddMenuItem(menu, "Move Gas Here", "Move Gas Here");
		
		// Give admin the option to change between spawning out the gas with the correct movement settings or not.
		if (g_bLegitCans)
		{
			AddMenuItem(menu, "Use Bad Movement Settings", "Use Bad Movement Settings");
		}
		else
		{
			AddMenuItem(menu, "Use Correct Movement Settings", "Use Correct Movement Settings");
		}
	}
	else
	{
		// Don't allow non-admins to move gas after round starts
		if (g_bRoundStart)
		{
			PrintToChat(client, "\x03Non-admins can only move gas before the round begins.")
			return;
		}
		else
		{
			if (HasConfigs())
			{
				AddMenuItem(menu, "Load Gas Config", "Load Gas Config");
			}
			AddMenuItem(menu, "Move Gas Here", "Move Gas Here");
		}
	}
	DisplayMenu(menu, client, MENU_TIME_FOREVER);
}

public mh_GasConfig(Handle:menu, MenuAction:action, param1, param2)
{
	switch (action)
	{
		case MenuAction_Select:
		{
			// Close menu if someone still had it open after round-start
			if (g_bRoundStart)
			{
				CloseHandle(menu);
			}
			
			//param1 is client, param2 is item
			new String:item[64];
			GetMenuItem(menu, param2, item, sizeof(item));

			if (StrEqual(item, "Create Gas Config"))
			{
				StartListenForSave(param1);
			}
			else if (StrEqual(item, "Load Gas Config"))
			{
				ShowLoadGasConfigMenu(param1);
			}
			else if (StrEqual(item, "Delete Gas Config"))
			{
				ShowDeleteGasConfigMenu(param1);
			}
			else if (StrEqual(item, "Set Default Config"))
			{
				ShowDefaultConfigMenu(param1);
			}
			else if (StrEqual(item, "Move Gas Here"))
			{
				MoveCansToClient(param1);
				ShowGasConfigMenu(param1);
			}
			else if (StrEqual(item, "Use Bad Movement Settings"))
			{
				ChangeSpawnType(param1, false);
				ShowGasConfigMenu(param1);
			}
			else if (StrEqual(item, "Use Correct Movement Settings"))
			{
				ChangeSpawnType(param1, true);
				ShowGasConfigMenu(param1);
			}
		}
		case MenuAction_Cancel:
		{
			if (param2 == MenuCancel_ExitBack)
			{
				DisplayTopMenu(g_hAdminMenu, param1, TopMenuPosition_LastCategory);
			}

		}
		case MenuAction_End:
		{
			CloseHandle(menu);
		}

	}
}

////////////////////
// Config Load Menu
////////////////////
ShowLoadGasConfigMenu(client)
{
	new Handle:menu = CreateMenu(mh_gas_config_load, MENU_ACTIONS_DEFAULT);
	SetMenuTitle(menu, "Load Gas Config");
	SetMenuExitBackButton(menu, true);
	
	new String:path[PLATFORM_MAX_PATH];
	
	Format(path, sizeof(path), "/addons/sourcemod/data/GasConfigs/%s", g_sMapName);
	
	new Handle:dir = OpenDirectory(path);
	if (dir == INVALID_HANDLE)
	{
		// Directory doesn't exist, return false
		PrintToChat(client, "\x03Couldn't find any gas setups for this map.");
		return;
	}
	
	new FileType:type;
	new String:file[128];
	// Loop through all the gas config files in the directory and add them to the menu
	while (ReadDirEntry(dir, file, sizeof(file), type))
	{
		if (type == FileType_File)
		{
			new String:cfgName[128];
			SplitString(file, ".", cfgName, sizeof(cfgName)); // remove the file extension..
			AddMenuItem(menu, cfgName, cfgName);
		}
	}
	
	DisplayMenu(menu, client, MENU_TIME_FOREVER);
}

public mh_gas_config_load(Handle:menu, MenuAction:action, param1, param2)
{
	switch (action)
	{
		case MenuAction_Select:
		{
			if ((GetUserAdmin(param1) == INVALID_ADMIN_ID) && g_bRoundStart)
			{
				// In case a non-admin had the gas menu open prior the round starting, left it open and waited to run this command until post-round start...
				PrintToChat(param1, "\x03Non-admins can only move gas before the round begins.");
				return;
			}
			if (g_bMovingCans)
			{
				PrintToChat(param1, "\x04Cans are currently being moved.");
				ShowLoadGasConfigMenu(param1);
				return;
			}
			new String:item[128];
			GetMenuItem(menu, param2, item, sizeof(item));
			
			LoadGasSetupHandle(item, param1);
			ShowLoadGasConfigMenu(param1);
			
			HighlightGasCans(item);
		}
		
		case MenuAction_Cancel:
		{
			if (param2 == MenuCancel_ExitBack)
			{
				ShowGasConfigMenu(param1);
			}

		}
		case MenuAction_End:
		{
			CloseHandle(menu);
		}
	}
}

/////////////////
// Config Delete Menu
/////////////////

ShowDeleteGasConfigMenu(client)
{
	new Handle:menu = CreateMenu(mh_gas_config_delete, MENU_ACTIONS_DEFAULT);
	SetMenuTitle(menu, "Delete Gas Config");
	SetMenuExitBackButton(menu, true);
	
	new String:path[PLATFORM_MAX_PATH];
	new FileType:type;
	
	Format(path, sizeof(path), "/addons/sourcemod/data/GasConfigs/%s", g_sMapName);
	
	new Handle:dir = OpenDirectory(path);
	if (dir == INVALID_HANDLE)
	{
		// Directory doesn't exist, return false
		PrintToChat(client, "Can't find directory for this map...");
		return;
	}
	
	new String:file[128];
	while (ReadDirEntry(dir, file, sizeof(file), type))
	{
		if (type == FileType_File)
		{
			new String:cfgName[128];
			SplitString(file, ".", cfgName, sizeof(cfgName));
			AddMenuItem(menu, cfgName, cfgName);
		}
	}
	
	DisplayMenu(menu, client, MENU_TIME_FOREVER);
}

public mh_gas_config_delete(Handle:menu, MenuAction:action, param1, param2)
{
	switch (action)
	{
		case MenuAction_Select:
		{
			//param1 is client, param2 is item
			new String:item[128];
			GetMenuItem(menu, param2, item, sizeof(item));
			RemoveGasSetupHandle(param1, item);
			ShowDeleteGasConfigMenu(param1);
		}
		
		case MenuAction_Cancel:
		{
			if (param2 == MenuCancel_ExitBack)
			{
				ShowGasConfigMenu(param1);
			}

		}
		case MenuAction_End:
		{
			CloseHandle(menu);
		}
	}
}

//=========================
// Default menu
//=========================

ShowDefaultConfigMenu(client)
{
	new Handle:menu = CreateMenu(mh_gas_config_default, MENU_ACTIONS_DEFAULT);
	SetMenuTitle(menu, "Set Default Config");
	SetMenuExitBackButton(menu, true);
	
	AddMenuItem(menu, "Normal Gas Spawns", "Normal Gas Spawns");
	
	new String:path[PLATFORM_MAX_PATH];
	new FileType:type;
	
	Format(path, sizeof(path), "/addons/sourcemod/data/GasConfigs/%s", g_sMapName);
	
	new Handle:dir = OpenDirectory(path);
	if (dir == INVALID_HANDLE)
	{
		// Directory doesn't exist, return false
		PrintToChat(client, "Can't find directory for this map...");
		return;
	}
	
	new String:file[128];
	while (ReadDirEntry(dir, file, sizeof(file), type))
	{
		if (type == FileType_File)
		{
			new String:cfgName[128];
			SplitString(file, ".", cfgName, sizeof(cfgName));
			AddMenuItem(menu, cfgName, cfgName);
		}
	}
	
	DisplayMenu(menu, client, MENU_TIME_FOREVER);
}

public mh_gas_config_default(Handle:menu, MenuAction:action, param1, param2)
{
	switch (action)
	{
		case MenuAction_Select:
		{
			new String:item[128];
			GetMenuItem(menu, param2, item, sizeof(item));
			if (StrEqual(item, "Normal Gas Spawns"))
			{
				ClearDefault(param1);
			}
			else
			{
				SaveDefault(param1, item);
			}
			ShowDefaultConfigMenu(param1);
		}
		
		case MenuAction_Cancel:
		{
			if (param2 == MenuCancel_ExitBack)
			{
				ShowGasConfigMenu(param1);
			}

		}
		case MenuAction_End:
		{
			CloseHandle(menu);
		}

	}
}

//=========================
// misc functions
//=========================

stock bool IsClientRootAdmin(client)
{
    return ((GetUserFlagBits(client) & ADMFLAG_ROOT) != 0);
}

/*
static bool:IsGenericAdmin(client) {
    return CheckCommandAccess(client, "generic_admin", ADMFLAG_GENERIC, false); 
}
*/

SetColor(ent, color)
{
	SetEntProp(ent, Prop_Send, "m_iGlowType", 3);
	SetEntProp(ent, Prop_Send, "m_glowColorOverride", color);
}

ClearGlow(ent)
{
	SetEntProp(ent, Prop_Send, "m_iGlowType", 0);
	SetEntProp(ent, Prop_Send, "m_glowColorOverride", 0);
}

// some of this might be new syntax. Really don't wanna bother with old syntax anyway.. - dustin
HighlightGasCans(String:fileName[128], bool:bHighlight = true)
{
	if (bHighlight)
	{
		PrintToChatAll("\x01Gas config selected: \x04%s", fileName);
		if (g_bRoundStart) return;
		
		g_fHighlightTime = GetGameTime();
		CreateTimer(HIGHLIGHT_TIMER, Timer_RemoveHighlight);
	}
	
	#define CLASSNAMES	4
	char sClassNames[][] = {"weapon_*", "prop_physics", "upgrade_ammo_*", "upgrade_laser_sight"};
	
	char sModelName[PLATFORM_MAX_PATH];
	for (int i = 0; i < CLASSNAMES; i++)
	{
		int entity = -1;
		
		while ((entity = FindEntityByClassname(entity, sClassNames[i])) != -1)
		{
			if (!IsValidEdict(entity) || !IsValidEntity(entity))
				continue;
			
			// weapon_gascan, upgraded ammo packs
			if (StrEqual(sClassNames[i], "weapon_*"))
			{
				GetEdictClassname(entity, sModelName, sizeof(sModelName));
				
				if (StrEqual(sModelName, "weapon_gascan")) 
				{
					if (bHighlight) SetColor(entity, COLOR_RED);
					else ClearGlow(entity);
				}
				
				// in-spawn, loose (out of spawn but not deployed), special ammo upgrade packs
				/* Note: currently this plugin doesn't save '_spawn' special ammo. Leaving here
				in case it gets updated to save undeployed ammo packs in a future update. */
				if (StrEqual(sModelName, "weapon_upgradepack_incendiary") ||
				StrEqual(sModelName, "weapon_upgradepack_incendiary_spawn") ||
				StrEqual(sModelName, "weapon_upgradepack_explosive") ||
				StrEqual(sModelName, "weapon_upgradepack_explosive_spawn")) 
				{
					if (bHighlight) SetColor(entity, COLOR_BLUE);
					else ClearGlow(entity);
				}
			}
			
			// gas cans, fireworks, propane
			if (StrEqual(sClassNames[i], "prop_physics"))
			{
				GetEntPropString(entity, Prop_Data, "m_ModelName", sModelName, sizeof(sModelName));
				
				if (StrContains(sModelName, "gascan") != -1)
				{
					if (bHighlight) SetColor(entity, COLOR_RED);
					else ClearGlow(entity);
				}
				
				if (StrContains(sModelName, "explosive_box001") != -1)
				{
					if (bHighlight) SetColor(entity, COLOR_YELLOW);
					else ClearGlow(entity);
				}
				
				if (StrContains(sModelName, "propanecanister") != -1)
				{
					if (bHighlight) SetColor(entity, COLOR_WHITE);
					else ClearGlow(entity);
				}
			}
			
			if (StrEqual(sClassNames[i], "upgrade_ammo_*"))
			{
				GetEntPropString(entity, Prop_Data, "m_ModelName", sModelName, sizeof(sModelName));
				
				if (StrContains(sModelName, "incendiary_ammo") != -1 ||
					StrContains(sModelName, "exploding_ammo") != -1)
					{
						if (bHighlight) SetColor(entity, COLOR_BLUE);
						else ClearGlow(entity);
					}
			}
			
			// laser sights
			if (StrEqual(sClassNames[i], "upgrade_laser_sight"))
			{
				GetEntPropString(entity, Prop_Data, "m_ModelName", sModelName, sizeof(sModelName));
				
				if (StrContains(sModelName, "laser_sights") != -1)
				{
					if (bHighlight) SetColor(entity, COLOR_BLUE);
					else ClearGlow(entity);
				}
			}
		}
	}
}

public Action:Timer_RemoveHighlight(Handle:timer)
{
	float fGrace = HIGHLIGHT_TIMER - 0.4;
	
	// In case multiple menu items selected in a row...
	// Easier than trying to invalidate a timer that's in-progress
	if (GetGameTime() - g_fHighlightTime > fGrace)
	{
		// remove the highlight
		HighlightGasCans("", false);
	}
	return Plugin_Handled;
}

stock bool IsClientWhiteListed(client)
{
	char authID[64];
	if (!GetClientAuthId(client, AuthId_SteamID64, authID, sizeof(authID)))
		return false;
	
	// dro
	if (StrEqual(authID, "76561198147125400"))
		return true;
	
	return false;
}