#include <sourcemod>
#include <sdktools>

#pragma semicolon 	1
#pragma newdecls required

#define CFG_PATH	"data/SIModelSpawns.cfg"

ConVar g_bPluginEnabled;

bool g_bRoundInProgress;
bool bIsCameraCreated;
bool g_bRoundEndDone;

int g_iSpawnCount;

#define MAX_SI	8
char sSIModelsList[MAX_SI][] =
{
	"models/infected/boomer.mdl", 
	"models/infected/boomette.mdl", 
	"models/infected/hunter.mdl",
	"models/infected/jockey.mdl", 
	"models/infected/charger.mdl", 
	"models/infected/spitter.mdl",
	"models/infected/smoker.mdl", 
	"models/infected/hulk.mdl"
};

public Plugin myinfo = {
	name = "Special infected Posing",
	author = "Gravity",
	description = "Sets posings of special infected models when round ends, Saving these to a cfg file.",
	version = "1.0.0",
	url = ""
};

public void OnPluginStart()
{
	g_bPluginEnabled = CreateConVar("siposer_enabled", "1", "Enable or disable the plugin.", 0, true, 0.0, true, 1.0);
	
	RegAdminCmd("sm_simodelmenu", Command_SIModelMenu, ADMFLAG_ROOT, "Opens up a menu for spawning SI models which are saved to cfg.");
	
	HookEvent("survival_round_start", Event_OnSurvStart);
	HookEvent("round_end", Event_OnRoundEnd);
}

public void OnMapStart()
{
	for (int i = 0; i < MAX_SI; i++)
	{
		PrecacheModel(sSIModelsList[i], true);
	}
}

// Create the cfg file if it doesnt exist
public void OnConfigsExecuted()
{
	char sPath[PLATFORM_MAX_PATH];
	BuildPath(Path_SM, sPath, sizeof(sPath), CFG_PATH);
	
	if(!FileExists(sPath))
	{
		KeyValues kv = new KeyValues("SImodel_Spawns");
		kv.ExportToFile(sPath);
		delete kv;
	}
}

/***********************************
	SI Model Menu system
************************************/

public Action Command_SIModelMenu(int client, int args)
{
	if( !client )
	{
		ReplyToCommand(client, "[SM] Command may be used in-game only.");
		return Plugin_Handled;
	}
	
	if( g_bRoundInProgress )
	{
		ReplyToCommand(client, "[SM] Can't use this cmd while survival round in progress.");
		return Plugin_Handled;
	}
	
	DrawSIModelMenu(client);
	
	return Plugin_Handled;
}

void DrawSIModelMenu(int client)
{
	Menu menu = new Menu(SIMenu_Callback);
	
	menu.SetTitle("SI Model Menu");
	menu.AddItem("Load Model Config", "Load Model Config");
	menu.AddItem("Delete Model Config", "Delete Model Config");
	menu.AddItem("Spawn SI Models", "Spawn SI Models");
	menu.AddItem("Create Camera", "Create Camera");
	menu.Display(client, MENU_TIME_FOREVER);
	menu.ExitButton = false;
}

void DrawSISpawnerMenu(int client)
{
	Menu menu = new Menu(Menu_CallBack);
	
	menu.SetTitle("SI Model Spawner");
	menu.AddItem("boomer", "Boomer");
	menu.AddItem("boomette", "Boomette");
	menu.AddItem("hunter", "Hunter");
	menu.AddItem("jockey", "Jockey");
	menu.AddItem("charger", "Charger");
	menu.AddItem("spitter", "Spitter");
	menu.AddItem("smoker", "Smoker");
	menu.AddItem("tank", "Tank");
	menu.Display(client, MENU_TIME_FOREVER);
	menu.ExitButton = false;
}

public int SIMenu_Callback(Menu menu, MenuAction action, int param1, int param2)
{
	switch(action)
	{
		case MenuAction_Select:
		{
			char sItem[64];
			menu.GetItem(param2, sItem, sizeof(sItem));
			if(StrEqual(sItem, "Load Model Config"))
			{
				if( bLoadCfgFile() )
				{
					PrintToChat(param1, "SI model config loaded!");
				}
				else
				{
					PrintToChat(param1, "Couldn't load SI model config..");
				}
			}
			else if(StrEqual(sItem, "Delete Model Config"))
			{
				if( bDeleteSavedConfig() )
				{
					PrintToChat(param1, "Config wiped for this map!");
				}
				else
				{
					PrintToChat(param1, "Config deletion failed...");
				}
			}
			else if(StrEqual(sItem, "Spawn SI Models"))
			{
				// Open up the another menu with SI models to spawn
				if( !bIsCameraCreated )
				{
					PrintToChat(param1, "You must spawn a camera first.");
				}
				else
				{
					DrawSISpawnerMenu(param1);
				}
			}
			else if(StrEqual(sItem, "Create Camera"))
			{
				SpawnInitCamera(param1);
			}
		}
		
		case MenuAction_End:
		{
			delete menu;
		}
	}
}

public int Menu_CallBack(Menu menu, MenuAction action, int param1, int param2)
{
	switch(action)
	{
		case MenuAction_Select:
		{
			char sItem[42];
			menu.GetItem(param2, sItem, sizeof(sItem));
			
			if( StrEqual(sItem, "boomer") )
			{
				SpawnInitSIModel(param1, "models/infected/boomer.mdl");
				DrawSISpawnerMenu(param1);
			}
			else if(StrEqual(sItem, "boomette"))
			{
				SpawnInitSIModel(param1, "models/infected/boomette.mdl");
				DrawSISpawnerMenu(param1);
			}
			else if(StrEqual(sItem, "hunter"))
			{
				SpawnInitSIModel(param1, "models/infected/hunter.mdl");
				DrawSISpawnerMenu(param1);
			}
			else if(StrEqual(sItem, "jockey"))
			{
				SpawnInitSIModel(param1, "models/infected/jockey.mdl");
				DrawSISpawnerMenu(param1);
			}
			else if(StrEqual(sItem, "charger"))
			{
				SpawnInitSIModel(param1, "models/infected/charger.mdl");
				DrawSISpawnerMenu(param1);
			}
			else if(StrEqual(sItem, "spitter"))
			{
				SpawnInitSIModel(param1, "models/infected/spitter.mdl");
				DrawSISpawnerMenu(param1);
			}
			else if(StrEqual(sItem, "smoker"))
			{
				SpawnInitSIModel(param1, "models/infected/smoker.mdl");
				DrawSISpawnerMenu(param1);
			}
			else if(StrEqual(sItem, "tank"))
			{
				SpawnInitSIModel(param1, "models/infected/hulk.mdl");
				DrawSISpawnerMenu(param1);
			}
		}
		
		case MenuAction_End:
		{
			delete menu;
		}
	}
}

/************************************************
	Spawning functions SI models & camera
************************************************/

void SpawnInitSIModel(int client, char[] model)
{
	float org[3], angle[3];
	GetClientAbsOrigin(client, org);
	GetClientAbsAngles(client, angle);
	
	char modelDest[64];
	strcopy(modelDest, sizeof(modelDest), model);
	
	PrintToChat(client, "\x04%s\x01 placed at \x05%f %f %f", modelDest, org[0], org[1], org[2]);
	
	CreateSIModel(modelDest, org, angle, true);
}

void SpawnInitCamera(int client)
{
	if( bIsCameraCreated )
	{
		return;
	}
	
	float org[3], angle[3];
	GetClientAbsOrigin(client, org);
	GetClientAbsAngles(client, angle);
	
	PrintToChat(client, "\x04Camera\x01 placed at \x05%f %f %f", org[0], org[1], org[2]);
	
	CreateCameraEntity(org, angle, true);
}

void CreateSIModel(char[] sModel, float origin[3], float angles[3], bool bSave = false)
{
	int iEntity = CreateEntityByName("prop_dynamic_override");
	
	if( IsValidEdict(iEntity) )
	{	
		SetEntityModel(iEntity, sModel);
		
		DispatchKeyValue(iEntity, "solid", "6");
		DispatchKeyValue(iEntity, "targetname", "buttmonkey");
		
		SetRandomAnimation(iEntity, sModel);
		
		DispatchSpawn(iEntity);
		
		TeleportEntity(iEntity, origin, angles, NULL_VECTOR);
		
		if( bSave )
		{
			RemoveEdict(iEntity);
			
			bSaveToCfgFile(sModel, origin, angles);
			
			g_iSpawnCount++;
		}
	}
}

void CreateCameraEntity( float position[3], float angles[3], bool bSave = false )
{
	int iEntity = CreateEntityByName("point_viewcontrol_multiplayer");
	
	if( IsValidEdict(iEntity))
    {
		DispatchSpawn(iEntity);
		
		//	Up the z coordinate a bit to get better view angle
		position[2] += 30.0;
		
		TeleportEntity(iEntity, position, angles, NULL_VECTOR);
		
		if( bSave )
		{
			// Save to cfg file pos
			AcceptEntityInput(iEntity, "kill");
			
			bSaveCamera(position, angles);
		}
		else {
			AcceptEntityInput(iEntity, "Enable");
		}
    }
}

/****************************
	Events
****************************/

public void Event_OnRoundEnd(Event event, const char[] name, bool dontBroadcast)
{	
	if( !GetConVarBool(g_bPluginEnabled) && !IsSurvival() ) return;
	
	if( g_bRoundEndDone )
	{
		g_bRoundEndDone = false;
		return;
	}
	
	g_bRoundEndDone = true;
	
	if( g_bRoundInProgress )
	{
		g_bRoundInProgress = false;
	}
	
	// Load positions
	bLoadCfgFile();
}

public void Event_OnSurvStart(Event event, const char[] name, bool dontBroadcast)
{
	g_bRoundInProgress = true;
	
	bIsCameraCreated = false;
}

/***************************************
	Saving methods & KV stuff
***************************************/

void kv_goToTop(KeyValues kv)
{
	while (kv.NodesInStack() != 0)
		kv.GoBack();
}

bool bDeleteSavedConfig()
{
	char sPath[PLATFORM_MAX_PATH];
	BuildPath(Path_SM, sPath, sizeof(sPath), CFG_PATH);
	
	KeyValues kv = new KeyValues("SImodel_Spawns");
	
	// Import file
	kv.ImportFromFile(sPath);
	kv_goToTop(kv);
	
	char sMap[42];
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

bool bSaveCamera(float pos[3], float ang[3])
{
	char sPath[PLATFORM_MAX_PATH];
	BuildPath(Path_SM, sPath, sizeof(sPath), CFG_PATH);
	
	KeyValues kv = new KeyValues("SImodel_Spawns");
	
	// Import file
	kv.ImportFromFile(sPath);
	kv_goToTop(kv);
	
	char sMap[42];
	GetCurrentMap(sMap, sizeof(sMap));
	
	kv.JumpToKey(sMap, true);
	kv.JumpToKey("camera", true);
	
	kv.SetVector("position", pos);
	kv.SetVector("angles", ang);
	
	kv_goToTop(kv);
	kv.ExportToFile(sPath);
	
	delete kv;
	
	bIsCameraCreated = true;
	
	return true;
}

bool bSaveToCfgFile(char[] sModelName, float pos[3], float ang[3])
{
	char sPath[PLATFORM_MAX_PATH];
	BuildPath(Path_SM, sPath, sizeof(sPath), CFG_PATH);
	
	KeyValues kv = new KeyValues("SImodel_Spawns");
	
	// Import file
	kv.ImportFromFile(sPath);
	kv_goToTop(kv);
	
	char sMap[42];
	GetCurrentMap(sMap, sizeof(sMap));
	
	char sNum[20];
	char key[40] = "prop";
	
	IntToString(g_iSpawnCount, sNum, sizeof(sNum));
	
	StrCat(key, sizeof(key), sNum);
	
	// Create map section
	kv.JumpToKey(sMap, true);
	kv.JumpToKey(key, true);
	
	kv.SetString("model", sModelName);
	kv.SetVector("position", pos);
	kv.SetVector("angles", ang);
	
	kv_goToTop(kv);
	kv.ExportToFile(sPath);
	
	delete kv;
	
	return true;
}

bool bLoadCfgFile()
{
	char sPath[PLATFORM_MAX_PATH];
	BuildPath(Path_SM, sPath, sizeof(sPath), CFG_PATH);
	
	KeyValues kv = new KeyValues("SImodel_Spawns");
	
	// Import file
	kv.ImportFromFile(sPath);
	kv_goToTop(kv);
	
	char sMap[42];
	GetCurrentMap(sMap, sizeof(sMap));
	
	if(!kv.JumpToKey(sMap, false))
	{
		delete kv;
		return false;
	}
	
	char sModel[42];
	
	float pos[3], ang[3];
	
	char sName[42];
	float campos[3], camangle[3];
	
	if(kv.GotoFirstSubKey(false))
	{
		do
		{
			kv.GetSectionName(sName, sizeof(sName));
			
			if(StrEqual(sName, "camera")){
				kv.GetVector("position", campos);
				kv.GetVector("angles", camangle);
				CreateCameraEntity(campos, camangle, false);
			}
			
			kv.GetString("Model", sModel, sizeof(sModel));
			kv.GetVector("position", pos);
			kv.GetVector("angles", ang);
			
			CreateSIModel(sModel, pos, ang, false);
		
		} while (kv.GotoNextKey(false));
	}
	
	kv_goToTop(kv);
	
	return true;
}

/*******************************
Shared stuff
*******************************/

bool IsSurvival()
{
	char GameName[16];
	GetConVarString(FindConVar("mp_gamemode"), GameName, sizeof(GameName));
	if (StrContains(GameName, "survival", false) != -1)
	{
		return true;
	}
	return false;
}

//	Sets a random animation on a SI.
void SetRandomAnimation( int entindex, char[] sModelName )
{
	if( StrEqual(sModelName, "models/infected/boomer.mdl") ) {		// Boomer
		int rndpick = GetRandomInt(1, 4);
		switch(rndpick)
		{
			case 1:
			{
				DispatchKeyValue(entindex, "DefaultAnim", "ACT_IDLE");
			}
			case 2:
			{
				DispatchKeyValue(entindex, "DefaultAnim", "ACT_CROUCHIDLE");
			}
			case 3:
			{
				DispatchKeyValue(entindex, "DefaultAnim", "ACT_TERROR_CROUCH_LEAKER");
			}
			case 4:
			{
				DispatchKeyValue(entindex, "DefaultAnim", "ACT_TERROR_CROUCHIDLE_LEAKER");
			}
		}
	}
	else if( StrEqual(sModelName, "models/infected/charger.mdl") ) {	// Charger
		int rndpick = GetRandomInt(1, 4);
		switch(rndpick)
		{
			case 1:
			{
				DispatchKeyValue(entindex, "DefaultAnim", "ACT_IDLE");
			}
			case 2:
			{
				DispatchKeyValue(entindex, "DefaultAnim", "ACT_CROUCHIDLE");
			}
			case 3:
			{
				DispatchKeyValue(entindex, "DefaultAnim", "ACT_TERROR_CHARGER_PUMMEL");
			}
			case 4:
			{
				DispatchKeyValue(entindex, "DefaultAnim", "ACT_TERROR_CHARGER_POUND_UP");
			}
		}
	}
	else if( StrEqual(sModelName, "models/infected/hunter.mdl") ) {		// Hunter
		int rndpick = GetRandomInt(1, 4);
		switch(rndpick)
		{
			case 1:
			{
				DispatchKeyValue(entindex, "DefaultAnim", "ACT_IDLE");
			}
			case 2:
			{
				DispatchKeyValue(entindex, "DefaultAnim", "ACT_CROUCHIDLE");
			}
			case 3:
			{
				DispatchKeyValue(entindex, "DefaultAnim", "ACT_TERROR_HUNTER_POUNCE_KNOCKOFF_R");
			}
			case 4:
			{
				DispatchKeyValue(entindex, "DefaultAnim", "ACT_TERROR_HUNTER_POUNCE_MELEE");
			}
		}
	}
	else if( StrEqual(sModelName, "models/infected/spitter.mdl") ) {	// Spitter
		int rndpick = GetRandomInt(1, 4);
		switch(rndpick)
		{
			case 1:
			{
				DispatchKeyValue(entindex, "DefaultAnim", "ACT_IDLE");
			}
			case 2:
			{
				DispatchKeyValue(entindex, "DefaultAnim", "ACT_CROUCHIDLE");
			}
			case 3:
			{
				DispatchKeyValue(entindex, "DefaultAnim", "ACT_TERROR_SPITTER_SPIT");
			}
			case 4:
			{
				DispatchKeyValue(entindex, "DefaultAnim", "ACT_TERROR_SHOVED_BACKWARD");
			}
		}
	}
	else if( StrEqual(sModelName, "models/infected/hulk.mdl") ) {		// Tank
		int rndpick = GetRandomInt(1, 4);
		switch(rndpick)
		{
			case 1:
			{
				DispatchKeyValue(entindex, "DefaultAnim", "ACT_IDLE");
			}
			case 2:
			{
				DispatchKeyValue(entindex, "DefaultAnim", "ACT_CROUCHIDLE");
			}
			case 3:
			{
				DispatchKeyValue(entindex, "DefaultAnim", "ACT_HULK_THROW");
			}
			case 4:
			{
				DispatchKeyValue(entindex, "DefaultAnim", "ACT_TERROR_HULK_VICTORY_B");
			}
		}
	}
	else	//	Else default to Global enough ACT_CROUCHIDLE
	{
		DispatchKeyValue(entindex, "DefaultAnim", "ACT_CROUCHIDLE");
	}
}