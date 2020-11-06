#include <sourcemod>
#include <sdktools>
#include <sdkhooks>

#pragma semicolon	1
#pragma newdecls required

public Plugin myinfo = 
{
	name = "Fix Item Properties",
	author = "Gravity",
	version = "1.0"
}

/*
 * Original code from FixMaps.sp by khan
*/
public void OnPluginStart()
{
	HookEvent("survival_round_start", Event_OnSurvivalStart);
}

public void Event_OnSurvivalStart(Event event, const char[] name, bool dontBroadcast)
{
	// Set the movetype on any gascans or propane so that the infected don't get stuck on them
	int iEnt;
	while ((iEnt = FindEntityByClassname(iEnt, "weapon_gascan")) != -1) 
	{
		if (!IsValidEdict(iEnt) || !IsValidEntity(iEnt)) {
			continue;
		}
		
		SetEntProp(iEnt, Prop_Send, "m_nSolidType", 1);
	}
	
	iEnt = -1;
	char sEntModel[64];
	while ((iEnt = FindEntityByClassname(iEnt, "prop_physics")) != -1) 
	{
		if (!IsValidEdict(iEnt) || !IsValidEntity(iEnt)) {
			continue;
		}
		
		GetEntPropString(iEnt, Prop_Data, "m_ModelName", sEntModel, sizeof(sEntModel));
		if (StrContains(sEntModel, "propanecanister", false) != -1 || StrContains(sEntModel, "gascan", false) != -1)
		{
			SetEntProp(iEnt, Prop_Send, "m_nSolidType", 1);
		}
	}
}

public void OnEntityCreated(int entity, const char[] classname)
{
	if (StrEqual("upgrade_ammo_incendiary", classname) || StrEqual("upgrade_ammo_explosive", classname))
	{
		// Set solid type on special ammo when it spawned so that infected don't get stuck on them
		SDKHook(entity, SDKHook_Spawn, OnSpecialAmmoSpawn);
	}
}

public void OnSpecialAmmoSpawn(int iEntity)
{
	CreateTimer(0.2, Timer_SetSpecialSolidType, iEntity);
}

public Action Timer_SetSpecialSolidType(Handle hTimer, any ent)
{
	if (IsValidEntity(ent)) 
		SetEntProp(ent, Prop_Send, "m_nSolidType", 1);
}