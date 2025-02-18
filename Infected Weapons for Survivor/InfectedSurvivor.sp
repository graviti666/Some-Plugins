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

Handle g_hTimerOnce[MAXPLAYERS+1];

bool bHasAbility[MAXPLAYERS + 1];

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
	if (!PrepSDKCall_SetFromConf(gdata, SDKConf_Virtual, "CBaseAbility::OnCreate()")) SetFailState("Signature set fail for % CBaseAbility::OnCreate() %");
	PrepSDKCall_AddParameter(SDKType_CBasePlayer, SDKPass_Pointer);
	
	g_hBaseAbilityCreate = EndPrepSDKCall();
	if (g_hBaseAbilityCreate == null)
		SetFailState("Bad offset % CTerrorPlayer::RoundRespawn() % contact police");
	
	delete gdata;
}

public void OnMapStart()
{
	for (int i = 0; i < MAX_INFECTED_WEAPONS; i++)
	{
		PrecacheModel(sSpecialModels[i], true);
	}
	
	for (int i = 1; i <= MaxClients; i++)
	{
		bKeepSurvivorModel[i] = false;
		bHasAbility[i] = false;
		
		g_hTimerOnce[i] = null;
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

public int Menu_Callback(Menu menu, MenuAction action, int param1, int param2)
{
	if (action == MenuAction_Select)
	{
		MakeMenu(param1);
		
		char sInfo[42];
		menu.GetItem(param2, sInfo, sizeof(sInfo));
		
		if (StrEqual(sInfo, "reset"))
		{
			bHasAbility[param1] = false;
			
			SetEntProp(param1, Prop_Send, "m_customAbility", -1);
			int slot = GetPlayerWeaponSlot(param1, 0);
			if (slot != -1 && IsValidEntity(slot))
			{
				AcceptEntityInput(slot, "kill");
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
			
			PrintToChat(param1, "Ability reset.");
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
	
		int wp_index = GivePlayerItem(param1, sInfo);
		if (wp_index == -1 || !IsValidEntity(wp_index))
		{
			PrintToChat(param1, "%s Something unexpected happened failed to equip weapon %s", PLUGIN_TAG, sInfo);
		}
		
		EquipPlayerWeapon(param1, wp_index);
		TrySetAbility(param1, sInfo);
		
		bHasAbility[param1] = true;
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