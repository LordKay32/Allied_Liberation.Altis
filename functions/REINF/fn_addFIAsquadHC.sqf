params ["_typeGroup", ["_withBackpck", ""]];

private ["_nearVeh", "_nearX"];

if (player != theBoss) exitWith {["Deploy Squad", "Only the Commander has access to this function."] call A3A_fnc_customHint;};
if (markerAlpha respawnTeamPlayer == 0) exitWith {["Deploy Squad", "You cannot deploy a new squad while you are moving your HQ."] call A3A_fnc_customHint;};
if (!([player] call A3A_fnc_hasRadio)) exitWith {
    ["Deploy Squad", "You need a radio in your inventory to be able to give orders to other squads."] call A3A_fnc_customHint;
};

private _exit = false;
{
	if (((side _x == Invaders) or (side _x == Occupants)) and (_x distance petros < 500) and ([_x] call A3A_fnc_canFight) and !(isPlayer _x)) exitWith {_exit = true};
} forEach allUnits;
if (_exit) exitWith {["Deploy Squad", "You cannot deploy squads with enemies near your HQ."] call A3A_fnc_customHint;};

if (_typeGroup isEqualType "") then {
	if (_typeGroup == "not_supported") then {_exit = true; ["Deploy Squad", "The group or vehicle type you requested is not supported in your modset."] call A3A_fnc_customHint;};
};

if (_exit) exitWith {};

private _hr = 0;
private _isInfantry = false;
private _costs = 0;
private _costHR = 0;
private _formatX = [];

switch (true) do {
	
	case (_typeGroup in [groupsUKSquad,staticAAteamPlayer,UKMGStatic,vehSDKTankUKM4,vehSDKTankChur,vehSDKTransPlaneUK]) : {
	_hr = server getVariable "UKhr";
	};

	case (_typeGroup in [groupsSASSquad,groupsSASRecon,groupSASSniper]) : {
	_hr = server getVariable "SAShr";
	};

	case (_typeGroup in [groupsUSSquad,groupsUSAT,vehSDKLightArmed,SDKMortar,vehSDKAA,vehSDKTankUSM4,vehSDKTankUSM5,vehSDKRepair,vehSDKFuel,vehSDKAmmo,vehSDKMedical,vehInfSDKBoat,vehSDKBoat,vehSDKTransPlaneUS]) : {
	_hr = server getVariable "UShr";
	};
	
	case (_typeGroup in [groupsparaSquad]) : {
	_hr = server getVariable "parahr";
	};
	
	case (_typeGroup in [groupsSDKSquad]) : {
	_hr = server getVariable "SDKhr";
	};
};

private _resourcesFIA = server getVariable "resourcesFIA";

if (_typeGroup isEqualType []) then {
	{
		private _typeUnit = _x;
		_formatX pushBack _typeUnit;
		_costs = _costs + (server getVariable _typeUnit);
		_costHR = _costHR + 1;
	} forEach _typeGroup;

	if (_withBackpck == "UKMG") then {_costs = _costs + ([UKMGStatic] call A3A_fnc_vehiclePrice)};
	if (_withBackpck == "Mortar") then {_costs = _costs + ([SDKMortar] call A3A_fnc_vehiclePrice)};
	_isInfantry = true;

} else {

	switch _typeGroup do {
    	case staticAAteamPlayer: {
    		{
			private _typeUnit = _x;
			_formatX pushBack _typeUnit;
			_costs = _costs + (server getVariable _typeUnit);
			_costHR = _costHR + 1;
			} forEach vehUKAACrew;
			_costs = _costs + ([vehSDKAA] call A3A_fnc_vehiclePrice)
		};
   		case UKMGStatic: {
    		{
			private _typeUnit = _x;
			_formatX pushBack _typeUnit;
			_costs = _costs + (server getVariable _typeUnit);
			_costHR = _costHR + 1;
			} forEach groupUKMGCrew;
			_costs = _costs + ([_typeGroup] call A3A_fnc_vehiclePrice)
		};
		case vehSDKAA: {
    		{
			private _typeUnit = _x;
			_formatX pushBack _typeUnit;
			_costs = _costs + (server getVariable _typeUnit);
			_costHR = _costHR + 1;
			} forEach groupUSAACrew;
			_costs = _costs + ([_typeGroup] call A3A_fnc_vehiclePrice)
		};
		case vehSDKLightArmed: {
    		{
			private _typeUnit = _x;
			_formatX pushBack _typeUnit;
			_costs = _costs + (server getVariable _typeUnit);
			_costHR = _costHR + 1;
			} forEach vehUSMGCrew;
			_costs = _costs + ([_typeGroup] call A3A_fnc_vehiclePrice)
		};
		case SDKMortar: {
    		{
			private _typeUnit = _x;
			_formatX pushBack _typeUnit;
			_costs = _costs + (server getVariable _typeUnit);
			_costHR = _costHR + 1;
			} forEach groupUSMortarCrew;
			_costs = _costs + ([_typeGroup] call A3A_fnc_vehiclePrice)
		};
		case vehSDKTankUSM4: {
    		{
			private _typeUnit = _x;
			_formatX pushBack _typeUnit;
			_costs = _costs + (server getVariable _typeUnit);
			_costHR = _costHR + 1;
			} forEach tankUScrew;
			_costs = _costs + ([_typeGroup] call A3A_fnc_vehiclePrice)
		};
		case vehSDKTankUSM5: {
    		{
			private _typeUnit = _x;
			_formatX pushBack _typeUnit;
			_costs = _costs + (server getVariable _typeUnit);
			_costHR = _costHR + 1;
			} forEach tankM5crew;
			_costs = _costs + ([_typeGroup] call A3A_fnc_vehiclePrice)
		};
		case vehSDKTankUKM4: {
    		{
			private _typeUnit = _x;
			_formatX pushBack _typeUnit;
			_costs = _costs + (server getVariable _typeUnit);
			_costHR = _costHR + 1;
			} forEach tankUKcrew;
			_costs = _costs + ([_typeGroup] call A3A_fnc_vehiclePrice)
		};
		case vehSDKTankChur: {
    		{
			private _typeUnit = _x;
			_formatX pushBack _typeUnit;
			_costs = _costs + (server getVariable _typeUnit);
			_costHR = _costHR + 1;
			} forEach tankUKcrew;
			_costs = _costs + ([_typeGroup] call A3A_fnc_vehiclePrice)
		};
		case vehSDKRepair: {
    		{
			private _typeUnit = _x;
			_formatX pushBack _typeUnit;
			_costs = _costs + (server getVariable _typeUnit);
			_costHR = _costHR + 1;
			} forEach [USEng,USMil];
			_costs = _costs + ([_typeGroup] call A3A_fnc_vehiclePrice)
		};
		case vehSDKFuel: {
    		{
			private _typeUnit = _x;
			_formatX pushBack _typeUnit;
			_costs = _costs + (server getVariable _typeUnit);
			_costHR = _costHR + 1;
			} forEach [USEng,USMil];
			_costs = _costs + ([_typeGroup] call A3A_fnc_vehiclePrice)
		};
		case vehSDKAmmo: {
    		{
			private _typeUnit = _x;
			_formatX pushBack _typeUnit;
			_costs = _costs + (server getVariable _typeUnit);
			_costHR = _costHR + 1;
			} forEach [USEng,USMil];
			_costs = _costs + ([_typeGroup] call A3A_fnc_vehiclePrice)
		};
		case vehSDKMedical: {
    		{
			private _typeUnit = _x;
			_formatX pushBack _typeUnit;
			_costs = _costs + (server getVariable _typeUnit);
			_costHR = _costHR + 1;
			} forEach [USMedic,USMil];
			_costs = _costs + ([_typeGroup] call A3A_fnc_vehiclePrice)
		};
		case vehInfSDKBoat: {
    		{
			private _typeUnit = _x;
			_formatX pushBack _typeUnit;
			_costs = _costs + (server getVariable _typeUnit);
			_costHR = _costHR + 1;
			} forEach [USMil];
			_costs = _costs + ([_typeGroup] call A3A_fnc_vehiclePrice)
		};
		case vehSDKBoat: {
    		{
			private _typeUnit = _x;
			_formatX pushBack _typeUnit;
			_costs = _costs + (server getVariable _typeUnit);
			_costHR = _costHR + 1;
			} forEach [USMil,USMil,USMil];
			_costs = _costs + ([_typeGroup] call A3A_fnc_vehiclePrice)
		};
		case vehSDKTransPlaneUK: {
    		{
			private _typeUnit = _x;
			_formatX pushBack _typeUnit;
			_costs = _costs + (server getVariable _typeUnit);
			_costHR = _costHR + 1;
			} forEach [UKPilot,UKPilot];
			_costs = _costs + ([_typeGroup] call A3A_fnc_vehiclePrice)
		};
		case vehSDKTransPlaneUS: {
    		{
			private _typeUnit = _x;
			_formatX pushBack _typeUnit;
			_costs = _costs + (server getVariable _typeUnit);
			_costHR = _costHR + 1;
			} forEach [USPilot,USPilot];
			_costs = _costs + ([_typeGroup] call A3A_fnc_vehiclePrice)
		};		
	};
	if (_typeGroup == staticAAteamPlayer) then {
		if (server getVariable (vehSDKAA + "_count") < 1) then {_exit = true; ["Deploy Squad", "You do not have any of the chosen vehicle type to deploy this squad."] call A3A_fnc_customHint;};
	} else {
		if (server getVariable (_typeGroup + "_count") < 1) then {_exit = true; ["Deploy Squad", "You do not have any of the chosen vehicle type to deploy this squad."] call A3A_fnc_customHint;};
	};
	if ((_typeGroup == SDKMortar) or (_typeGroup == UKMGStatic)) exitWith { _isInfantry = true };
};

if (_hr < _costHR) then {_exit = true; ["Deploy Squad", format ["You do not have enough HR for this request (%1 required).",_costHR]] call A3A_fnc_customHint;};

if (_resourcesFIA < _costs) then {_exit = true; ["Deploy Squad", format ["You do not have enough CP for this request (%1%2 required).",_costs, currencySymbol]] call A3A_fnc_customHint;};

if (_exit) exitWith {};

//JB code limited arsenal
private ["_squadloadout","_loadout","_fullSquadGear","_number"];

_squadloadout = [];
{
_loadout = rebelLoadouts get _x;
_squadloadout pushback _loadout;
} forEach _formatX;

_fullSquadGear = _squadloadout call A3A_fnc_reorgLoadoutSquad;
	
	_emptyList = [];
	{
	_number = [jna_dataList select (_x select 0 call jn_fnc_arsenal_itemType), _x select 0]call jn_fnc_arsenal_itemCount; 
	if ((_number <= (_x select 1)) && !(_number == -1)) then { _emptyList pushBack (_x select 0) }
	} forEach _fullSquadGear;

if (count _emptyList > 0) exitWith {
		
		private _weaps = [];
		private _mags = [];
		private _strings = [];
		
		{
			_weaps = getText (configFile >> "CfgWeapons" >> _x >> "displayName");
			_strings pushBack _weaps;
			_mags = getText (configFile >> "CfgMagazines" >> _x >> "displayName");
			_strings pushBack _mags;
		} forEach _emptyList;
		
		_strings = _strings - [""];
		
	["Recruit Squad", format ["The following gear has run too low for you to recruit this squad: <t color='#ffff00'>%1", _strings], "FAIL"] call SCRT_fnc_ui_showDynamicTextMessage;
};

//

private _mounts = [];
private _vehType = switch true do {
    case (!_isInfantry && _typeGroup isEqualTo staticAAteamPlayer): {
        if (vehSDKAA isEqualTo "not_supported") exitWith {_mounts pushBack ["LIB_FlaK_38",-1,[[1],[],[]]]; "UNI_Stud_Open_Cargo_OD"};
    };
    case (!_isInfantry): {_typeGroup};
    case (count _formatX isEqualTo 2): {vehSDKBike};
    case (count _formatX > 4 && !(_typeGroup isEqualTo groupsSASSquad) && !(_typeGroup isEqualTo groupsSDKSquad)): {if (server getVariable (vehSDKTruck + "_count") >= (server getVariable (vehSDKTruckClosed + "_count"))) then {vehSDKTruck} else {vehSDKTruckClosed}};
    case (_typeGroup isEqualTo groupsSASSquad): {vehSDKHeavyArmed};
    case (_typeGroup isEqualTo groupsSDKSquad): {civTruck};
    default {vehSDKLightUnarmed};
};

private _idFormat = switch _typeGroup do {
    case groupsSASRecon: {"SAS-Rcn-"};
    case groupsUSAT: {"US-AT-"};
    case groupSASSniper: {"SAS-Snpr-"};
    case SDKMortar: {"US-Mort-"};
    case UKMGStatic: {"UK-MG-"};
    case vehSDKAA: {"US-AA-"};
    case vehSDKLightArmed: {"M.MG-"};
    case staticAAteamPlayer: {"M.AA-"};
    case groupsUKSquad: {"UK-Sqd-"};
    case groupsUSSquad: {"US-Sqd-"};
    case groupsSASSquad: {"SAS-Sqd-"};
    case groupsparaSquad: {"82nd-Sqd-"};
    case groupsSDKSquad: {"Partz-Sqd-"};
    case vehSDKTankUSM4: {"Arm.USM4-"};
    case vehSDKTankUSM5: {"Arm.USM5-"};
    case vehSDKTankUKM4: {"Arm.UKM4-"};
    case vehSDKTankChur: {"Arm.UKCh-"};
    case vehSDKRepair: {"Sup.Rpr-"};
    case vehSDKFuel: {"Sup.Fuel-"};
    case vehSDKAmmo: {"Sup.Ammo-"};
    case vehSDKMedical: {"Sup.Med-"};
    case vehInfSDKBoat: {"Nav.Inf-"};
    case vehSDKBoat: {"Nav.Veh-"};
    case vehSDKTransPlaneUK: {"RAF.Tran-"};
    case vehSDKTransPlaneUS: {"USAAF.Tran-"};
    default {
        switch _withBackpck do {
            case "UKMG": {"UK-SqMG-"};
            case "Mortar": {"Mortar"};
            default {"Squad-"};
        };
    };
};
private _special = if (_isInfantry) then {
    if (_typeGroup isEqualType []) then { _withBackpck } else {"staticAutoT"};
} else {
    if (_typeGroup == staticAAteamPlayer) exitWith {"BuildAA"};
    "VehicleSquad"
};

private _nearX = "";
_exit = false;

switch (true) do {
    case (_typeGroup isEqualTo groupsSDKSquad): {
		_nearX = [citiesX, position player] call BIS_fnc_nearestPosition;
	};

	case (_typeGroup in [vehSDKRepair, vehSDKFuel, vehSDKAmmo, vehSDKMedical]): {
		sqdMrkFlsh = true;
	
		potMarkers = [];

			{
			if (sidesX getVariable [_x,sideUnknown] == teamPlayer) then {potMarkers pushBack _x};
			} forEach (["Synd_HQ"] + airportsX + milbases + supportpostsFIA);

		if (!visibleMap) then {openMap true};

		[] spawn {
			private _mrkList = [];
			private _num = 0;
			{
			_num = _num + 1;
			private _circleMrk = createMarkerLocal [format ["MrkCircle_%1", _num], (getMarkerPos _x)];
			_circleMrk setMarkerShapeLocal "ICON";
			_circleMrk setMarkerTypeLocal "mil_circle";
			_circleMrk setMarkerSizeLocal [1.5, 1.5];
			_mrkList pushBack _circleMrk;
			} forEach potMarkers;
	
			while {sqdMrkFlsh == true} do {
				{
					_x setMarkerColorLocal "ColorYellow";
				} forEach _mrkList;
				sleep 1;
				{
					_x setMarkerColorLocal "colorGUER";
				} forEach _mrkList;
				sleep 1;
				if (sqdMrkFlsh == false) exitWith {{deleteMarkerLocal _x} forEach _mrkList};
			};
		};

		positionTel = [];

		onMapSingleClick "positionTel = _pos";

		["Deploy Squad", "Select the base you want the squad to deploy at (HQ, airbases, military bases or support posts)."] call A3A_fnc_customHint;

		waitUntil {sleep 0.5; (count positionTel > 0) or (not visiblemap)};
		onMapSingleClick "";

		if (!visibleMap) exitWith {sqdMrkFlsh = false; _exit = true};
		sqdMrkFlsh = false;
		private _positionTel = positionTel;

		_nearX = [(["Synd_HQ"] + airportsX + milbases + supportpostsFIA),_positionTel] call BIS_fnc_nearestPosition;

		if ((getMarkerPos _nearX) distance _positionTel > 50) exitWith {
		["Deploy Squad", "Select your HQ or a friendly airbase or military base.""Select your HQ or a friendly airbase, military base or support post."] call A3A_fnc_customHint;
		};

		if (not(sidesX getVariable [_nearX,sideUnknown] == teamPlayer)) exitWith {["Deploy Squad", "Select your HQ or a friendly airbase, military base or support post."] call A3A_fnc_customHint;};

		{
			if (((side _x == Invaders) or (side _x == Occupants)) and (_x distance (getMarkerPos _nearX) < 500) and ([_x] call A3A_fnc_canFight) and !(isPlayer _x)) exitWith {_exit = true; ["Deploy Squad", "You cannot deploy units when there are enemies near the base."] call A3A_fnc_customHint};
		} forEach allUnits;
		
		if (_nearX in supportpostsFIA) then {
			_nearVeh = (getMarkerPos _nearX) nearObjects [_typeGroup, 20];
			if ({alive _x} count _nearVeh == 0) exitWith {_exit = true; ["Deploy Squad", "This vehicle type is not present at that support post."] call A3A_fnc_customHint;};
		};
	};

	default {

		sqdMrkFlsh = true;
	
		potMarkers = [];

		if (_typeGroup in [groupsSASRecon, groupsUSAT, groupSASSniper, SDKMortar, UKMGStatic, vehSDKAA, vehSDKLightArmed, staticAAteamPlayer, groupsUKSquad, groupsUSSquad, groupsSASSquad, groupsparaSquad, vehSDKTankUSM4, vehSDKTankUSM5, vehSDKTankUKM4, vehSDKTankChur]) then {
			{
			if (sidesX getVariable [_x,sideUnknown] == teamPlayer) then {potMarkers pushBack _x};
			} forEach (["Synd_HQ"] + airportsX + milbases);
		};

		if (_typeGroup in [vehInfSDKBoat, vehSDKBoat]) then {
			{
			if (sidesX getVariable [_x,sideUnknown] == teamPlayer) then {potMarkers pushBack _x};
			} forEach seaports;
		};
		
		if (_typeGroup in [vehSDKTransPlaneUK, vehSDKTransPlaneUS]) then {
			{
			if (sidesX getVariable [_x,sideUnknown] == teamPlayer) then {potMarkers pushBack _x};
			} forEach airportsX;
		};

		if (!visibleMap) then {openMap true};

		[] spawn {
			private _mrkList = [];
			private _num = 0;
			{
			_num = _num + 1;
			private _circleMrk = createMarkerLocal [format ["MrkCircle_%1", _num], (getMarkerPos _x)];
			_circleMrk setMarkerShapeLocal "ICON";
			_circleMrk setMarkerTypeLocal "mil_circle";
			_circleMrk setMarkerSizeLocal [1.5, 1.5];
			_mrkList pushBack _circleMrk;
			} forEach potMarkers;
	
			while {sqdMrkFlsh == true} do {
				{
					_x setMarkerColorLocal "ColorYellow";
				} forEach _mrkList;
				sleep 1;
				{
					_x setMarkerColorLocal "colorGUER";
				} forEach _mrkList;
				sleep 1;
				if (sqdMrkFlsh == false) exitWith {{deleteMarkerLocal _x} forEach _mrkList};
			};
		};

		positionTel = [];

		onMapSingleClick "positionTel = _pos";

		["Deploy Squad", "Select the base you want the squad to deploy at (HQ, airbases or military bases)."] call A3A_fnc_customHint;

		waitUntil {sleep 0.5; (count positionTel > 0) or (not visiblemap)};
		onMapSingleClick "";

		if (!visibleMap) exitWith {sqdMrkFlsh = false; _exit = true};
		sqdMrkFlsh = false;
		private _positionTel = positionTel;

		if (_typeGroup in [groupsSASRecon, groupsUSAT, groupSASSniper, SDKMortar, UKMGStatic, vehSDKAA, vehSDKLightArmed, staticAAteamPlayer, groupsUKSquad, groupsUSSquad, groupsSASSquad, groupsparaSquad, vehSDKTankUSM4, vehSDKTankUSM5, vehSDKTankUKM4, vehSDKTankChur]) then {
			_nearX = [(["Synd_HQ"] + airportsX + milbases),_positionTel] call BIS_fnc_nearestPosition;
		};

		if (_typeGroup in [vehInfSDKBoat, vehSDKBoat]) then {
			_nearX = [seaports, _positionTel] call BIS_fnc_nearestPosition;
		};
		
		if (_typeGroup in [vehSDKTransPlaneUK, vehSDKTransPlaneUS]) then {
			_nearX = [airportsX, _positionTel] call BIS_fnc_nearestPosition;
		};

		if ((getMarkerPos _nearX) distance _positionTel > 50) exitWith {
		["Deploy Squad", "Select your HQ or a friendly airbase or military base."] call A3A_fnc_customHint;
		};

		if (not(sidesX getVariable [_nearX,sideUnknown] == teamPlayer)) exitWith {["Deploy Squad", "Select your HQ or a friendly airbase or military base."] call A3A_fnc_customHint;};

		{
			if (((side _x == Invaders) or (side _x == Occupants)) and (_x distance (getMarkerPos _nearX) < 500) and ([_x] call A3A_fnc_canFight) and !(isPlayer _x)) exitWith {_exit = true; ["Deploy Squad", "You cannot deploy units when there are enemies near the base."] call A3A_fnc_customHint};
		} forEach allUnits;
	};
};

if (_exit) exitWith {};
_exit = false;

if (_isInfantry) then {
   
	private _vehCost = [_vehType] call A3A_fnc_vehiclePrice;
	if (_isInfantry and (_costs + _vehCost) > server getVariable "resourcesFIA") exitWith {
		if (visibleMap) then {openMap false};
	    ["Deploy Squad", format ["No CP left to buy a transport vehicle (%1%2 required), creating foot squad.",_vehCost, currencySymbol]] call A3A_fnc_customHint;
	    [_formatX, _idFormat, _special, _nearX] spawn A3A_fnc_spawnHCGroup;
	    _exit = true;
	};
	if (_isInfantry and (server getVariable (_vehType + "_count") < 1)) exitWith {
		if (visibleMap) then {openMap false};
	    ["Deploy Squad", "No transport vehicles available, creating foot squad. "] call A3A_fnc_customHint;
	    [_formatX, _idFormat, _special, _nearX] spawn A3A_fnc_spawnHCGroup;
	    _exit = true;
	};
	
	createDialog "vehQuery";
	sleep 1;
	disableSerialization;
	private _display = findDisplay 100;

	if (str (_display) != "no display") then {
		private _ChildControl = _display displayCtrl 104;
		_ChildControl  ctrlSetTooltip format ["Buy a vehicle for this squad for %1%2.", _vehCost, currencySymbol];
		_ChildControl = _display displayCtrl 105;
		_ChildControl  ctrlSetTooltip "Foot Infantry";
	};

	waitUntil {(!dialog) or (!isNil "vehQuery")};
	if ((!dialog) and (isNil "vehQuery")) exitWith { if (visibleMap) then {openMap false}; [_formatX, _idFormat, _special, _nearX] spawn A3A_fnc_spawnHCGroup; _exit = true }; //spawn group call here

	vehQuery = nil;
};

if (_exit) exitWith {{[_x select 0 call jn_fnc_arsenal_itemType, _x select 0, _x select 1]call jn_fnc_arsenal_removeItem } forEach _fullSquadGear};

if (!visibleMap) then {openMap true};

positionTel = [];
positionDir = [];
	
private _circleMrk = createMarkerLocal ["BRCircle", (getMarkerPos _nearX)];
_circleMrk setMarkerShapeLocal "ELLIPSE";
_circleMrk setMarkerSizeLocal [250, 250];
_circleMrk setMarkerColorLocal "ColorGreen";
_circleMrk setMarkerAlphaLocal 0.5;

onMapSingleClick "positionTel = _pos";

["Deploy Squad", "Select the location you want the squad vehicle to deploy at (must be within 250m of squad base)."] call A3A_fnc_customHint;

waitUntil {sleep 0.5; (count positionTel > 0) or (not visiblemap)};
if (!visibleMap) exitWith {deleteMarkerLocal _circleMrk};
		
deleteMarkerLocal _circleMrk;
_positionTel = positionTel;
		
if ((getMarkerPos _nearX) distance _positionTel > 250) exitWith {
	["Deploy Squad", "Location must be within 250m of squad base."] call A3A_fnc_customHint;
	deleteMarkerLocal _circleMrk;
};

if ((getMarkerPos _nearX) distance _positionTel > 250) exitWith {
	["Deploy Squad", "Location must be within 250m of squad base."] call A3A_fnc_customHint;
	deleteMarkerLocal _circleMrk;
};

private _originMrk = createMarkerLocal ["BRStart", _positionTel];
_originMrk setMarkerShapeLocal "ICON";
_originMrk setMarkerTypeLocal "hd_end";
_originMrk setMarkerTextLocal "Vehicle Position";

onMapSingleClick "positionDir = _pos";

["Deploy Squad", "Select the direction you want the squad vehicle to face"] call A3A_fnc_customHint;

waitUntil {sleep 0.5; (count positionDir > 0) or (not visiblemap)};
if (!visibleMap) exitWith {deleteMarkerLocal _originMrk};
		
private _positionDir = positionDir;
		
private _directionMrk = createMarkerLocal ["BRFin", _positionDir];
_directionMrk setMarkerShapeLocal "ICON";
_directionMrk setMarkerTypeLocal "hd_dot";
_directionMrk setMarkerTextLocal "Vehicle Direction";
		
sleep 1;
		
if (visibleMap) then {openMap false};
deleteMarkerLocal _originMrk;
deleteMarkerLocal _directionMrk;
private _dirVeh = [_positionTel, _positionDir] call BIS_fnc_dirTo;
		
private _vehiclePlacementMethod =
{
	private ["_vehicle"];
	if (_nearX in supportpostsFIA) then {
		_vehicle = _nearVeh select 0;
		_vehicle setPos _positionTel;
		_vehicle setDir _dirVeh;
	} else {
		_vehicle = _vehType createVehicle _positionTel;
		_vehicle setDir _dirVeh;
		teamPlayerVehDeployed = teamPlayerVehDeployed + 1;
		publicVariable "teamPlayerVehDeployed";
	};
	
	if (_vehType == vehSDKAA) then {
		_vehicle animateSource ['stoiki_hide', 1];
		_aaMount = createVehicle ["LIB_FlaK_38", [0,0,1100], [], 0, "NONE"];
		_aaMount animateSource ['Hide_Shield', 1];
		_aaMount animateSource ['Hide_Shield_Sight', 1];
		_aaMount animateSource ['Hide_Shield_Small', 1];
		_aaMount attachTo [_vehicle, [0,-2,0.175]];
	};
	[_formatX, _idFormat, _special, _vehicle] spawn A3A_fnc_spawnHCGroup;
};

[_vehType, "HCSquadVehicle", [_formatX, _idFormat, _special], _mounts] call _vehiclePlacementMethod;

{ [_x select 0 call jn_fnc_arsenal_itemType, _x select 0, _x select 1]call jn_fnc_arsenal_removeItem } forEach _fullSquadGear;
