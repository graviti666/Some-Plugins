/*
Maybe you could use EmitSoundToAll instead? I haven't tried making it play sounds on entities (apart from players), but I guess it's worth a shot.
There are 6 channels the sound can be played from for EmitSoundToAll.
Channel 1 = CHAN_WEAPON (sound will be overrode by the target's gunshots)
Channel 2 = CHAN_VOICE (sound will be overrode when the target sprints or dies)
Channel 3 = CHAN_ITEM (sound will be overrode by the target's weapon reload sounds/item pickups)
Channel 4 = CHAN_BODY (sound will be overrode by the target's own footsteps)
Channel 5 = CHAN_STREAM (sound will be overrode by another sound played on this same channel; unused by game, I think)
Channel 6 = CHAN_STATIC (sound cannot be overrode, it will overlap instead - bad idea for looping sounds because you can't stop them)
*/
#include <sourcemod>
#include <sdktools>
#include <adminmenu>

#pragma semicolon	1
#pragma newdecls required

ConVar g_hSoundLoopTimes;

bool g_bListenSave[MAXPLAYERS + 1];
bool g_bIsEarrapeOn;

public Plugin myinfo =
{
	name = "Sounds Menu",
	author = "Gravity",
	description = "Provides a sounds menu interface to the admin menu.",
	version = "1.0",
	url = ""
};

public void OnPluginStart()
{	
	AddCommandListener(OnSayCommand, "say");
	AddCommandListener(OnSayCommand, "say_team");
	
	LoadTranslations("common.phrases");
	
	TopMenu topmenu = GetAdminTopMenu();
	if (LibraryExists("adminmenu") && (topmenu != null))
	{
		OnAdminMenuReady(topmenu);
	}
	
	g_hSoundLoopTimes = CreateConVar("soundmenu_loop_count", "20", "The times a sound plays (loops) with the ear rape option enabled.");
}

public void OnMapStart()
{
	for (int i = 1; i <= MaxClients; i++)
	{
		g_bListenSave[i] = false;
	}
	g_bIsEarrapeOn = false;
}

/*******************************
	Save sound file path
*********************************/

public Action OnSayCommand(int client, const char[] command, int argc)
{	
	if (g_bListenSave[client])
	{
		char sPathHandle[256];
		GetCmdArgString(sPathHandle, sizeof(sPathHandle));
		
		StripQuotes(sPathHandle);
		TrimString(sPathHandle);
		
		PrintToChat(client, "\x01Saved Sound File -> \x05%s", sPathHandle);
		SaveSoundPath(sPathHandle);
		
		g_bListenSave[client] = false;
		return Plugin_Handled;
	}
	return Plugin_Continue;
}

/*********************************
	Adding commands to adminmenu
*********************************/

public void OnAdminMenuReady(Handle topmenu)
{
	if (topmenu == null) 
	{
		LogError("Unable to add commands to admin menu. invalid handle.");
		return;
	}
	
	// Add new category to admin menu
	TopMenuObject SoundMenuOpt = AddToTopMenu(topmenu, "sm_sound_menu_cat", TopMenuObject_Category, Category_Handler, INVALID_TOPMENUOBJECT);
	
	AddToTopMenu(topmenu, "sm_menuplaysound", TopMenuObject_Item, AdminMenu_PlaySound, SoundMenuOpt, "sm_menuplaysound", ADMFLAG_ROOT); // Play
	AddToTopMenu(topmenu, "sm_menusavesound", TopMenuObject_Item, AdminMenu_SaveSound, SoundMenuOpt, "sm_menusavesound", ADMFLAG_ROOT); // Save sound
	AddToTopMenu(topmenu, "sm_menuwipesound", TopMenuObject_Item, AdminMenu_WipeSound, SoundMenuOpt, "sm_menuwipesound", ADMFLAG_ROOT); // Save sound
	AddToTopMenu(topmenu, "sm_earrapesound", TopMenuObject_Item, AdminMenu_EnableEarrape, SoundMenuOpt, "sm_earrapesound", ADMFLAG_ROOT);	// Enable earrape mode
}

public void Category_Handler(Handle topmenu, TopMenuAction action, TopMenuObject object_id, int param, char[] buffer, int maxlength)
{
	if(action == TopMenuAction_DisplayTitle)
	{
		Format(buffer, maxlength, "Play Sound Files");
	}
	else if(action == TopMenuAction_DisplayOption)
	{
		Format(buffer, maxlength, "Play Sound Files");
	}
}

public void AdminMenu_PlaySound(Handle topmenu, TopMenuAction action, TopMenuObject object_id, int param, char[] buffer, int maxlength)
{
	if (action == TopMenuAction_DisplayOption)
	{
		Format(buffer, maxlength, "Choose File");
	}
	else if (action == TopMenuAction_SelectOption)
	{
		BuildFilesMenu(param);
	}
}

public void AdminMenu_WipeSound(Handle topmenu, TopMenuAction action, TopMenuObject object_id, int param, char[] buffer, int maxlength)
{
	if (action == TopMenuAction_DisplayOption)
	{
		Format(buffer, maxlength, "Clear Sounds File List (wipes all saved)");
	}
	else if (action == TopMenuAction_SelectOption)
	{
		WipeSoundsList(param);
	}
}

public void AdminMenu_SaveSound(Handle topmenu, TopMenuAction action, TopMenuObject object_id, int param, char[] buffer, int maxlength)
{
	if (action == TopMenuAction_DisplayOption)
	{
		Format(buffer, maxlength, "Save Sound File Path");
	}
	else if (action == TopMenuAction_SelectOption)
	{
		BeginSaveSoundPath(param);
	}
}

public void AdminMenu_EnableEarrape(Handle topmenu, TopMenuAction action, TopMenuObject object_id, int param, char[] buffer, int maxlength)
{
	if (action == TopMenuAction_DisplayOption)
	{
		Format(buffer, maxlength, "Enable Ear Rape Mode (currently: %s)", g_bIsEarrapeOn ? "enabled" : "disabled");
	}
	else if (action == TopMenuAction_SelectOption)
	{
		if (!g_bIsEarrapeOn) {
			g_bIsEarrapeOn = true;
		}
		else {
			g_bIsEarrapeOn = false;
		}
		
	}
}

void WipeSoundsList(int client)
{
	char sPath[PLATFORM_MAX_PATH];
	BuildPath(Path_SM, sPath, sizeof(sPath), "data/SoundsMenuSounds.txt");
	
	if (!FileExists(sPath)) {
		LogError("Error 'data/SoundsMenuSounds.txt' file not found...");
		return;
	}
	
	File file = OpenFile(sPath, "w");
	if (file == null) {
		LogError("Couldnt open file for writing");
		return;
	}
	PrintToChat(client, "\x01Cleared Sound File list file.");
	delete file;
}

void SaveSoundPath(char[] sSoundPath)
{
	char sPath[PLATFORM_MAX_PATH];
	BuildPath(Path_SM, sPath, sizeof(sPath), "data/SoundsMenuSounds.txt");
	
	if (!FileExists(sPath)) {
		LogError("Error 'data/SoundsMenuSounds.txt' file not found...");
		return;
	}
	
	File file = OpenFile(sPath, "a");
	if (file == null) {
		LogError("Couldnt open file for writing");
		return;
	}
	
	//file.WriteLine("");
	file.WriteLine(sSoundPath);
	delete file;
}

void BeginSaveSoundPath(int client)
{
	PrintToChat(client, "\x01Type in a full sound file path \x05excluding\x01 the 'sound' part. Example:\n ambient/explosions/explode_1.wav");
	g_bListenSave[client] = true;
}

void BuildFilesMenu(int client)
{
	if (!client)
		return;
	
	Menu menu = new Menu(MenuHandler_PlaySound);
	menu.SetTitle("Select File:");
	menu.ExitBackButton = false;
	
	char sPath[PLATFORM_MAX_PATH];
	BuildPath(Path_SM, sPath, sizeof(sPath), "data/SoundsMenuSounds.txt");
	
	if (!FileExists(sPath)) {
		LogError("Error 'data/SoundsMenuSounds.txt' file not found...");
		return;
	}
	
	char sFile[PLATFORM_MAX_PATH];
	File file = OpenFile(sPath, "r");
	while (file.ReadLine(sFile, sizeof(sFile))) {
		TrimString(sFile);
		StripQuotes(sFile);
		
		menu.AddItem(sFile, sFile);
		
		if (file.EndOfFile()) {
			break;
		}
	}
	
	delete file;
	menu.Display(client, MENU_TIME_FOREVER);
}

public int MenuHandler_PlaySound(Handle menu, MenuAction action, int param1, int param2)
{
	switch (action)
	{
		case MenuAction_Select:
		{
			char sFile[PLATFORM_MAX_PATH];
			GetMenuItem(menu, param2, sFile, sizeof(sFile));
			
			PrintToConsole(param1, "File played was >> %s", sFile);
			PlaySound(sFile);
			
			// Re-draw
			BuildFilesMenu(param1);
		}
		case MenuAction_End:
		{
			delete menu;
		}
	}
}

void PlaySound(const char[] sPath)
{
	PrecacheSound(sPath);
	int entity = SOUND_FROM_PLAYER;
	
	if (g_bIsEarrapeOn) 
	{
		int loopc = GetConVarInt(g_hSoundLoopTimes);
		for (int i = 0; i < loopc; i++) 
		{
			int r = GetRandomInt(0, 2);
			switch (r) 
			{
				case 0:
				{
					EmitSoundToAll(sPath, entity, SNDCHAN_AUTO);
				}
				case 1:
				{
					EmitSoundToAll(sPath, entity, SNDCHAN_STATIC);
				}
				case 2:
				{
					EmitSoundToAll(sPath, entity, SNDCHAN_WEAPON);
				}
			}
		}
	}
	else
	{
		EmitSoundToAll(sPath, entity);
	}
}