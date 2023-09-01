private ["_posUnitsX","_nearX","_thingX","_groupX","_unitsX","_leave","_veh"];

_thingX = _this select 0;

if (((_thingX select 0) isEqualType grpNull) && (count _thingX > 1)) exitWith {["Garrison", "Select only one squad at a time to garrison."] call A3A_fnc_customHint;};

_groupX = grpNull;
_unitsX = objNull;

if ((_thingX select 0) isEqualType grpNull) then
	{
	_groupX = _thingX select 0;
	_unitsX = units _groupX;
	}
else
	{
	_unitsX = _thingX;
	};

_posUnitsX = getPos (_unitsX select 0);

_nearX = [markersX,_posUnitsX] call BIS_fnc_nearestPosition;

if (not(sidesX getVariable [_nearX,sideUnknown] == teamPlayer)) exitWith {["Garrison","The nearest zone does not belong to the Allies."] call A3A_fnc_customHint;};

if ([(_unitsX select 0),300] call A3A_fnc_enemyNearCheck) exitWith {["Garrison", "You cannot garrison units here whilst there are enemies nearby."] call A3A_fnc_customHint;};

_leave = false;

{	
	if (_x distance (getMarkerPos _nearX) > 250) exitWith {_leave = true}
} forEach _unitsX;

if (_leave) exitWith {["Garrison", "Not all units in the group are near the marker."] call A3A_fnc_customHint;};

private _alreadyInGarrison = false;
{
	private _garrisondIn = _x getVariable "markerX";
	if !(isNil "_garrisondIn") then {_alreadyInGarrison = true};
} forEach _unitsX;
if _alreadyInGarrison exitWith {["Garrison", "The units selected already are in a garrison."] call A3A_fnc_customHint};

if ((groupID _groupX in ["MineF", "Watch", "Post", "Road"]) or {(isPlayer(leader _groupX))}) exitWith {
	["Garrison", "You cannot garrison player led, Watchpost, Roadblocks or Minefield building squads"] call A3A_fnc_customHint;
};

{
	if (isPlayer _x or !alive _x) exitWith {_leave = true};
} forEach _unitsX;
if (_leave) exitWith {["Garrison", "Dead or player-controlled units cannot be added to any garrison."] call A3A_fnc_customHint;};

{
	private _unitType = _x getVariable "unitType";
	if (isNil "_unitType") exitWith {_leave = true};
	if ((_unitType in [UKstaticCrewTeamPlayer, USstaticCrewTeamPlayer, SDKUnarmed, UKUnarmed, USUnarmed, typePetros]) or (_unitType in arrayCivs)) exitWith {_leave = true}
} forEach _unitsX;
if (_leave) exitWith {["Garrison", "Static crewmen, prisoners, refugees, Petros or unknown units cannot be added to any garrison."] call A3A_fnc_customHint;};

{
	private _unitType = _x getVariable "unitType";
	if (_unitType in (SASTroops + paraTroops + SDKTroops + [UKPilot, UKCrew, USPilot, USCrew])) exitWith {_leave = true}
} forEach _unitsX;
if (_leave) exitWith {["Garrison", "Only regular US or UK infantry can be added to a garrison."] call A3A_fnc_customHint;};

if (!(isNull _groupX) && !((groupId (hcSelected player select 0) select [3,3]) == "Sqd")) exitWith {["Garrison", "Only regular US or UK infantry squads can be added to a garrison."] call A3A_fnc_customHint;};

if (isNull _groupX) then
	{
	_groupX = createGroup teamPlayer;
	_unitsX joinSilent _groupX;
	//{arrayids = arrayids + [name _x]} forEach _unitsX;
	["Garrison", "Adding units to garrison."] call A3A_fnc_customHint;
		{
		if ((_x getVariable "unitType") in USTroops) then {
			{arrayUSids pushBackUnique (name _x)}};
		
		if ((_x getVariable "unitType") in UKTroops) then {
			{arrayUKids pushBackUnique (name _x)}}
		} forEach _unitsX;
	}
else
	{
	["Garrison", format ["Adding %1 squad to garrison.", groupID _groupX]] call A3A_fnc_customHint;
	theBoss hcRemoveGroup _groupX;
	};

// Send types, because the units may be deleted before the remoteExec hits
private _unitTypes = _unitsX apply { _x getVariable "unitType" };
[_unitTypes,teamPlayer,_nearX,0] remoteExec ["A3A_fnc_garrisonUpdate",2];
_noBorrar = false;

private _veh = objectParent (_unitsX select 0);
if !(isNull _veh) then {
	_groupX leaveVehicle _veh;
	private _typeVehX = typeOf _veh;
	private _count = server getVariable (_typeVehX + "_count");
	_count = _count + 1;
	server setVariable [(_typeVehX + "_count"), _count, true];
	sleep 30;
	deleteVehicle _veh;
};	
	
if (spawner getVariable _nearX != 2) then
{
	private _targPos = getMarkerPos _nearX;
	private _wp = _groupX addWaypoint [(getMarkerPos _nearX), 0];
	_wp setWaypointType "MOVE";
	_groupX setCurrentWaypoint _wp;
	{
	_x setVariable ["markerX",_nearX,true];
	_x setVariable ["spawner",nil,true];
	_x addEventHandler ["killed",
		{
		_victim = _this select 0;
		_markerX = _victim getVariable "markerX";
		if (!isNil "_markerX") then
			{
			if (sidesX getVariable [_markerX,sideUnknown] == teamPlayer) then
				{
				[_victim getVariable "unitType",teamPlayer,_markerX,-1] remoteExec ["A3A_fnc_garrisonUpdate",2];
				_victim setVariable [_markerX,nil,true];
				};
			};
		}];
	} forEach _unitsX;

	// trigger actual garrison join when close to target
	[_nearX, _groupX] spawn {
		params ["_marker", "_group"];
		waitUntil {
			sleep 5;
			isNull leader _group or { leader _group distance getMarkerPos _marker < 20 }
		};
		sleep 10;			// give units some time to get onto marker
		if !(isNull leader _group) then { [_marker] remoteExec ["A3A_fnc_updateRebelStatics", 2] };
	};

	waitUntil {sleep 1; (spawner getVariable _nearX == 2 or !(sidesX getVariable [_nearX,sideUnknown] == teamPlayer))};
	if (!(sidesX getVariable [_nearX,sideUnknown] == teamPlayer)) exitWith {_noBorrar = true};
};

if (!_noBorrar) then
	{
	{
	if (alive _x) then
		{
		deleteVehicle _x
		};
	} forEach _unitsX;
	deleteGroup _groupX;
	}
else
	{
	//añadir el groupX al HC y quitarles variables
	{
	if (alive _x) then
		{
		_x setVariable ["markerX",nil,true];
		_x setVariable ["spawner",true,true];
		_x removeAllEventHandlers "killed";
		_x addEventHandler ["killed", {
			_victim = _this select 0;
			_killer = _this select 1;
			[_victim] remoteExec ["A3A_fnc_postmortem",2];
			if ((isPlayer _killer) and (side _killer == teamPlayer)) then
				{
				if (!isMultiPlayer) then
					{
					_nul = [0,20,0] remoteExec ["A3A_fnc_resourcesFIA",2];
					_killer addRating 1000;
					};
				}
			else
				{
				if (side _killer == Occupants) then
					{
					_nul = [0.25,0,getPos _victim] remoteExec ["A3A_fnc_citySupportChange",2];
					};
				};
			_victim setVariable ["spawner",nil,true];
			}];
		};
	} forEach _unitsX;
	theBoss hcSetGroup [_groupX];
	["Garrison", format ["Group %1 is back to HC control because the zone which was pointed to garrison has been lost.",groupID _groupX]] call A3A_fnc_customHint;
	};
