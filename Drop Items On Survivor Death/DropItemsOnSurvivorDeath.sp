#include <sourcemod>
#include <sdktools>

#pragma semicolon	1
#pragma newdecls required

#define DROP_WEAPON_IN_SLOT_VIRTUAL		571

Handle g_hDropWeaponSlot;

public Plugin myinfo = 
{
	name = "Drop Items On Survivor Death",
	author = "Gravity",
	description = "Makes survivors drop all their items, melee kits etc on death properly.",
	version = "1.0",
	url = ""
};

public void OnPluginStart()
{
	StartPrepSDKCall(SDKCall_Player);
	if (!PrepSDKCall_SetVirtual(DROP_WEAPON_IN_SLOT_VIRTUAL))
		SetFailState("Failed to set CTerrorPlayer::DropWeaponInSlot(int) virtual");
	PrepSDKCall_AddParameter(SDKType_PlainOldData, SDKPass_Plain); // Slot 0 = primary 1 = secondary etc
	
	g_hDropWeaponSlot = EndPrepSDKCall();
	if (g_hDropWeaponSlot == null)
		SetFailState("Failed to set CTerrorPlayer::DropWeaponInSlot(int) virtual");
	
	HookEvent("player_hurt", Event_OnHurtDeath);
}

public void Event_OnHurtDeath(Event event, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(event.GetInt("userid"));
	if (!IsValidSurvivor(client))
		return;

	// We just died
	// from: https://forums.alliedmods.net/showthread.php?t=220020 - Root_
	if (GetClientHealth(client) < 1)
	{
		// Drop all slots as should be handled by the game anyway when dying
		// Can't verify the slot here since they won't be equipped at this point but this should be fine
		for (int i = 0; i < 5; i++)
		{
			SDKCall(g_hDropWeaponSlot, client, i);
		}
	}
}

bool IsValidSurvivor(int client)
{
	return client && IsClientInGame(client) && GetClientTeam(client) == 2;
}