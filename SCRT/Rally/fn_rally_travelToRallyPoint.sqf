if (isNil "rallyProps" || {count rallyProps < 1}) exitWith {
    ["Rally Point", "the rally point does not exist."] call SCRT_fnc_misc_showDeniedActionHint;
};

if (vehicle player != player) exitWith {
    ["Rally Point", "You can't travel to the rally point in a vehicle."] call SCRT_fnc_misc_showDeniedActionHint;
};

if !([player] call A3A_fnc_canFight) exitWith {
    ["Rally Point", "You cannot fast travel while being unconscious."] call SCRT_fnc_misc_showDeniedActionHint;
};

if !((vehicle player getVariable "SA_Tow_Ropes") isEqualTo objNull) exitWith {
    ["Rally Point", "You cannot travel with your Tow Rope out or a Vehicle attached."] call SCRT_fnc_misc_showDeniedActionHint;
};

if (player != player getVariable ["owner",player]) exitWith {
    ["Rally Point", "You cannot travel to rally point while you are controlling AI."] call SCRT_fnc_misc_showDeniedActionHint;
};

private _friendlyBases = markersX select {_x in (["Synd_HQ"] + airportsX + milbases + supportpostsFIA); sidesX getVariable [_x,sideUnknown] == teamPlayer};
private _origin = [_friendlyBases, position player] call BIS_Fnc_nearestPosition; 
if (player distance getMarkerPos _origin > 250) exitWith {["Fast Travel", "You can only fast travel from HQ, Airports, Military Bases and Support Posts."] call SCRT_fnc_misc_showDeniedActionHint;};

private _remainingTravels = rallyPointRoot getVariable ["remainingTravels", 0];

if (_remainingTravels < 1) exitWith {
    ["Rally Point", "Not enough travel points."] call SCRT_fnc_misc_showDeniedActionHint;
    remoteExecCall ["SCRT_fnc_rally_deleteRallyPoint",2];
};

private _rallyPoint = rallyProps select 0;
private _rallyPosition = position _rallyPoint;

if ([_rallyPoint, 50] call A3A_fnc_enemyNearCheck) exitWith {
    ["Rally Point", "You cannot travel when enemies are surrounding rally point."] call SCRT_fnc_misc_showDeniedActionHint;
};

private _positionX = [_rallyPosition, 10, random 360] call BIS_fnc_relPos;
private _distanceX = round (((player distance2D _positionX)/100));

disableUserInput true; 
cutText [format ["Traveling to rally point, travel time: %1s, please wait.", _distanceX],"BLACK",1]; 
sleep 1;

private _timePassed = 0;

while {_timePassed < _distanceX} do {
    cutText [format ["Traveling to rally point, travel time: %1s, please wait.", (_distanceX - _timePassed)],"BLACK",0.0001];
    sleep 1;
    _timePassed = _timePassed + 1;
};

_positionX = _positionX findEmptyPosition [1,50,"man"];
player setPosATL _positionX;

disableUserInput false;
cutText ["You arrived to rally point.", "BLACK IN", 1];

private _remainingTravels = _remainingTravels - 1;
rallyPointRoot setVariable ["remainingTravels", _remainingTravels, true];
rallyPointMarker setMarkerText (format ["Rally Point (Remaining Travels: %1)", str _remainingTravels]);

if (_remainingTravels < 1) then {
    remoteExecCall ["SCRT_fnc_rally_deleteRallyPoint",2];
};

sleep 5;
{_x allowDamage true} forEach units _groupX;