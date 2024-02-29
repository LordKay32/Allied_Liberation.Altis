if (!isServer and hasInterface) exitWith {};

private ["_costs","_groupX","_unit","_minesX","_radiusX","_roads","_truckX","_mineX","_countX"];

_costs = (server getVariable USExp) + ([vehSDKRepair] call A3A_fnc_vehiclePrice);

[-1,-1*_costs,USExp] remoteExec ["A3A_fnc_resourcesFIA",2];

_loadout = rebelLoadouts get USExp;

_fullUnitGear = _loadout call A3A_fnc_reorgLoadoutUnit;

_emptyList = [];
{
private "_number";
_number = [jna_dataList select (_x select 0 call jn_fnc_arsenal_itemType), _x select 0]call jn_fnc_arsenal_itemCount; 
if ((_number <= (_x select 1)) && !(_number == -1)) then { _emptyList pushBack (_x select 0) }
} forEach _fullUnitGear;
	
if (count _emptyList > 0) exitWith {
		
	equipUnit = false;
		
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
	[
	"FAIL",
	 "Minefields",
	 parseText format["<t color='#ff0000' size='2'>Recruit Squad<br/><t color='#ffffff' size='1.5'>The following gear has run too low for you to recruit this unit: <t color='#ffff00' size='1.5'>%1", _strings], 30] spawn SCRT_fnc_ui_showMessage;
};

if (server getVariable (vehSDKRepair + "_count") < 1) exitWith {
[
  	"FAIL",
    "Minefields",
    parseText "There are no repair vehicles available for the engineer.", 
    30
] spawn SCRT_fnc_ui_showMessage;
};

//

private _nearX = "";

sqdMrkFlsh = true;
	
potMarkers = [];

{
if (sidesX getVariable [_x,sideUnknown] == teamPlayer) then {potMarkers pushBack _x};
} forEach (["Synd_HQ"] + airportsX + milbases);

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

[
  	"Info",
    "Minefields",
    parseText "Select the base you want the explosives engineer to deploy from (HQ, airbases or military bases).", 
    30
] spawn SCRT_fnc_ui_showMessage;

waitUntil {sleep 0.5; (count positionTel > 0) or (isMenuOpen == false)};
onMapSingleClick "";

if (isMenuOpen == false) exitWith {sqdMrkFlsh = false};
sqdMrkFlsh = false;
private _positionTel = positionTel;

_nearX = [(["Synd_HQ"] + airportsX + milbases),_positionTel] call BIS_fnc_nearestPosition;

if ((getMarkerPos _nearX) distance _positionTel > 50) exitWith {
	[
   	"FAIL",
    "Minefields",
    parseText "Select your HQ or a friendly airbase or military base.", 
    30
    ] spawn SCRT_fnc_ui_showMessage;
};

if (not(sidesX getVariable [_nearX,sideUnknown] == teamPlayer)) exitWith {
	[
	   	"FAIL",
        "Minefields",
        parseText "Select your HQ or a friendly airbase or military base.", 
        30
    ] spawn SCRT_fnc_ui_showMessage;
};
{
if (((side _x == Invaders) or (side _x == Occupants)) and (_x distance (getMarkerPos _nearX) < 500) and ([_x] call A3A_fnc_canFight) and !(isPlayer _x)) exitWith {["Minefields", "You cannot deploy units when there are enemies near the base."] call A3A_fnc_customHint};
} forEach allUnits;

positionTel = [];
positionDir = [];
	
private _circleMrk = createMarkerLocal ["BRCircle", (getMarkerPos _nearX)];
_circleMrk setMarkerShapeLocal "ELLIPSE";
_circleMrk setMarkerSizeLocal [250, 250];
_circleMrk setMarkerColorLocal "ColorGreen";
_circleMrk setMarkerAlpha 0.5;

onMapSingleClick "positionTel = _pos";

[
   	"Info",
    "Minefields",
    parseText "Select the location you want the vehicle to deploy at (must be within 250m of squad base).", 
	30
] spawn SCRT_fnc_ui_showMessage;

waitUntil {sleep 0.5; (count positionTel > 0) or (isMenuOpen == false)};
if (isMenuOpen == false) exitWith {deleteMarkerLocal _circleMrk};
		
deleteMarkerLocal _circleMrk;
_positionTel = positionTel;
		
if ((getMarkerPos _nearX) distance _positionTel > 250) exitWith {
	[
	   	"FAIL",
	    "Minefields",
	    parseText "Location must be within 250m of squad base.", 
		30
	] spawn SCRT_fnc_ui_showMessage;
	deleteMarkerLocal _circleMrk;
};

private _originMrk = createMarkerLocal ["BRStart", _positionTel];
_originMrk setMarkerShapeLocal "ICON";
_originMrk setMarkerTypeLocal "hd_end";
_originMrk setMarkerTextLocal "Vehicle Position";

onMapSingleClick "positionDir = _pos";

[
  	"Info",
    "Minefields",
    parseText "Select the direction you want the vehicle to face.", 
	30
] spawn SCRT_fnc_ui_showMessage;

waitUntil {sleep 0.5; (count positionDir > 0) or (isMenuOpen == false)};
if (isMenuOpen == false) exitWith {deleteMarkerLocal _originMrk};
		
private _positionDir = positionDir;
		
private _directionMrk = createMarkerLocal ["BRFin", _positionDir];
_directionMrk setMarkerShapeLocal "ICON";
_directionMrk setMarkerTypeLocal "hd_dot";
_directionMrk setMarkerTextLocal "Vehicle Direction";

sleep 1;
		
deleteMarkerLocal _originMrk;
deleteMarkerLocal _directionMrk;
private _dirVeh = [_positionTel, _positionDir] call BIS_fnc_dirTo;
closeDialog 0;
closeDialog 0;

["Minefields", "An Explosive Specialist is available on your High Command bar.<br/><br/>Send him anywhere on the map to deactivate mines. He will load his vehicle with mines he found.<br/><br/>Upon returning back to HQ he will unload mines stored in his vehicle."] call A3A_fnc_customHint;

//

_groupX = createGroup teamPlayer;

_unit = [_groupX, USExp, (getMarkerPos _nearX), [], 0, "NONE"] call A3A_fnc_createUnit;
[_unit] spawn A3A_fnc_FIAinit;
teamPlayerDeployed = teamPlayerDeployed + 1;
publicVariable "teamPlayerDeployed";
_groupX setGroupIdGlobal [format ["MineSw%1",{side (leader _x) == teamPlayer} count allGroups]];

{ [_x select 0 call jn_fnc_arsenal_itemType, _x select 0, _x select 1]call jn_fnc_arsenal_removeItem } forEach _fullUnitGear;

_minesX = [];
sleep 1;

_truckX = vehSDKRepair createVehicle _positionTel;
_truckX setDir _dirVeh;

[_truckX, teamPlayer] call A3A_fnc_AIVEHinit;
teamPlayerVehDeployed = teamPlayerVehDeployed + 1;
publicVariable "teamPlayerVehDeployed";

_groupX addVehicle _truckX;
[_unit] orderGetIn true;
//_unit setBehaviour "SAFE";
theBoss hcSetGroup [_groupX];


while {alive _unit} do
	{
	waitUntil {sleep 1;(!alive _unit) or (unitReady _unit)};
	if (alive _unit) then
		{
		if (alive _truckX) then
			{
			if ((count magazineCargo _truckX > 0) and (_unit distance (getMarkerPos respawnTeamPlayer) < 100)) then
				{
				[_truckX,boxX] remoteExec ["A3A_fnc_ammunitionTransfer",2];
				sleep 30;
				};
			};
		_minesX = allmines select {(_x distance _unit) < 100};
		if (count _minesX == 0) then
			{
			waitUntil {sleep 1;(!alive _unit) or (!unitReady _unit)};
			}
		else
			{
			moveOut _unit;
			[_unit] orderGetin false;
			_minesX = [_minesX,[],{_unit distance _x},"ASCEND"] call BIS_fnc_sortBy;
			_countX = 0;
			_total = count _minesX;
			while {(alive _unit) and (_countX < _total)} do
				{
				_mineX = _minesX select _countX;
				[_unit] orderGetin false;
				_unit doMove position _mineX;
				_timeOut = time + 15;
				waitUntil {sleep 0.5; (_unit distance _mineX < 8) or (!alive _unit) or (time > _timeOut)};
				if (alive _unit) then
					{
					_unit action ["Deactivate",_unit,_mineX];
					//_unit action ["deactivateMine", _unit];
					sleep 3;
					_toDelete = nearestObjects [position _unit, ["WeaponHolderSimulated", "GroundWeaponHolder", "WeaponHolder"], 9];
					if (count _toDelete > 0) then
						{
						_wh = _toDelete select 0;
						if (alive _truckX) then {_truckX addMagazineCargoGlobal [((magazineCargo _wh) select 0),1]};
						deleteVehicle _mineX;
						deleteVehicle _wh;
						};
					_countX = _countX + 1;
					};
				};
			if(alive _unit) then
				{
				[_unit] orderGetIn true;
				};
			};
		};
	sleep 1;
	};
