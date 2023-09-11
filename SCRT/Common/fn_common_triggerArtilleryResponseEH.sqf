params ["_unit"];

if (side _unit != teamPlayer) exitWith {};

private _gunner  = gunner _unit;
if (!isNull _gunner && {side _gunner != teamPlayer}) exitWith {};

private _artillery = _this select 0;
private _dataX = _artillery getVariable ["detection",[position _artillery,0]];
private _positionX = position _artillery;
_chance = _dataX select 1;
if ((_positionX distance (_dataX select 0)) < 300) then {
    _chance = _chance + 2;
}
else {
    _chance = 0;
};

if (random 100 < _chance) then {
    {
        if !(side _x in [Occupants, Invaders]) then { continue };
        [leader _x, [_artillery, 4]] remoteExec ["reveal", leader _x];
    } forEach allGroups;

    if (_artillery distance posHQ < 300) then {
        if !("DEF_HQ" in A3A_activeTasks) then {
            [[],"A3A_fnc_attackHQ"] remoteExec ["A3A_fnc_scheduler",2];
            _chance = 0;
        };
    } else {
        private _airports = airportsX select {
            (getMarkerPos _x distance _artillery < distanceForAirAttack) and ([_x,true] call A3A_fnc_airportCanAttack) and (sidesX getVariable [_x,sideUnknown] != teamPlayer)
        };

        private _milbases = airportsX select {
            (getMarkerPos _x distance _artillery < distanceForLandAttack) and ([_positionX, getMarkerPos _x] call A3A_fnc_arePositionsConnected) and (sidesX getVariable [_x,sideUnknown] != teamPlayer)
        };
		
		private _artyOutposts = ["outpost_9", "outpost_20", "outpost_17", "outpost_12", "outpost_40"] select {
			(getMarkerPos _x distance _artillery < 8000) and count (nearestObjects [(getMarkerPos _x), [NATOHowitzer], 250]) > 0 and (sidesX getVariable [_x,sideUnknown] != teamPlayer)
		};			
		
        private _bases = _airports + _milbases + _artyOutposts;

        if (count _bases > 0) then {
            private _base = selectRandom _bases;
            _sideX = sidesX getVariable [_base,sideUnknown];
            
            private _reveal = [_positionX, _sideX] call A3A_fnc_calculateSupportCallReveal;
			
			if (_base in _artyOutposts) then {
				[(getPos _artillery)] remoteExec ["A3A_fnc_artyAttack", 2];
			};
			
            if (_base in _airports) then {
                [_artillery, _reveal, ["AIRSTRIKE", "QRF"], _sideX, 0.4] remoteExec ["A3A_fnc_sendSupport", 2];
            }; 
            
            if (_base in _milbases) then {
                [_artillery, _reveal, ["MORTAR", "QRF"], _sideX, 0.75] remoteExec ["A3A_fnc_sendSupport", 2];
            };
        };

        _chance = 0;
    };
};

_artillery setVariable ["detection",[_positionX,_chance]];