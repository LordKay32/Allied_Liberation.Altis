if (!isServer and hasInterface) exitWith {};

private ["_groupX","_unit","_radiusX","_roads","_road","_pos","_truckX","_textX","_mrk","_ATminesAdd","_APminesAdd","_tsk","_magazines","_typeMagazines","_cantMagazines","_newCantMagazines","_mineX","_typeX","_truckX"];

private _typeX = _this select 0;
private _positionMines = _this select 1;
private _quantity = _this select 2;
private _mine = _this select 3;

private _allLoadouts = [];

private _costs = (2*(server getVariable USExp)) + ([vehSDKLightUnarmed] call A3A_fnc_vehiclePrice);
[-2,(-1*_costs), USExp] remoteExec ["A3A_fnc_resourcesFIA",2];

#include "\A3\Ui_f\hpp\defineResinclDesign.inc"

_index = _mine call jn_fnc_arsenal_itemType;
[_index,_mine,_quantity] call jn_fnc_arsenal_removeItem;

_mrk = createMarker [format ["Minefield%1", random 1000], _positionMines];
_mrk setMarkerShape "ELLIPSE";
_mrk setMarkerSize [100,100];
_mrk setMarkerType "hd_warning";
_mrk setMarkerColor "ColorRed";
_mrk setMarkerBrush "DiagGrid";
[_mrk,0] remoteExec ["setMarkerAlpha",[Occupants,Invaders]];

//
["minefieldMap", "onMapSingleClick"] call BIS_fnc_removeStackedEventHandler;

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
    parseText "Select the base you want the outpost squad to deploy from (HQ, airbases or military bases).", 
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
_circleMrk setMarkerAlphaLocal 0.5;

onMapSingleClick "positionTel = _pos";

[
   	"Info",
    "Minefields",
    parseText "Select the location you want the squad vehicle to deploy at (must be within 250m of squad base).", 
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
    parseText "Select the direction you want the squad vehicle to face.", 
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

//

private _taskId = "Mines" + str A3A_taskCount;
[[teamPlayer,civilian],_taskId,[format ["An Engineer Team has been deployed at your command with High Command Option. Once they reach the position, they will start to deploy %1 mines in the area. Cover them in the meantime.",_quantity],"Minefield Deploy",_mrk],_positionMines,false,0,true,"map",true] call BIS_fnc_taskCreate;
[_taskId, "Mines", "CREATED"] remoteExecCall ["A3A_fnc_taskUpdate", 2];

_positionX = getMarkerPos _nearX;

_groupX = createGroup teamPlayer;

_unit = [_groupX, USExp, _positionX, [], 0, "NONE"] call A3A_fnc_createUnit;
sleep 1;
_unit = [_groupX, USExp, _positionX, [], 0, "NONE"] call A3A_fnc_createUnit;
_groupX setGroupId ["MineF"];

_road = [getMarkerPos respawnTeamPlayer] call A3A_fnc_findNearestGoodRoad;
_pos = position _road findEmptyPosition [1,30,vehSDKLightUnarmed];

_truckX = vehSDKLightUnarmed createVehicle _positionTel;
_truckX setDir _dirVeh;

_groupX addVehicle _truckX;
{
	[_x] spawn A3A_fnc_FIAinit; 
	[_x] orderGetIn true;
	_loadout = rebelLoadouts get USExp;
	_fullUnitGear = _loadout call A3A_fnc_reorgLoadoutUnit;
	{ [_x select 0 call jn_fnc_arsenal_itemType, _x select 0, _x select 1]call jn_fnc_arsenal_removeItem } forEach _fullUnitGear;
	teamPlayerDeployed = teamPlayerDeployed + 1;
	publicVariable "teamPlayerDeployed";
} forEach units _groupX;

[_truckX, teamPlayer] call A3A_fnc_AIVEHinit;
[_truckX] spawn A3A_fnc_vehDespawner;
leader _groupX setBehaviour "SAFE";
theBoss hcSetGroup [_groupX];
_truckX allowCrewInImmobile true;

//waitUntil {sleep 1; (count crew _truckX > 0) or (!alive _truckX) or ({alive _x} count units _groupX == 0)};

waitUntil {sleep 1; (!alive _truckX) or ((_truckX distance _positionMines < 50) and ({alive _x} count units _groupX > 0))};

if ((_truckX distance _positionMines < 50) and ({alive _x} count units _groupX > 0)) then
	{
	if (isPlayer leader _groupX) then
		{
		_owner = (leader _groupX) getVariable ["owner",leader _groupX];
		(leader _groupX) remoteExec ["removeAllActions",leader _groupX];
		_owner remoteExec ["selectPlayer",leader _groupX];
		(leader _groupX) setVariable ["owner",_owner,true];
		{[_x] joinsilent group _owner} forEach units group _owner;
		[group _owner, _owner] remoteExec ["selectLeader", _owner];
		"" remoteExec ["hint",_owner];
		waitUntil {!(isPlayer leader _groupX)};
		};
	theBoss hcRemoveGroup _groupX;
	[petros,"hint","Engineer Team deploying mines.", "Minefields"] remoteExec ["A3A_fnc_commsMP",[teamPlayer,civilian]];
	_nul = [leader _groupX, _mrk, "SAFE","SPAWNED", "SHOWMARKER"] execVM "scripts\UPSMON.sqf";//TODO need delete UPSMON link
	sleep 30*_quantity;
	if ((alive _truckX) and ({alive _x} count units _groupX > 0)) then
		{
		{deleteVehicle _x; _unitLoadout = getUnitLoadout _x; _allLoadouts pushBack _unitLoadout; teamPlayerStoodDown = teamPlayerStoodDown + 1 ;publicVariable "teamPlayerStoodDown"} forEach units _groupX;
		deleteGroup _groupX;
		deleteVehicle _truckX;
		_mineType = _mine trim ["_mag", 2];
		for "_i" from 1 to _quantity do {
			if (_typeX == "ATMine") then {
				if (random 100 < 33) then {
					_mineX = createMine [_mineType,_positionMines,[],100];
				} else {
					_roadPos = [[[_positionMines, 100]], [], { isOnRoad _this }] call BIS_fnc_randomPos;
					if (count _roadPos == 2) then {_mineX = createMine [_mineType,_positionMines,[],100]} else {_mineX = createMine [_mineType,_roadPos,[],0]};
				};
			} else {
				_mineX = createMine [_mineType,_positionMines,[],100];
			};
			teamPlayer revealMine _mineX;
		};
		[_taskId, "Mines", "SUCCEEDED"] call A3A_fnc_taskSetState;
		sleep 15;
		[_taskId, "Mines", 0] spawn A3A_fnc_taskDelete;
		[2,_costs,USExp] remoteExec ["A3A_fnc_resourcesFIA",2];
		
		_fullSquadGear = _allLoadouts call A3A_fnc_reorgLoadoutSquad;
		{ [_x select 0 call jn_fnc_arsenal_itemType, _x select 0, _x select 1]call jn_fnc_arsenal_addItem } forEach _fullSquadGear;
		}
	else
		{
		[_taskId, "Mines", "FAILED"] call A3A_fnc_taskSetState;
		sleep 15;
		theBoss hcRemoveGroup _groupX;
		[_taskId, "Mines", 0] spawn A3A_fnc_taskDelete;
		{deleteVehicle _x} forEach units _groupX;
		deleteGroup _groupX;
		deleteVehicle _truckX;
		deleteMarker _mrk;
		};
	}
else
	{
	[_taskId, "Mines", "FAILED"] call A3A_fnc_taskSetState;
	sleep 15;
	theBoss hcRemoveGroup _groupX;
	[_taskId, "Mines", 0] spawn A3A_fnc_taskDelete;
	{deleteVehicle _x} forEach units _groupX;
	deleteGroup _groupX;
	deleteVehicle _truckX;
	deleteMarker _mrk;
	};
