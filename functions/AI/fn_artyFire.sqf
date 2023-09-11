/*
 * Name:	fn_artyFire
 * Date:	6/09/2023
 * Version: 1.0
 * Author:  JB
 *
 * Description:
 * arty fire
 *
 * Parameter(s):
 * _PARAM1 (TYPE): DESCRIPTION.
 * _PARAM2 (TYPE): DESCRIPTION.
 *
 * Returns:
 * %RETURNS%
 */

params ["_artyArrayDef1","_rounds","_artyRoundsArr1","_typeAmmunition","_typeArty","_pos","_ang"];

for "_i" from 0 to (count _artyArrayDef1) - 1 do
	{
	if (_rounds > 0) then
		{
		_piece = _artyArrayDef1 select _i;
		_countX = _artyRoundsArr1 select _i;
		//hint format ["roundsX que faltan: %1, roundsX que tiene %2",_rounds,_countX];
		if (_typeAmmunition == SDKMortarHEMag) then {_piece loadMagazine [[0], "LIB_M2_60", "LIB_60mm_M2_SmokeShell"]};
		if (_countX >= _rounds) then
			{
			if (_typeArty != "BARRAGE") then
				{
				_piece commandArtilleryFire [_pos,_typeAmmunition,_rounds];
				}
			else
				{
				for "_r" from 1 to _rounds do
					{
					_piece commandArtilleryFire [_pos,_typeAmmunition,1];
					sleep 2;
					_pos = [_pos,10,_ang + 5 - (random 10)] call BIS_fnc_relPos;
					};
				};
			_rounds = 0;
			}
		else
			{
			if (_typeArty != "BARRAGE") then
				{
				_piece commandArtilleryFire [[_pos,random 10,random 360] call BIS_fnc_relPos,_typeAmmunition,_countX];
				}
			else
				{
				for "_r" from 1 to _countX do
					{
					_piece commandArtilleryFire [_pos,_typeAmmunition,1];
					sleep 2;
					_pos = [_pos,10,_ang + 5 - (random 10)] call BIS_fnc_relPos;
					};
				};
			_rounds = _rounds - _countX;
			};
		};
	};

if (_typeArty != "BARRAGE") then
	{
	sleep 5;
	_eta = (_artyArrayDef1 select 0) getArtilleryETA [_positionTel, ((getArtilleryAmmo [(_artyArrayDef1 select 0)]) select 0)];
	_timeX = time + _eta - 5;
	if (isNil "_timeX") exitWith {
        diag_log format ["%1: [Antistasi] | ERROR | ArtySupport.sqf | Params: %2,%3,%4,%5",servertime,_artyArrayDef1 select 0,_positionTel,((getArtilleryAmmo [(_artyArrayDef1 select 0)]) select 0),(_artyArrayDef1 select 0) getArtilleryETA [_positionTel, ((getArtilleryAmmo [(_artyArrayDef1 select 0)]) select 0)]];
	};
	_textX = format ["Acknowledged. Fire mission is inbound. %2 Rounds fired. ETA %1 secs.",round _eta,_roundsMax - _rounds];
	[petros,"sideChat",_textX] remoteExec ["A3A_fnc_commsMP",[teamPlayer,civilian]];
	};

if (_typeArty != "BARRAGE") then
	{
	waitUntil {sleep 1; time > _timeX};
	[petros,"sideChat","Splash. Out."] remoteExec ["A3A_fnc_commsMP",[teamPlayer,civilian]];
	};
sleep 10;
deleteMarkerLocal _mrkFinal;
if (_typeArty == "BARRAGE") then {deleteMarkerLocal _mrkFinal2};

if (_forcedX) then {
	sleep 20;
	if (_markerX in forcedSpawn) then {
		forcedSpawn = forcedSpawn - [_markerX];
		publicVariable "forcedSpawn";
	};
};