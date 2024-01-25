diag_log format ["%1: [Antistasi] | INFO | loadServer Starting.",servertime];
if (isServer) then {
	diag_log format ["%1: [Antistasi] | INFO | Starting Persistent Load.",servertime];
	petros allowdamage false;
	A3A_saveVersion = 0;
	["version"] call A3A_fnc_getStatVariable;
	["savedPlayers"] call A3A_fnc_getStatVariable;
	["watchpostsFIA"] call A3A_fnc_getStatVariable; publicVariable "watchpostsFIA";
	["roadblocksFIA"] call A3A_fnc_getStatVariable; publicVariable "roadblocksFIA";
	["aapostsFIA"] call A3A_fnc_getStatVariable; publicVariable "aapostsFIA";
	["mortarpostsFIA"] call A3A_fnc_getStatVariable; publicVariable "mortarpostsFIA";
	["lightroadblocksFIA"] call A3A_fnc_getStatVariable; publicVariable "lightroadblocksFIA";
	["hmgpostsFIA"] call A3A_fnc_getStatVariable; publicVariable "hmgpostsFIA";
	["atpostsFIA"] call A3A_fnc_getStatVariable; publicVariable "atpostsFIA";
	["supportpostsFIA"] call A3A_fnc_getStatVariable; publicVariable "supportpostsFIA";
	["mrkSDK"] call A3A_fnc_getStatVariable;
	["mrkCSAT"] call A3A_fnc_getStatVariable;
	["destroyedSites"] call A3A_fnc_getStatVariable;
	["minesX"] call A3A_fnc_getStatVariable;
	["attackCountdownOccupants"] call A3A_fnc_getStatVariable;
    ["attackCountdownInvaders"] call A3A_fnc_getStatVariable;
	["antennas"] call A3A_fnc_getStatVariable;
	//["hr"] call A3A_fnc_getStatVariable;
	["UKhr"] call A3A_fnc_getStatVariable;
	["UShr"] call A3A_fnc_getStatVariable;
	["SAShr"] call A3A_fnc_getStatVariable;
	["parahr"] call A3A_fnc_getStatVariable;
	["SDKhr"] call A3A_fnc_getStatVariable;
	["dateX"] call A3A_fnc_getStatVariable;
	["weather"] call A3A_fnc_getStatVariable;
	["prestigeOPFOR"] call A3A_fnc_getStatVariable;
	["prestigeBLUFOR"] call A3A_fnc_getStatVariable;
	["resourcesFIA"] call A3A_fnc_getStatVariable;
	["intelPoints"] call A3A_fnc_getStatVariable;
	["garrison"] call A3A_fnc_getStatVariable;
	["usesWurzelGarrison"] call A3A_fnc_getStatVariable;
	["baseMarkersX"] call A3A_fnc_getStatVariable;
	["mrkAntennas"] call A3A_fnc_getStatVariable;
	["skillFIA"] call A3A_fnc_getStatVariable;
	["maxConstructions"] call A3A_fnc_getStatVariable;
	["membersX"] call A3A_fnc_getStatVariable;
	["vehInGarage"] call A3A_fnc_getStatVariable;
    ["HR_Garage"] call A3A_fnc_getStatVariable;
	["destroyedBuildings"] call A3A_fnc_getStatVariable;
	["idlebases"] call A3A_fnc_getStatVariable;
	["idleassets"] call A3A_fnc_getStatVariable;
	["killZones"] call A3A_fnc_getStatVariable;
	["controlsSDK"] call A3A_fnc_getStatVariable;
	["bombRuns"] call A3A_fnc_getStatVariable;
	["supportPoints"] call A3A_fnc_getStatVariable;
	waitUntil {!isNil "arsenalInit"};
	["jna_dataList"] call A3A_fnc_getStatVariable;
	["isTraderQuestCompleted"] call A3A_fnc_getStatVariable;
	["traderPosition"] call A3A_fnc_getStatVariable;
	["traderDiscount"] call A3A_fnc_getStatVariable;
	["areOccupantsDefeated"] call A3A_fnc_getStatVariable;
	["areInvadersDefeated"] call A3A_fnc_getStatVariable;
	["rebelLoadouts"] call A3A_fnc_getStatVariable;
	["randomizeRebelLoadoutUniforms"] call A3A_fnc_getStatVariable;
	["artilleryList"] call A3A_fnc_getStatVariable; publicVariable "artilleryList";
	["flakList"] call A3A_fnc_getStatVariable; publicVariable "flakList";
	["battleshipStarted"] call A3A_fnc_getStatVariable; publicVariable "battleshipStarted";
	["battleshipDone"] call A3A_fnc_getStatVariable; publicVariable "battleshipDone";
	["finalStatistics"] call A3A_fnc_getStatVariable;
	["introFinished"] call A3A_fnc_getStatVariable; publicVariable "introFinished";
	["rebelCity"] call A3A_fnc_getStatVariable; publicVariable "rebelCity";

	//===========================================================================
	#include "\A3\Ui_f\hpp\defineResinclDesign.inc"

	//RESTORE THE STATE OF THE 'UNLOCKED' VARIABLES USING JNA_DATALIST
	{
		private _arsenalTabDataArray = _x;
		private _unlockedItemsInTab = _arsenalTabDataArray select { _x select 1 == -1 } apply { _x select 0 };
		{
			[_x, true] call A3A_fnc_unlockEquipment;
		} forEach _unlockedItemsInTab;
	} forEach jna_dataList;

	if !(unlockedNVGs isEqualTo []) then {
		haveNV = true; publicVariable "haveNV"
	};

	//Check if we have radios unlocked and update haveRadio.
	call A3A_fnc_checkRadiosUnlocked;

	//Sort optics list so that snipers pick the right sight
	unlockedOptics = [unlockedOptics,[],{getNumber (configfile >> "CfgWeapons" >> _x >> "ItemInfo" >> "mass")},"DESCEND"] call BIS_fnc_sortBy;

	{
		if (sidesX getVariable [_x,sideUnknown] != teamPlayer) then {
			_positionX = getMarkerPos _x;
			_nearX = [(markersX - controlsX - watchpostsFIA - roadblocksFIA - aapostsFIA - atpostsFIA - mortarpostsFIA - lightroadblocksFIA - hmgpostsFIA - supportpostsFIA),_positionX] call BIS_fnc_nearestPosition;
			_sideX = sidesX getVariable [_nearX,sideUnknown];
			sidesX setVariable [_x,_sideX,true];
		};
	} forEach controlsX;

	{
		if (sidesX getVariable [_x,sideUnknown] == sideUnknown) then {
			sidesX setVariable [_x,Occupants,true];
		};
	} forEach markersX;

	{
		[_x] call A3A_fnc_mrkUpdate
	} forEach (markersX - controlsX);

	if (count watchpostsFIA > 0) then {
		markersX = markersX + watchpostsFIA;
		publicVariable "markersX";
	};

	if (count roadblocksFIA > 0) then {
		markersX = markersX + roadblocksFIA;
		publicVariable "markersX";
	};

	if (count aapostsFIA > 0) then {
		markersX = markersX + aapostsFIA;
		publicVariable "markersX";
	};

	if (count mortarpostsFIA > 0) then {
		markersX = markersX + mortarpostsFIA;
		publicVariable "markersX";
	};

	if (count lightroadblocksFIA > 0) then {
		markersX = markersX + lightroadblocksFIA;
		publicVariable "markersX";
	};

	if (count atpostsFIA > 0) then {
		markersX = markersX + atpostsFIA;
		publicVariable "markersX";
	};

	if (count hmgpostsFIA > 0) then {
		markersX = markersX + hmgpostsFIA;
		publicVariable "markersX";
	};

	if (count supportpostsFIA > 0) then {
		markersX = markersX + supportpostsFIA;
		publicVariable "markersX";
	};
	
	{
		if (_x in destroyedSites) then {
			sidesX setVariable [_x, Invaders, true];
			[_x] call A3A_fnc_destroyCity
		};
	} forEach citiesX;

    //Load aggro stacks and level and calculate current level
    ["aggressionOccupants"] call A3A_fnc_getStatVariable;
	["aggressionInvaders"] call A3A_fnc_getStatVariable;
    [true] call A3A_fnc_calculateAggression;

	["chopForest"] call A3A_fnc_getStatVariable;


	["posHQ"] call A3A_fnc_getStatVariable;
	["nextTick"] call A3A_fnc_getStatVariable;
	["staticsX"] call A3A_fnc_getStatVariable;
	["constructionsX"] call A3A_fnc_getStatVariable;

	{_x setPos getMarkerPos respawnTeamPlayer} forEach ((call A3A_fnc_playableUnits) select {side _x == teamPlayer});
	_sites = markersX select {sidesX getVariable [_x,sideUnknown] == teamPlayer};

	tierPreference = 1;
	publicVariable "tierPreference";
	
	// update war tier silently, calls updatePreference if changed
	//[true] call A3A_fnc_tierCheck;

	if (isNil "usesWurzelGarrison") then {
		//Create the garrison new
		diag_log "No WurzelGarrison found, creating new!";
		[airportsX, "Airport", [0,0,0]] spawn A3A_fnc_createGarrison;	//New system
		[resourcesX, "Other", [0,0,0]] spawn A3A_fnc_createGarrison;	//New system
		[factories, "Other", [0,0,0]] spawn A3A_fnc_createGarrison;
		[outposts, "Outpost", [1,1,0]] spawn A3A_fnc_createGarrison;
		[milbases, "MilitaryBase", [0,0,0]] spawn A3A_fnc_createGarrison;
		[seaports, "Other", [1,0,0]] spawn A3A_fnc_createGarrison;

	} else {
		//Garrison save in wurzelformat, load it
		diag_log "WurzelGarrison found, loading it!";
		["wurzelGarrison"] call A3A_fnc_getStatVariable;
	};

	//Vehicles count
	["vehicleCountArray"] call A3A_fnc_getStatVariable;
	_vehicleCountArray = vehicleCountArray;
	{
		private _count = vehFIA find _x;
		server setVariable [_x + "_count", _vehicleCountArray select _count, true];
	}forEach vehFIA;

    //Load state of testing timer
    ["testingTimerIsActive"] call A3A_fnc_getStatVariable;

	clearMagazineCargoGlobal boxX;
	clearWeaponCargoGlobal boxX;
	clearItemCargoGlobal boxX;
	clearBackpackCargoGlobal boxX;

	[] remoteExec ["A3A_fnc_statistics",[teamPlayer,civilian]];
	diag_log format ["%1: [Antistasi] | INFO | Persistent Load Completed.",servertime];
	diag_log format ["%1: [Antistasi] | INFO | Generating Map Markers.",servertime];
	["tasks"] call A3A_fnc_getStatVariable;
	if !(isMultiplayer) then {
		{//Can't we go around this using the initMarker? And only switching marker?
			_pos = getMarkerPos _x;
			_dmrk = createMarker [format ["Dum%1",_x], _pos];
			_dmrk setMarkerShape "ICON";
			[_x] call A3A_fnc_mrkUpdate;
			if (sidesX getVariable [_x,sideUnknown] != teamPlayer) then {
				_nul = [_x] call A3A_fnc_createControls;
			};
		} forEach airportsX;

		{
			_pos = getMarkerPos _x;
			_dmrk = createMarker [format ["Dum%1",_x], _pos];
			_dmrk setMarkerShape "ICON";
			_dmrk setMarkerSize [0.6, 0.6];
			_dmrk setMarkerType "plp_mark_as_industrial";
			_dmrk setMarkerText "Industry";
			[_x] call A3A_fnc_mrkUpdate;
			if (sidesX getVariable [_x,sideUnknown] != teamPlayer) then {
				_nul = [_x] call A3A_fnc_createControls;
			};
		} forEach resourcesX;

		{
			_pos = getMarkerPos _x;
			_dmrk = createMarker [format ["Dum%1",_x], _pos];
			_dmrk setMarkerShape "ICON";
			_dmrk setMarkerSize [0.6, 0.6];
			_dmrk setMarkerType "plp_mark_as_industrial";
			_dmrk setMarkerText "Industry";
			[_x] call A3A_fnc_mrkUpdate;
			if (sidesX getVariable [_x,sideUnknown] != teamPlayer) then {
				_nul = [_x] call A3A_fnc_createControls;
			};
		} forEach factories;

		{
			_pos = getMarkerPos _x;
			_dmrk = createMarker [format ["Dum%1",_x], _pos];
			_dmrk setMarkerShape "ICON";
			_dmrk setMarkerSize [0.6, 0.6];
			if (toLower worldName in ["enoch", "vn_khe_sanh"]) then {
				_dmrk setMarkerType "plp_mark_as_artycannon";
			} else {
				_dmrk setMarkerType "plp_mark_as_watchtower";
			};
			[_x] call A3A_fnc_mrkUpdate;
			if (sidesX getVariable [_x,sideUnknown] != teamPlayer) then {
				_nul = [_x] call A3A_fnc_createControls;
			};
		} forEach outposts;

		{
			_pos = getMarkerPos _x;
			_dmrk = createMarker [format ["Dum%1",_x], _pos];
			_dmrk setMarkerShape "ICON";
			if (_x in ["seaport","seaport_1","seaport_2","seaport_3","seaport_5"]) then {
				_dmrk setMarkerSize [0.75, 0.75];
				_dmrk setMarkerType "plp_mark_civ_harbor";
				_dmrk setMarkerText "Port";
			} else {
				_dmrk setMarkerSize [0.6, 0.6];
				_dmrk setMarkerType "plp_mark_as_pier";
				_dmrk setMarkerText "Dock";
			};
			[_x] call A3A_fnc_mrkUpdate;
			if (sidesX getVariable [_x,sideUnknown] != teamPlayer) then {
				_nul = [_x] call A3A_fnc_createControls;
			};
		} forEach seaports;

		{
			_pos = getMarkerPos _x;
			_dmrk = createMarker [format ["Dum%1",_x], _pos];
			_dmrk setMarkerShape "ICON";
			_dmrk setMarkerSize [0.75, 0.75];
			_dmrk setMarkerType "plp_mark_civ_embassy";
			_dmrk setMarkerText "Military Base";
			[_x] call A3A_fnc_mrkUpdate;
			if (sidesX getVariable [_x,sideUnknown] != teamPlayer) then {
				_nul = [_x] call A3A_fnc_createControls;
			};
		} forEach milbases;
	};

	placementDone = true; publicVariable "placementDone";
	petros allowdamage true;
};
diag_log format ["%1: [Antistasi] | INFO | loadServer Completed.",servertime];
