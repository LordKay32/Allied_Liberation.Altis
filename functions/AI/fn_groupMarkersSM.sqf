/*
 * Name:	fn_groupMarkersSM
 * Date:	24/11/2023
 * Version: 1.0
 * Author:  JB
 *
 * Description:
 * Group markers for startMission
 *
 * Parameter(s):
 * _PARAM1 (TYPE): DESCRIPTION.
 * _PARAM2 (TYPE): DESCRIPTION.
 *
 * Returns:
 * %RETURNS%
 */

params ["_unit"];
private _name = name _unit;

//Map markers
[_unit, _name] spawn {
	params ["_unit", "_name"];
	while {alive _unit} do {
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