params ["_newPosition"];

respawnTeamPlayer setMarkerPos _newPosition;
posHQ = _newPosition; publicVariable "posHQ";

[respawnTeamPlayer, 1, teamPlayer] call A3A_fnc_setMarkerAlphaForSide;
[respawnTeamPlayer, 1, civilian] call A3A_fnc_setMarkerAlphaForSide;

private _alignNormals = {
	private _thing = _this;
	_thing setVectorUp surfaceNormal getPos _thing;
};

private _firePos = [_newPosition, 3, getDir petros] call BIS_Fnc_relPos;
_rnd = getdir petros;
_pos = [_firePos, 3, _rnd] call BIS_Fnc_relPos;
boxX setPos _pos;
_rnd = _rnd + 45;
_pos = [_firePos, 3, _rnd] call BIS_Fnc_relPos;
mapX setDir ([_firePos, _pos] call BIS_fnc_dirTo);
mapX setPos _pos;
_rnd = _rnd + 45;
_pos = [_firePos, 3, _rnd] call BIS_Fnc_relPos;
_rnd = _rnd + 45;
_pos = [_firePos, 3, _rnd] call BIS_Fnc_relPos;
_emptyPos = _pos findEmptyPosition [0,50,(typeOf flagX)];
_pos = if (count _emptyPos > 0) then {_emptyPos} else {_pos};
flagX setPos _pos;
_emptyPos = _pos findEmptyPosition [0,50,(typeOf flagX)];
_pos = if (count _emptyPos > 0) then {_emptyPos} else {_pos};
flagUK setPos _pos;
_rnd = _rnd + 45;
_emptyPos = _pos findEmptyPosition [0,50,(typeOf vehicleBox)];
_pos = if (count _emptyPos > 0) then {_emptyPos} else {_pos};
vehicleBox setPos _pos;

//Align with ground. Deliberately ignoring flagX, because a flag pole at 45 degrees looks /weird/
{_x call _alignNormals} forEach [boxX, mapX, vehicleBox];

"Synd_HQ" setMarkerPos _newPosition;
chopForest = false; publicVariable "chopForest";