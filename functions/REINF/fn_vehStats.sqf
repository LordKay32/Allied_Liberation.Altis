if (count hcSelected player == 0) exitWith {["Vehicle Info", "You must select one group on the HC bar."] call A3A_fnc_customHint;};

private ["_groupX","_veh","_textX","_unitsX","_cargoArray"];

/*
_esStatic = false;
{if (vehicle _x isKindOf "StaticWeapon") exitWith {_esStatic = true}} forEach units _groupX;
if (_esStatic) exitWith {hint "Static Weapon squad vehicles cannot be managed"};
*/

if (_this select 0 == "mount") exitWith
	{
	_textX = "";
	{
	_groupX = _x;
	_veh = objNull;
	{
	_owner = _x getVariable "owner";
	if (!isNil "_owner") then {if (_owner == _groupX) exitWith {_veh = _x}};
	} forEach vehicles;
	if !(isNull _veh) then
		{
		_transporte = true;
		if (count allTurrets [_veh, false] > 0) then {_transporte = false};
		if (_transporte) then
			{
			if ((units _groupX) findIf {vehicle _x != _x} != -1) then
				{
				_textX = format ["%2%1 dismounting<br/>",groupID _groupX,_textX];
				{[_x] orderGetIn false; [_x] allowGetIn false} forEach units _groupX;
				}
			else
				{
				_textX = format ["%2%1 boarding<br/>",groupID _groupX,_textX];
				{[_x] orderGetIn true; [_x] allowGetIn true} forEach units _groupX;
				};
			}
		else
			{
			_cargoArray = [];
			{
			_role = assignedVehicleRole _x;
			if (_role select 0 == "cargo") then {_cargoArray pushBack _x};
			} forEach units _groupX;
			_mounted = true;
			{
			if !(_x in _veh) exitWith {_mounted = false}; 
			} forEach _cargoArray;
			if (_mounted) then
				{
				_textX = format ["%2%1 dismounting<br/>",groupID _groupX,_textX];
				if (canMove _veh) then
					{
					{[_x] orderGetIn false; [_x] allowGetIn false} forEach _cargoArray;
					}
				else
					{
					_veh allowCrewInImmobile false;
					{[_x] orderGetIn false; [_x] allowGetIn false} forEach units _groupX;
					}
				}
			else
				{
				_textX = format ["%2%1 boarding<br/>",groupID _groupX,_textX];
				{[_x] orderGetIn true; [_x] allowGetIn true} forEach units _groupX;
				};
			};
		};
	} forEach hcSelected player;
	if (_textX != "") then {["Vehicle Info", format ["%1",_textX]] call A3A_fnc_customHint;};
	};
	
if (_this select 0 == "transport") exitWith {
	if (count hcSelected player < 1) exitWith {["Vehicle Info", "Select only one group on the HC bar."] call A3A_fnc_customHint;};
	_veh = cursorObject;
	_groupX = hcSelected player select 0;
	if ((units _groupX) findIf {vehicle _x != _x} == -1) then {
		
		hcShowBar false;
		hcShowBar true;

		_units = units _groupX;
	
		_groupLeader = leader _groupX;
	
		_noOfUnits = count _units;
	
		_nearestVehs = nearestObjects [getPos _groupLeader,[],400];
		_nearestBoardableVehs = _nearestVehs select {count (fullCrew [_x, "cargo", true]) >= 2 && side _x == teamPlayer};
		private _vehMarkers = [];
		{
		_vehPos = getPos _x;
		_marker = createMarkerLocal [format ["transport%1", random 1000], _vehPos];
	
		switch (true) do {
			case (typeOf _x in (vehTrucks + vehSupplyTrucks + vehAmmoTrucks)) : {
				_marker setMarkerTypeLocal "plp_icon_truck";
			};
			case (typeOf _x in vehAPCs) : {
				_marker setMarkerTypeLocal "plp_icon_motinfantry";
			};
			case (typeOf _x in vehTanks) : {
				_marker setMarkerTypeLocal "plp_icon_tank";
			};
			case (_x isKindOf "plane") : {
				_marker setMarkerTypeLocal  "plp_icon_planeCargo";
			};
			case (_x isKindOf "ship") : {
				_marker setMarkerTypeLocal "plp_icon_boat";
			};
			default {
				_marker setMarkerTypeLocal "plp_icon_vehicle";
			};
		};

		_cargoSpaces = if (typeOf _x in [vehSDKTransPlaneUK, vehSDKTransPlaneUS]) then {(_x emptyPositions "Cargo") + (_x emptyPositions "Turret")} else {_x emptyPositions "Cargo"};
		private _name = getText (configFile >> "CfgVehicles" >> typeOf _x >> "displayName");

		if (_noOfUnits <= _cargoSpaces) then {
			_marker setMarkerColorLocal colorTeamPlayer;
		} else {
			_marker setMarkerColorLocal "ColorUNKNOWN";
		};

		_marker setMarkerTextLocal format ["%1: %2 cargo spaces", _name,_cargoSpaces];
		_vehMarkers pushBack _marker;
		} forEach _nearestBoardableVehs;

		if (!visibleMap) then {openMap true};

		positionTel = [];

		onMapSingleClick "positionTel = _pos";

		["Group Transport", "Select transport vehicle."] call A3A_fnc_customHint;

		waitUntil {sleep 0.5; (count positionTel > 0) or (not visiblemap)};
		onMapSingleClick "";

		if (!visibleMap) exitWith {{deleteMarkerLocal _x} forEach _vehMarkers};

		_positionTel = positionTel;

		_vehDistances = [];
		{
		_distance = getPos _x distance _positionTel;
		_vehDistances pushBack [_distance,_x];
		} forEach _nearestBoardableVehs;
	
		_vehDistances sort true;
	
		_veh = (_vehDistances select 0) select 1;
		
		_cargoSpacesVeh = _veh emptyPositions "Cargo";
		if (_noOfUnits > _cargoSpacesVeh) exitWith {["Group Transport", "The selected vehicle does not have enough cargo space for this group."] call A3A_fnc_customHint; {deleteMarkerLocal _x} forEach _vehMarkers};

		if (typeOf _veh in [vehSDKTransPlaneUK, vehSDKTransPlaneUS, vehSDKBoat, vehInfSDKBoat]) then {
			[_groupX, _veh] spawn {
			params ["_groupX", "_veh"];
			units _groupX doMove (getPos _veh);
			_groupX addVehicle _veh;
			waitUntil {sleep 1; leader _groupX distance _veh < 30};
			{
			[_x] allowGetIn true;
			_x moveInAny _veh;
			sleep 0.5;
			} forEach units _groupX};
		} else {
			{
			[_x] allowGetIn true; _x assignAsCargo _veh; [_x] orderGetIn true; 
			} forEach units _groupX;
		};
		private _nameVeh = getText (configFile >> "CfgVehicles" >> typeOf _veh >> "displayName");
		["Group Transport", format ["%1 boarding %2.", _groupX, _nameVeh]] call A3A_fnc_customHint;
		{deleteMarkerLocal _x} forEach _vehMarkers;
	} else {
		{
		unassignVehicle	_x;
		[_x] allowGetIn false;
		} forEach units _groupX;
	};
};	
	
	
_textX = "";
_groupX = (hcSelected player select 0);
player sideChat format ["%1, SITREP!!",groupID _groupX];
_unitsX = units _groupX;
_holding = if (_unitsX findIf {_x checkAIFeature "PATH" == false} != -1) then {"Disabled"} else {"Enabled"};
_textX = format ["%1 Status<br/><br/>Alive members: %2<br/>Able to combat: %3<br/>Current task: %4<br/>Combat Mode: %5<br/>Movement: %6<br/>",groupID _groupX,{alive _x} count _unitsX,{[_x] call A3A_fnc_canFight} count _unitsX,_groupX getVariable ["taskX","Patrol"],behaviour (leader _groupX),_holding];
if ({[_x] call A3A_fnc_isMedic} count _unitsX > 0) then {_textX = format ["%1Operative Medic<br/>",_textX]} else {_textX = format ["%1No operative Medic<br/>",_textX]};
if ({_x call A3A_fnc_typeOfSoldier == "ATMan"} count _unitsX > 0) then {_textX = format ["%1With AT capabilities",_textX]};
if (!(isNull(_groupX getVariable ["mortarsX",objNull])) or ({_x call A3A_fnc_typeOfSoldier == "StaticMortar"} count _unitsX > 0)) then
	{
	if ({vehicle _x isKindOf "StaticWeapon"} count _unitsX > 0) then {_textX = format ["%1<br/>Mortar is deployed",_textX]} else {_textX = format ["%1Mortar not deployed<br/>",_textX]};
	}
else
	{
	if ({_x call A3A_fnc_typeOfSoldier == "StaticGunner"} count _unitsX > 0) then
		{
		if ({vehicle _x isKindOf "StaticWeapon"} count _unitsX > 0) then {_textX = format ["%1<br/>Static is deployed",_textX]} else {_textX = format ["%1Static not deployed<br/>",_textX]};
		};
	};

_veh = objNull;
{
_owner = _x getVariable "owner";
if (!isNil "_owner") then {if (_owner == _groupX) exitWith {_veh = _x}};
} forEach vehicles;
if (isNull _veh) then
	{
	{
	if ((vehicle _x != _x) and (_x == driver _x) and !(vehicle _x isKindOf "StaticWeapon")) exitWith {_veh = vehicle _x};
	} forEach _unitsX;
	};
if !(isNull _veh) then
	{
	_textX = format ["%1<br/>Current vehicle:<br/>%2<br/>",_textX,getText (configFile >> "CfgVehicles" >> (typeOf _veh) >> "displayName")];
	if (!alive _veh) then
		{
		_textX = format ["%1DESTROYED",_textX];
		}
	else
		{
		if (!canMove _veh) then {_textX = format ["%1DISABLED<br/>",_textX]};
		if (count allTurrets [_veh, false] > 0) then
			{
			if (!canFire _veh) then {_textX = format ["%1WEAPON DISABLED<br/>",_textX]};
			if (someAmmo _veh) then {_textX = format ["%1Munitioned<br/>",_textX]};
			};
		_textX = format ["%1Boarded:%2/%3",_textX,{vehicle _x == _veh} count _unitsX,{alive _x} count _unitsX];
		};
	};
if (combatMode _groupX == "GREEN") then {_textX = format ["%1<br/><br/><t color='#ff0000'>HOLDING FIRE</t>",_textX];};
if (fleeing (leader _groupX)) then {_textX = format ["%1<br/><br/><t color='#ff0000'>RETREATING</t>",_textX];};

["Vehicle Info", format ["%1",_textX]] call A3A_fnc_customHint;

