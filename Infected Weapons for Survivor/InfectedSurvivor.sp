#include <sourcemod>
#include <sdktools>

#pragma semicolon	1
#pragma newdecls required

#define PLUGIN_TAG	"\x01(\x03InfectedSurvivor\x01)"

#define MAX_INFECTED_WEAPONS	7
char sInfectedWeapons[MAX_INFECTED_WEAPONS][] =
{
	"weapon_hunter_claw",
	"weapon_jockey_claw",
	"weapon_charger_claw",
	"weapon_spitter_claw",
	"weapon_tank_claw",
	"weapon_boomer_claw",
	"weapon_smoker_claw"
};

char sInfectedWeapons_Readable[MAX_INFECTED_WEAPONS][] =
{
	"Hunter claw",
	"Jockey claw",
	"Charger claw",
	"Spitter claw",
	"Tank claw",
	"Boomer claw",
	"Smoker claw"
};

Handle g_hBaseAbilityCreate;

#define DROP_WEAPON_IN_SLOT		571
Handle g_hDropWeaponSlot;

#define TANK_MODEL "models/infected/hulk.mdl"

bool bKeepSurvivorModel[MAXPLAYERS + 1];

char sSpecialModels[MAX_INFECTED_WEAPONS][] =
{
	"models/infected/hunter.mdl",
	"models/infected/jockey.mdl",
	"models/infected/charger.mdl",
	"models/infected/spitter.mdl",
	"models/infected/hulk.mdl",
	"models/infected/boomer.mdl",
	"models/infected/smoker.mdl"
};

public Plugin myinfo = 
{
	name = "Infected Weapons for Survivors",
	author = "Gravity",
	description = "trash",
	version = "1.0"
}

public void OnPluginStart()
{
	RegAdminCmd("sm_iclass", Cmd_EquipInfectedWeapon, ADMFLAG_ROOT);
	
	Handle gdata = LoadGameConfigFile("SurvivalRoundManager");
	StartPrepSDKCall(SDKCall_Entity);
	if (!PrepSDKCall_SetFromConf(gdata, SDKConf_Virtual, "CBaseAbility::OnCreate()")) 
		SetFailState("Signature set fail for % CBaseAbility::OnCreate() %");
	PrepSDKCall_AddParameter(SDKType_CBasePlayer, SDKPass_Pointer);
	
	g_hBaseAbilityCreate = EndPrepSDKCall();
	if (g_hBaseAbilityCreate == null)
		SetFailState("Bad offset CBaseAbility::OnCreate()");
	
	StartPrepSDKCall(SDKCall_Player);
	if (!PrepSDKCall_SetVirtual(DROP_WEAPON_IN_SLOT))
		SetFailState("Failed to set CTerrorPlayer::DropWeaponInSlot(int) virtual");
	PrepSDKCall_AddParameter(SDKType_PlainOldData, SDKPass_Plain); // Slot 0 = primary 1 = secondary etc
	
	g_hDropWeaponSlot = EndPrepSDKCall();
	if (g_hDropWeaponSlot == null)
		SetFailState("Failed to set CTerrorPlayer::DropWeaponInSlot(int) virtual");
	
	delete gdata;
}

public void OnMapStart()
{
	for (int i = 0; i < MAX_INFECTED_WEAPONS; i++)
	{
		PrecacheModel(sSpecialModels[i], true);
	}
}

public Action Cmd_EquipInfectedWeapon(int client, int args)
{
	MakeMenu(client);
	return Plugin_Handled;
}

void MakeMenu(int client)
{
	if (!client) return;
	Menu menu = new Menu(Menu_Callback);
	menu.SetTitle("Select infected weapon:");
	menu.AddItem("reset", "Reset");
	menu.AddItem("keepmodel", "Maintain Survivor Model?");
	for (int i = 0; i < MAX_INFECTED_WEAPONS; i++)
	{
		menu.AddItem(sInfectedWeapons[i], sInfectedWeapons_Readable[i]);
	}
	
	menu.ExitButton = false;
	menu.Display(client, MENU_TIME_FOREVER);
}

int g_OldWeapon[MAXPLAYERS+1];

public int Menu_Callback(Menu menu, MenuAction action, int param1, int param2)
{
	if (action == MenuAction_Select)
	{
		MakeMenu(param1);
		
		char sInfo[42];
		menu.GetItem(param2, sInfo, sizeof(sInfo));
		
		if (StrEqual(sInfo, "reset"))
		{
			// Already reset?
			if (GetEntPropEnt(param1, Prop_Send, "m_customAbility") == -1) {
				PrintToChat(param1, "Failed. You don't have any ability.");
				return 0;
			}
			
			SetEntPropEnt(param1, Prop_Send, "m_customAbility", -1);
			
			int slot = GetPlayerWeaponSlot(param1, 0);
			if (slot != -1)
			{
				char class[32];
				GetEdictClassname(slot, class, sizeof(class));	
				for (int i = 0; i < MAX_INFECTED_WEAPONS; i++)
				{
					if (strcmp(class, sInfectedWeapons[i]) == 0)
						AcceptEntityInput(slot, "kill");
				}
				
				if (g_OldWeapon[param1] != INVALID_ENT_REFERENCE)
				{
					int old = EntRefToEntIndex(g_OldWeapon[param1]);
					if (old != 0 && IsValidEdict(old))
						EquipPlayerWeapon(param1, old);
				}
			}
			
			int character = GetEntProp(param1, Prop_Send, "m_survivorCharacter");
			switch (character)
			{
				case 0: // nick
				{
					PrecacheModel("models/survivors/survivor_gambler.mdl");
					SetEntityModel(param1, "models/survivors/survivor_gambler.mdl");
				}
				case 1: // rochelle
				{
					PrecacheModel("models/survivors/survivor_producer.mdl");
					SetEntityModel(param1, "models/survivors/survivor_producer.mdl");
				}
				case 2: // coach
				{
					PrecacheModel("models/survivors/survivor_coach.mdl");
					SetEntityModel(param1, "models/survivors/survivor_coach.mdl");
				}
				case 3: // ellis
				{
					PrecacheModel("models/survivors/survivor_mechanic.mdl");
					SetEntityModel(param1, "models/survivors/survivor_mechanic.mdl");
				}
				case 4: // Bil
				{
					PrecacheModel("models/survivors/survivor_namvet.mdl");
					SetEntityModel(param1, "models/survivors/survivor_namvet.mdl");
				}
				case 5: // Zoey models/survivors/survivor_teenangst.mdl
				{
					PrecacheModel("models/survivors/survivor_teenangst.mdl");
					SetEntityModel(param1, "models/survivors/survivor_teenangst.mdl");
				}
				case 6: // Francis
				{
					PrecacheModel("models/survivors/survivor_biker.mdl");
					SetEntityModel(param1, "models/survivors/survivor_biker.mdl");
				}
				case 7: // Louis
				{
					PrecacheModel("models/survivors/survivor_manager.mdl");
					SetEntityModel(param1, "models/survivors/survivor_manager.mdl");
				}
			}
			
			PrintToChat(param1, "Ability Removed.");
			return 0;
		}
		else if (StrEqual(sInfo, "keepmodel"))
		{
			if (!bKeepSurvivorModel[param1])
				bKeepSurvivorModel[param1] = true;
			else
				bKeepSurvivorModel[param1] = false;
			
			PrintToChat(param1, "%s", bKeepSurvivorModel[param1] ? "Now keeping Survivor Model (tank excluded)" : "Now using SI models");
			return 0;
		}
	
		// Handle the old weapon, kill SI weapon or drop gun
		int ent = GetPlayerWeaponSlot(param1, 0);
		if (ent != -1)
		{
			char ent_class[32];
			GetEdictClassname(ent, ent_class, sizeof(ent_class));
			for (int i = 0; i < MAX_INFECTED_WEAPONS; i++)
			{
				if (strcmp(ent_class, sInfectedWeapons[i]) == 0) {
					AcceptEntityInput(ent, "kill");
				}
				else
				{
					g_OldWeapon[param1] = EntIndexToEntRef(ent);
					SDKCall(g_hDropWeaponSlot, param1, ent);
				}
			}
		}
	
		int wp_index = GivePlayerItem(param1, sInfo);
		if (wp_index == -1 || !IsValidEntity(wp_index))
		{
			PrintToChat(param1, "%s Something unexpected happened failed to equip weapon %s", PLUGIN_TAG, sInfo);
		}
		
		EquipPlayerWeapon(param1, wp_index);
		TrySetAbility(param1, sInfo);
	}
	else if (action == MenuAction_End)
	{
		delete menu;
	}
	
	return 0;
}

void TrySetAbility(int client, const char[] wp)
{
	if (StrEqual(wp, "weapon_hunter_claw"))
	{	
		if (!bKeepSurvivorModel[client])
			//Change model to the corresponding Special infected
			SetEntityModel(client, sSpecialModels[0]);
		
		Ability(client, "ability_lunge");
	}
	else if (StrEqual(wp, "weapon_jockey_claw"))
	{
		if (!bKeepSurvivorModel[client])
			// Change model to the corresponding Special infected
			SetEntityModel(client, sSpecialModels[1]);
		
		Ability(client, "ability_leap");
	}
	else if (StrEqual(wp, "weapon_charger_claw"))
	{
		if (!bKeepSurvivorModel[client])
			// Change model to the corresponding Special infected
			SetEntityModel(client, sSpecialModels[2]);
			
		Ability(client, "ability_charge");
	}
	else if (StrEqual(wp, "weapon_spitter_claw"))
	{
		if (!bKeepSurvivorModel[client])
			// Change model to the corresponding Special infected
			SetEntityModel(client, sSpecialModels[3]);
		
		Ability(client, "ability_spit");
	}
	else if (StrEqual(wp, "weapon_tank_claw"))
	{
		// Change model to the corresponding Special infected
		// In order for tank rocks to work we need to change the model
		SetEntityModel(client, sSpecialModels[4]);
		Ability(client, "ability_throw");
	}
	else if (StrEqual(wp, "weapon_boomer_claw"))
	{
		if (!bKeepSurvivorModel[client])
			// Change model to the corresponding Special infected
			SetEntityModel(client, sSpecialModels[5]);
		
		Ability(client, "ability_vomit");
	}
	else if (StrEqual(wp, "weapon_smoker_claw"))
	{
		if (!bKeepSurvivorModel[client])
			// Change model to the corresponding Special infected
			SetEntityModel(client, sSpecialModels[6]);
		
		Ability(client, "ability_tongue");
	}
}

void Ability(int client, const char[] name)
{
    int entity = CreateEntityByName(name);    	
    DispatchSpawn(entity);
    
    if (!IsValidEdict(entity))
    	return;
    
    SetEntPropEnt(client, Prop_Send, "m_customAbility", entity);
   
    SDKCall(g_hBaseAbilityCreate, entity, client);
}