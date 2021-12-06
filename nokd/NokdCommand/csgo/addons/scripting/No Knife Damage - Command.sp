#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <multicolors>
#include <autoexecconfig>
#include <adminmenu>

#define DEBUG

#pragma semicolon 1

#pragma newdecls required

char g_ChatPrefix[256];
ConVar gConVar_Chat_Prefix;

ConVar gConVar_KnifeOn_Message;
ConVar gConVar_KnifeOff_Message;

bool KnifeDamage = true;

//ADMIN MENU

Handle hAdminMenu;

public Plugin myinfo = 
{
	name = "No Knife Damage - Command", 
	author = "LanteJoula", 
	description = "No Knife Damage - Command", 
	version = "1.3", 
	url = "https://steamcommunity.com/id/lantejoula/"
};

public void OnPluginStart()
{
	//Translations
	LoadTranslations("noknifedamage-command.phrases");
	
	//ConVars
	AutoExecConfig_SetFile("plugin.noknifedamage-command");
	
	gConVar_Chat_Prefix = AutoExecConfig_CreateConVar("sm_noknifedamage_chat_prefix", "[{green}TAG{default}]", "Chat Prefix");
	
	gConVar_KnifeOn_Message = AutoExecConfig_CreateConVar("sm_noknifedamage_knifeon_message", "1", "Enable/Disable the Message when Staff Enable Knife Damage (1 - Enable | 0 - Disable)", 0, true, 0.0, true, 1.0);
	gConVar_KnifeOff_Message = AutoExecConfig_CreateConVar("sm_noknifedamage_knifeoff_message", "1", "Enable/Disable the Message when Staff Disable Knife Damage (1 - Enable | 0 - Disable)", 0, true, 0.0, true, 1.0);
	
	
	AutoExecConfig_ExecuteFile();
	AutoExecConfig_CleanFile();
	
	gConVar_Chat_Prefix.AddChangeHook(OnPrefixChange);
	
	
	for (int client = 1; client <= MaxClients; client++)
	{
		if (IsClientInGame(client))
		{
			SDKHook(client, SDKHook_OnTakeDamage, TakeDamageHook);
		}
	}
	
	RegAdminCmd("sm_knifedamage", KnifeDamageMenu, ADMFLAG_GENERIC);
	RegAdminCmd("sm_kd", KnifeDamageMenu, ADMFLAG_GENERIC);
	
	KnifeDamage = true;
}

//Prefix

public void SavePrefix()
{
	GetConVarString(gConVar_Chat_Prefix, g_ChatPrefix, sizeof(g_ChatPrefix));
}

public void OnConfigsExecuted()
{
	SavePrefix();
}

public void OnPrefixChange(ConVar cvar, char[] oldvalue, char[] newvalue)
{
	SavePrefix();
}

//PLUGIN

public void OnClientPutInServer(int client)
{
	SDKHook(client, SDKHook_OnTakeDamage, TakeDamageHook);
}

public Action TakeDamageHook(int client, int &attacker, int &inflictor, float &damage, int &damagetype)
{
	if (!KnifeDamage)
	{
		if ((client >= 1) && (client <= MaxClients) && (attacker >= 1) && (attacker <= MaxClients) && (attacker == inflictor))
		{
			char WeaponName[64];
			GetClientWeapon(attacker, WeaponName, sizeof(WeaponName));
			
			if (StrContains(WeaponName, "weapon_knife") != -1 || StrEqual(WeaponName, "weapon_bayonet") || StrEqual(WeaponName, "weapon_melee") || StrEqual(WeaponName, "weapon_axe") || StrEqual(WeaponName, "weapon_hammer") || StrEqual(WeaponName, "weapon_spanner") || StrEqual(WeaponName, "weapon_fists"))
			{
				damage = 0.0;
				return Plugin_Changed;
			}
		}
	}
	return Plugin_Continue;
}

//Menu

public Action KnifeDamageMenu(int client, int args)
{
	ShowMenuKnifeDamage(client);
}

void ShowMenuKnifeDamage(int client)
{
	char KnifeOffMenu1[128];
	char KnifeOnMenu1[128];
	
	Menu menu = new Menu(Menu_Handler);
	menu.SetTitle("%t\n ", "KnifeDamageMenuTitle");
	
	if (KnifeDamage)
	{
		Format(KnifeOffMenu1, sizeof(KnifeOffMenu1), "%t", "KnifeOffMenu");
		menu.AddItem("1", KnifeOffMenu1);
	}
	else
	{
		Format(KnifeOnMenu1, sizeof(KnifeOnMenu1), "%t", "KnifeOnMenu");
		menu.AddItem("2", KnifeOnMenu1);
	}
	
	menu.ExitButton = true;
	menu.Display(client, MENU_TIME_FOREVER);
}

public int Menu_Handler(Menu menu, MenuAction action, int client, int args)
{
	if (action == MenuAction_Select)
	{
		char selectedItem[200];
		menu.GetItem(args, selectedItem, sizeof(selectedItem));
		if (StrEqual(selectedItem, "1"))
		{
			KnifeDamage = false;
			
			if (gConVar_KnifeOff_Message.BoolValue)
				CPrintToChatAll("%s %t", g_ChatPrefix, "KnifeOff");
		}
		if (StrEqual(selectedItem, "2"))
		{
			KnifeDamage = true;
			
			if (gConVar_KnifeOn_Message.BoolValue)
				CPrintToChatAll("%s %t", g_ChatPrefix, "KnifeOn");
		}
	}
	else if (action == MenuAction_End)
	{
		delete menu;
	}
}

//ADMIN DEAGLE - ADMIN MENU

public void OnAllPluginsLoaded()
{
	Handle topmenu;
	if (LibraryExists("adminmenu") && ((topmenu = GetAdminTopMenu()) != null))
		OnAdminMenuReady(topmenu);
}

public void OnAdminMenuReady(Handle topmenu)
{
	if (topmenu == hAdminMenu)
		return;
	
	hAdminMenu = topmenu;
	CreateTimer(1.0, Timer_AttachAdminMenu);
}

public Action Timer_AttachAdminMenu(Handle timer)
{
	TopMenuObject menu_category = AddToTopMenu(hAdminMenu, "knifedamage", TopMenuObject_Category, Handle_Category, INVALID_TOPMENUOBJECT, "knifedamage", ADMFLAG_GENERIC);
	if (menu_category == INVALID_TOPMENUOBJECT)
		return;
	
	AddToTopMenu(hAdminMenu, "sm_knifedamage", TopMenuObject_Item, AdminMenu_NoKnifeDamage, menu_category, "sm_knifedamage", ADMFLAG_GENERIC);
}

public void Handle_Category(TopMenu topmenu, TopMenuAction action, TopMenuObject topobj_id, int param, char[] buffer, int maxlength)
{
	if (action == TopMenuAction_DisplayTitle)
		Format(buffer, maxlength, "%T", "Knife Damage Title in Admin", param);
	else if (action == TopMenuAction_DisplayOption)
		Format(buffer, maxlength, "%T", "Knife Damage Title in Admin", param);
}

public void AdminMenu_NoKnifeDamage(TopMenu topmenu, TopMenuAction action, TopMenuObject topobj_id, int client, char[] buffer, int maxlength)
{
	if (action == TopMenuAction_DisplayOption)
		Format(buffer, maxlength, "%T", "Knife Damage Buttom in Admin", client);
	else if (action == TopMenuAction_SelectOption)
		ShowMenuKnifeDamage(client);
} 