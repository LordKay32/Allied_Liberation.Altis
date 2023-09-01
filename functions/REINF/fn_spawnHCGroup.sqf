/*
Author: Håkon
Description:
    handles spawning in HC groups

Arguments:
0. <Array> Units types to spawn
1. <String> ID format for the group
2. <String> Special handling of group spawning
3. <Object> Vehicle to assign to the group (optional)

Return Value:
<Group> The spawned group

Scope: Any
Environment: Any
Public: Yes
Dependencies:

Example:

License: MIT License
*/
params [
    ["_unitTypes", [], [[]]]
    , ["_idFormat", "", [""]]
    , ["_special", "", [""]]

];

private ["_markerX"];

private _vehicleOrBase = _this select 3;

private _vehicle = objNull;
private _spawnPos = [];

if (_vehicleOrBase in (["Synd_HQ"] + airportsX + milbases + citiesX)) then {
	_spawnPos = getMarkerPos _vehicleOrBase;
} else {
	_vehicle = _vehicleOrBase;
	_markerX = [(["Synd_HQ"] + airportsX + milbases + seaports + citiesX + supportpostsFIA),getPos _vehicle] call BIS_fnc_nearestPosition;
	_spawnPos = getMarkerPos _markerX
};

//calculate base cost
private _cost = if (isNull _vehicle) then { 0 } else { [typeOf _vehicle] call A3A_fnc_vehiclePrice };
private _costHR = 0;
{
    _cost = _cost + (server getVariable _x); _costHR = _costHR + 1
} forEach _unitTypes;

//spawn group
private _pos = [_spawnPos, 30, random 360] call BIS_Fnc_relPos;
private _group = [_pos, teamPlayer, _unitTypes, true] call A3A_fnc_spawnGroup;
_group setGroupIdGlobal [_idFormat + str ({side (leader _x) == teamPlayer} count allGroups)];

private _units = units _group;
{
[_x] call A3A_fnc_FIAinit; 
teamPlayerDeployed = teamPlayerDeployed + 1;
publicVariable "teamPlayerDeployed";
if ((_x getVariable "unitType") in squadLeaders) then {_x linkItem "ItemRadio"};
} forEach _units;
_group setBehaviour "SAFE";
theBoss hcSetGroup [_group];

if ((groupId _group select [0,3]) == "Sup") then {[_units, _vehicle] spawn {
	_units = _this select 0;
	_vehicle = _this select 1;
	waitUntil {sleep 1; (((_units select 0) in _vehicle) && ((_units select 1) in _vehicle))};
	{
		_x disableAI "AUTOCOMBAT";
		_x disableAI "AUTOTARGET";
		_x disableAI "TARGET";
		_x setBehaviour "CARELESS";
	} forEach _units;
	};
};

if (_idFormat == "SAS-Rcn-") then {
	_group setBehaviour "STEALTH";
	_group setCombatMode "GREEN";
	[_group] spawn A3A_fnc_reconSquadRecon;
};

if (_idFormat in ["Nav.Inf-","RAF.Tran-","USAAF.Tran-"]) then {
		{
		_x disableAI "AUTOCOMBAT";
		_x disableAI "AUTOTARGET";
		_x disableAI "TARGET";
		_x setBehaviour "CARELESS";
	} forEach _units;
};

petros directSay "SentGenReinforcementsArrived";
["Deploy Squad", format ["Group %1 at your command.<br/><br/>Groups are managed from the High Command bar (Default: CTRL+SPACE)<br/><br/>If the group gets stuck, use the AI Control feature to make them start moving. Mounted Static teams tend to get stuck (solving this is WiP)<br/><br/>To assign a vehicle for this group, look at some vehicle, and use Vehicle Squad Mngmt option in Y menu.", groupID _group]] call A3A_fnc_customHint;

private _countUnits = count _units -1;
private _bypassAI = true;

//vehicle init funcs
private _initInfVeh = {
    if (isNull _vehicle) exitWith {};
    leader _group assignAsDriver _vehicle;
    call _initVeh;
    ["Deploy Squad", "Vehicle Purchased"] call A3A_fnc_customHint;
    petros directSay "SentGenBaseUnlockVehicle";
};

private _initVeh = {
    [_vehicle, teamPlayer] call A3A_fnc_AIVEHinit;
    [_vehicle] spawn A3A_fnc_vehDespawner;
    _group addVehicle _vehicle;
    _vehicle setVariable ["owner",_group,true];
    if (typeOf _vehicle in [vehSDKTankUSM4,vehSDKTankUSM5,vehSDKTankUKM4,vehSDKTankChur]) then {leader _group assignAsCommander _vehicle} else {leader _group assignAsDriver _vehicle};
    driver _vehicle action ["engineOn", _vehicle];
    {[_x] orderGetIn true; [_x] allowGetIn true} forEach units _group;
    
    if (_markerX in supportpostsFIA) exitWith {
    	[_markerX, _vehicle] spawn {
    		private ["_markerX","_vehicle","_staticPositionInfo","_staticDirection","_crew","_posObject","_pos","_dir","_typeX","_crewType","_time"];
    		_markerX = _this select 0;
    		_vehicle = _this select 1;
    		_staticPositionInfo = staticPositions getVariable [_markerX, []];
			_staticDirection = _staticPositionInfo select 1;
    		waitUntil {sleep 5; _vehicle distance (getMarkerPos _markerX) > 50};
   			waitUntil {sleep 5; _vehicle distance (getMarkerPos _markerX) < 35};
			_crew = (crew _vehicle) select {alive _x};
			doGetOut _crew;
			_crew allowGetIn false;
			sleep 10;
			_crewType = [];
			{
			_typeX = _x getVariable "unitType";
			_crewType pushBack _typeX;
			} forEach _crew;
			[(count _crewType),0,_crewType] remoteExec ["A3A_fnc_resourcesFIA",2];
			{
			deleteVehicle _x
			} forEach _crew;
			_posObject = ((getMarkerPos _markerX) nearObjects ["Land_HelipadEmpty_F", 15]) select 0;
			
			if (typeOf _vehicle == vehSDKRepair) then {_pos = _posObject getRelPos [11.5, 40]; _dir = _staticDirection + 315};
			if (typeOf _vehicle == vehSDKAmmo) then {_pos = _posObject getRelPos [12, 310]; _dir = _staticDirection + 225};
			if (typeOf _vehicle == vehSDKFuel) then {_pos = _posObject getRelPos [12, 230];	_dir = _staticDirection + 315};
			if (typeOf _vehicle == vehSDKMedical) then {_pos = _posObject getRelPos [12, 140]; _dir = _staticDirection + 225};			
			
			_time = time + 30;
			waitUntil {sleep 2; (count (_pos findEmptyPosition [0, 0, vehSDKRepair]) > 0) || time == _time};
			if (time == _time) exitWith {};
			if (count (_pos findEmptyPosition [0, 0, vehSDKRepair]) > 0) then {_vehicle setDir _dir; _vehicle setPos _pos;}
    	};
    };
    
    private _count = server getVariable ((typeOf _vehicle) + "_count");
    _count = _count - 1;
    server setVariable [((typeOf _vehicle) + "_count"), _count, true];
};

// special handling
switch _special do {
    //static squad
    case "staticAutoT": {
        private _staticType = switch _idFormat do {
            case "US-Mort-": {SDKMortar};
            case "UK-MG-": {UKMGStatic};
            case "US-MG-": {USMGStatic};
            default {""};
        };

        call _initInfVeh;
        _group setVariable ["staticAutoT",false,true];
        [_group, _staticType] spawn A3A_fnc_MortyAI;
        _cost = _cost + ([_staticType] call A3A_fnc_vehiclePrice);
        private _count = server getVariable (_staticType + "_count");
    	_count = _count - 1;
    	server setVariable [(_staticType + "_count"), _count, true];
    };

    //vehicle squad
    case "BuildAA": {
        (_units # 0) assignAsDriver _vehicle;
        (_units # 4) assignAsGunner _vehicle;
        call _initVeh;
        _cost = _cost + ([staticAAteamPlayer] call A3A_fnc_vehiclePrice);

    };
    case "VehicleSquad": {
        (_units # (_countUnits -1)) assignAsDriver _vehicle;
        (_units # _countUnits) assignAsGunner _vehicle;
        call _initVeh;
    };

    //inf squad
    _bypassAI = false;
    call _initInfVeh;
    case "MG": {
        (_units # (_countUnits - 1)) addBackpackGlobal supportStaticsSDKB2;
        (_units # _countUnits) addBackpackGlobal MGStaticSDKB;
        _cost = _cost + ([SDKMGStatic] call A3A_fnc_vehiclePrice);
    };
    case "Mortar": {
        (_units # (_countUnits - 1)) addBackpackGlobal supportStaticsSDKB3;
        (_units # _countUnits) addBackpackGlobal MortStaticSDKB;
        _cost = _cost + ([SDKMortar] call A3A_fnc_vehiclePrice);
    };
};

[- _costHR, - _cost, (_unitTypes select 0)] remoteExec ["A3A_fnc_resourcesFIA", 2];

if !(_bypassAI) then {_group spawn A3A_fnc_attackDrillAI};

_group
