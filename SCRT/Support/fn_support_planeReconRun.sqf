private _positionOrigin = getMarkerPos supportMarkerOrigin;
private _positionDestination = getMarkerPos supportMarkerDestination;
private _angle = [_positionOrigin, _positionDestination] call BIS_fnc_dirTo;
private _angleOrigin = _angle - 180;

private _originPosition = [_positionOrigin, 3000, _angleOrigin] call BIS_fnc_relPos;

private _planeData = [_originPosition, _angle, vehSDKPlaneUK2, teamPlayer] call A3A_fnc_spawnVehicle;
private _plane = _planeData select 0;
private _planeCrew = _planeData select 1;
private _groupPlane = _planeData select 2;

_plane setPosATL [getPosATL _plane select 0, getPosATL _plane select 1, 1000];
_plane disableAI "TARGET";
_plane disableAI "AUTOTARGET";
private _minAltASL = ATLToASL [_positionDestination select 0, _positionDestination select 1, 0];
_plane flyInHeightASL [(_minAltASL select 2) +75, (_minAltASL select 2) +75, (_minAltASL select 2) +57];

driver _plane sideChat "Starting plane run. ETA 30 seconds.";
private _wp1 = group _plane addWaypoint [_positionOrigin, 0];
_wp1 setWaypointType "MOVE";
_wp1 setWaypointSpeed "LIMITED";
_wp1 setWaypointBehaviour "CARELESS";

    private _wp = group _plane addWaypoint [_positionDestination, 0];
    _wp setWaypointSpeed "LIMITED";
    _wp setWaypointType "LOITER";
	_wp setWaypointTimeout [30, 45, 60];

        _wp setWaypointStatements ["true", format ["if !(local this) exitWith {}; [%1, %2, %3] spawn SCRT_fnc_common_recon;isSupportMarkerPlacingLocked=false;publicVariable 'isSupportMarkerPlacingLocked';", _positionDestination, 350, 180]];


_wp3 = group _plane addWaypoint [_originPosition, 3];
_wp3 setWaypointType "MOVE";
_wp3 setWaypointSpeed "FULL";

private _timeOut = time + 600;
sleep 15;
waitUntil { sleep 1; (getPos _plane distance2D _originPosition < 200) or (time > _timeOut) or !(canMove _plane) };

if (isSupportMarkerPlacingLocked) then {
    isSupportMarkerPlacingLocked = false;
    publicVariable "isSupportMarkerPlacingLocked";
};

if !(canMove _plane) then { sleep cleantime };
deleteVehicle _plane;
{deleteVehicle _x} forEach _planeCrew;
deleteGroup _groupPlane;