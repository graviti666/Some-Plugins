#include <sourcemod>
#include <sdktools>

#define DEBUG		0

#pragma semicolon 1
#pragma newdecls required

#define CFG_PATH	"data/simodels.cfg"

ConVar g_bPluginEnabled;
ConVar g_MaxModelEntities;

bool g_bRoundInProgress;
bool g_bLoaded;

int ModelSpawnCount = 0;

public Plugin myinfo = {
	name = "Special infected Posing",
	author = "Gravity",
	description = "Sets posings of special infected models when round ends, Saving these to a cfg file.",
	version = "0.0.0",
	url = ""
};

public void OnPluginStart()
{
	g_bPluginEnabled = CreateConVar("siposer_enabled", "1", "Enable or disable the plugin.", 0, true, 0.0, true, 1.0);
	g_MaxModelEntities = CreateConVar("siposer_maxmodels", "5", "Max amount of SI models before the camera is spawned.", 0, true, 1.0, true, 10.0);
	
	HookEvent("round_end", Event_OnRoundEnd);
	HookEvent("survival_round_start", Event_OnSurvStart);
	
	RegAdminCmd("sm_spawnsimodel", Command_SpawnSIModel, ADMFLAG_ROOT, "Spawns static SI models saving to cfg.");
	//RegAdminCmd("sm_simodelmenu", Command_SpawnSIModelMenu, ADMFLAG_ROOT, "Creates a Menu to spawn SI models.");
}

public void OnMapStart()
{
	//	Don't know if really necessary but good to precache em
	PrecacheModel("models/infected/boomer.mdl", true);
	PrecacheModel("models/infected/boomette.mdl", true);
	PrecacheModel("models/infected/hunter.mdl", true);
	PrecacheModel("models/infected/jockey.mdl", true);
	PrecacheModel("models/infected/charger.mdl", true);
	PrecacheModel("models/infected/spitter.mdl", true);
	PrecacheModel("models/infected/smoker.mdl", true);
	PrecacheModel("models/infected/hulk.mdl", true);
	
	g_bRoundInProgress = false;
	
	ModelSpawnCount = 0;
	
	g_bLoaded = false;
}

public Action Command_SpawnSIModel(int client, int args)
{
	if( !client )
	{
		ReplyToCommand(client, "Command may be used in-game only.");
		return Plugin_Handled;
	}

	if( g_bRoundInProgress )
	{
		ReplyToCommand(client, "Cannot spawn SI models while round in progress.");
		return Plugin_Handled;
	}
	
	if( args < 1 )
	{
		ReplyToCommand(client, "sm_spawnsimodel <Boomer, Hunter ...>");
		return Plugin_Handled;
	}
	
	float vAngles[3], vOrigin[3];
	
	GetClientAbsOrigin(client, vOrigin);
	GetClientAbsAngles(client, vAngles);
	
	// get cmd arguments
	char modelArg[32], tempModelBuff[54];
	GetCmdArg(1, modelArg, sizeof(modelArg));
	
	ReplaceModelString(modelArg, tempModelBuff, sizeof(tempModelBuff));
	
	if( ModelSpawnCount > GetConVarInt(g_MaxModelEntities) )
	{
		PrintToChat(client, "\x01Cannot add anymore \x03model\x01 spawns. spawned (\x04%i/%i\x01)", ModelSpawnCount, GetConVarInt(g_MaxModelEntities));
		return Plugin_Handled;
	}
	
	if( ModelSpawnCount < GetConVarInt(g_MaxModelEntities) )
	{
		PrintToChat(client, "\x03Model\x01 \x04%i\x01 placed at [\x04%f %f %f\x01]", ModelSpawnCount, vOrigin[0], vOrigin[1], vOrigin[2]);
		CreateSIModel(tempModelBuff, vOrigin, vAngles, true);
	}
	else
	{
		PrintToChat(client, "\x03Camera\x01 placed at [\x04%f %f %f\x01]", vOrigin[0], vOrigin[1], vOrigin[2]);
		CreateCameraEntity( vOrigin, vAngles, true);
	}
	
	return Plugin_Handled;	
}

void ReplaceModelString( char[] argument, char[] sBuffer, int size )
{
	if( StrEqual(argument, "Boomer") ) strcopy(sBuffer, size, "models/infected/boomer.mdl");
	else if( StrEqual(argument, "Boomette") ) strcopy(sBuffer, size, "models/infected/boomette.mdl");
	else if( StrEqual(argument, "Charger") ) strcopy(sBuffer, size, "models/infected/charger.mdl");
	else if( StrEqual(argument, "Jockey") ) strcopy(sBuffer, size, "models/infected/jockey.mdl");
	else if( StrEqual(argument, "Smoker") ) strcopy(sBuffer, size, "models/infected/smoker.mdl");
	else if( StrEqual(argument, "Hunter") ) strcopy(sBuffer, size, "models/infected/hunter.mdl");
	else if( StrEqual(argument, "Spitter") ) strcopy(sBuffer, size, "models/infected/spitter.mdl");
	else if( StrEqual(argument, "Tank") ) strcopy(sBuffer, size, "models/infected/hulk.mdl");
}

void CreateSIModel( char[] model, float origin[3], float angles[3], bool bSave = false )
{
	int iEntity = CreateEntityByName("prop_dynamic_override");
	
	if( IsValidEdict(iEntity) )
    {
		SetEntityModel(iEntity, model);
		DispatchKeyValue(iEntity, "Solid", "6");
		DispatchKeyValue(iEntity, "targetname", "simodel");
		
		SetRandomAnimation(iEntity, model);
		
		DispatchSpawn(iEntity);
		
		TeleportEntity(iEntity, origin, angles, NULL_VECTOR);
		
		if( bSave )
		{
			ModelSpawnCount++;
			SavePositionToCfg( iEntity, model, origin, angles, true);
			CreateTimer(10.0, TimerDeleteEnt, iEntity, TIMER_FLAG_NO_MAPCHANGE);
		}
    }
    
    #if DEBUG
    PrintToChatAll("[SIPOS] CreateSImodel fired");
    #endif
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
			SavePositionToCfg( iEntity, "", position, angles, false );
			AcceptEntityInput(iEntity, "kill");
		}
		else {
			AcceptEntityInput(iEntity, "Enable");
		}
    }
}

// Taken from silver's melee spawn plugin

void SavePositionToCfg( int index, char[] sModelName = "", float pos[3], float ang[3], bool bIsModel = false )
{
	// Create the file if it doesn't exist
	char sPath[PLATFORM_MAX_PATH];
	BuildPath(Path_SM, sPath, sizeof(sPath), "%s", CFG_PATH);
	if( !FileExists(sPath) )
	{
		File hCfg = OpenFile(sPath, "w");
		hCfg.WriteLine("");
		delete hCfg;
	}
	
	// Load config
	KeyValues hFile = new KeyValues("SIModelSpawns");
	if( !hFile.ImportFromFile(sPath) )
	{
		LogError("Unable to load cfg file. assuming empty.");
	}

	// Check for current map in the config
	char sMap[64];
	GetCurrentMap(sMap, 64);
	if( !hFile.JumpToKey(sMap, true) )
	{
		LogError("Failed to add map to cfg..");
		delete hFile;
		return;
	}
	
	//	Save the models pos/angle
	if( bIsModel )
	{
		// Retrieve how many Models saved
		int iCount = hFile.GetNum("count", 0);
	
		// Save count
		iCount++;
		hFile.SetNum("count", iCount);

		char sTemp[10];

		IntToString(iCount, sTemp, sizeof(sTemp));

		if( hFile.JumpToKey(sTemp, true) )
		{
			// Save angle / origin under count section
			hFile.SetString("model", sModelName);
			hFile.SetVector("ang", ang);
			hFile.SetVector("pos", pos);
			hFile.SetNum("ent", index);
			
			// Save cfg file
			hFile.Rewind();
			hFile.ExportToFile(sPath);
		}
		else
			LogError("Failed to save position to (%s) cfg.", sPath);
	}
	else {
		// Create section for the camera
		if( hFile.JumpToKey("camerapos", true) )
		{
			hFile.SetString("model", sModelName);
			hFile.SetVector("ang", ang);
			hFile.SetVector("pos", pos);
			hFile.SetNum("ent", index);
			
			// Save cfg file
			hFile.Rewind();
			hFile.ExportToFile(sPath);
		}
		else {
			LogError("Couldn't jump to camera key section on cfg file.");
		}
	}
	
	delete hFile;
}

void LoadSavedCfgPositions()
{
	if( g_bLoaded ) return;
	
	g_bLoaded = true;

	char sPath[PLATFORM_MAX_PATH];
	BuildPath(Path_SM, sPath, sizeof(sPath), "%s", CFG_PATH);
	if( !FileExists(sPath) ) return;

	// Load config
	KeyValues hFile = new KeyValues("SIModelSpawns");
	if( !hFile.ImportFromFile(sPath) )
	{
		delete hFile;
		return;
	}

	// Check for current map in the config
	char sMap[64];
	GetCurrentMap(sMap, 64);
	if( !hFile.JumpToKey(sMap) )
	{
		delete hFile;
		return;
	}
	
	// Get the Models | camera pos/angles
	char sTemp[10], sModel[30];
	float vPos[3], vAng[3];
	
	int iCount = hFile.GetNum("count", 1);
	
	IntToString(iCount, sTemp, sizeof(sTemp));

	if( hFile.GotoFirstSubKey(false) )
	{
		do
		{
			hFile.GetString("model", sModel, sizeof(sModel));
			hFile.GetVector("ang", vAng);
			hFile.GetVector("pos", vPos);
			
			CreateSIModel( sModel, vPos, vAng, false );
			
		} while (hFile.GotoNextKey(false));
		
		hFile.GoBack();
	}
	
	// Go to camera section
	char sCam[20];
	hFile.GetString("camerapos", sCam, sizeof(sCam));
	
	float vCamPos[3], vCamAng[3];
	
	if( hFile.JumpToKey("camerapos") )
	{
		hFile.GetVector("ang", vCamAng);
		hFile.GetVector("pos", vCamPos);
		
		CreateCameraEntity( vCamPos, vCamAng, false );
		
		hFile.GoBack();
	}
	
	delete hFile;
}

public Action TimerDeleteEnt(Handle timer, any iEntity)
{
	if( IsValidEdict(iEntity) )
	{
		RemoveEdict(iEntity);
	}
}

//	Events
public void Event_OnRoundEnd(Event event, const char[] name, bool dontBroadcast)
{	
	if( !GetConVarBool(g_bPluginEnabled) && !IsSurvival() ) return;
	
	if( g_bRoundInProgress )
	{
		g_bRoundInProgress = false;
	}
	
	LoadSavedCfgPositions();
}

public void Event_OnSurvStart(Event event, const char[] name, bool dontBroadcast)
{
	g_bRoundInProgress = true;
	g_bLoaded = false;
}

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
