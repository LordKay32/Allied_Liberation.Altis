/*
 * Name:	fn_spawnPartizans
 * Date:	19/05/2024
 * Version: 1.0
 * Author:  JB
 *
 * Description:
 * %DESCRIPTION%
 *
 * Parameter(s):
 * _PARAM1 (TYPE): DESCRIPTION.
 * _PARAM2 (TYPE): DESCRIPTION.
 *
 * Returns:
 * %RETURNS%
 */

params ["_markerX"];
	private _positionX = getMarkerPos _markerX;
	private _soldiers = [];
	private _groups = [];
	private _SDKpos = [0,0,0];
	private _dir = 0;
	if (_markerX in ["Kavala","Charkia","Sofia","Panochori","Athira","Telos","Zaros","Pyrgos","AgiosDionysios","Neochori","Paros"]) then {
		_church = nearestObjects [_positionX, ["Land_Church_04_white_red_F","Land_Church_04_white_F","Land_Church_04_yellow_F"], 400]; 
		_dir = getDir (_church select 0);
		_SDKpos = (_church select 0) getRelPos [10, 0];
		TestSofia1 = true;
	} else {
		_church = nearestTerrainObjects [_positionX, ["CHURCH"], 400];	
		_dir = (getDir (_church select 0)) + 270;
		_SDKpos = (_church select 0) getRelPos [8, 270]};
		_groupA = [_SDKpos, teamPlayer, groupSDKLeaders] call A3A_fnc_spawnGroup;
		_groupA selectLeader ((units _groupA) select 2);
		_SDKLeader = leader _groupA;
		_groupA setBehaviour "SAFE";
		[_SDKLeader,"SDKRecruit"] remoteExec ["A3A_fnc_flagaction",0,_SDKLeader];
		sleep 0.5;
		_groupA setFormDir _dir;
		TestSofia2 = true;
	{
		[_x,_markerX] call A3A_fnc_FIAinitBases;
		_soldiers pushBack _x;
		_x setDir _dir;
	} forEach units _groupA;
	_groups pushBack _groupA;
	_groupB = [_positionX, teamPlayer, groupsSDKSquad] call A3A_fnc_spawnGroup;
	//_nul = [leader _groupB, _markerX, "SAFE","SPAWNED","NOVEH2","NOFOLLOW"] execVM "scripts\UPSMON.sqf";
	{
		[_x,_markerX] call A3A_fnc_FIAinitBases;
		_soldiers pushBack _x;
	} forEach units _groupB;
	_groups pushBack _groupB;
	[_groupB, _positionX, 200, 3, 1, false] call A3A_fnc_cityGarrison;
	TestSofia3 = true;
		
if (_markerX in majorCitiesX) then {
	_pos = _positionX findEmptyPosition [10,100];
	_groupC = [_pos, teamPlayer, groupsSDKSquad] call A3A_fnc_spawnGroup;
	//_nul = [leader _groupC, _markerX, "SAFE","SPAWNED","RANDOMUP","NOVEH2","NOFOLLOW"] execVM "scripts\UPSMON.sqf";
	{
		[_x,_markerX] call A3A_fnc_FIAinitBases;
		_soldiers pushBack _x;
	} forEach units _groupC;
	_groups pushBack _groupC;
	[_groupC, _positionX, 200, 3, 1, false] call A3A_fnc_cityGarrison;
	TestSofia4 = true;
};

waitUntil {sleep 1; (spawner getVariable _markerX == 2)};

{ if (alive _x) then { deleteVehicle _x }; } forEach _soldiers;

{deleteGroup _x} forEach _groups;



