#include <sourcemod>
#include <sdktools>

#define IS_VALID_CLIENT(%1)     (%1 > 0 && %1 <= MaxClients)
#define IS_SURVIVOR(%1)         (GetClientTeam(%1) == 2)
#define IS_INFECTED(%1)         (GetClientTeam(%1) == 3)
#define IS_VALID_INGAME(%1)     (IS_VALID_CLIENT(%1) && IsClientInGame(%1))
#define IS_VALID_SURVIVOR(%1)   (IS_VALID_INGAME(%1) && IS_SURVIVOR(%1))
#define IS_VALID_INFECTED(%1)   (IS_VALID_INGAME(%1) && IS_INFECTED(%1))
#define IS_SURVIVOR_ALIVE(%1)   (IS_VALID_SURVIVOR(%1) && IsPlayerAlive(%1))
#define IS_INFECTED_ALIVE(%1)   (IS_VALID_INFECTED(%1) && IsPlayerAlive(%1))

#define L4D_TEAM_SURVIVORS 2
#define L4D_TEAM_INFECTED 3
#define L4D_TEAM_SPECTATE 1

public Plugin:myinfo =
{
	name = "Team Select",
	author = "khan",
	description = "Allow players to switch teams",
	version = "1.0"
};

public OnPluginStart()
{	
	// Console commands to spectate or join survivors
	RegConsoleCmd("spectate", Command_Spectate);
	RegConsoleCmd("spec", Command_Spectate);
	RegConsoleCmd("survivor", Command_Survivor);
	RegConsoleCmd("survivors", Command_Survivor);
	RegConsoleCmd("js", Command_Survivor);
	
	// Admin command for joining infected team
	RegAdminCmd("ji", Command_Infected, ADMFLAG_KICK, "join infected team");
	RegAdminCmd("infected", Command_Infected, ADMFLAG_KICK, "join infected team");
}

public Action:Command_Spectate(client, args)
{
	if(GetClientTeam(client) != L4D_TEAM_SPECTATE)
	{
		ChangePlayerTeam(client, L4D_TEAM_SPECTATE, "");
	}
	return Plugin_Handled;
}


public Action:Command_Survivor(client, args)
{
	if(GetClientTeam(client) != L4D_TEAM_SURVIVORS)
	{
		new String:player[128];
		if (args > 0)
		{
			// Get the survivor name if it was passed in
			GetCmdArgString(player, sizeof(player));
		}
		
		ChangePlayerTeam(client, L4D_TEAM_SURVIVORS, player);
	}
	else if (args > 0)
	{
		// Player is trying to switch survivor
		new String:player[128];
		GetCmdArgString(player, sizeof(player));
		
		// Verify that the survivor that they want is available
		if (CheckSurvivor(player))
		{
			// Force the player to spectate then join as the player they want
			ChangePlayerTeam(client, L4D_TEAM_SPECTATE, "");
			ChangePlayerTeam(client, L4D_TEAM_SURVIVORS, player);
		}
	}

	return Plugin_Handled;
}

public bool:CheckSurvivor(String:name[128])
{
	new String:clientName[128];
	new String:dest[128];
	for (new i = 0; i < MaxClients; i++)
	{
		if (IS_VALID_INGAME(i))
		{
			if (GetClientName(i, clientName, sizeof(clientName)))
			{
				dest = clientName;
				if (strlen(name) < strlen(clientName))
				{
					ReplaceString(dest, sizeof(dest), clientName[strlen(name)], "");
				}
				
				if (StrEqual(dest, name, false))
				{
					// Found survivor that they want to play as
					return true;
				}
			}
		}
	}
	
	// Couldn't find the player that they wanted to join as. Already taken or they typed it wrong.
	return false;
}

public Action:Command_Infected(client, args)
{
	new String:player[128];
	new String:clientName[128];
	new bool:foundPlayer = false;
	
	// Admin can pass in a players name as an argument to move other players to infected
	if (args > 0)
	{
		// Get name of player to move to infected team
		GetCmdArgString(player, sizeof(player));
		for (new i = 0; i < MaxClients; i++)
		{
			if (IS_VALID_INGAME(i))
			{
				if (GetClientName(i, clientName, sizeof(clientName)))
				{
					if (StrEqual(clientName, player))
					{
						// Found player...
						client = i;
						foundPlayer = true;
						break;
					}
				}
			}
		}
		
		if (!foundPlayer)
		{
			// Couldn't find the player that they want to move to infected team
			return Plugin_Handled;
		}
	}
	
	// Move player to infected team if not already there
	if (GetClientTeam(client) != L4D_TEAM_INFECTED)
	{
		ChangePlayerTeam(client, L4D_TEAM_INFECTED, "");
	}
	
	return Plugin_Handled;
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
	
	// Reset this cmds flags
	SetCommandFlags(command, flags);
}