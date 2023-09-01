//Original Author: Barbolani
//Edited and updated by the Antstasi Community Development Team

params [["_timeInHours", 1/2], ["_occScale", 1], ["_invScale", 1.2]];

private _fileName = "fn_economics";

// Increase one type by _increase*_typeCoeff, if total of types is lower than _baseCap*_typeCoeff
_fnc_economics = {
    params ["_types", "_typeCoeff", "_baseCap", "_increase"];

    if (_types isEqualTo []) exitWith {};

    isNil {
        private _totalItems = 0;
        {
            // fractions don't count towards cap
            _totalItems = _totalItems + floor (timer getVariable [_x, 0]);
        } forEach _types;

        if (_totalItems < _typeCoeff * _baseCap) then {
            private _type = selectRandom _types;
            private _currentItems = timer getVariable [_type, 0];
            timer setVariable [_type, _currentItems + _typeCoeff * _increase, true];
        };
    };
};

// Community with ~30 players killed roughly 2 APCs per hour, probably similar for attack helis
// However they weren't spawning QRFs or singleAttacks due to maxUnits bugs, so this is probably low
// Air vehicles set fairly high because we're using a lot of them since 2.4
// Coeff 1.0 means one vehicle per hour with 9 players @ tierWar 7, or two vehicles per hour for 26 players.

// 9 players @ tierWar 7 => balanceScale 1
private _playerScale = call A3A_fnc_getPlayerScale;
private _balanceScale = _playerScale * (3 + tierWar) / 10;

//--------------------------------------Occupants--------------------------------------------------
private _airbases = { sidesX getVariable [_x, sideUnknown] == Occupants } count airportsX;
private _milbases = { sidesX getVariable [_x, sideUnknown] == Occupants } count milbases;
private _outposts = { sidesX getVariable [_x, sideUnknown] == Occupants } count outposts;
private _seaports = { sidesX getVariable [_x, sideUnknown] == Occupants } count seaports;

private _airCap = _occScale * _balanceScale * (4 + _airbases*2);
private _groundCap = _occScale * _balanceScale * (4 + _airbases + _milbases + _outposts*0.5);
private _increase = _occScale * _balanceScale * _timeInHours;

[[staticATOccupants], 2.0, _groundCap, _increase] call _fnc_economics;
[staticAAOccupants, 2.0, _groundCap, _increase] call _fnc_economics;
[vehNATOAPC, 4, _groundCap, _increase] call _fnc_economics;
[vehNATOTanks, 2, _groundCap, _increase] call _fnc_economics;
[vehNATOAA, 2, _groundCap, _increase] call _fnc_economics;
[[vehNATOMRLS], 0.3, _groundCap, _increase] call _fnc_economics;           // not used atm?
[[vehNATOBoat], 2.0, _balanceScale * (2 + _seaports*2), _increase] call _fnc_economics;
[vehNATOPlanes, 0.5, _airCap, _increase] call _fnc_economics;             // only used for major attacks
[vehNATOPlanesAA, 0.5, _airCap, _increase] call _fnc_economics;           // only used for major attacks
[vehNATOTransportPlanes, 3, _airCap, _increase] call _fnc_economics;
[vehNATOTransportHelis - [vehNATOPatrolHeli], 2.5, _airCap, _increase] call _fnc_economics;
[vehNATOAttackHelis, 1.2, _airCap, _increase] call _fnc_economics;

private _natoArray = flatten [staticATOccupants, staticAAOccupants, vehNATOAPC, vehNATOTanks, vehNATOAA, vehNATOBoat, vehNATOPlanes, vehNATOPlanesAA, vehNATOTransportPlanes, (vehNATOTransportHelis - [vehNATOPatrolHeli]), vehNATOAttackHelis, vehNATOMRLS];
_natoArray = _natoArray apply { [_x, timer getVariable [_x, 0]] };
[3, format ["Occupants arsenal: %1", str _natoArray], _fileName] call A3A_fnc_log;

//--------------------------------------Invaders---------------------------------------------------
_airbases = { sidesX getVariable [_x, sideUnknown] == Invaders } count airportsX;
_milbases = { sidesX getVariable [_x, sideUnknown] == Invaders } count milbases;
_outposts = { sidesX getVariable [_x, sideUnknown] == Invaders } count outposts;
_seaports = { sidesX getVariable [_x, sideUnknown] == Invaders } count seaports;

_airCap = _invScale * _balanceScale * (4 + _airbases*2);
_groundCap = _invScale * _balanceScale * (4 + _airbases + _milbases + _outposts*0.5);
_increase = _invScale * _balanceScale * _timeInHours;

[[staticATInvaders], 1.0, _groundCap, _increase] call _fnc_economics;
[staticAAInvaders, 1.0, _groundCap, _increase] call _fnc_economics;
[vehCSATAPC, 1.8, _groundCap, _increase] call _fnc_economics;
[vehCSATTanks, 0.6, _groundCap, _increase] call _fnc_economics;
[vehCSATAA, 0.6, _groundCap, _increase] call _fnc_economics;
[[vehCSATMRLS], 0.3, _groundCap, _increase] call _fnc_economics;           // not used atm?
[[vehCSATBoat], 1.0, _balanceScale * (2 + _seaports*2), _increase] call _fnc_economics;
[vehCSATPlanes, 0.25, _airCap, _increase] call _fnc_economics;             // only used for major attacks
[vehCSATPlanesAA, 0.25, _airCap, _increase] call _fnc_economics;           // only used for major attacks
[vehCSATTransportPlanes, 1.5, _airCap, _increase] call _fnc_economics;
[vehCSATTransportHelis - [vehCSATPatrolHeli], 2.5, _airCap, _increase] call _fnc_economics;
[vehCSATAttackHelis, 1.2, _airCap, _increase] call _fnc_economics;

private _csatArray = flatten [staticATInvaders, staticAAInvaders, vehCSATAPC, vehCSATTanks, vehCSATAA, vehCSATBoat, vehCSATPlanes, vehCSATPlanesAA, vehCSATTransportPlanes, (vehCSATTransportHelis - [vehCSATPatrolHeli]), vehCSATAttackHelis, vehCSATMRLS];
_csatArray = _csatArray apply { [_x, timer getVariable [_x, 0]] };
[3, format ["Invaders arsenal: %1", str _csatArray], _fileName] call A3A_fnc_log;
