/*
--
Information
--
Dream SAMP Gamemode - Private Server
Version 0.1
--
Thanks :
--
DEntisT : https://github.com/DEntis-T/OMP-DETUtils

--
For Help :
--
DEntisT - Login and Register System
--
*/

// Predefines:

#define DETUTILS_NO_DIALOG
#define DETUTILS_NO_ANTICHEAT
#define DETUTILS_NO_MODULE_WARNINGS
#define DETUTILS_NO_MAPEDITOR
#define DETUTILS_NO_VISUAL
#define DETUTILS_NO_PROPERTIES
#define DETUTILS_NO_TEAMS
#define DETUTILS_NO_ANDROID_CHECK
#define DETUTILS_NO_DMZONE
#define DETUTILS_NO_VARS

// Colors:

#define c_red  "{ff1100}"
#define c_blue "{ff1100}"
#define c_white "{ffffff}"
#define c_yellow "{f2ff00}"
#define c_green "{f2ff00}"
#define c_pink "{ff00bb}"
#define c_ltblue "{00f2ff}"
#define c_orange "{ffa200}"

#define  col_red 0xff1100AA
#define  col_blue 0xff1100AA
#define  col_white 0xffffffAA
#define  col_yellow 0xf2ff00AA
#define  col_green 0xf2ff00AA
#define  col_pink 0xff00bbAA
#define  col_ltblue 0x00f2ffAA
#define  col_orange 0xffa200AA

// Includes:

#include <a_samp>
#include <DETUTILS\d_samp>

// Code:

main(){}

stock ReturnPlayerName(p)
{
	new name[MAX_PLAYER_NAME];
	GetPlayerName(p, name, sizeof name);
	return name;
}

enum
{
    DIALOG_LOGIN,
    DIALOG_REGISTER,
    DIALOG_GENDER,
    DIALOG_SKIN
}

enum PlayerData
{
    password[64],
    money,
    staff,
    gender,
    skin,
    level
}

new PlayerCache[MAX_PLAYERS][PlayerData];

public OnGameModeInit()
{
	SetGameModeText("Dream v0.1");
	return 1;
}

public OnGameModeExit()
{
	return 1;
}

public OnPlayerConnect(playerid)
{
    new LoadQuery[32], SaveQuery[32], file[32];
    format(LoadQuery, 32, "%s_LOAD", ReturnPlayerName(playerid));
    format(SaveQuery, 32, "%s_SAVE", ReturnPlayerName(playerid));
    format(file, 32, "%s.ini", ReturnPlayerName(playerid));
    CreateQuery(SaveQuery, QUERY_TYPE_SAVE, "Users", file); // Create a query which will save cache
    CreateQuery(LoadQuery, QUERY_TYPE_LOAD, "Users", file); // Create a query which will load data
    FormatQuery(LoadQuery, "LOAD *"); // format the file query

    if(QueryFileExist(SaveQuery)) // Check if the query file exists.... (Users/DEntisT.ini)
    {
        new content[1024]; // var in which the content will be stored
        
        SendQuery(LoadQuery); // send it
        GetLoadedQueryContent(LoadQuery, content); // After the LOAD query was sent, we need to get the content of the data.

        new array[6][64]; // declare this array for PARSING
        ParseQueryContent(content, array); // Parse the content
        strmid(PlayerCache[playerid][password], array[0], 0, strlen(array[0])); // Get the password
        PlayerCache[playerid][money] = strval(array[1]);
        PlayerCache[playerid][staff] = strval(array[2]);
		PlayerCache[playerid][gender] = strval(array[3]);
		PlayerCache[playerid][skin] = strval(array[4]);
		PlayerCache[playerid][level] = strval(array[5]);
        ShowPlayerDialog(playerid, DIALOG_LOGIN, DIALOG_STYLE_INPUT,
            "Login", "Molimo Vas da se ulogujete! Lozinka:", "OK","Odustani"); // Show the login dialog
    }
    else if(!QueryFileExist(SaveQuery)) // If the player is not registered.
    {
        ShowPlayerDialog(playerid, DIALOG_REGISTER, DIALOG_STYLE_INPUT,
            "Registracija", "Dobrodosli - Unesite zeljenu lozinku:", "OK","Odustani"); // show the register dialog
    }
    return 1;
}

public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
    new SaveQuery[32];
    format(SaveQuery, 32, "%s_SAVE", ReturnPlayerName(playerid));
    if(dialogid == DIALOG_LOGIN) // Check if it is login dialog
    {
        if(!response) return Kick(playerid); // If ESC pressed, kick
        if(response) // else
        {
            if(!strcmp(PlayerCache[playerid][password], inputtext)) // check if the player input the correct password
            {
            	SetSpawnInfo(playerid, PlayerCache[playerid][skin], 26, 405.7272,-1540.2748,32.2734,223.2633,0, 0, 0, 0, 0, 0);
                SpawnPlayer(playerid); // Spawn the player
            }
            else Kick(playerid); // if the password is wrong, kick
        }
    }
    if(dialogid == DIALOG_REGISTER) // Check if it is register dialog
    {
        if(!response) return Kick(playerid); // If ESC pressed, kick
        if(response) // else
        {
            strmid(PlayerCache[playerid][password], inputtext, 0, 64); // Store the provided password
            new query[1024]; // Declare the string
            PlayerCache[playerid][money] = 1000; // Give starter money
            PlayerCache[playerid][staff] = 0; // Set staff value to 0
            format(query, 1024, "SAVE * %s,%i,%i,%i,%i,%i",
                PlayerCache[playerid][password],
                PlayerCache[playerid][money],
                PlayerCache[playerid][staff],
				PlayerCache[playerid][gender],
				PlayerCache[playerid][skin],
				PlayerCache[playerid][level]); // Format the file query
            FormatQuery(SaveQuery, query); // Apply the format
            SendQuery(SaveQuery); // Send the query we formatted
            SpawnPlayer(playerid); // Spawn the player
            SendClientMessage(playerid, -1, "Lozinka je sacuvana. Nastavite sa registracijom.");
            ShowPlayerDialog(playerid, DIALOG_GENDER, DIALOG_STYLE_LIST,
			"Odaberi spol",
			"Musko\nZensko",
			"OK", "Odustani");
        }
    }
    if(dialogid == DIALOG_GENDER)
	{
	    if(!response) return ShowPlayerDialog(playerid, DIALOG_GENDER, DIALOG_STYLE_LIST,
			"Odaberi spol",
			"Musko\nZensko",
			"OK", "Odustani");
	    if(response)
	    {
			switch(listitem)
			{
			    case 0:
			    {
			        PlayerCache[playerid][gender] = 0;
			        SendClientMessage(playerid, -1, "U redu, vi ste musko.");
				}
				case 1:
				{
				    PlayerCache[playerid][gender] = 1;
				    SendClientMessage(playerid, -1, "U redu, vi ste zensko.");
				}
			}
			ShowPlayerDialog(playerid, DIALOG_SKIN, DIALOG_STYLE_INPUT,
			"Odaberi skin",
			"U prazan prostor upisite ID skina koji zelite.",
			"OK", "Odustani");
		}
	}	if(dialogid == DIALOG_SKIN)
	{
	    if(!response) return ShowPlayerDialog(playerid, DIALOG_SKIN, DIALOG_STYLE_INPUT,
			"Odaberte id skina od 1 do 311",
			"Error: Morate odabrati ID.\nU prazan prostor upisite ID skina koji zelite.",
			"OK", "Odustani");
	    if(response)
	    {
	        new parameters[128], idx;

			new id;

			parameters = strtok(inputtext, idx);

			if(strlen(parameters) == 0) return ShowPlayerDialog(playerid, DIALOG_SKIN, DIALOG_STYLE_INPUT,
			"Odaberi skin",
			"Error: Invalid ID.\nU prazan prostor upisite ID skina koji zelite.",
			"OK", "Odustani");

			id = strval(parameters);
			
			if(id < 0 || id > 311) return ShowPlayerDialog(playerid, DIALOG_SKIN, DIALOG_STYLE_INPUT,
			"Odaberi skin",
			"Error: Invalid ID.\nU prazan prostor upisite ID skina koji zelite.",
			"OK", "Odustani");
			
			PlayerCache[playerid][skin] = id;
			
			SetPlayerSkin(playerid, id);
			SendClientMessage(playerid, -1, "Uspesno ste prosli sve korake registracije, dobrodosli na server.");
			SetSpawnInfo(playerid, 0, PlayerCache[playerid][skin], 405.7272,-1540.2748,32.2734,223.2633,0, 0, 0, 0, 0, 0);
			SpawnPlayer(playerid);
		}
	}
    return 1;
}

public OnPlayerDeath(playerid, killerid, reason)
{
	return 1;
}

public OnPlayerDisconnect(playerid, reason)
{
    new SaveQuery[32];
    format(SaveQuery, 32, "%s_SAVE", ReturnPlayerName(playerid));
    new LoadQuery[32];
    format(SaveQuery, 32, "%s_LOAD", ReturnPlayerName(playerid));

    new query[1024];
    format(query, 1024, "SAVE * %s,%i,%i,%i,%i,%i",
                PlayerCache[playerid][password],
                PlayerCache[playerid][money],
                PlayerCache[playerid][staff],
				PlayerCache[playerid][gender],
				PlayerCache[playerid][skin],
				PlayerCache[playerid][level]);
    FormatQuery(SaveQuery, query);
    SendQuery(SaveQuery);
    DestroyQuery(SaveQuery);
    DestroyQuery(LoadQuery);
    return 1;
}

@command(.type = SLASH_COMMAND) setskin(playerid, params[])
{
	new parameters[128], idx;

	new id;

	parameters = strtok(params, idx);

	if(strlen(parameters) == 0) return SendClientMessage(playerid, -1, "Use: /setskin <id>");

	id = strval(parameters);

	SetPlayerSkin(playerid, id);
	PlayerCache[playerid][skin] = id;
	return 1;
}

@command(.type = SLASH_COMMAND) stats(playerid, params[])
{
	new playerstats[1024];
	format(playerstats, sizeof playerstats, "Vasa statistika:\n\nLozinka : %s\nNovac : %i\nStaff Nivo : %i\nSpol : %s\nSkin : %i\nLevel : %i",
	PlayerCache[playerid][password],
	PlayerCache[playerid][money],
	PlayerCache[playerid][staff],
	PlayerCache[playerid][gender] ? "Zensko" : "Musko",
	PlayerCache[playerid][skin],
	PlayerCache[playerid][level]);
	return 1;
}

