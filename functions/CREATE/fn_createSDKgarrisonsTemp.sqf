// Create a new rebel unit in a garrison that's already spawned

_markerX = _this select 0;
_typeX = _this select 1;
_positionX = getMarkerPos _markerX;
if (_typeX isEqualType "") then
	{
	// Select a suitable group from the current garrison for this unit
	_groups = if (_typeX in [USstaticCrewTeamPlayer, UKstaticCrewTeamPlayer]) then {[]} else {
		allGroups select {
			(leader _x getVariable ["markerX",""] == _markerX)
			and (count units _x < 8) and (vehicle (leader _x) == leader _x)
			and (side _x == teamPlayer)				// can happen with surrendered enemy garrison
		};
	};
	_groupX = if (_groups isEqualTo []) then
		{
		createGroup teamPlayer
		}
	else
		{
		_groups select 0;
		};
	_unit = [_groupX, _typeX, _positionX, [], 0, "NONE"] call A3A_fnc_createUnit;
	[_unit,_markerX] call A3A_fnc_FIAinitBases;
	if (_typeX in [UKMil, USMil, SDKMil]) then { [_markerX] remoteExec ["A3A_fnc_updateRebelStatics", 2] };
	if (_typeX in squadLeaders) then {_groupX selectLeader _unit};
	if (_markerX in watchpostsFIA) then {
		_groupX setBehaviour "STEALTH";
		_groupX setCombatMode "GREEN";
		_unit setVariable ["spawner",true,true];
		_unit setUnitTrait ["camouflageCoef",0.4];
		_unit setUnitTrait ["audibleCoef",0.4];
		[_unit] spawn {
		_unit = _this select 0;
		while {alive _unit} do {	
			waitUntil {sleep 1; ((_unit nearEntities 300) findIf {side _x == Occupants || side _x == Invaders}) != -1 and combatMode (group _unit) == "GREEN"};
			_unit setUnitPos "DOWN";
			waitUntil {sleep 1; ((_unit nearEntities 300) findIf {side _x == Occupants || side _x == Invaders}) == -1 or combatMode (group _unit) != "GREEN"};
			_unit setUnitPos "AUTO";
		};
	};
		};
	if (_groups isEqualTo []) then
		{
		_nul = [leader _groupX, _markerX, "SAFE","SPAWNED","NOVEH2","NOFOLLOW"] execVM "scripts\UPSMON.sqf";//TODO need delete UPSMON link
		};
	
	if (_markerX in (mortarpostsFIA + supportpostsFIA + watchpostsFIA)) exitWith {};
	[_unit,_markerX] spawn
		{
		private _unit = _this select 0;
		private _markerX = _this select 1;
		waitUntil {sleep 1; (spawner getVariable _markerX == 2)};
		if (alive _unit) then
			{
			private _groupX = group _unit;
			if ((_unit getVariable "unitType") in [USstaticCrewTeamPlayer, UKstaticCrewTeamPlayer]) then {deleteVehicle (vehicle _unit)};
			deleteVehicle _unit;
			if (count units _groupX == 0) then {deleteGroup _groupX};
			};
		};
	};
