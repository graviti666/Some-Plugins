#include <sourcemod>
#include <sdktools>

#pragma semicolon 	1
#pragma newdecls required

#define SURV	2
#define INF	3

#define CFG_PATH	"data/SIModelSpawns.cfg"

ConVar g_bPluginEnabled;

bool g_bRoundInProgress;

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
	// since redrawing menu
	if (!client || g_bRoundInProgress)
		return;
	
	Menu menu = new Menu(SIMenu_Callback);
	
	menu.SetTitle("SI Model Menu");
	menu.AddItem("Load Random Model Config", "Load Random Model Config");
	menu.AddItem("Load Lastest Model Config", "Load Lastest Model Config");
	menu.AddItem("Delete Model Config", "Delete Model Config");
	menu.AddItem("Spawn SI Models", "Spawn SI Models");
	menu.AddItem("Create Camera", "Create Camera");
	menu.AddItem("Correct Camera Angle", "Correct Camera Angle");
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
			bool bDrawSIModelMenu = true;
			
			if(StrEqual(sItem, "Load Random Model Config"))
			{
				if( bLoadCfgFile(true) )
				{
					PrintToChat(param1, "SI model config loaded!");
					
					CreateTimer(2.5, Timer_SlayAll);
				}
				else
				{
					PrintToChat(param1, "Couldn't load SI model config..");
				}
			}
			// probably could combine this into last if statement. Just a quick edit for now
			else if(StrEqual(sItem, "Load Lastest Model Config"))
			{
				if( bLoadCfgFile(true, true))
				{
					PrintToChat(param1, "SI model config loaded!");
					
					CreateTimer(2.5, Timer_SlayAll);
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
				if( !kv_IsCameraCreated() )
				{
					PrintToChat(param1, "You must spawn a camera first.");
				}
				else
				{
					bDrawSIModelMenu = false;
					DrawSISpawnerMenu(param1);
				}
			}
			else if(StrEqual(sItem, "Create Camera"))
			{
				SpawnInitCamera(param1);
			}
			// Correct Camera Angle
			else if( StrEqual(sItem, "Correct Camera Angle"))
			{
				SetClientAngleCorrectly(param1);
			}
			
			// redraw
			if (bDrawSIModelMenu) {
				DrawSIModelMenu(param1);
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

public Action Timer_SlayAll(Handle timer)
{
	for (int i = 1; i <= MaxClients; i++)
	{
		if (!IsClientInGame(i)) continue;
		if (GetClientTeam(i) == SURV || GetClientTeam(i) == INF)
			ForcePlayerSuicide(i);
	}
	return Plugin_Handled;
}

void SetClientAngleCorrectly(int client)
{
	if( !client )
	{
		ReplyToCommand(client, "[SM] Command may be used in-game only.");
		return;
	}
	
	// when using TeleportEntity, the direction you're looking doesn't get saved.
	// Use this function so you know for sure where the camera's going to be facing before you save it
	float org[3], angle[3];
	GetClientAbsOrigin(client, org);
	GetClientAbsAngles(client, angle);
	TeleportEntity(client, org, angle, NULL_VECTOR);
}

/************************************************
	Spawning functions SI models & camera
************************************************/

void SpawnInitSIModel(int client, const char[] model)
{
	float org[3], angle[3];
	GetClientAbsOrigin(client, org);
	GetClientAbsAngles(client, angle);
	
	PrintToChat(client, "\x04%s\x01 placed at \x05%f %f %f", model, org[0], org[1], org[2]);
	
	CreateSIModel(model, org, angle, true);
}

void SpawnInitCamera(int client)
{
	
	float org[3], angle[3];
	GetClientAbsOrigin(client, org);
	GetClientAbsAngles(client, angle);
	
	PrintToChat(client, "\x04Camera\x01 placed at \x05%f %f %f", org[0], org[1], org[2]);
	PrintToChat(client, "Any new SI models will be saved under this camera angle.");
	
	CreateCameraEntity(org, angle, true);
	g_iSpawnCount = 0; // reset spawn count
}

void CreateSIModel(const char[] sModel, float origin[3], float angles[3], bool bSave = false)
{
	int iEntity = CreateEntityByName("prop_dynamic_override");
	
	if( IsValidEdict(iEntity) )
	{
		// Convert origin/angles vecs to string for sending those with a keyvalue
		char sOrigin[64], sAngles[64];
		
		Format(sOrigin, sizeof(sOrigin), "%f %f %f", origin[0], origin[1], origin[2]);
		Format(sAngles, sizeof(sAngles), "%f %f %f", angles[0], angles[1], angles[2]);
		
		SetEntityModel(iEntity, sModel);
		
		// Make it non-solid and disable any shadows the model would cast (for optimization).
		DispatchKeyValue(iEntity, "solid", "0");
		DispatchKeyValue(iEntity, "disableshadows", "1");
		DispatchKeyValue(iEntity, "origin", sOrigin);
		DispatchKeyValue(iEntity, "angles", sAngles);
		
		DispatchSpawn(iEntity);
		
		//TODO Test test test functionality of new method
		SetRandomAnimation(iEntity, sModel);
		
		if( bSave )
		{
			// Delay the removal a bit
			CreateTimer(5.0, Timer_DeleteEntity, iEntity);
			
			bSaveToCfgFile(sModel, origin, angles);
			
			g_iSpawnCount++;
		}
	}
}

public Action Timer_DeleteEntity(Handle timer, any iEntity)
{
	if(IsValidEdict(iEntity))
	{
		RemoveEdict(iEntity);
	}
	return Plugin_Stop;
}

void CreateCameraEntity( float position[3], float angles[3], bool bSave = false )
{
	int iEntity = CreateEntityByName("point_viewcontrol_multiplayer");
	
	if( IsValidEdict(iEntity))
    {
		DispatchSpawn(iEntity);
		
		//	Up the z coordinate a bit to get better view angle
		position[2] += 31.0;
		
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
	if (!GetConVarBool(g_bPluginEnabled) || !IsSurvival())
		return;
	
	g_bRoundInProgress = false;
	
	// Round end event gets called again shortly after survival round actually ended
	float time = event.GetFloat("time");
	if (time == 0)
		return;
	
	
	// Load positions
	bLoadCfgFile();
}

public void Event_OnSurvStart(Event event, const char[] name, bool dontBroadcast)
{
	g_bRoundInProgress = true;
}

/***************************************
	Saving methods & KV stuff
***************************************/

void kv_goToTop(KeyValues kv)
{
	while (kv.NodesInStack() != 0)
		kv.GoBack();
}

int kv_countSubDirectories(KeyValues kv)
{
	if (!kv.GotoFirstSubKey())
	{
		return 0;
	}
	
	int count = 1; // starting at first sub key
	while (kv.GotoNextKey(false))
	{
		count++;
	}
	
	kv.GoBack();
	return count;
}

bool kv_IsCameraCreated()
{
	char sPath[PLATFORM_MAX_PATH];
	BuildPath(Path_SM, sPath, sizeof(sPath), CFG_PATH);
	KeyValues kv = new KeyValues("SImodel_Spawns");
	
	// Import file
	kv.ImportFromFile(sPath);
	kv_goToTop(kv);
	
	char sMap[42];
	GetCurrentMap(sMap, sizeof(sMap));
	
	if (!kv.JumpToKey(sMap, false)) {
		delete kv;
		return false;
	}
	
	// "c1m4_atrium" -> "%i"
	if (!kv.GotoFirstSubKey()) {
		delete kv;
		return false;
	}
	
	if (!kv.JumpToKey("camera", false)) {
		delete kv;
		return false;
	}
	delete kv;
	return true;
}

/*void kv_pickRandomSectionName(KeyValues kv, char[] buffer, int size)
{
	int iSubSectionCount = kv_countSubDirectories(kv);
	int rndpick = GetRandomInt(1, iSubSectionCount);
	
	char sSection[12];
	IntToString(rndpick, sSection, sizeof(sSection));
	strcopy(buffer, size, sSection);
}*/

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
	
	// every time camera is saved it makes a new section under the map name.
	// makes it easier to save SI positions under that specific section
	int iName = kv_countSubDirectories(kv) + 1;
	char sName[12];
	IntToString(iName, sName, sizeof(sName));
	kv.JumpToKey(sName, true);
	
	kv.JumpToKey("camera", true);
	
	kv.SetVector("position", pos);
	kv.SetVector("angles", ang);
	
	kv_goToTop(kv);
	kv.ExportToFile(sPath);
	
	delete kv;
	
	return true;
}

bool bSaveToCfgFile(const char[] sModelName, float pos[3], float ang[3])
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
	
	int iSubSection = kv_countSubDirectories(kv);
	char sTmp[12];
	IntToString(iSubSection, sTmp, sizeof(sTmp));
	kv.JumpToKey(sTmp, true);
	
	kv.JumpToKey(key, true);
	
	kv.SetString("model", sModelName);
	kv.SetVector("position", pos);
	kv.SetVector("angles", ang);
	
	kv_goToTop(kv);
	kv.ExportToFile(sPath);
	
	delete kv;
	
	return true;
}

bool bLoadCfgFile(bool PrintSection = false, bool LatestSave = false)
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
	
	int iSubSectionCount = kv_countSubDirectories(kv);
	int rndpick = GetRandomInt(1, iSubSectionCount);
	if (LatestSave)
	{
		rndpick = iSubSectionCount;
	}
	
	char sTmp[12];
	IntToString(rndpick, sTmp, sizeof(sTmp));
	kv.JumpToKey(sTmp, true);
	
	// in case an admin wants to delete the config they're viewing via the setup menu
	// or maybe wants to delete a specific SI model from that config
	if (PrintSection)
	{
		PrintToChatAll("\x01Map: \x04%s\x01, Section: \x04%s", sMap, sTmp);
	}
	
	char sModel[48];
	float pos[3], ang[3];
	
	char sName[42];
	float campos[3], camangle[3];
	
	if(kv.GotoFirstSubKey(false))
	{
		do
		{
			kv.GetSectionName(sName, sizeof(sName));
			
			if(StrEqual(sName, "camera")) {
				// Choose a camera at random
				kv.GetVector("position", campos);
				kv.GetVector("angles", camangle);
				
				CreateCameraEntity(campos, camangle, false);
			}
			else
			{
				kv.GetString("Model", sModel, sizeof(sModel));
				kv.GetVector("position", pos);
				kv.GetVector("angles", ang);
				
				CreateSIModel(sModel, pos, ang, false);
			}
		
		} while (kv.GotoNextKey(false));
	}
	
	delete kv;
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

// Format: <output name> <targetname>,<inputname>,<parameter>,<delay>,<max times to fire (-1 == infinite)>
// Adds an Output to the entity 'SetAnimation' with the specified animation string and fires it.
// Set random animation sequence by model
void SetRandomAnimation(int entity, const char[] ModelName)
{
	if(StrEqual(ModelName, "models/infected/boomer.mdl"))
	{
		int rnd = GetRandomInt(1, 2);
		switch(rnd)
		{
			case 1:
			{
				SetVariantString("OnUser1 !self:SetAnimation:BoomerVar_squat:0.1");
				AcceptEntityInput(entity, "AddOutput");
				AcceptEntityInput(entity, "FireUser1");
			}
			case 2:
			{
				SetVariantString("OnUser1 !self:SetAnimation:Crouch_Idle_Upper_KNIFE:0.1");
				AcceptEntityInput(entity, "AddOutput");
				AcceptEntityInput(entity, "FireUser1");
			}
		}
	}
	else if(StrEqual(ModelName, "models/infected/boomette.mdl"))
	{
		int rnd = GetRandomInt(1, 2);
		switch(rnd)
		{
			case 1:
			{
				SetVariantString("OnUser1 !self:SetAnimation:Crouch_Idle_Upper_KNIFE:0.1");
				AcceptEntityInput(entity, "AddOutput");
				AcceptEntityInput(entity, "FireUser1");
			}
			case 2:
			{
				SetVariantString("OnUser1 !self:SetAnimation:BoomerVar_squat:0.1");
				AcceptEntityInput(entity, "AddOutput");
				AcceptEntityInput(entity, "FireUser1");
			}
		}
	}
	else if(StrEqual(ModelName, "models/infected/hunter.mdl"))
	{
		int rnd = GetRandomInt(1, 2);
		switch(rnd)
		{
			case 1:
			{
				SetVariantString("OnUser1 !self:SetAnimation:Idle_Crouching_01:0.1");
				AcceptEntityInput(entity, "AddOutput");
				AcceptEntityInput(entity, "FireUser1");
			}
			case 2:
			{
				SetVariantString("OnUser1 !self:SetAnimation:Idle_Standing_02:0.1");
				AcceptEntityInput(entity, "AddOutput");
				AcceptEntityInput(entity, "FireUser1");
			}
		}
	}
	else if(StrEqual(ModelName, "models/infected/jockey.mdl"))
	{
		int rnd = GetRandomInt(1, 2);
		switch(rnd)
		{
			case 1:
			{
				SetVariantString("OnUser1 !self:SetAnimation:Crouch_Idle:0.1");
				AcceptEntityInput(entity, "AddOutput");
				AcceptEntityInput(entity, "FireUser1");
			}
			case 2:
			{
				SetVariantString("OnUser1 !self:SetAnimation:Standing_Idle:0.1");
				AcceptEntityInput(entity, "AddOutput");
				AcceptEntityInput(entity, "FireUser1");
			}
		}
	}
	else if(StrEqual(ModelName, "models/infected/charger.mdl"))
	{
		int rnd = GetRandomInt(1, 2);
		switch(rnd)
		{
			case 1:
			{
				SetVariantString("OnUser1 !self:SetAnimation:Crouch_Idle_Upper_KNIFE:0.1");
				AcceptEntityInput(entity, "AddOutput");
				AcceptEntityInput(entity, "FireUser1");
			}
			case 2:
			{
				SetVariantString("OnUser1 !self:SetAnimation:Idle_Upper_KNIFE:0.1");
				AcceptEntityInput(entity, "AddOutput");
				AcceptEntityInput(entity, "FireUser1");
			}
		}
	}
	else if(StrEqual(ModelName, "models/infected/spitter.mdl"))
	{
		int rnd = GetRandomInt(1, 2);
		switch(rnd)
		{
			case 1:
			{
				SetVariantString("OnUser1 !self:SetAnimation:Crouch_Idle:0.1");
				AcceptEntityInput(entity, "AddOutput");
				AcceptEntityInput(entity, "FireUser1");
			}
			case 2:
			{
				SetVariantString("OnUser1 !self:SetAnimation:Standing_Idle:0.1");
				AcceptEntityInput(entity, "AddOutput");
				AcceptEntityInput(entity, "FireUser1");
			}
		}
	}
	else if(StrEqual(ModelName, "models/infected/smoker.mdl"))
	{
		int rnd = GetRandomInt(1, 2);
		switch(rnd)
		{
			case 1:
			{
				SetVariantString("OnUser1 !self:SetAnimation:Crouch_Idle_Upper_KNIFE:0.1");
				AcceptEntityInput(entity, "AddOutput");
				AcceptEntityInput(entity, "FireUser1");
			}
			case 2:
			{
				SetVariantString("OnUser1 !self:SetAnimation:Idle_Upper_KNIFE:0.1");
				AcceptEntityInput(entity, "AddOutput");
				AcceptEntityInput(entity, "FireUser1");
			}
		}
	}
	else if(StrEqual(ModelName, "models/infected/hulk.mdl"))
	{
		int rnd = GetRandomInt(1, 2);
		switch(rnd)
		{
			case 1:
			{
				SetVariantString("OnUser1 !self:SetAnimation:Crouch_Idle:0.1");
				AcceptEntityInput(entity, "AddOutput");
				AcceptEntityInput(entity, "FireUser1");
			}
			case 2:
			{
				SetVariantString("OnUser1 !self:SetAnimation:Idle:0.1");
				AcceptEntityInput(entity, "AddOutput");
				AcceptEntityInput(entity, "FireUser1");
			}
		}
	}
}