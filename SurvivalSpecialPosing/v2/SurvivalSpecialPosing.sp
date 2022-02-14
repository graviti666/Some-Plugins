/*
 * Feb 13, 2022 - v2. Plugin updated to make it easier to see SI poses as your editing the config

 * 24, August 2020 - Disabled rooftop fall cameras as theyre quite buggy.
*/
#include <sourcemod>
#include <sdktools>

#pragma semicolon 	1
#pragma newdecls required

#define SPEC	1
#define SURV	2
#define INF		3

#define TIMER_LOAD_TEMPORARY_POSE 2.5
#define MIN_SI_REQ 4 // amount of SI required at minimum to move on to next config

#define CFG_PATH	"data/simodelspawns.cfg"

ConVar g_bPluginEnabled;

bool g_bRoundInProgress;
bool g_bSlaySurvivors;

int g_iDeletionID;
int g_iConfigID;

ArrayList g_hArray_SIIndexes;

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

// Modules
#include "SurvivalSpecialPosingModules/keyvaluesHandler.sp"
#include "SurvivalSpecialPosingModules/menuHandler.sp"

public Plugin myinfo = {
	name = "Special infected Posing",
	author = "Gravity, dustin",
	description = "Sets posings of special infected models when round ends, Saving these to a cfg file.",
	version = "2.0",
	url = ""
};

/* 
	OPTIONAL TODO

	* On round end config load: make sure there's a camera + at least 4 SI in whatever config's selected.
		Probably unnecessary safety check since configs are only gonna be set up by server owner
			& gonna comment out access to sm_simodelmenu once configs are set up.
	
	* "delete this config?"" confirmation. If no camera created yet, might be a bit confusing when
		the config gets loaded and SI spawn yet no camera spawns to the SI's position. Something more to 
			keep in mind when using this plugin.
*/

public void OnPluginStart()
{
	g_bPluginEnabled = CreateConVar("siposer_enabled", "1", "Enable or disable the plugin.", 0, true, 0.0, true, 1.0);
	
	RegAdminCmd("sm_simodelmenu", Command_SIModelMenu, ADMFLAG_ROOT, "Opens up a menu for spawning SI models which are saved to cfg.");
	
	HookEvent("survival_round_start", Event_OnSurvStart);
	HookEvent("round_end", Event_OnRoundEnd);
	HookEvent("round_start", Event_OnRoundInitialize);
	
	g_hArray_SIIndexes = new ArrayList();
}

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
	
	DrawMainMenu(client);
	
	return Plugin_Handled;
}

public void OnMapStart()
{
	for (int i = 0; i < MAX_SI; i++)
	{
		PrecacheModel(sSIModelsList[i], true);
	}
	
	if (IsRooftop())
		DisableRooftopDeathFallCameras();
	
	g_iConfigID = g_iDeletionID = 0;
	g_hArray_SIIndexes.Clear();
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

/*
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
*/

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

int CreateSIModel(const char[] sModel, float origin[3], float angles[3], bool bSave = false)
{
	int iEntity = CreateEntityByName("prop_dynamic_override");
	
	if( IsValidEdict(iEntity) && IsValidEntity(iEntity) )
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
		
		SetRandomAnimation(iEntity, sModel);
		g_hArray_SIIndexes.Push(iEntity);
		
		if( bSave )
		{
			bSaveToCfgFile(sModel, origin, angles);
		}
	}

	return iEntity;
}

void CreateCameraEntity( float position[3], float angles[3], bool bTempLoad = false)
{
	int iEntity = CreateEntityByName("point_viewcontrol_multiplayer");
	
	if( IsValidEdict(iEntity) && IsValidEntity(iEntity) )
    {
		position[2] += 30.0;	// Get the camera of ground a bit increase z pos
		
		// Again doing this instead of TeleportEntity, becus better.
		char sOrigin[64], sAngle[64];
		
		Format(sOrigin, sizeof(sOrigin), "%f %f %f", position[0], position[1], position[2]);
		Format(sAngle, sizeof(sAngle), "%f %f %f", angles[0], angles[1], angles[2]);
		
		DispatchKeyValue(iEntity, "origin", sOrigin);
		DispatchKeyValue(iEntity, "angles", sAngle);
		
		DispatchSpawn(iEntity);
		
		AcceptEntityInput(iEntity, "enable");

		if (bTempLoad)
		{
			// disable camera after a few seconds
			CreateTimer(TIMER_LOAD_TEMPORARY_POSE, Timer_DisableCamera, iEntity);
		}
    }
}

public Action Timer_DisableCamera(Handle timer, int cameraEntity)
{
	AcceptEntityInput(cameraEntity, "disable");
	AcceptEntityInput(cameraEntity, "kill");
}

/****************************
	Events
****************************/

/*
 * Possible FIX for spectators ending up stuck in objects after new round load.
 * Spawn a new viewcontroller entity on pre-round start, and disable it same frame.
 * NEED to delay spawning the entity by a few seconds or it errors out.
*/
public void Event_OnRoundInitialize(Event event, const char[] name, bool dontBroadcast)
{
	CreateTimer(2.0, Timer_ResolveSpecs, _, TIMER_FLAG_NO_MAPCHANGE);
	
	if (IsRooftop())
	{
		DisableRooftopDeathFallCameras();
	}

	g_iConfigID = g_iDeletionID = 0;
	g_hArray_SIIndexes.Clear();

}

public Action Timer_ResolveSpecs(Handle timer)
{
	float fRandomPos[3] =  { -3645.134033, -2882.085449, 0.031250 };
	int iEntity = CreateEntityByName("point_viewcontrol_multiplayer");
	if (IsValidEdict(iEntity))
	{
		TeleportEntity(iEntity, fRandomPos, NULL_VECTOR, NULL_VECTOR);
		DispatchSpawn(iEntity);
		AcceptEntityInput(iEntity, "enable");
		AcceptEntityInput(iEntity, "disable");
		//PrintToChatAll("Spec fix fired.");
	}
}

public void Event_OnRoundEnd(Event event, const char[] name, bool dontBroadcast)
{	
	if (!GetConVarBool(g_bPluginEnabled) || !IsSurvival())
		return;
	
	g_bRoundInProgress = false;
	
	// Round end event gets called again shortly after survival round actually ended
	float time = event.GetFloat("time");
	
	if (time < 60.0)
		return;
	
	// Load positions
	bLoadCfgFile(-1, true);
}

public void Event_OnSurvStart(Event event, const char[] name, bool dontBroadcast)
{
	g_bRoundInProgress = true;		
}


/*******************************
Shared stuff
*******************************/

void DisableRooftopDeathFallCameras()
{
	int entity = -1;
	while ((entity = FindEntityByClassname(entity, "point_deathfall_camera")) != -1)
	{
		if (IsValidEntity(entity)) AcceptEntityInput(entity, "kill");
	}
}

bool IsRooftop()
{
	char sMap[32];
	GetCurrentMap(sMap, sizeof(sMap));
	return (StrEqual(sMap, "c8m5_rooftop"));
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

void DespawnSIProps()
{
	for (int i = 0; i < g_hArray_SIIndexes.Length; i++)
	{
		int entity = g_hArray_SIIndexes.Get(i);
		if (IsValidEdict(entity)) RemoveEdict(entity);
	}

	g_hArray_SIIndexes.Clear();
}

void slaysurvivors()
{
	for (int i = 1; i <= MaxClients; i++)
	{
		if (IsClientInGame(i) && GetClientTeam(i) == SURV && IsPlayerAlive(i))
		{
			ForcePlayerSuicide(i);
		}
	}
}
