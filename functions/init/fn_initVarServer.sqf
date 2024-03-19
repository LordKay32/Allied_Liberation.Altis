/*
 * This file is called after initVarCommon.sqf, on the server only.
 *
 * We also initialise anything in here that we don't want a client that's joining to overwrite, as JIP happens before initVar.
 */
scriptName "initVarServer.sqf";
private _fileName = "initVarServer.sqf";
[2,"initVarServer started",_fileName] call A3A_fnc_log;


//Little bit meta.
serverInitialisedVariables = ["serverInitialisedVariables"];

private _declareServerVariable = {
	params ["_varName", "_varValue"];

	serverInitialisedVariables pushBackUnique _varName;

	if (!isNil "_varValue") then {
		missionNamespace setVariable [_varName, _varValue];
	};
};

//Declares a variable that will be synchronised to all clients at the end of initVarServer.
//Only needs using on the first declaration.
#define ONLY_DECLARE_SERVER_VAR(name) [#name] call _declareServerVariable
#define DECLARE_SERVER_VAR(name, value) [#name, value] call _declareServerVariable
#define ONLY_DECLARE_SERVER_VAR_FROM_VARIABLE(name) [name] call _declareServerVariable
#define DECLARE_SERVER_VAR_FROM_VARIABLE(name, value) [name, value] call _declareServerVariable

////////////////////////////////////////
//     GENERAL SERVER VARIABLES      ///
////////////////////////////////////////
[2,"initialising general server variables",_fileName] call A3A_fnc_log;

//time to delete dead bodies, vehicles etc..
DECLARE_SERVER_VAR(cleantime, 3600);
//initial spawn distance. Less than 1Km makes parked vehicles spawn in your nose while you approach.
//User-adjustable variables are now declared in initParams
//DECLARE_SERVER_VAR(distanceSPWN, 1000);
DECLARE_SERVER_VAR(distanceSPWN1, distanceSPWN*1.3);
DECLARE_SERVER_VAR(distanceSPWN2, distanceSPWN*0.5);
//The furthest distance the AI can attack from using helicopters or planes
DECLARE_SERVER_VAR(distanceForAirAttack, 16000);
//The furthest distance the AI can attack from using trucks and armour
DECLARE_SERVER_VAR(distanceForLandAttack, 6000);

//Disabled DLC according to server parameters
DECLARE_SERVER_VAR(disabledMods, call A3A_fnc_initDisabledMods);

//Legacy tool for scaling AI difficulty. Could use a rewrite.
DECLARE_SERVER_VAR(difficultyCoef, if !(isMultiplayer) then {0} else {floor ((({side group _x == teamPlayer} count (call A3A_fnc_playableUnits)) - ({side group _x != teamPlayer} count (call A3A_fnc_playableUnits))) / 5)});


//Mostly state variables, used by various parts of Antistasi.
DECLARE_SERVER_VAR(bigAttackInProgress, false);
DECLARE_SERVER_VAR(AAFpatrols,0);
DECLARE_SERVER_VAR(smallCAmrk, []);
DECLARE_SERVER_VAR(smallCApos, []);

DECLARE_SERVER_VAR(attackPos, []);
DECLARE_SERVER_VAR(attackMrk, []);
DECLARE_SERVER_VAR(airstrike, []);

DECLARE_SERVER_VAR(mobilemortarsFIA, []);

//Variables used for the internal support system
DECLARE_SERVER_VAR(occupantsSupports, []);
DECLARE_SERVER_VAR(invadersSupports, []);

DECLARE_SERVER_VAR(supportTargetsChanging, false);

DECLARE_SERVER_VAR(occupantsRadioKeys, 0);
DECLARE_SERVER_VAR(invaderRadioKeys, 0);

//Vehicles currently in the garage
DECLARE_SERVER_VAR(vehInGarage, []);

//Should vegetation around HQ be cleared
DECLARE_SERVER_VAR(chopForest, false);

DECLARE_SERVER_VAR(skillFIA, 1);																		//Initial skill level for FIA soldiers
//Initial Occupant Aggression
DECLARE_SERVER_VAR(aggressionOccupants, 70);
DECLARE_SERVER_VAR(aggressionStackOccupants, []);
DECLARE_SERVER_VAR(aggressionLevelOccupants, 4);
//Initial Invader Aggression
DECLARE_SERVER_VAR(aggressionInvaders, 70);
DECLARE_SERVER_VAR(aggressionStackInvaders, []);
DECLARE_SERVER_VAR(aggressionLevelInvaders, 4);
//Initial war tier.
DECLARE_SERVER_VAR(tierWar, 10);
DECLARE_SERVER_VAR(bombRuns, 1);
DECLARE_SERVER_VAR(supportPoints, 1);
//Should various units, such as patrols and convoys, be revealed.
DECLARE_SERVER_VAR(revealX, false);
//Whether the players have Nightvision unlocked
DECLARE_SERVER_VAR(haveNV, false);
DECLARE_SERVER_VAR(A3A_activeTasks, []);
DECLARE_SERVER_VAR(A3A_taskCount, 0);
//List of statics (MGs, AA, etc) that will be saved and loaded.
DECLARE_SERVER_VAR(staticsToSave, []);
//List of player-placed buildings that will be saved and loaded.
DECLARE_SERVER_VAR(constructionsToSave, []);
//Whether the players have access to radios.
DECLARE_SERVER_VAR(haveRadio, call A3A_fnc_checkRadiosUnlocked);
//List of vehicles that are reported (I.e - Players can't go undercover in them)
DECLARE_SERVER_VAR(reportedVehs, []);
//Whether the players have access to trader.
DECLARE_SERVER_VAR(isTraderQuestCompleted, true);
//Trader position.
DECLARE_SERVER_VAR(traderPosition, []);
//Trader discount.
DECLARE_SERVER_VAR(traderDiscount, 0);
//Latest pursuers spawn time
//Players who attend in parachute jumps
DECLARE_SERVER_VAR(paradropAttendants, []);
//Stores  custom AI rebel loadouts.
DECLARE_SERVER_VAR(rebelLoadouts, createHashMap);
//Override uniforms on rebel loadouts
DECLARE_SERVER_VAR(randomizeRebelLoadoutUniforms, true);

//Check if occupants and invaders are defeated
DECLARE_SERVER_VAR(areOccupantsDefeated, false);
DECLARE_SERVER_VAR(areInvadersDefeated, false);

DECLARE_SERVER_VAR(A3A_coldWarMode, false);

//IntroMission
DECLARE_SERVER_VAR(introFinished, false);
introAttackStarted = false;

//Currently destroyed buildings.
//DECLARE_SERVER_VAR(destroyedBuildings, []);
//Initial HR
//server setVariable ["hr", 8, true];
server setVariable ["UKhr", 50, true];
server setVariable ["SAShr", 10, true];
server setVariable ["UShr", 50, true];
server setVariable ["parahr", 20, true];
server setVariable ["SDKhr", 0, true];
//Initial faction money pool
server setVariable ["resourcesFIA", 10000, true];
//Initial intel points
server setVariable ["intelPoints", 0, true];
// Time of last garbage clean. Note: serverTime may not reset to zero if server was not restarted. Therefore, it should capture the time at start of mission.
DECLARE_SERVER_VAR(A3A_lastGarbageCleanTime, serverTime);

////////////////////////////////////
//     SERVER ONLY VARIABLES     ///
////////////////////////////////////
//We shouldn't need to sync these.
[2,"Setting server only variables",_fileName] call A3A_fnc_log;

prestigeOPFOR = [25, 25] select cadetMode;												//Initial % support for NATO on each city
prestigeBLUFOR = 25;																	//Initial % FIA support on each city
// Indicates time in seconds before next counter attack.
attackCountdownOccupants = 3600;
attackCountdownInvaders = 3600;

cityIsSupportChanging = false;
resourcesIsChanging = false;
savingServer = false;

prestigeIsChanging = false;

zoneCheckInProgress = false;
garrisonIsChanging = false;
movingMarker = false;
markersChanging = [];

playerHasBeenPvP = [];

savedPlayers = [];
destroyedBuildings = [];		// synced only on join, to avoid spam on change

testingTimerIsActive = false;

A3A_tasksData = [];

artilleryList = [true, true, true, true, true, true, true, true, true, true];
publicVariable "artilleryList";
flakList = [true, true, true, true];
publicVariable "flakList";
mineMarkers = ["minefield_1","minefield_2","minefield_3","minefield_4","minefield_5","minefield_6","minefield_7","minefield_8","minefield_9","minefield_10","minefield_11","minefield_12","minefield_13","minefield_14","minefield_15"];
rebelCity = "NONE";
publicVariable "rebelCity";

//
occupantKilled = 0;
publicVariable "occupantKilled";
occupantKilledByPlayers = 0;
publicVariable "occupantKilledByPlayers";
occupantVehKilled = 0;
publicVariable "occupantVehKilled";
occupantVehKilledByPlayers = 0;
publicVariable "occupantVehKilledByPlayers";

playerDeaths = 0;
publicVariable "playerDeaths";
playerDeathsFF = 0;
publicVariable "playerDeathsFF";

teamPlayerDeployed = 0;
publicVariable "teamPlayerDeployed";
teamPlayerStoodDown = 0;
publicVariable "teamPlayerStoodDown";
teamPlayerKilled = 0;
publicVariable "teamPlayerKilled";
teamPlayerKilledFF = 0;
publicVariable "teamPlayerKilledFF";

partizanKilled = 0; 
publicVariable "partizanKilled";
partizanKilledFF = 0; 
publicVariable "partizanKilledFF";

teamPlayerVehDeployed = 0;
publicVariable "teamPlayerVehDeployed";
teamPlayerVehDepot = 0;
publicVariable "teamPlayerVehDepot";
teamPlayerVehKilled = 0;
publicVariable "teamPlayerVehKilled";
teamPlayerVehKilledFF = 0;
publicVariable "teamPlayerVehKilledFF";

civilianKilledByOccupant = 0;
publicVariable "civilianKilledByOccupant";
civilianKilledByteamPlayer = 0;
publicVariable "civilianKilledByteamPlayer";

prisonersCaptured = 0;
publicVariable "prisonersCaptured";
vehiclesCaptured = 0;
publicVariable "vehiclesCaptured";

sectorsLiberated = 0;
publicVariable "sectorsLiberated";
sectorsLost = 0;
publicVariable "sectorsLost";


//

battleshipStarted = false;
publicVariable "battleshipStarted";
battleshipDone = false;
publicVariable "battleshipDone";

WW2Weapons = [
	//Weapons
	["LIB_LeeEnfield_No4", 100],
	["LIB_Bren_Mk2", 25],
	["LIB_Sten_Mk2", 50],
	["LIB_Webley_mk6", 50],
	["LIB_PIAT",10],
	["LIB_LeeEnfield_No4_Scoped",20],
	["LIB_M1_Garand", 100],
	["LIB_M1918A2_BAR", 25],
	["LIB_M1_Carbine", 50],
	["LIB_M1A1_Carbine", 25],
	["LIB_M1A1_Thompson", 50],
	["LIB_Colt_M1911", 80],
	["LIB_M1A1_Bazooka", 20],
	["LIB_M1903A4_Springfield", 25],
	["LIB_M3_GreaseGun", 40],
	["LIB_M1919A4", 20],
	["LIB_M1919A6", 10],
	["LIB_Welrod_mk1", 10],
	["LIB_FLARE_PISTOL", 50]
];
publicVariable "WW2Weapons";

WW2Magazines = [
	//Ammo
	["LIB_10Rnd_770x56", 12000],
	["LIB_30Rnd_770x56", 6000],
	["LIB_32Rnd_9x19_Sten", 12800],
	["LIB_6Rnd_455", 2400],
	["LIB_1Rnd_89m_PIAT", 40],
	["LIB_8Rnd_762x63", 12000],
	["LIB_20Rnd_762x63", 6000],
	["LIB_15Rnd_762x33", 12000],
	["LIB_30Rnd_45ACP", 12000],
	["LIB_7Rnd_45ACP", 2800],
	["LIB_1Rnd_60mm_M6", 80],
	["LIB_5Rnd_762x63", 1500],
	["LIB_30Rnd_M3_GreaseGun_45ACP", 6000],
	["LIB_50Rnd_762x63", 10000],
	["LIB_30Rnd_770x56_MKVIII", 1800],
	["LIB_20Rnd_762x63_M1", 2400],
	["LIB_MillsBomb", 200],
	["LIB_No77", 25],
	["fow_e_no69", 100],
	["LIB_No82", 80],
	["LIB_US_Mk_2", 200],
	["LIB_US_M18", 250],
	["LIB_US_M18_Green", 50],
	["LIB_US_M18_Yellow", 50],
	["LIB_US_M18_Red", 25],
	["LIB_M3_MINE_mag", 25],
	["LIB_US_M1A1_ATMINE_mag", 25],
	["fow_e_tnt_onepound_mag", 40],
	["fow_e_tnt_twopound_mag", 20],
	["LIB_1Rnd_G_MillsBomb", 150],
	["LIB_1Rnd_G_Mk2", 200],
	["LIB_1Rnd_G_M9A1", 100],
	["LIB_6Rnd_9x19_Welrod", 600],
	["LIB_1Rnd_flare_white", 800]
];
publicVariable "WW2Magazines";

WW2Items = [
	//Items
	["LIB_ACC_GL_Enfield_CUP_Empty", 25],
	["LIB_ACC_GL_M7", 40],
	["MineDetector", 50],
	["fow_i_fak_uk", 200],
	["fow_i_fak_us", 200],
	["Medikit", 50],
	["ToolKit", 50],
	//Backpack
	["B_Carryall_cbr", 50]
];
publicVariable "WW2Items";

WehrmachtUniforms = [
	"U_LIB_GER_Schutze",
	"U_LIB_GER_Oberschutze",
	"U_LIB_GER_MG_schutze",
	"U_LIB_GER_Unterofficer",
	"U_LIB_GER_Soldier_camo2",
	"U_LIB_GER_Medic",
	"U_LIB_GER_Scharfschutze"
];
publicVariable "WehrmachtUniforms";

WehrmachtVests = [
	"V_LIB_GER_VestKar98",
	"V_LIB_GER_VestUnterofficer",
	"V_LIB_GER_VestMG",
	"V_LIB_GER_PioneerVest",
	"V_LIB_GER_SniperBelt"
];
publicVariable "WehrmachtVests";

WehrMachtBackpacks = [
	"B_LIB_GER_SapperBackpack_empty",
	"B_LIB_GER_MedicBackpack_empty",
	"B_LIB_GER_Panzer_Empty"
];
publicVariable "WehrMachtBackpacks";

WehrmachtHelmets = [
	"H_LIB_GER_Helmet",
	"H_LIB_GER_Cap",
	"H_LIB_GER_HelmetCamo"
];
publicVariable "WehrmachtHelmets";

WehrmachtWeapons = [
	"LIB_K98",
	"LIB_MP40",
	"LIB_MG34",
	"LIB_MG42",
	"LIB_K98ZF39",
	"LIB_M1908",
	"LIB_FG42G",
	"LIB_G43"
];
publicVariable "WehrmachtWeapons";

WehrmachtLaunchers = [
	"LIB_RPzB",
	"LIB_PzFaust_30m",
	"LIB_PzFaust_60m"
];
publicVariable "WehrmachtLaunchers";

WehrmachtMagazines = [
	"LIB_5Rnd_792x57",
	"LIB_50Rnd_792x57",
	"LIB_50Rnd_792x57_SMK",
	"LIB_50Rnd_792x57_sS",
	"LIB_10Rnd_792x57",
	"LIB_20Rnd_792x57",
	"LIB_32rnd_9x19",
	"LIB_1Rnd_G_PZGR_30",
	"LIB_1Rnd_G_PZGR_40",
	"LIB_1Rnd_G_SPRGR_30",
	"LIB_8Rnd_9x19_P08",
	"LIB_1Rnd_RPzB"
];
publicVariable "WehrmachtMagazines";

WehrmachtExplosives = [	
	"LIB_Shg24",
	"LIB_M39",
	"LIB_TMI_42_MINE_mag",
	"LIB_shumine_42_MINE_mag",
	"LIB_SMI_35_MINE_mag",
	"LIB_Ladung_Small_MINE_mag",
	"LIB_Ladung_Big_MINE_mag"
];
publicVariable "WehrmachtExplosives";

WehrmachtItems = [
	"fow_i_fak_ger",
	"LIB_ACC_GW_SB_Empty"
];
publicVariable "WehrmachtItems";

///////////////////////////////////////////
//     INITIALISING ITEM CATEGORIES     ///
///////////////////////////////////////////
[2,"Initialising item categories",__FILE__] call A3A_fnc_log;

//We initialise a LOT of arrays based on the categories. Every category gets a 'allX' variables and an 'unlockedX' variable.

private _unlockableCategories = allCategoriesExceptSpecial + ["AA", "AT", "GrenadeLaunchers", "ArmoredVests", "ArmoredHeadgear", "BackpacksCargo"];

//Build list of 'allX' variables, such as 'allWeapons'
DECLARE_SERVER_VAR(allEquipmentArrayNames, allCategories apply {"all" + _x});

//Build list of 'unlockedX' variables, such as 'allWeapons'
DECLARE_SERVER_VAR(unlockedEquipmentArrayNames, _unlockableCategories apply {"unlocked" + _x});

//Various arrays used by the loot system. Could also be done using DECLARE_SERVER_VAR individually.
private _otherEquipmentArrayNames = [
	"initialRebelEquipment",
	"lootBasicItem",
	"lootNVG",
	"lootItem",
	"lootWeapon",
	"lootAttachment",
	"lootMagazine",
	"lootGrenade",
	"lootExplosive",
	"lootBackpack",
	"lootHelmet",
	"lootVest",
	"lootDevice",
	"invaderStaticWeapon",
	"occupantStaticWeapon",
	"rebelStaticWeapon",
	"invaderBackpackDevice",
	"occupantBackpackDevice",
	"rebelBackpackDevice",
	"civilianBackpackDevice"
];

DECLARE_SERVER_VAR(otherEquipmentArrayNames, _otherEquipmentArrayNames);

//We're going to use this to sync the variables later.
everyEquipmentRelatedArrayName = allEquipmentArrayNames + unlockedEquipmentArrayNames + otherEquipmentArrayNames;

//Initialise them all as empty arrays.
{
	DECLARE_SERVER_VAR_FROM_VARIABLE(_x, []);
} forEach everyEquipmentRelatedArrayName;

//Create a global namespace for custom unit types.
DECLARE_SERVER_VAR(A3A_customUnitTypes, [true] call A3A_fnc_createNamespace);

////////////////////////////////////
//          MOD CONFIG           ///
////////////////////////////////////
[2,"Setting mod configs",_fileName] call A3A_fnc_log;

//TFAR config
if (A3A_hasTFAR) then
{
	if (isServer) then
	{
		[] spawn {
			waitUntil {sleep 1; !isNil "TF_server_addon_version"};
			[2,"Initializing TFAR settings","initVar.sqf"] call A3A_fnc_log;
			["TF_no_auto_long_range_radio", true, true,"mission"] call CBA_settings_fnc_set;						//set to false and players will spawn with LR radio.
			tf_teamPlayer_radio_code = "";publicVariable "tf_teamPlayer_radio_code";								//to make enemy vehicles usable as LR radio
			tf_east_radio_code = tf_teamPlayer_radio_code; publicVariable "tf_east_radio_code";					//to make enemy vehicles usable as LR radio
			tf_guer_radio_code = tf_teamPlayer_radio_code; publicVariable "tf_guer_radio_code";					//to make enemy vehicles usable as LR radio
			["TF_same_sw_frequencies_for_side", true, true,"mission"] call CBA_settings_fnc_set;						//synchronize SR default frequencies
			["TF_same_lr_frequencies_for_side", true, true,"mission"] call CBA_settings_fnc_set;						//synchronize LR default frequencies
		};
	};
};

////////////////////////////////////
//      CIVILIAN UNITS LIST      ///
////////////////////////////////////
[2,"Creating civilians",_fileName] call A3A_fnc_log;

//No real reason we initialise this on the server right now...
private _arrayCivs = [];

switch (true) do {
	case (toLower worldName in ["tanoa", "rhspkl", "cam_lao_nam", "vn_khe_sanh"]): {
		_arrayCivs append ["C_man_sport_1_F_tanoan","C_man_polo_1_F_asia"];
	};
	default {
		_arrayCivs append ["C_man_polo_1_F","C_man_polo_2_F","C_man_polo_3_F"];
	};
	//TODO: Africans when some Africa terrain will be supported
};

DECLARE_SERVER_VAR(arrayCivs, _arrayCivs);

//money magazines
private _arrayMoney = ["Money_bunch","Money_roll","Money_stack","Money"];
DECLARE_SERVER_VAR(arrayMoney, _arrayMoney);

//money props
private _arrayMoneyLand = ["Item_Money_bunch","Item_Money_roll","Item_Money_stack","Item_Money"];
DECLARE_SERVER_VAR(arrayMoneyLand, _arrayMoneyLand);

//SHOULD BE SYNCHRONIZED WITH arrayMoney VARIABLE
private _arrayMoneyAmount = [
	HALs_money_oldManItemsPrice select 0,
	HALs_money_oldManItemsPrice select 1,
	HALs_money_oldManItemsPrice select 2,
	HALs_money_oldManItemsPrice select 3
];
DECLARE_SERVER_VAR(arrayMoneyAmount, _arrayMoneyAmount);

//////////////////////////////////////
//         TEMPLATE SELECTION      ///
//////////////////////////////////////
[2,"Reading templates",_fileName] call A3A_fnc_log;

private _templateVariables = [
	//Allies
	"nameTeamPlayer",
	"SDKFlag",
	"SDKFlag2",
	"SDKFlagTexture",
	"SDKFlagMarkerType",
	"typePetros",
	"SDKUnarmed",
	"SDKMedic",
	"SDKMG",
	"SDKMil",
	"SDKSL",
	"SDKEng",
	"UKstaticCrewTeamPlayer",
	"UKUnarmed",
	"UKsniper",
	"UKMil",
	"UKMedic",
	"UKMG",
	"UKExp",
	"UKGL",
	"UKSL",
	"UKEng",
	"UKATman",
	"UKPilot",
	"UKCrew",
	"SASsniper",
	"SASMil",
	"SASMedic",
	"SASMG",
	"SASExp",
	"SASSL",
	"SASATman",
	"USstaticCrewTeamPlayer",
	"USUnarmed",
	"USsniper",
	"USMil",
	"USMedic",
	"USMG",
	"USExp",
	"USGL",
	"USSL",
	"USEng",
	"USATman",
	"USPilot",
	"USCrew",
	"parasniper",
	"paraMil",
	"paraMedic",
	"paraMG",
	"paraExp",
	"paraGL",
	"paraSL",
	"paraEng",
	"paraATman",
	"UKTroops",
	"SASTroops",
	"USTroops",
	"paraTroops",
	"SDKTroops",
	"alliedTroops",
	"groupsUKSquad",
	"groupsUSSquad",
	"groupsparaSquad",
	"groupsSASSquad",
	"groupsSDKSquad",
	"groupsSASRecon",
	"groupsUSAT",
	"groupSASSniper",
	"groupSDKLeaders",
	"vehUKAACrew",
	"vehUSMGCrew",
	"groupUSMortarCrew",
	"groupUSMGCrew",
	"groupUKMGCrew",
	"tankUKcrew",
	"tankUScrew",
	"tankM5crew",
	"sdkTier1",
	"sdkTier2",
	"sdkTier3",
	"sdkTier4",
	"sdkTier5",
	"sdkTier6",
	"soldiersSDK",
	"vehSDKBike",
	"vehSDKLightArmed",
	"vehSDKHeavyArmed",
	"vehSDKAT",
	"vehSDKLightUnarmed",
	"vehSDKTruck",
	"vehSDKTruckClosed",
	"vehSDKPlane",
	"vehUSPayloadPlane",
	"vehUKPayloadPlane",
	"vehSDKBoat",
	"vehInfSDKBoat",
	"vehSDKAttackBoat",
	"vehSDKRepair",
	"vehSDKFuel",
	"vehSDKAmmo",
	"vehSDKMedical",
	"vehSDKAA",
	"vehSDKAPCUK1",
	"vehSDKAPCUK2",
	"vehSDKAPCUS",
	"vehSDKTankChur",
	"vehSDKTankCroc",
	"vehSDKTankHow",
	"vehSDKTankUKM4",
	"vehSDKTankUSM5",
	"vehSDKTankUSM4",
	"vehSDKPlaneUK1",
	"vehSDKPlaneUK2",
	"vehSDKPlaneUK3",
	"vehSDKTransPlaneUK",
	"vehSDKPlaneUS1",
	"vehSDKPlaneUS2",
	"vehSDKPlaneUS3",
	"vehSDKTransPlaneUS",
	"civCar",
	"civTruck",
	"civHeli",
	"civBoat",
	"UKMGStatic",
	"USMGStatic",
	
	"staticATTeamPlayer",
	"staticAATeamPlayer",
	"SDKMortar",
	"SDKArtillery",
	"SDKMortarHEMag",
	"SDKMortarSmokeMag",
	"SDKArtilleryHEMag",
	"UKMGStaticWeap",
	"UKMGStaticSupp",
	"USMGStaticWeap",
	"USMGStaticSupp",
	"MortStaticWeap",
	"MortStaticSupp",
	"ATStaticSDKB",
	"AAStaticSDKB",
	"supportStaticsSDKB2",
	"supportStaticsSDKB3",
	"ATMineMags",
	"APERSMineMags",	

	//@Spoffy, is the correct like this?
	"breachingExplosivesAPC",
	"breachingExplosivesTank",

	//Occupants
	"nameOccupants",
	"NATOFlag",
	"NATOFlagTexture",
	"flagNATOmrk",
	"NATOAmmobox",
    "NATOSurrenderCrate",
    "NATOEquipmentBox",
	"NATOPlayerLoadouts",
	"vehNATOPVP",
	"NATOGrunt",
	"NATOOfficer",
	"NATOOfficer2",
	"NATOCrew",
	"NATOUnarmed",
	"staticCrewOccupants",
	"NATOPilot",
	"NATOSniper",
	"NATOMGMan",
	"FIARifleman",
	"FIAMarksman",
	"policeOfficer",
	"policeGrunt",
	"groupsNATOSentry",
	"groupsNATOSniper",
	"groupsNATOAA",
	"groupsNATOAT",
	"groupsNATOmid",
	"NATOSquad",
	"NATOSpecOp",
	"NATOParaSquad",
	"groupsNATOSquadT1",
	"groupsNATOSquadT2",
	"groupsFIASmall",
	"groupsFIAMid",
	"groupsFIASquad",
	"vehNATOBike",
	"vehNATOLightArmed",
	"vehNATOLightUnarmed",
	"vehNATOTrucks",
	"vehNATOCargoTrucks",
	"vehNATOAmmoTruck",
	"vehNATOFuelTruck",
	"vehNATOMedical",
	"vehNATORepairTruck",
	"vehNATOLight",
	"vehNATOAPC",
	"vehNATOLightAPC",
	"vehNATOTanks",
	"vehNATOAA",
	"vehNATOAttack",
	"vehNATOBoat",
	"vehNATORBoat",
	"vehNATOBoats",
	"vehNATOPlanes",
	"vehNATOPlanesAA",
	"vehNATOTransportPlanes",
	"vehNATOPatrolHeli",
	"vehNATOTransportHelis",
	"vehNATOAttackHelis",
	"vehNATOUAV",
	"vehNATOUAVSmall",
	"vehNATOMRLS",
	"vehNATOMRLSMags",
	"vehNATONormal",
	"vehNATOUtilityTrucks",
	"vehNATOAir",
	"vehFIAArmedCars",
	"vehFIATrucks",
	"vehFIAAPC",
	"vehFIATanks",
	"vehFIACars",
	"NATOMG",
	"staticATOccupants",
	"staticAAOccupants",
	"NATOMortar",
	"NATOHowitzer",
	"NATOAARadar",
	"NATOAASam",
	"NATOmortarMagazineHE",
	"NATOHowitzerMagazineHE",
	"vehPoliceCars",

	//Invaders
	"nameInvaders",
	"CSATFlag",
	"CSATFlagTexture",
	"flagCSATmrk",
	"CSATAmmoBox",
    "CSATSurrenderCrate",
    "CSATEquipmentBox",
	"CSATPlayerLoadouts",
	"vehCSATPVP",
	"CSATGrunt",
	"CSATOfficer",
	"CSATOfficer2",
	"CSATCrew",
	"CSATUnarmed",
	"CSATMarksman",
	"staticCrewInvaders",
	"CSATPilot",
	"WAMRifleman",
	"WAMMarksman",
	"groupsCSATSentry",
	"groupsCSATSniper",
	"groupsCSATsmall",
	"groupsCSATAA",
	"groupsCSATAT",
	"groupsCSATmid",
	"CSATSquad",
	"CSATSpecOp",
	"groupsCSATSquadT1",
	"groupsCSATSquadT2",
	"groupsCSATSquadT3",
	"groupsWAMSmall",
	"groupsWAMMid",
	"groupsWAMSquad",
	"vehWAMArmedCars",
	"vehWAMTrucks",
	"vehWAMAPC",
	"vehWAMTanks",
	"vehWAMCars",
	"vehCSATBike",
	"vehCSATLightArmed",
	"vehCSATLightUnarmed",
	"vehCSATTrucks",
	"vehCSATCargoTrucks",
	"vehCSATAmmoTruck",
	"vehCSATFuelTruck",
	"vehCSATMedical",
	"vehCSATRepairTruck",
	"vehCSATLight",
	"vehCSATAPC",
	"vehCSATLightAPC",
	"vehCSATTanks",
	"vehCSATAA",
	"vehCSATAttack",
	"vehCSATBoat",
	"vehCSATRBoat",
	"vehCSATBoats",
	"vehCSATPlanes",
	"vehCSATPlanesAA",
	"vehCSATTransportPlanes",
	"vehCSATPatrolHeli",
	"vehCSATTransportHelis",
	"vehCSATAttackHelis",
	"vehCSATUAV",
	"vehCSATUAVSmall",
	"vehCSATMRLS",
	"vehCSATMRLSMags",
	"vehCSATNormal",
	"vehCSATUtilityTrucks",
	"vehCSATAir",
	"CSATMG",
	"staticATInvaders",
	"staticAAInvaders",
	"CSATMortar",
	"CSATHowitzer",
	"CSATAARadar",
	"CSATAASam",
	"CSATmortarMagazineHE",
	"CSATHowitzerMagazineHE",
	"shop_UAV",
    "shop_AA",
    "shop_MRAP",
    "shop_wheel_apc",
    "shop_track_apc",
    "shop_heli",
    "shop_tank",
	"shop_plane",
	"additionalShopLight",
	"additionalShopAtgmVehicles",
	"additionalShopManpadsVehicles",
	"additionalShopArtillery",

	"smallBunker",
	"sandbag",
	"lootCrate",
	"rallyPoint",
	"civSupplyVehicle"
];

//CUP-only technical variables
if(A3A_hasCup) then {
	_templateVariables append ["vehSDKLightUnarmedArmored", "technicalArmoredBtr", "technicalArmoredAa", "technicalArmoredSpg", "technicalArmoredMg"];
};

{
	ONLY_DECLARE_SERVER_VAR_FROM_VARIABLE(_x);
} forEach _templateVariables;

call compile preProcessFileLineNumbers "Templates\selector.sqf";
//Set SDKFlagTexture on FlagX
if (local flagX) then { flagX setFlagTexture SDKFlagTexture } else { [flagX, SDKFlagTexture] remoteExec ["setFlagTexture", owner flagX] };

////////////////////////////////////
//     TEMPLATE SANITY CHECK      //
////////////////////////////////////
[2,"Sanity-checking templates",_fileName] call A3A_fnc_log;

// modify these appropriately when adding new template vars
private _nonClassVars = ["nameTeamPlayer", "SDKFlagTexture", "SDKFlagMarkerType", "nameOccupants", "NATOPlayerLoadouts", "NATOFlagTexture", "flagNATOmrk", "nameInvaders", "CSATPlayerLoadouts", "CSATFlagTexture", "flagCSATmrk"];
private _magazineVars = ["SDKMortarHEMag", "SDKMortarSmokeMag", "vehNATOMRLSMags", "vehCSATMRLSMags", "breachingExplosivesAPC", "breachingExplosivesTank", "NATOmortarMagazineHE", "NATOHowitzerMagazineHE", "CSATmortarMagazineHE", "CSATHowitzerMagazineHE"];

private _missingVars = [];
private _badCaseVars = [];
{
	call {
		private _varName = _x;
		private _var = missionNamespace getVariable _varName;
		if (isNil "_var") exitWith { [1, "Missing template var " + _varName, _filename] call A3A_fnc_log };

		if !(_var isEqualType []) then {_var = [_var]};									// plain string case, eg factions, some units
		if (_varname find "breachingExplosives" != -1) then { _var = _var apply {_x#0} };		// ["class", n] case for breaching explosives
		if (_var#0 isEqualType []) then {												// arrays of arrays case, used for infantry groups
			private _classes = [];
			{ _classes append _x } forEach _var;
			_var = _classes;
		};

		private _section = if (_x in _magazineVars) then {"CfgMagazines"} else {"CfgVehicles"};
		{
			if ("loadouts_" in _x) then {continue};
			if ("not_supported" in _x) then {continue};
			if !(_x isEqualType "") exitWith { [1, "Bad template var " + _varName, _filename] call A3A_fnc_log };
			if !(_x isEqualTo configName (configFile >> _section >> _x)) then
			{
			    if !(isClass (configFile >> _section >> _x)) then {
			        _missingVars pushBackUnique _x;
			    } else {
					_badCaseVars pushBackUnique _x;
				};
			};
		} forEach _var;
	};
} forEach (_templateVariables - _nonClassVars);

if (count _missingVars > 0) then {
	[1, format ["Missing classnames: %1", _missingVars], _filename] call A3A_fnc_log;
};
if (count _badCaseVars > 0) then {
	[1, format ["Miscased classnames: %1", _badCaseVars], _filename] call A3A_fnc_log;
};

////////////////////////////////////
//      CIVILIAN VEHICLES       ///
////////////////////////////////////
[2,"Creating civilian vehicles lists",_fileName] call A3A_fnc_log;

private _fnc_vehicleIsValid = {
	params ["_type"];
	private _configClass = configFile >> "CfgVehicles" >> _type;
	if !(isClass _configClass) exitWith {
		[1, format ["Vehicle class %1 not found", _type], _filename] call A3A_fnc_log;
		false;
	};
	if (_configClass call A3A_fnc_getModOfConfigClass in disabledMods) then {false} else {true};
};

private _fnc_filterAndWeightArray = {

	params ["_array", "_targWeight"];
	private _output = [];
	private _curWeight = 0;

	// first pass, filter and find total weight
	for "_i" from 0 to (count _array - 2) step 2 do {
		if ((_array select _i) call _fnc_vehicleIsValid) then {
			_output pushBack (_array select _i);
			_output pushBack (_array select (_i+1));
			_curWeight = _curWeight + (_array select (_i+1));
		};
	};
	if (_curWeight == 0) exitWith {_output};

	// second pass, re-weight
	private _weightMod = _targWeight / _curWeight;
	for "_i" from 0 to (count _output - 2) step 2 do {
		_output set [_i+1, _weightMod * (_output select (_i+1))];
	};
	_output;
};

private _civVehicles = [];
private _civVehiclesWeighted = [];

_civVehiclesWeighted append ([civVehCommonData, 4] call _fnc_filterAndWeightArray);
_civVehiclesWeighted append ([civVehIndustrialData, 1] call _fnc_filterAndWeightArray);
_civVehiclesWeighted append ([civVehMedicalData, 0.1] call _fnc_filterAndWeightArray);
_civVehiclesWeighted append ([civVehRepairData, 0.1] call _fnc_filterAndWeightArray);
_civVehiclesWeighted append ([civVehRefuelData, 0.1] call _fnc_filterAndWeightArray);

for "_i" from 0 to (count _civVehiclesWeighted - 2) step 2 do {
	_civVehicles pushBack (_civVehiclesWeighted select _i);
};

_civVehicles append [civCar, civTruck, civSupplyVehicle];			// Civ car/truck from rebel template, in case they're different

DECLARE_SERVER_VAR(arrayCivVeh, _civVehicles);
DECLARE_SERVER_VAR(civVehiclesWeighted, _civVehiclesWeighted);


private _civBoats = [];
private _civBoatsWeighted = [];

// Boats don't need any re-weighting, so just copy the data

for "_i" from 0 to (count civBoatData - 2) step 2 do {
	private _boat = civBoatData select _i;
	if (_boat call _fnc_vehicleIsValid) then {
		_civBoats pushBack _boat;
		_civBoatsWeighted pushBack _boat;
		_civBoatsWeighted pushBack (civBoatData select (_i+1));
	};
};

DECLARE_SERVER_VAR(civBoats, _civBoats);
DECLARE_SERVER_VAR(civBoatsWeighted, _civBoatsWeighted);

private _undercoverVehicles = (arrayCivVeh - ["C_Quadbike_01_F"]) + civBoats + [civHeli];
DECLARE_SERVER_VAR(undercoverVehicles, _undercoverVehicles);

//////////////////////////////////////
//      GROUPS CLASSIFICATION      ///
//////////////////////////////////////
[2,"Identifying unit types",_fileName] call A3A_fnc_log;
//Identify Squad Leader Units
private _squadLeaders = [
	"loadouts_reb_militia_SquadLeader",
	"loadouts_reb_militia_ukSquadLeader",
	"loadouts_reb_militia_usSquadLeader",
	"loadouts_reb_militia_sasSquadLeader",
	"loadouts_reb_militia_paraSquadLeader",
	"loadouts_occ_militia_SquadLeader",
	"loadouts_occ_military_SquadLeader",
	"loadouts_occ_elite_SquadLeader",
	"loadouts_occ_SF_SquadLeader",
	"loadouts_inv_militia_SquadLeader",
	"loadouts_inv_military_SquadLeader",
	"loadouts_inv_elite_SquadLeader",
	"loadouts_inv_SF_SquadLeader"
];
DECLARE_SERVER_VAR(squadLeaders, _squadLeaders);
//Identify radio-capable units
private _radioMen = [
	"loadouts_occ_militia_Radioman",
	"loadouts_occ_military_Radioman",
	"loadouts_occ_elite_Radioman",
	"loadouts_occ_SF_Radioman",
	"loadouts_inv_militia_Radioman",
	"loadouts_inv_military_Radioman",
	"loadouts_inv_elite_Radioman",
	"loadouts_inv_SF_Radioman"
];
DECLARE_SERVER_VAR(radioMen, _radioMen);
//Identify Medic Units
private _medics = [
	"loadouts_reb_militia_medic",
	"loadouts_reb_militia_ukmedic",
	"loadouts_reb_militia_usmedic",
	"loadouts_reb_militia_sasmedic",
	"loadouts_reb_militia_paramedic",
	"loadouts_occ_militia_Medic",
	"loadouts_occ_military_Medic",
	"loadouts_occ_elite_Medic",
	"loadouts_occ_SF_Medic",
	"loadouts_inv_militia_Medic",
	"loadouts_inv_military_Medic",
	"loadouts_inv_elite_Medic",
	"loadouts_inv_SF_Medic"
];
DECLARE_SERVER_VAR(medics, _medics);
//Define Sniper Groups and Units
private _sniperGroups = [
	"loadouts_reb_militia_uksniper",
	"loadouts_reb_militia_ussniper",
	"loadouts_reb_militia_sassniper",
	"loadouts_reb_militia_parasniper",
	"loadouts_occ_military_Sniper",
	"loadouts_occ_elite_Sniper",
	"loadouts_inv_militia_Sniper",
	"loadouts_inv_military_Sniper",
	"loadouts_inv_elite_Sniper"
];
DECLARE_SERVER_VAR(sniperGroups, _sniperGroups);

if (A3A_has3CBFactions && {(threecbfOccupantFaction == 4 || A3A_hasGlobMob)}) then {
  A3A_coldWarMode = true;
  publicVariable "A3A_coldWarMode";

  [2,"3CB Factions and US Cold War template or 3CBF+GM detected, Cold War Mode to be initiated.",_fileName] call A3A_fnc_log;
};

//////////////////////////////////////
//        ITEM INITIALISATION      ///
//////////////////////////////////////
//This is all very tightly coupled.
//Beware when changing these, or doing anything with them, really.

[2,"Initializing hardcoded categories",_fileName] call A3A_fnc_log;
[] call A3A_fnc_categoryOverrides;
[2,"Scanning config entries for items",_fileName] call A3A_fnc_log;
//[A3A_fnc_equipmentIsValidForCurrentModset] call A3A_fnc_configSort;
[2,"Categorizing vehicle classes",_fileName] call A3A_fnc_log;
[] call A3A_fnc_vehicleSort;
[2,"Categorizing equipment classes",_fileName] call A3A_fnc_log;
[] call A3A_fnc_equipmentSort;
[2,"Sorting grouped class categories",_fileName] call A3A_fnc_log;
[] call A3A_fnc_itemSort;
[2,"Building loot lists",_fileName] call A3A_fnc_log;
[] call A3A_fnc_loot;

////////////////////////////////////
//   CLASSING TEMPLATE VEHICLES  ///
////////////////////////////////////
[2,"Identifying vehicle types",_fileName] call A3A_fnc_log;

//little experiment with hashmap
private _vehNormal = (vehNATONormal + vehCSATNormal + vehNATOCargoTrucks + vehCSATCargoTrucks + vehFIACars + vehFIATrucks + vehFIAArmedCars + vehWAMCars + vehWAMTrucks + vehWAMArmedCars + vehPoliceCars + [vehNATOBike,vehCSATBike,vehSDKTruck,vehSDKLightArmed,vehSDKAT,vehSDKBike,vehSDKRepair,vehSDKFuel]) createHashMapFromArray [];
DECLARE_SERVER_VAR(vehNormal, _vehNormal);

private _vehMilitia = vehFIATrucks + vehFIACars + vehFIAAPC + vehFIAArmedCars + vehFIATanks + vehWAMTrucks + vehWAMCars + vehWAMAPC + vehWAMArmedCars + vehWAMTanks;
DECLARE_SERVER_VAR(vehMilitia, _vehMilitia);

private _vehBoats = [vehNATOBoat,vehNATORBoat,vehCSATBoat,vehCSATRBoat,vehSDKBoat,vehInfSDKBoat,vehSDKAttackBoat];
DECLARE_SERVER_VAR(vehBoats, _vehBoats);

private _vehAttack = vehNATOAttack + vehCSATAttack + [vehSDKHeavyArmed, vehSDKAPCUK1, vehSDKAPCUS, vehSDKAPCUK2, vehSDKAT, vehSDKTankChur, vehSDKTankCroc, vehSDKTankHow, vehSDKTankUKM4, vehSDKTankUSM5, vehSDKTankUSM4];
DECLARE_SERVER_VAR(vehAttack, _vehAttack);

private _vehPlanes = (vehNATOAir + vehCSATAir + [vehSDKPlane, vehUSPayloadPlane, vehUKPayloadPlane, vehSDKPlaneUK1, vehSDKPlaneUK2, vehSDKPlaneUK3, vehSDKPlaneUS1, vehSDKPlaneUS2, vehSDKPlaneUS3, vehSDKTransPlaneUK, vehSDKTransPlaneUS]);
DECLARE_SERVER_VAR(vehPlanes, _vehPlanes);

private _vehAttackHelis = vehCSATAttackHelis + vehNATOAttackHelis;
DECLARE_SERVER_VAR(vehAttackHelis, _vehAttackHelis);

private _vehHelis = vehNATOTransportHelis + vehCSATTransportHelis + vehAttackHelis + [vehNATOPatrolHeli,vehCSATPatrolHeli];
DECLARE_SERVER_VAR(vehHelis, _vehHelis);

private _vehFixedWing = vehNATOPlanes + vehNATOPlanesAA + vehCSATPlanes + vehCSATPlanesAA + vehNATOTransportPlanes + vehCSATTransportPlanes + [vehSDKPlane, vehUSPayloadPlane, vehUKPayloadPlane, vehSDKPlaneUK1, vehSDKPlaneUK2, vehSDKPlaneUK3, vehSDKPlaneUS1, vehSDKPlaneUS2, vehSDKPlaneUS3, vehSDKTransPlaneUK, vehSDKTransPlaneUS];
DECLARE_SERVER_VAR(vehFixedWing, _vehFixedWing);

private _vehUAVs = [vehNATOUAV,vehCSATUAV,vehNATOUAVSmall,vehCSATUAVSmall];
DECLARE_SERVER_VAR(vehUAVs, _vehUAVs);

private _vehAmmoTrucks = [vehNATOAmmoTruck,vehCSATAmmoTruck, vehSDKAmmo];
DECLARE_SERVER_VAR(vehAmmoTrucks, _vehAmmoTrucks);

private _vehSupplyTrucks = [vehNATOFuelTruck,vehNATOMedical,vehNATORepairTruck, vehCSATFuelTruck, vehCSATRepairTruck, vehCSATMedical, vehSDKRepair, vehSDKFuel, vehSDKMedical];
DECLARE_SERVER_VAR(vehSupplyTrucks, _vehSupplyTrucks);

private _vehAPCs = vehNATOAPC + vehCSATAPC + vehFIAAPC + vehWAMAPC + vehNATOLightAPC + vehCSATLightAPC + [vehSDKHeavyArmed, vehSDKAPCUK1, vehSDKAPCUS, vehSDKAPCUK2, vehSDKAT];
DECLARE_SERVER_VAR(vehAPCs, _vehAPCs);

private _vehTanks = vehNATOTanks + vehCSATTanks + vehFIATanks + vehWAMTanks + [vehSDKTankChur, vehSDKTankCroc, vehSDKTankHow, vehSDKTankUKM4, vehSDKTankUSM5, vehSDKTankUSM4];
DECLARE_SERVER_VAR(vehTanks, _vehTanks);

private _vehTrucks = vehNATOTrucks + vehCSATTrucks + vehFIATrucks + vehWAMTrucks + [vehSDKTruck + vehSDKTruckClosed];
DECLARE_SERVER_VAR(vehTrucks, _vehTrucks);

private _vehAA = vehNATOAA + vehCSATAA + [vehSDKAA];
DECLARE_SERVER_VAR(vehAA, _vehAA);

private _vehMRLS = [vehCSATMRLS, vehNATOMRLS];
DECLARE_SERVER_VAR(vehMRLS, _vehMRLS);

private _vehArmor = vehTanks + vehAA + vehMRLS + vehAPCs;
DECLARE_SERVER_VAR(vehArmor, _vehArmor);

private _vehTransportAir = vehNATOTransportHelis + vehCSATTransportHelis + vehNATOTransportPlanes + vehCSATTransportPlanes + [vehSDKTransPlaneUK, vehSDKTransPlaneUS];
DECLARE_SERVER_VAR(vehTransportAir, _vehTransportAir);

private _vehFastRope = ["O_Heli_Light_02_unarmed_F","B_Heli_Transport_01_camo_F","RHS_UH60M_d","UK3CB_BAF_Merlin_HC3_18_GPMG_DDPM_RM","UK3CB_BAF_Merlin_HC3_18_GPMG_Tropical_RM","RHS_Mi8mt_vdv","RHS_Mi8mt_vv","RHS_Mi8mt_Cargo_vv"];
DECLARE_SERVER_VAR(vehFastRope, _vehFastRope);

private _vehUnlimited = vehNATONormal + vehCSATNormal + [vehNATORBoat,vehNATOPatrolHeli,vehCSATRBoat,vehCSATPatrolHeli,vehNATOUAV,vehNATOUAVSmall,NATOMortar,NATOHowitzer,NATOAARadar,NATOAASam,vehCSATUAV,vehCSATUAVSmall, CSATMortar, CSATHowitzer, CSATAARadar, CSATAASam] + CSATMG + NATOMG;
DECLARE_SERVER_VAR(vehUnlimited, _vehUnlimited);

private _vehFIA = [civCar, civTruck, vehSDKBike, vehSDKLightUnarmed, vehSDKLightArmed, vehSDKTruck, vehSDKTruckClosed, vehSDKRepair, vehSDKFuel, vehSDKAmmo, vehSDKMedical, vehSDKHeavyArmed, vehSDKAPCUK1, vehSDKAPCUS, vehSDKAPCUK2, vehSDKAT, vehSDKTankChur, vehSDKTankCroc, vehSDKTankHow, vehSDKTankUKM4, vehSDKTankUSM5, vehSDKTankUSM4, vehSDKPlaneUK1, vehSDKPlaneUK2, vehSDKPlaneUK3, vehSDKPlaneUS1, vehSDKPlaneUS2, vehSDKPlaneUS3, vehUSPayloadPlane, vehUKPayloadPlane, vehSDKTransPlaneUK, vehSDKTransPlaneUS, UKMGStatic, USMGStatic, staticATteamPlayer, staticAAteamPlayer, SDKMortar, SDKArtillery, vehInfSDKBoat, vehSDKBoat, vehSDKAttackBoat];
DECLARE_SERVER_VAR(vehFIA, _vehFIA);

private _vehCargoTrucks = (vehTrucks + vehNATOCargoTrucks + vehCSATCargoTrucks) select { [_x] call A3A_fnc_logistics_getVehCapacity > 1 };
DECLARE_SERVER_VAR(vehCargoTrucks, _vehCargoTrucks);

private _vehArty = [NATOMortar, vehNATOMRLS, SDKMortar, SDKArtillery];
DECLARE_SERVER_VAR(vehArty, _vehArty);

private _vehClassToCrew = call A3A_fnc_initVehClassToCrew;
DECLARE_SERVER_VAR(A3A_vehClassToCrew,_vehClassToCrew);

//WW2 Allied vehicle starting numbers

{server setVariable [_x + "_count", 0, true]} forEach [vehSDKMedical,vehSDKHeavyArmed,vehSDKAT,vehSDKTankCroc,vehSDKTankHow,vehSDKPlaneUK1,vehSDKPlaneUK3,vehSDKPlaneUS2,vehSDKPlaneUS3,vehSDKTransPlaneUK,staticATteamPlayer,SDKArtillery,vehSDKAttackBoat];
{server setVariable [_x + "_count", 1, true]} forEach [civTruck,vehSDKRepair,vehSDKFuel,vehSDKAmmo,vehSDKAPCUK1,vehSDKAPCUK2,vehSDKTankChur,vehSDKTankUKM4,vehSDKPlaneUK2,vehSDKPlaneUS1,vehUSPayloadPlane,vehUKPayloadPlane,vehSDKTransPlaneUS,staticAAteamPlayer,SDKMortar,vehSDKBoat];
{server setVariable [_x + "_count", 2, true]} forEach [civCar,vehSDKLightArmed,vehSDKTruck,vehSDKTruckClosed,vehSDKAPCUS,vehSDKTankUSM4,vehSDKTankUSM5,vehInfSDKBoat];
{server setVariable [_x + "_count", 4, true]} forEach [UKMGStatic,USMGStatic];
{server setVariable [_x + "_count", 6, true]} forEach [vehSDKBike,vehSDKLightUnarmed];

//WW2 arsenal boxes
server setVariable ["IG_supplyCrate_F" + "_count", 1000, true];

///////////////////////////
//     MOD TEMPLATES    ///
///////////////////////////
//Please respect the order in which these are called,
//and add new entries to the bottom of the list.
if (A3A_hasACE) then {
	[] call A3A_fnc_aceModCompat;
};
if (A3A_hasRHS) then {
	[] call A3A_fnc_rhsModCompat;
};
if (A3A_hasCup) then {
	[] call A3A_fnc_cupModCompat;
};

if (A3A_coldWarMode && {toLower	worldName != "blud_vidda"}) then { //vidda has unique lightning config
	setDate [1991, 5, 10, 7, 0];
};

////////////////////////////////////
//     ACRE ITEM MODIFICATIONS   ///
////////////////////////////////////
if (A3A_hasACRE) then {initialRebelEquipment append ["ACRE_PRC343","ACRE_PRC148","ACRE_PRC152","ACRE_SEM52SL"];};
if (A3A_hasACRE && startWithLongRangeRadio) then {initialRebelEquipment append ["ACRE_SEM70", "ACRE_PRC117F", "ACRE_PRC77"];};

////////////////////////////////////
//    UNIT AND VEHICLE PRICES    ///
////////////////////////////////////
[2,"Creating pricelist",_fileName] call A3A_fnc_log;
{server setVariable [_x,50,true]} forEach [UKMil, USMil, SDKMil];
{server setVariable [_x,75,true]} forEach (sdkTier1 - [UKMil, USMil, SDKMil]);
{server setVariable [_x,100,true]} forEach sdkTier2;
{server setVariable [_x,150,true]} forEach sdkTier3;
{server setVariable [_x,200,true]} forEach sdkTier4;
{server setVariable [_x,250,true]} forEach sdkTier5;
{server setVariable [_x,300,true]} forEach sdkTier6;
{timer setVariable [_x,12,true]} forEach [staticATOccupants] + staticAAOccupants;
{timer setVariable [_x,12,true]} forEach  [staticATInvaders] + staticAAInvaders;
{timer setVariable [_x,10,true]} forEach vehNATOAPC;
{timer setVariable [_x,10,true]} forEach vehCSATAPC;
{timer setVariable [_x,10,true]} forEach vehNATOTanks;
{timer setVariable [_x,10,true]} forEach vehCSATTanks;
{timer setVariable [_x,6,true]} forEach vehNATOAA;
{timer setVariable [_x,6,true]} forEach vehCSATAA;
timer setVariable [vehNATOBoat,6,true];
timer setVariable [vehCSATBoat,6,true];
{timer setVariable [_x,10,true]} forEach vehNATOPlanes;
{timer setVariable [_x,10,true]} forEach vehCSATPlanes;
{timer setVariable [_x,10,true]} forEach vehNATOPlanesAA;
{timer setVariable [_x,10,true]} forEach vehCSATPlanesAA;
{timer setVariable [_x,6,true]} forEach vehNATOTransportPlanes;
{timer setVariable [_x,1,true]} forEach vehNATOTransportHelis - [vehNATOPatrolHeli];
{timer setVariable [_x,6,true]} forEach vehCSATTransportPlanes;
{timer setVariable [_x,10,true]} forEach vehCSATTransportHelis - [vehCSATPatrolHeli];
{timer setVariable [_x,0,true]} forEach vehNATOAttackHelis;
{timer setVariable [_x,10,true]} forEach vehCSATAttackHelis;
timer setVariable [vehNATOMRLS,0,true];
timer setVariable [vehCSATMRLS,5,true];

server setVariable [civCar,350,true];
server setVariable [civTruck,600,true];
server setVariable [civBoat,200,true];
server setVariable [vehSDKBike, 250, true];
server setVariable [vehSDKLightUnarmed,250,true];
server setVariable [vehSDKTruck,400,true];
server setVariable [vehSDKTruckClosed,400,true];
server setVariable [vehSDKLightArmed, 400, true];
server setVariable [vehSDKRepair, 500, true];
server setVariable [vehSDKFuel, 500, true];
server setVariable [vehSDKAmmo, 600, true];
server setVariable [vehSDKMedical, 600, true];
server setVariable [vehSDKHeavyArmed,750,true];
server setVariable [vehSDKAPCUK1,800,true];
server setVariable [vehSDKAPCUS, 1000,true];
server setVariable [vehSDKAPCUK2,1000,true];
server setVariable [vehSDKAT, 1500, true];
server setVariable [vehSDKAA,2000,true];
server setVariable [vehSDKTankChur,2500,true];
server setVariable [vehSDKTankCroc, 2750, true];
server setVariable [vehSDKTankHow, 2800, true];
server setVariable [vehSDKTankUKM4, 2400, true];
server setVariable [vehSDKTankUSM5, 1600, true];
server setVariable [vehSDKTankUSM4, 2400, true];
server setVariable [vehSDKPlaneUK1, 3000, true];
server setVariable [vehSDKPlaneUK2,3000,true];
server setVariable [vehSDKPlaneUK3,4000,true];
server setVariable [vehSDKPlaneUS1, 3200, true];
server setVariable [vehSDKPlaneUS2, 3800, true];
server setVariable [vehSDKPlaneUS3, 5000, true];
server setVariable [vehUKPayloadPlane, 8000, true];
server setVariable [vehUSPayloadPlane, 7500, true];
server setVariable [vehSDKTransPlaneUK, 2500, true];
server setVariable [vehSDKTransPlaneUS, 2500, true];
server setVariable [vehInfSDKBoat, 1200, true];
server setVariable [vehSDKBoat, 1500, true];
server setVariable [vehSDKAttackBoat, 1800, true];
server setVariable [UKMGStatic,250,true];
server setVariable [USMGStatic, 250, true];
server setVariable [staticATteamPlayer, 1200, true];
server setVariable [staticAAteamPlayer, 1600, true];
server setVariable [SDKMortar, 500, true];
server setVariable [SDKArtillery, 1600, true];

//black market costs
{server setVariable [_x,2000,true]} forEach shop_UAV;
{server setVariable [_x,6000,true]} forEach shop_AA;
{server setVariable [_x,4500,true]} forEach shop_MRAP;
{server setVariable [_x,8000,true]} forEach shop_wheel_apc;
{server setVariable [_x,9500,true]} forEach shop_track_apc;
{server setVariable [_x,25000,true]} forEach shop_heli;
{server setVariable [_x,35000,true]} forEach shop_plane;

if (!(shop_tank isEqualTo [])) then {
	private _firstTank = shop_tank select 0;
	if (!isNil "_firstTank") then {
		server setVariable [_firstTank, 10500, true];
	};

	private _secondTank = shop_tank select 1;
	if (!isNil "_secondTank") then {
		server setVariable [_secondTank, 15000, true];
	};

	private _thirdTank = shop_tank select 2;
	if (!isNil "_thirdTank") then {
		server setVariable [_thirdTank, 17500, true];
	};
};

if (!(additionalShopArtillery isEqualTo [])) then {
	if (A3A_hasCup) then {
		server setVariable [(additionalShopArtillery select 0), 2000, true];
		server setVariable [(additionalShopArtillery select 1), 15000, true];
		server setVariable [(additionalShopArtillery select 2), 20000, true];
	};
	if (A3A_has3CBFactions) then {
		server setVariable [(additionalShopArtillery select 0), 15000, true];
		server setVariable [(additionalShopArtillery select 1), 25000, true];
		server setVariable [(additionalShopArtillery select 2), 30000, true];
	};
};

{server setVariable [_x,1500,true]} forEach additionalShopLight;
{server setVariable [_x,5000,true]} forEach additionalShopAtgmVehicles;
{server setVariable [_x,7500,true]} forEach additionalShopManpadsVehicles;

//technicals cost
if(A3A_hasCup) then {
	server setVariable [vehSDKLightUnarmedArmored, 400, true];
	server setVariable [technicalArmoredBtr, 3250, true];
	server setVariable [technicalArmoredAa, 3000, true];
	server setVariable [technicalArmoredSpg, 3000, true];
	server setVariable [technicalArmoredMg, 2250, true];
};

//lootcrate cost
server setVariable [lootCrate, 100, true];

//rally point cost
server setVariable [rallyPoint, 100, true];

///////////////////////
//     GARRISONS    ///
///////////////////////
[2,"Initialising Garrison Variables",_fileName] call A3A_fnc_log;

tierPreference = 1;
cityUpdateTiers = [4, 8];
cityStaticsTiers = [0.2, 1];
airportUpdateTiers = [3, 6, 8];
airportStaticsTiers = [0.5, 0.75, 1];
outpostUpdateTiers = [4, 7, 9];
outpostStaticsTiers = [0.4, 0.7, 1];
milbaseUpdateTiers = [3, 6, 8];
milbaseStaticsTiers = [0.5, 0.75, 1];
otherUpdateTiers = [3, 7];
otherStaticsTiers = [0.3, 1];
[] call A3A_fnc_initPreference;

////////////////////////////
//     REINFORCEMENTS    ///
////////////////////////////
[2,"Initialising Reinforcement Variables",_fileName] call A3A_fnc_log;
DECLARE_SERVER_VAR(reinforceMarkerOccupants, []);
DECLARE_SERVER_VAR(reinforceMarkerInvaders, []);
DECLARE_SERVER_VAR(canReinforceOccupants, []);
DECLARE_SERVER_VAR(canReinforceInvaders, []);

/////////////////////////////////////////
//     SYNCHRONISE SERVER VARIABLES   ///
/////////////////////////////////////////
[2,"Sending server variables",_fileName] call A3A_fnc_log;

//Declare this last, so it syncs last.
DECLARE_SERVER_VAR(initVarServerCompleted, true);
{
	publicVariable _x;
} forEach serverInitialisedVariables;

[2,"initVarServer completed",_fileName] call A3A_fnc_log;