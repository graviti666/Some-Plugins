#include <sourcemod>
#include <sdktools>

#pragma semicolon	1
#pragma newdecls required

#define debug	0

#if debug
char g_sLogFile[256];
#endif

bool g_bHasCustomName[MAXPLAYERS + 1];

char sOrgName[MAXPLAYERS + 1][MAX_NAME_LENGTH];
char sCustomName[MAXPLAYERS + 1][MAX_NAME_LENGTH];

public Plugin myinfo =
{
	name = "Survival Name Change",
	author = "Gravity",
	description = "",
	version = "1.0",
	url = ""
};

public void OnPluginStart()
{
	RegAdminCmd("sm_endname", Cmd_ChangePlayerEndName, ADMFLAG_ROOT, "Set a name for a player that appears in round end HUD.");
	
	HookEvent("round_end", Event_OnRoundEnd);	// Was: EventHookMode_Pre
	
	// Makes the name change silent
	HookUserMessage(GetUserMessageId("SayText2"), Hook_SayText2, true);
	
	#if debug
	BuildPath(Path_SM, g_sLogFile, sizeof(g_sLogFile), "logs/survival_name_change_debug.log");
	#endif
}

public Action Hook_SayText2(UserMsg msg_id, any msg, const int[] players, int playersNum, bool reliable, bool init)
{
	char[] sMessage = new char[24];
	if (GetUserMessageType() == UM_Protobuf)
	{
		Protobuf pbmsg = msg;
		pbmsg.ReadString("msg_name", sMessage, 24);
	}
	else
	{
		BfRead bfmsg = msg;
		bfmsg.ReadByte();
		bfmsg.ReadByte();
		bfmsg.ReadString(sMessage, 24, false);
	}

	if (StrEqual(sMessage, "#Cstrike_Name_Change"))
	{
		return Plugin_Handled;
	}
	return Plugin_Continue;
}

public void Event_OnRoundEnd(Event event, const char[] name, bool dontBroadcast)
{	
	static int ifirecount;
	ifirecount++;
	
	if (ifirecount == 1)
	{
		for (int i = 1; i <= MaxClients; i++)
		{
			if (!IsClientInGame(i))
				continue;
			
			if (g_bHasCustomName[i]) 
			{
				SetClientName(i, sCustomName[i]);
			}	
		}
	}
	else if (ifirecount == 2)
	{			
		for (int i = 1; i <= MaxClients; i++)
		{
			if (!IsClientInGame(i))
				continue;
			
			if (g_bHasCustomName[i])
			{
				SetClientName(i, sOrgName[i]);
			}
		}
		ifirecount = 0;
	}
}

public Action Cmd_ChangePlayerEndName(int client, int args)
{
	if (args < 2) {
		PrintToChat(client, "\x01[SM] Usage: sm_endname <target> <name>");
		return Plugin_Handled;
	}
	
	char sName[128], sPlayer[64];
	GetCmdArg(1, sPlayer, sizeof(sPlayer));
	GetCmdArg(2, sName, sizeof(sName));
	StripQuotes(sName);
	
	char target_name[MAX_TARGET_LENGTH];
	int target_list[MAXPLAYERS], target_count; 
	bool tn_is_ml;
	
	if ((target_count = ProcessTargetString(sPlayer, client, target_list, MAXPLAYERS, COMMAND_FILTER_CONNECTED, target_name, sizeof(target_name), tn_is_ml)) <= 0)
	{
		ReplyToTargetError(client, target_count);
		return Plugin_Handled;
	}
	
	for (int i = 0; i < target_count; i++)
	{
		g_bHasCustomName[target_list[i]] = true;
		
		// Store custom and original name
		Format(sCustomName[target_list[i]], sizeof(sCustomName[]), sName);
		
		char name[MAX_NAME_LENGTH];
		GetClientName(target_list[i], name, sizeof(name));
		Format(sOrgName[target_list[i]], sizeof(sOrgName[]), "%s", name);
		
		PrintToChat(client, "\x05%N\x01's end name will be \x03%s", target_list[i], sName);
	}
	return Plugin_Handled;
}

stock bool IsClientRootAdmin(int client)
{
    return ((GetUserFlagBits(client) & ADMFLAG_ROOT) != 0);
}