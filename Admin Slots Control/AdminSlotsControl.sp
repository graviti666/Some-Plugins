#include <sourcemod>
#include <connecthook>

#pragma semicolon	1
#pragma newdecls required

#define CONFIG_LINE_BUFFER_SIZE		512

#define ADMINS_CFG_FILE		"configs/admins_simple.ini"

ConVar g_hAdminSlotRejectionMsg; 

Handle g_hMaxPlayers;

int g_iSlots, g_iAdjustedSlots;

public Plugin myinfo = 
{
	name = "Admin Slots Control",
	author = "Gravity",
	description = "Allows admins to join the server even if theres not a available slot by connecting through ip:port from console",
	version = "1.0",
	url = ""
};

public void OnPluginStart()
{
	g_hAdminSlotRejectionMsg = CreateConVar("admin_slots_reject_msg", "[SM] No scouts allowed, this slot is reserved for admins.", "Default rejection message to use when a non-admin tries to connect to the hidden slot.", 0);
	CreateTimer(1.0, Timer_GetConvarsDelayed);
}

public Action Timer_GetConvarsDelayed(Handle timer)
{
	g_hMaxPlayers = FindConVar("sv_maxplayers");
	PrintToServer("[AdminSlotsControl] Cached relevant convars succesfully.");
}

/* 
 * OnClientConnect gets called too late so we need this + ConnectHook extension for this to work apparently. 
*/ 
public Action OnClientPreConnect(const char[] name, const char[] password, const char[] ip, const char[] steamID, char rejectReason[255])
{
	PrintToAnyPresentAdmins(name, ip, steamID);
	
	// When slots are limited (set 4/4 - 5/5) but a player is trying to connect manually "connect ip:port" only allow admins through
	if (IsSlotsLimited())
	{
		if (IsPlayerWhiteListed(steamID))
		{
			AdjustSlots();
			
			// Allow the admin to connect.
			PrintToServer("[AdminSlotsControl] admin %s is connecting to server allowing connection...", steamID);
			return Plugin_Continue;
		}
		else
		{
			PrintToServer("[AdminSlotsControl] Player Trying to connect is non-admin rejecting...");
			
			char sRejectionMessage[128];
			g_hAdminSlotRejectionMsg.GetString(sRejectionMessage, sizeof(sRejectionMessage));
			strcopy(rejectReason, sizeof(rejectReason), sRejectionMessage);
			return Plugin_Handled;
		}
	}
	
	// Allow connection
	return Plugin_Continue;
}

void PrintToAnyPresentAdmins(const char[] sName, const char[] sIP, const char[] sSteamID)
{
	for (int i = 1; i <= MaxClients; i++)
	{
		if (!IsClientInGame(i))continue;
		
		if (IsClientRootAdmin(i))
		{
			PrintToChat(i, "\x05%s\x01 Connecting... \x04%s\x01  \x03%s\x01", sName, sSteamID, sIP);
		}
	}
}

// STEAM_1:1:60678580
public bool IsPlayerWhiteListed(const char[] sourceID)
{
	char sPath[PLATFORM_MAX_PATH];
	BuildPath(Path_SM, sPath, sizeof(sPath), ADMINS_CFG_FILE); // admins_simple.ini
	
	char sBuffer[CONFIG_LINE_BUFFER_SIZE];
	File hFile = OpenFile(sPath, "r");
	
	if (hFile == null) {
		LogError("Error parsing admins_simple.ini");
		return false;
	}
	
	while (hFile.ReadLine(sBuffer, sizeof(sBuffer))) 
	{	
		// Check the numbers after: STEAM_1:1: part only
		if (StrContains(sBuffer, sourceID[10]) != -1)
			return true;
		
		if (hFile.EndOfFile()) {
			break;
		}
	}
	if (hFile != null) {
		delete hFile;
	}
	return false;
}

void AdjustSlots()
{
	g_iSlots = GetConVarInt(g_hMaxPlayers);
	g_iAdjustedSlots = g_iSlots + 1;
	SetConVarInt(g_hMaxPlayers, g_iAdjustedSlots);
}

bool IsSlotsLimited()
{
	int maxplayers = GetConVarInt(g_hMaxPlayers);
	int player_count = GetRealPlayerCount();
	
	// If current value of sv_maxplayers equals the current player count of the server slots are limited.
	if (maxplayers == player_count)
	{
		return true;
	}
	return false;
}

// Count real survivor and spectator players
int GetRealPlayerCount()
{
	int count;
	for (int i = 1; i <= MaxClients; i++)
	{
		if (!IsClientInGame(i))continue;
		
		if (GetClientTeam(i) == 2 || GetClientTeam(i) == 1)
		{
			if (IsFakeClient(i))
				continue;
				
			count++;
		}
	}
	return count;
}

stock bool IsClientRootAdmin(int client)
{
    return ((GetUserFlagBits(client) & ADMFLAG_ROOT) != 0);
}