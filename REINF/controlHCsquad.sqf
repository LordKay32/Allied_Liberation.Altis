if (player != theBoss) exitWith {["Control Squad", "Only Commander has the ability to control HC units."] call A3A_fnc_customHint;};
if (captive player) exitWith {["Control Squad", "You cannot control squads while undercover."] call A3A_fnc_customHint;};
if (!isNil "A3A_FFPun_Jailed" && {(getPlayerUID player) in A3A_FFPun_Jailed}) exitWith {["Control Squad", "Nope. Not happening."] call A3A_fnc_customHint;};

_groups = _this select 0;

_groupX = _groups select 0;
_unit = leader _groupX;
private _name = name _unit;

private _face = face _unit;
private _voice = speaker player;

if !([_unit] call A3A_fnc_canFight) exitWith {["Control Squad", "You cannot control an unconscious or dead unit."] call A3A_fnc_customHint;};

while {(count (waypoints _groupX)) > 0} do
 {
  deleteWaypoint ((waypoints _groupX) select 0);
 };

_wp = _groupX addwaypoint [getpos _unit,0];

{
if (_x != vehicle _x) then
	{
	[_x] orderGetIn true;
	};
} forEach units group player;

hcShowBar false;
hcShowBar true;

_unit setVariable ["owner",player,true];
_eh1 = player addEventHandler ["HandleDamage",
	{
	_unit = _this select 0;
	_unit removeEventHandler ["HandleDamage",_thisEventHandler];
	//removeAllActions _unit;
	selectPlayer _unit;
	(units group player) joinsilent group player;
	group player selectLeader player;
	["Control Squad", "Returned to original Unit as it received damage."] call A3A_fnc_customHint;
	nil;
	}];
_eh2 = _unit addEventHandler ["HandleDamage",
	{
	_unit = _this select 0;
	_unit removeEventHandler ["HandleDamage",_thisEventHandler];
	removeAllActions _unit;
	selectPlayer (_unit getVariable "owner");
	(units group player) joinsilent group player;
	group player selectLeader player;
	["Control Squad", "Returned to original Unit as controlled AI received damage."] call A3A_fnc_customHint;
	nil;
	}];
selectPlayer _unit;

player setFace _face;

{
	[_x, _name] spawn {
		params ["_unit", "_name"];
		while {(alive _unit) && ((units group _unit) findIf {_x == player} != -1)} do {
			waitUntil {sleep 0.5; visibleMap || {visibleGPS || {isMenuOpen}}};
			while {(visibleMap || {visibleGPS || {isMenuOpen}})} do {
				private _unitDir = getDir _unit;
				private _unitMarker = createMarkerLocal [format["unitMarker_%1", random 1000], position _unit];
				if (_unit getVariable ["incapacitated",false]) then {_unitMarker setMarkerColorLocal "colorRed"; _unitMarker setMarkerTypeLocal "plp_icon_cross"; _unitMarker setMarkerSizeLocal [0.5, 0.5]} else {_unitMarker setMarkerColorLocal "colorGUER"; _unitMarker setMarkerTypeLocal "mil_triangle"; _unitMarker setMarkerDirLocal _unitDir; _unitMarker setMarkerSizeLocal [0.5, 1];};
				if (isPlayer _unit) then {_unitMarker setMarkerTextLocal format ["%1 (%2)", _name, name _unit]} else {_unitMarker setMarkerTextLocal format ["%1", name _unit]};
				if (group _unit == stragglers || ((units group _unit) findIf {_x == player} == -1) || (player getVariable ["incapacitated", false])) then {_unitMarker setMarkerAlphaLocal 0} else {_unitMarker setMarkerAlphaLocal 1};
				sleep 0.5;
				deleteMarkerLocal _unitMarker;
			};
		};
	};
} forEach units _groupX;

_timeX = aiControlTime;

_unit addAction ["Return Control to AI",{selectPlayer (player getVariable ["owner",player])}];

waitUntil {sleep 1;["Control Squad", format ["Time to return control to AI: %1.", _timeX]] call A3A_fnc_customHint; _timeX = _timeX - 1; (_timeX < 0) or (isPlayer theBoss)};

removeAllActions _unit;
if (!isPlayer (_unit getVariable ["owner",_unit])) then {selectPlayer (_unit getVariable ["owner",_unit])};
//_unit setVariable ["owner",nil,true];
_unit removeEventHandler ["HandleDamage",_eh2];
player removeEventHandler ["HandleDamage",_eh1];
(units group theBoss) joinsilent group theBoss;
group theBoss selectLeader theBoss;
["Control Squad", ""] call A3A_fnc_customHint;

_unit setFace _face;
player setSpeaker _voice;