private ["_markerX","_positionX","_size","_buildings"];

_markerX = _this select 0;

_positionX = getMarkerPos _markerX;
_size = [_markerX] call A3A_fnc_sizeMarker;

_buildings = _positionX nearobjects ["house",_size];

{
	if ((random 100 < 70) && !(isObjectHidden _x) && (damage _x < 1)) then {
		_x setDamage 1;
		sleep 0.4;
	};
} forEach _buildings;

[_markerX,false] spawn A3A_fnc_blackout;