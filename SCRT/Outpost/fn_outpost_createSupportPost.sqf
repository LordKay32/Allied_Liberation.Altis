params ["_nearX", "_positionTel", "_dirVeh", "_position", "_direction"];

private _moneyCost = outpostCost select 0;
private _hrCost = outpostCost select 1;
private _typeVehX = outpostCost select 2;

private _textX = format ["%1 Support Post", nameTeamPlayer];
private _tsk = "";

private _marker = createMarker [format ["FIASupportPost%1", random 1000], _position];
_marker setMarkerShape "ICON";

//creating task
private _timeLimit = 90 * settingsTimeMultiplier;
private _dateLimit = [date select 0, date select 1, date select 2, date select 3, (date select 4) + _timeLimit];
private _dateLimitNum = dateToNumber _dateLimit;

private _taskId = "outpostTask" + str A3A_taskCount;
[[teamPlayer,civilian],_taskId,["We are sending a team to establish a support post. Use HC to send the team to their destination.","Support Post Deploy",_marker],_position,false,0,true,"Move",true] call BIS_fnc_taskCreate;
[_taskId, "outpostTask", "CREATED"] remoteExecCall ["A3A_fnc_taskUpdate", 2];

_formatX = [USSL,USMG,USATman,USMedic,USMil,USMG];

[-_hrCost,-_moneyCost,_formatX] remoteExec ["A3A_fnc_resourcesFIA",2];

{
	private _count = server getVariable (_x + "_count");
	_count = _count - 1;
	server setVariable [(_x + "_count"), _count, true];
} forEach _typeVehX;

_groupX = [getMarkerPos _nearX, teamPlayer, _formatX] call A3A_fnc_spawnGroup;
_groupX setGroupId ["Post"];

private _squadloadout = [];
{
private _loadout = rebelLoadouts get _x;
_squadloadout pushback _loadout;
} forEach _formatX;

private _fullSquadGear = _squadloadout call A3A_fnc_reorgLoadoutSquad;

{ [_x select 0 call jn_fnc_arsenal_itemType, _x select 0, _x select 1]call jn_fnc_arsenal_removeItem } forEach _fullSquadGear;

{
    [_x] call A3A_fnc_FIAinit;
    teamPlayerDeployed = teamPlayerDeployed + 1;
	publicVariable "teamPlayerDeployed";
    if ((_x getVariable "unitType") in squadLeaders) then {_x linkItem "ItemRadio"};
} forEach units _groupX;
leader _groupX setBehaviour "SAFE";
_groupX setFormation "FILE";

_truckA = (_typeVehX select 0) createVehicle _positionTel;
_truckA setDir _dirVeh;
_groupX addVehicle _truckA;

_pos = _truckA getRelPos [10, 180];
_truckB = (_typeVehX select 1) createVehicle _pos;
_truckB setDir _dirVeh;
_groupX addVehicle _truckB;

_pos = _truckB getRelPos [10, 180];
_truckC = (_typeVehX select 2) createVehicle _pos;
_truckC setDir _dirVeh;
_groupX addVehicle _truckC;

_pos = _truckC getRelPos [10, 180];
_truckD = (_typeVehX select 3) createVehicle _pos;
_truckD setDir _dirVeh;
_groupX addVehicle _truckD;

_pos = _truckD getRelPos [10, 180];
_truckE = (_typeVehX select 4) createVehicle _pos;
_truckE setDir _dirVeh;
_groupX addVehicle _truckE;

teamPlayerVehDeployed = teamPlayerVehDeployed + 6;
publicVariable "teamPlayerVehDeployed";

{
	_groupX addVehicle _x;
} forEach [_truckA, _truckB, _truckC, _truckD, _truckE];

leader _groupX assignAsDriver _truckA;
(units _groupX) select 1 assignAsCargo _truckA;
(units _groupX) select 2 assignAsDriver _truckB;
(units _groupX) select 3 assignAsDriver _truckC;
(units _groupX) select 4 assignAsDriver _truckD;
(units _groupX) select 5 assignAsDriver _truckE;
(units _groupX) orderGetIn true;
theBoss hcSetGroup [_groupX];

outpostCost = nil;
["REMOVE"] call SCRT_fnc_ui_establishOutpostEventHandler;
ctrlSetFocus ((findDisplay 60000) displayCtrl 2700);
sleep 0.01;
closeDialog 0;
closeDialog 0;
[] call SCRT_fnc_ui_clearOutpost;

waitUntil {sleep 1; ({alive _x} count units _groupX == 0) or ({(alive _x) and (_x distance _position < 25)} count units _groupX > 0) or (dateToNumber date > _dateLimitNum)};

if ({(alive _x) and (_x distance _position < 25)} count units _groupX > 0) then {
	if (isPlayer leader _groupX) then {
		_owner = (leader _groupX) getVariable ["owner",leader _groupX];
		(leader _groupX) remoteExec ["removeAllActions",leader _groupX];
		_owner remoteExec ["selectPlayer",leader _groupX];
		(leader _groupX) setVariable ["owner",_owner,true];
		{[_x] joinsilent group _owner} forEach units group _owner;
		[group _owner, _owner] remoteExec ["selectLeader", _owner];
		"" remoteExec ["hint",_owner];
		waitUntil {!(isPlayer leader _groupX)};
	};
	supportpostsFIA = supportpostsFIA + [_marker]; publicVariable "supportpostsFIA";
	sidesX setVariable [_marker,teamPlayer,true];
	markersX = markersX + [_marker];
	publicVariable "markersX";
	[_taskId, "outpostTask", "SUCCEEDED"] call A3A_fnc_taskSetState;
	_nul = [-5,5,_position] remoteExec ["A3A_fnc_citySupportChange",2];
	_marker setMarkerType "n_service";
	_marker setMarkerColor colorTeamPlayer;
	_marker setMarkerText _textX;
    _garrison = [USSL,USMG,USATman,USMedic,USMil,USMG];
    garrison setVariable [_marker,_garrison,true];
    garrison setVariable [(_marker + "_statics"),_typeVehX,true];
    staticPositions setVariable [_marker, [_position, _direction], true];
} else {
    [_taskId, "outpostTask", "FAILED"] call A3A_fnc_taskSetState;
    sleep 3;
    deleteMarker _marker;
};

theBoss hcRemoveGroup _groupX;

sleep 10;

{
    deleteVehicle _x
} forEach units _groupX;

{
	deleteVehicle _x;
} forEach [_truckA, _truckB, _truckC, _truckD, _truckE];

deleteGroup _groupX;
sleep 5;

[[_marker],"SCRT_fnc_outpost_createSupportPostDistance"] remoteExec ["A3A_fnc_scheduler",2];

sleep 10;

[_taskId, "outpostTask", 0] spawn A3A_fnc_taskDelete;