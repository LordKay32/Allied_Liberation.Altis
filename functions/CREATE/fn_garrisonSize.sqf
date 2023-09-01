params ["_markerX", ["_ignoreFrontier", false]];

if ("carrier" in _markerX) exitWith { 0 };

private _size = [_markerX] call A3A_fnc_sizeMarker;
private _frontierX = if (_ignoreFrontier) then { false } else { [_markerX] call A3A_fnc_isFrontline };

private _groups = 0;

switch(true) do {
    case (_markerX in (airportsX + milbases)): {
        _groups = 2 + round (_size/20);
        _groups = _groups min 10;
        if (_frontierX) then {_groups = _groups + 6};
    };
    case (_markerX in outposts): {
        _groups = 1 + round (_size/20);
        _buildings = nearestObjects [getMarkerPos _markerX,(["Land_TTowerBig_1_F","Land_TTowerBig_2_F","Land_Communication_F"]) + listMilBld, _size];
        if (count _buildings > 0) then {_groups = _groups + 2};
        _groups = _groups min 6;
        if (_frontierX) then {_groups = _groups + 4};
    };
    default {
        _groups = if (sidesX getVariable [_markerX,sideUnknown] == Occupants) then {1 + round (_size/30)} else {1 + round (_size/30)};
        _groups = _groups min 4;
        if (_frontierX) then {_groups = _groups + 2};
    };
};

4 * (_groups max 3);
