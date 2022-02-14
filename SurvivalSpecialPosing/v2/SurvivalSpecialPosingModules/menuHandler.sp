/***********************************
	SI Model Menu system
************************************/

void DrawMainMenu(int client)
{
	// since redrawing menu
	if (!client || g_bRoundInProgress)
		return;
	
	Menu menu = new Menu(MainMenu_Callback);
	
	menu.SetTitle("SI Model Menu");

	menu.AddItem("load pose", "load pose");
	menu.AddItem("End round pose & slay", "End round pose & slay");
	menu.AddItem("create new pose", "create new pose");
	menu.AddItem("delete a pose", "delete a pose");
	menu.AddItem("Spawn SI Models", "Spawn SI Models");
	menu.AddItem("clear SI models", "clear SI models");

	menu.Display(client, MENU_TIME_FOREVER);
	menu.ExitButton = false;
}

public int MainMenu_Callback(Menu menu, MenuAction action, int param1, int param2)
{
	switch(action)
	{
		case MenuAction_Select:
		{
			char sItem[64];
			menu.GetItem(param2, sItem, sizeof(sItem));
			
			if(StrEqual(sItem, "load pose"))
			{
				g_bSlaySurvivors = false;
				LoadPoseMenu(param1);
			}
			// probably could combine this into last if statement. Just a quick edit for now
			else if(StrEqual(sItem, "End round pose & slay"))
			{
				g_bSlaySurvivors = true;
				LoadPoseMenu(param1);
			}
			else if (StrEqual(sItem, "create new pose"))
			{
				if (g_iConfigID != 0)
				{
					// Camera needs to be created
					if (!kv_IsCameraCreated(param1, g_iConfigID))
					{
						PrintToChat(param1, "[SM] need to create camera in current config first before making a new one.");
						DrawMainMenu(param1);
					}
					// at least x SI need to be saved in current config
					else if (g_hArray_SIIndexes.Length < MIN_SI_REQ)
					{
						PrintToChat(param1, "\x01[SM] Need at least \x04%i\x01 SI saved in current config (#\x04%i\x01) to create a new one.", MIN_SI_REQ, g_iConfigID);
						DrawMainMenu(param1);
					}
					else
					{
						DespawnSIProps();
						int Section = iStartNewSection();
						g_iConfigID = Section;

						PrintToChat(param1, "\x01[SM] Section \x04%i\x01 created. Any SI spawned will be saved under this section.", g_iConfigID);
						DrawSISpawnerMenu(param1);
					}
				}
				else
				{
					DespawnSIProps();
					int Section = iStartNewSection();
					g_iConfigID = Section;

					PrintToChat(param1, "\x01[SM] Section \x04%i\x01 created. Any SI spawned will be saved under this section.", g_iConfigID);
					DrawSISpawnerMenu(param1);
				}
			}

			else if(StrEqual(sItem, "delete a pose"))
			{
				LoadDeleteMenu(param1);
			}

			else if(StrEqual(sItem, "Spawn SI Models"))
			{
				if (g_iConfigID <= 0)
				{
					PrintToChat(param1, "[SM] You need to load a config or create new one first.");
					DrawMainMenu(param1);
				}
				else
				{
					DrawSISpawnerMenu(param1);
				}
				
			}

			else if(StrEqual(sItem, "clear SI models"))
			{
				DespawnSIProps();
				PrintToChat(param1, "[SM] SI models cleared. No config currently selected.");
				g_iConfigID = g_iDeletionID = 0;

				DrawMainMenu(param1);

			}
		}
		
		case MenuAction_End:
		{
			delete menu;
		}
	}
}

void DrawSISpawnerMenu(int client)
{
	Menu menu = new Menu(spawner_CallBack);
	
	menu.SetTitle("SI Model Spawner");
	menu.AddItem("boomer", "Boomer");
	menu.AddItem("boomette", "Boomette");
	menu.AddItem("hunter", "Hunter");
	menu.AddItem("jockey", "Jockey");
	menu.AddItem("charger", "Charger");
	menu.AddItem("spitter", "Spitter");
	menu.AddItem("smoker", "Smoker");
	menu.AddItem("tank", "Tank");
	menu.AddItem("camera", "camera");

	menu.Display(client, MENU_TIME_FOREVER);
	menu.ExitButton = false;
}

public int spawner_CallBack(Menu menu, MenuAction action, int param1, int param2)
{
	switch(action)
	{
		case MenuAction_Select:
		{
			char sItem[42];
			menu.GetItem(param2, sItem, sizeof(sItem));
			
			if( StrEqual(sItem, "boomer") )
			{
				SpawnInitSIModel(param1, "models/infected/boomer.mdl");
				DrawSISpawnerMenu(param1);
			}
			else if(StrEqual(sItem, "boomette"))
			{
				SpawnInitSIModel(param1, "models/infected/boomette.mdl");
				DrawSISpawnerMenu(param1);
			}
			else if(StrEqual(sItem, "hunter"))
			{
				SpawnInitSIModel(param1, "models/infected/hunter.mdl");
				DrawSISpawnerMenu(param1);
			}
			else if(StrEqual(sItem, "jockey"))
			{
				SpawnInitSIModel(param1, "models/infected/jockey.mdl");
				DrawSISpawnerMenu(param1);
			}
			else if(StrEqual(sItem, "charger"))
			{
				SpawnInitSIModel(param1, "models/infected/charger.mdl");
				DrawSISpawnerMenu(param1);
			}
			else if(StrEqual(sItem, "spitter"))
			{
				SpawnInitSIModel(param1, "models/infected/spitter.mdl");
				DrawSISpawnerMenu(param1);
			}
			else if(StrEqual(sItem, "smoker"))
			{
				SpawnInitSIModel(param1, "models/infected/smoker.mdl");
				DrawSISpawnerMenu(param1);
			}
			else if(StrEqual(sItem, "tank"))
			{
				SpawnInitSIModel(param1, "models/infected/hulk.mdl");
				DrawSISpawnerMenu(param1);
			}
			else if(StrEqual(sItem, "camera"))
			{
				float pos[3], ang[3];
				GetClientAbsOrigin(param1, pos);
				GetClientAbsAngles(param1, ang);

				if (bSaveCamera(param1, pos, ang))
				{
					PrintToChat(param1, "[SM] Camera placed at %f %f %f", pos[0], pos[1], pos[2]);
				}

				DrawSISpawnerMenu(param1);
			}
		}
		
		case MenuAction_End:
		{
			delete menu;
		}
	}
}

void LoadPoseMenu(int client)
{
	if (client < 1 || !IsClientInGame(client)) return;

	int iMenuItems = GetNumOfPoseConfigs();
	if (iMenuItems == -1)
	{
		PrintToChat(client, "[SM] No configs found for this map.");
		DrawMainMenu(client);
		return;
	}

	Menu menu = new Menu(LoadPose_MenuCallBack);
	menu.SetTitle("Load a config");

	char sName[8];
	for (int i = 1; i <= iMenuItems; i++)
	{
		Format(sName, sizeof(sName), "%i", i);
		menu.AddItem(sName, sName);
	}
	menu.Display(client, MENU_TIME_FOREVER);
	menu.ExitButton = false;
}

public int LoadPose_MenuCallBack(Menu menu, MenuAction action, int param1, int param2)
{
	switch(action)
	{
		case MenuAction_Select:
		{
			// despawn existing pose first
			DespawnSIProps();

			char sItem[8];
			menu.GetItem(param2, sItem, sizeof(sItem));
			int iConfig = StringToInt(sItem);

			if (g_bSlaySurvivors)
			{
				slaysurvivors();
				bLoadCfgFile(iConfig, false, true);
				g_bSlaySurvivors = false;
			}
			else
			{
				if (bLoadCfgFile(iConfig))
				{
					g_iConfigID = iConfig;
					PrintToChat(param1, "\x01[SM] Config \x04%i\x01 loaded successfully. Any SI spawned will be saved under this config.", g_iConfigID);
					LoadPoseMenu(param1);
				}
			}
			
		}

		case MenuAction_End:
		{
			delete menu;
		}
	}
}

void LoadDeleteMenu(int client)
{
	if (client < 1 || !IsClientInGame(client)) return;

	int iMenuItems = GetNumOfPoseConfigs();
	if (iMenuItems == -1)
	{
		PrintToChat(client, "[SM] No configs found for this map.");
		DrawMainMenu(client);
		return;
	}

	//PrintToChat(client, "[SM] After selection, config will get loaded to confirm deletion.");

	Menu menu = new Menu(DeletePose_MenuCallBack);
	menu.SetTitle("Delete a config");

	char sName[8];
	for (int i = 1; i <= iMenuItems; i++)
	{
		Format(sName, sizeof(sName), "%i", i);
		menu.AddItem(sName, sName);
	}
	menu.Display(client, MENU_TIME_FOREVER);
	menu.ExitButton = false;
}

public int DeletePose_MenuCallBack(Menu menu, MenuAction action, int param1, int param2)
{
	switch(action)
	{
		case MenuAction_Select:
		{
			char sItem[8];
			menu.GetItem(param2, sItem, sizeof(sItem));
			int iConfig = StringToInt(sItem);
			g_iDeletionID = iConfig;

			DespawnSIProps();
			bLoadCfgFile(iConfig);
			LoadDeleteConfirmationMenu(param1);
		}

		case MenuAction_End:
		{
			delete menu;
		}
	}
}

void LoadDeleteConfirmationMenu(int client)
{
	if (client < 1 || !IsClientInGame(client)) return;

	Menu menu = new Menu(DeleteConfirmation_MenuCallBack);

	char sTitle[32];
	Format(sTitle, sizeof(sTitle), "Delete this config (#%i)?", g_iDeletionID);
	menu.SetTitle("Delete this config?");

	menu.AddItem("yes", "yes");
	menu.AddItem("no", "no");

	menu.Display(client, MENU_TIME_FOREVER);
	menu.ExitButton = false;
}

public int DeleteConfirmation_MenuCallBack(Menu menu, MenuAction action, int param1, int param2)
{
	switch(action)
	{

		case MenuAction_Select:
		{
			DespawnSIProps();

			char sItem[8];
			menu.GetItem(param2, sItem, sizeof(sItem));
			if (StrEqual(sItem, "yes"))
			{
				if (g_iDeletionID > 0 && bDeleteSavedConfig(param1, g_iDeletionID))
				{
					PrintToChat(param1, "\x01[SM] config \x04%i\x01 deleted successfully.", g_iDeletionID);
					g_iConfigID = 0; // reset this incase config is empty for this map after deletion
				}
			}
			LoadDeleteMenu(param1);
		}

		case MenuAction_End:
		{
			delete menu;
		}
	}
}