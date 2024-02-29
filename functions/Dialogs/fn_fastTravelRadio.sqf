private ["_roads","_pos","_positionX","_groupX"];

private _checkX = false;
private _distanceX = 250;

private _markersX = markersX + [respawnTeamPlayer];

if (!isNil "isRallyPointPlaced" && {isRallyPointPlaced}) then {
	_markersX = _markersX + [rallyPointMarker];
};

if (vehicle player != player) exitWith {
	["Fast Travel", "You cannot fast travel in a vehicle."] call SCRT_fnc_misc_showDeniedActionHint;
};

if (!isNil "A3A_FFPun_Jailed" && {(getPlayerUID player) in A3A_FFPun_Jailed}) exitWith {["Fast Travel", "You cannot fast travel while being FF Punished."] call A3A_fnc_customHint;};

if (player != player getVariable ["owner",player]) exitWith {
	["Fast Travel", "You cannot Fast Travel while you are controlling AI"] call SCRT_fnc_misc_showDeniedActionHint;
};
private _friendlyBases = _markersX select {(_x in (["Synd_HQ"] + airportsX + milbases + supportpostsFIA)) && (sidesX getVariable [_x,sideUnknown] == teamPlayer)};
private _origin = [_friendlyBases, position player] call BIS_Fnc_nearestPosition; 
if (player distance getMarkerPos _origin > _distanceX) exitWith {["Fast Travel", "You can only fast travel from HQ, Airports, Military Bases and Support Posts."] call SCRT_fnc_misc_showDeniedActionHint;};

positionTel = [];

["Fast Travel", "Click on the zone you want to travel."] call A3A_fnc_customHint;
if (!visibleMap) then {openMap true};
onMapSingleClick "positionTel = _pos;";

waitUntil {sleep 1; (count positionTel > 0) or (not visiblemap)};
onMapSingleClick "";

private _positionTel = positionTel;
private _earlyEscape = false;

if (count _positionTel > 0) then {
	private _base = [_markersX, _positionTel] call BIS_Fnc_nearestPosition;
	if (!isNil "rallyPointMarker" && {_base == rallyPointMarker}) then {
		[] spawn SCRT_fnc_rally_travelToRallyPoint;
		openMap false;
		_earlyEscape = true;
	};
};

if (_earlyEscape) exitWith {};

private _isEnemiesNearby = false;

if(fastTravelIndividualEnemyCheck) then {
	_isEnemiesNearby = [player,_distanceX] call A3A_fnc_enemyNearCheck;

} else {
	
	if ([player,_distanceX] call A3A_fnc_enemyNearCheck) exitWith {_isEnemiesNearby = true}
	
};

if (_isEnemiesNearby) exitWith {
	["Fast Travel", "You cannot Fast Travel with enemies near the group."] call SCRT_fnc_misc_showDeniedActionHint;
};

if (count _positionTel > 0) then {
	_base = [_markersX, _positionTel] call BIS_Fnc_nearestPosition;

	if !(_base in (["Synd_HQ"] + airportsX + milbases + supportpostsFIA)) exitWith {
		["Fast Travel", "Players are only allowed to Fast Travel to HQ, Airbases, Military Bases, Support Posts and the Rally Point."] call SCRT_fnc_misc_showDeniedActionHint;
	};

	if ((sidesX getVariable [_base,sideUnknown] == Occupants) or (sidesX getVariable [_base,sideUnknown] == Invaders)) exitWith {
		["Fast Travel", "You cannot Fast Travel to an enemy controlled zone"] call A3A_fnc_customHint; openMap [false,false];
	};

	if ([getMarkerPos _base,_distanceX] call A3A_fnc_enemyNearCheck) exitWith {
		["Fast Travel", "You cannot Fast Travel to an area under attack or with enemies in the surrounding."] call SCRT_fnc_misc_showDeniedActionHint; openMap [false,false]
	};

	if (_positionTel distance getMarkerPos _base < 100) then {
		_positionX = [getMarkerPos _base, 10, random 360] call BIS_Fnc_relPos;

		//if (!_esHC) then {disableUserInput true; cutText ["Fast traveling, please wait","BLACK",2]; sleep 2;} else {hcShowBar false;hcShowBar true;hint format ["Moving group %1 to destination",groupID _groupX]; sleep _distanceX;};
		_forcedX = false;
		if (!isMultiplayer) then {if (not(_base in forcedSpawn)) then {_forcedX = true; forcedSpawn = forcedSpawn + [_base]}};
		_distanceX = round ((player distance _positionX)/100);
		disableUserInput true; cutText [format ["Fast traveling, travel time: %1s , please wait", _distanceX],"BLACK",1]; sleep 1;

 			_timePassed = 0;
 			while {_timePassed < _distanceX} do
 				{
 				cutText [format ["Fast traveling, travel time: %1s , please wait", (_distanceX - _timePassed)],"BLACK",0.0001];
 				sleep 1;
 				_timePassed = _timePassed + 1;
 				};

		_positionX = _positionX findEmptyPosition [1,50,"man"];
		player setPosATL _positionX;

		disableUserInput false; cutText ["You arrived at the destination.","BLACK IN",1];
		if (_forcedX) then {forcedSpawn = forcedSpawn - [_base]};
		sleep 5;
		}
	else
		{
		["Fast Travel", "You must click near a marker under your control."] call SCRT_fnc_misc_showDeniedActionHint;
		};
	};
openMap false;
