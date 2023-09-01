params ["_level"];

if(_level == 1) exitWith {"Very Low"};
if(_level == 2) exitWith {"Low"};
if(_level == 3) exitWith {"Medium"};
if(_level == 4) exitWith {"High"};
if(_level == 5) exitWith {"Very High"};

[1, format ["Bad level recieved, cannot generate string, was %1", _level], "calculateAggression", true] call A3A_fnc_log;
"None"
