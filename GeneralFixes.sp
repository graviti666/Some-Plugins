/* ===========================================
	credits:
	Bot duplication prevention code by Sir.
	
	Set of 5 Fixes (optional by cvar):
	
	Port Sacrifice (c7m3_port) Ammo pile spawn Fix
	- Spawns an ammo pile at the usual holdout location on survival.
	
	Admin Immunity
	- Admins can't be kicked by non-admins.
	
	Voting
	- Spectators cannot call votes.
	- Bot's can't be kicked.
	- Lobby and map votes can't be called while a survival round is in progress.
	
	Bot Duplication
	- Duplicating bots (going idle and changing character) is blocked. ( This creates a glitch where hundreds of medkits will spawn if a 
	  new player joins the game and takes a slot of a previously kicked bot. )
	
	Rooftop (c8m5_rooftop) Weapon spawns Fix
	- Weapon spawns wont disappear on rooftop (rifles and shotguns).
============================================== */
#include <sourcemod>
#include <sdktools>

#pragma semicolon	1
#pragma newdecls required

ConVar g_hEnablePlugin;
ConVar g_hAdminImmunityFix;
ConVar g_hSpectatorVotes;
ConVar g_hPreventKickingBots;
ConVar g_hFixPortSacrifice;
ConVar g_hFixRooftopGuns;
ConVar g_hBlockBotDuping;

#define TEAM_SPECTATORS		1
#define TEAM_SURVIVORS		2

// Spawn position for the ammo pile on port sacrifice.
float AmmoPileLocation[3] = {530.250000, -596.093750, 45.227451};

bool g_bRoundInProgress;

public Plugin myinfo = {
	name = "General Exploit & Issue Fixes",
	author = "Gravity",
	description = "Prevent issues with votes & game exploits/bugs.",
	version = "1.0",
	url = ""
}

public void OnPluginStart()
{
	g_hEnablePlugin = CreateConVar("l4d2_fixes_enabled", 							"1", 	"Enable or disable plugin.", 0, true, 0.0, true, 1.0);
	g_hAdminImmunityFix = CreateConVar("l4d2_fixes_admin_immunity", 				"1", 	"Can people kick admins from server?", 0, true, 0.0, true, 1.0);
	g_hSpectatorVotes = CreateConVar("l4d2_fixes_block_spectator_votes", 			"1", 	"Can spectators call votes?", 0, true, 0.0, true, 1.0);
	g_hPreventKickingBots = CreateConVar("l4d2_fixes_prevent_kicking_bots", 		"1", 	"Prevent kicking bots from the server? causes bug where extra kits spawn.", 0, true, 0.0, true, 1.0);
	g_hFixPortSacrifice = CreateConVar("l4d2_fixes_port_sacrifice_ammofix", 		"1", 	"Prevents an ammo pile not spawning on port sacrifice in the house.", 0, true, 0.0, true, 1.0);
	g_hFixRooftopGuns = CreateConVar("l4d2_fixes_rooftop_guns_fix", 				"1", 	"Should weapon spawns on rooftop not disappear?", 0, true, 0.0, true, 1.0);
	g_hBlockBotDuping = CreateConVar("l4d2_fixes_block_bot_duplication",			"1",	"Prevents a bug where going idle and switching team spawns extra bots.", 0, true, 0.0, true, 1.0);
	
	AddCommandListener(Listener_CallVote, "callvote");
	AddCommandListener(Listener_Join, "jointeam");
	
	HookEvent("survival_round_start", Event_OnRoundStartSurv);
	HookEvent("player_left_start_area", Event_OnRoundInitialized);
	HookEvent("round_end", Event_OnRoundEnd);
	
	//	Auto creates a cfg file within sourcemod/cfg
	AutoExecConfig(true, "generalfixes");
}

// ===========================
//			Events
// ===========================
public void Event_OnRoundStartSurv(Event event, const char[] name, bool dontBroadcast)
{
	g_bRoundInProgress = true;
}

public void Event_OnRoundEnd(Event event, const char[] name, bool dontBroadcast)
{
	if( g_bRoundInProgress ) 
	{
		g_bRoundInProgress = false;
	}
}

public void Event_OnRoundInitialized(Event event, const char[] name, bool dontBroadcast)
{
	char sMap[32];
	GetCurrentMap(sMap, sizeof(sMap));
	
	if( StrEqual(sMap, "c7m3_port") )
	{
		// Check if ammo pile exists in the coordinates if not spawn it
		if( g_hFixPortSacrifice.BoolValue )
		{
			int ammo = FindEntityByLocation("weapon_ammo_spawn", AmmoPileLocation);
		
			// Couldn't find ammopile at usual spot, create one.
			if(!IsValidEntity(ammo))
			{
				int ammoSpawn = CreateEntityByName("weapon_ammo_spawn");
				
				if(ammoSpawn != -1) {
					DispatchKeyValue(ammoSpawn, "origin", "530.250000, -596.093750, 45.227451");
					DispatchKeyValue(ammoSpawn, "disableshadows", "1");
					DispatchKeyValue(ammoSpawn, "solid", "0");
					DispatchKeyValue(ammoSpawn, "targetname", "Bitch");
					DispatchSpawn(ammoSpawn);
				}
			}	
		}
	}
	
	// Find weapon spawns on rooftop and set spawnflags to 8 'Infinite Items' so they wont disappear
	if( StrEqual(sMap, "c8m5_rooftop") )
	{
		if( g_hFixRooftopGuns.BoolValue )
		{
			int ak = FindEntityByName("weapon_rifle_ak47_spawn");
			if(ak != -1)
			{
				DispatchKeyValue(ak, "spawnflags", "8");
				DispatchSpawn(ak);
			}
			
			int sg = FindEntityByName("weapon_autoshotgun_spawn");
			if(sg != -1)
			{
				DispatchKeyValue(sg, "spawnflags", "8");
				DispatchSpawn(sg);
			}
		
			int desRifle = FindEntityByName("weapon_rifle_desert_spawn"); /*for desert rifle on rooftop that disappears*/
			if(desRifle != -1)
			{
				DispatchKeyValue(desRifle, "spawnflags", "8");
				DispatchSpawn(desRifle);
			}
		}
	}
}

int FindEntityByName(char[] classname)
{
	int ent;
	while((ent = FindEntityByClassname(ent, classname)) != -1)
	{
		if(IsValidEntity(ent))
		{
			return ent;
		}
	}
	return -1;
}

int FindEntityByLocation(char[] classname, float EntPos[3])
{
	int ent;
	while((ent = FindEntityByClassname(ent, classname)) != -1)
	{
		if( IsValidEntity(ent) )
		{
			float vec[3];
			GetEntPropVector(ent, Prop_Send, "m_vecOrigin", vec);
			
			if( GetVectorDistance(vec, EntPos) < 5.0 )
			{
				return ent;
			}
		}
	}
	return -1;
}

public Action Listener_CallVote(int client, const char[] command, int argc)
{
	// Is plugin enabled?
	if (!g_hEnablePlugin.BoolValue || !IsSurvival() ) return Plugin_Continue;
	
	// Block all spectators from calling votes from the pause pause, unless client is admin.
	if (GetClientTeam(client) == TEAM_SPECTATORS && !IsValidAdmin(client))
	{
		if( g_hSpectatorVotes.BoolValue ) {
			PrintToChat(client, "[SM] Spectators are not allowed to vote.");
			return Plugin_Handled;
		}
	}
	
	char sIssue[64];
	GetCmdArg(1, sIssue, sizeof(sIssue));
	
	if (StrEqual(sIssue, "kick", false) )
	{
		char sTarget[64];
		GetCmdArg(2, sTarget, sizeof(sTarget));
		
		int target = GetClientOfUserId(StringToInt(sTarget));
		
		// Admin immunity fix
		if (target && IsClientInGame(target) && !IsFakeClient(target) && IsValidAdmin(target))
		{
			if( g_hAdminImmunityFix.BoolValue ) {
				PrintToChat(client, "[SM] Not allowed to kick admins.");
				PrintToChat(target, "\x05%N\x01 tried to kick you from the server but was blocked!", client);
				return Plugin_Handled;
			}
		}
		
		// Prevent kicking bots
		else if (target && IsClientInGame(target) && IsFakeClient(target))
		{
			if( g_hPreventKickingBots.BoolValue ) {	
				PrintToChat(client, "[SM] Not allowed to kick bots.");
				return Plugin_Handled;
			}
		}
	}
	else if (StrEqual(sIssue, "returntolobby", false) )
	{
		if( g_bRoundInProgress )
		{
			PrintToChat(client, "[SM] Not allowed to vote for lobby while survival round in progress.");
			return Plugin_Handled;
		}
	}
	else if (StrEqual(sIssue, "changechapter", false) )
	{
		if( g_bRoundInProgress )
		{
			PrintToChat(client, "[SM] Not allowed to change map while survival round in progress.");
			return Plugin_Handled;
		}
	}
	
	// Allow the vote
	return Plugin_Continue;
}

public Action Listener_Join(int client, const char[] command, int argc)
{
	if( g_hBlockBotDuping.BoolValue ) 
	{
		// Only care if they're targeting a specific Character.
		if (IsValidClient(client) && argc >= 2)
		{
			// Get Character they're trying to steal.
			char sJoinPlayer[128];
			char sJoin[32];
			GetCmdArg(1, sJoin, sizeof(sJoin));
			GetCmdArg(2, sJoinPlayer, sizeof(sJoinPlayer));

			// Are they trying to Join Survivors or nah?
			if (StringToInt(sJoin) != 2) return Plugin_Continue;

			// Loop through Survivors to see if someone owns that Character.
			for(int i = 1; i <= MaxClients; i++)
			{
				if (IsValidClient(i) && GetClientTeam(i) == TEAM_SURVIVORS)
				{
					if (!IsFakeClient(i))
					{
						char sModel[64];
						char sPlayer[64];
						GetClientModel(i, sModel, sizeof(sModel));

						if (StrEqual(sModel, "models/survivors/survivor_coach.mdl")) Format(sPlayer, sizeof(sPlayer), "Coach");
						else if (StrEqual(sModel, "models/survivors/survivor_gambler.mdl")) Format(sPlayer, sizeof(sPlayer), "Nick");
						else if (StrEqual(sModel, "models/survivors/survivor_producer.mdl")) Format(sPlayer, sizeof(sPlayer), "Rochelle");
						else if (StrEqual(sModel, "models/survivors/survivor_mechanic.mdl")) Format(sPlayer, sizeof(sPlayer), "Ellis");
						else if (StrEqual(sModel, "models/survivors/survivor_manager.mdl")) Format(sPlayer, sizeof(sPlayer), "Louis");
						else if (StrEqual(sModel, "models/survivors/survivor_teenangst.mdl")) Format(sPlayer, sizeof(sPlayer), "Zoey");
						else if (StrEqual(sModel, "models/survivors/survivor_namvet.mdl")) Format(sPlayer, sizeof(sPlayer), "Bill");
						else if (StrEqual(sModel, "models/survivors/survivor_biker.mdl")) Format(sPlayer, sizeof(sPlayer), "Francis");

						// Client is trying to take a Character that is already taken by a Player.
						// BLOCK.
						if (StrEqual(sJoinPlayer, sPlayer, false)) 
						{
							PrintToChat(client, "[SM] This survivor bot is already taken.");
							return Plugin_Handled;
						}
					}
				}
				else
				{
					if (HasIdlePlayer(i))
					{
						char sModel[64];
						char sPlayer[64];
						GetClientModel(i, sModel, sizeof(sModel));

						if (StrEqual(sModel, "models/survivors/survivor_coach.mdl")) Format(sPlayer, sizeof(sPlayer), "Coach");
						else if (StrEqual(sModel, "models/survivors/survivor_gambler.mdl")) Format(sPlayer, sizeof(sPlayer), "Nick");
						else if (StrEqual(sModel, "models/survivors/survivor_producer.mdl")) Format(sPlayer, sizeof(sPlayer), "Rochelle");
						else if (StrEqual(sModel, "models/survivors/survivor_mechanic.mdl")) Format(sPlayer, sizeof(sPlayer), "Ellis");
						else if (StrEqual(sModel, "models/survivors/survivor_manager.mdl")) Format(sPlayer, sizeof(sPlayer), "Louis");
						else if (StrEqual(sModel, "models/survivors/survivor_teenangst.mdl")) Format(sPlayer, sizeof(sPlayer), "Zoey");
						else if (StrEqual(sModel, "models/survivors/survivor_namvet.mdl")) Format(sPlayer, sizeof(sPlayer), "Bill");
						else if (StrEqual(sModel, "models/survivors/survivor_biker.mdl")) Format(sPlayer, sizeof(sPlayer), "Francis");

						// Client is trying to take a Character that is already taken by an IDLE Player.
						// BLOCK.
						if (StrEqual(sJoinPlayer, sPlayer, false)) 
						{
							PrintToChat(client, "[SM] This survivor bot is already taken.");
							return Plugin_Handled;
						}
					}
				}
			}
		}
	}
	return Plugin_Continue;
}

// ===================================
//				Shared
// ===================================

bool HasIdlePlayer(int bot)
{
	int client = GetClientOfUserId(GetEntProp(bot, Prop_Send, "m_humanSpectatorUserID"));
	if (IsValidClient(client) && !IsFakeClient(client) && GetClientTeam(client) == TEAM_SPECTATORS) 
		return true;
	return false;
}

bool IsValidClient(int client) { 
	return (client > 0 && client <= MaxClients && IsClientInGame(client));
}

bool IsValidAdmin(int client)
{
	if(GetUserAdmin(client) != INVALID_ADMIN_ID)
	{
		return true;
	}
	return false;
}

bool IsSurvival()
{
	char sGameMode[16];
	GetConVarString(FindConVar("mp_gamemode"), sGameMode, sizeof(sGameMode));
	if (StrContains(sGameMode, "survival", false) != -1)
	{
		return true;
	}
	return false;
}