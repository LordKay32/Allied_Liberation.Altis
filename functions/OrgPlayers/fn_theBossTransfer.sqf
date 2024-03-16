if !(isServer) exitWith {};
private _filename = "fn_theBossTransfer";
params [["_newBoss", objNull], ["_silent", false]];

if (!isNil "theBoss" and {!isNull theBoss}) then
{
	[3, format ["Removing %1 from Boss roles.", theBoss], _filename] call A3A_fnc_log;
	
	bossHCGroupsTransfer = hcAllGroups theBoss;
	hcRemoveAllGroups theBoss;

	theBoss synchronizeObjectsRemove [HC_commanderX];
	HC_commanderX synchronizeObjectsRemove [theBoss];
};

theBoss = _newBoss;
publicVariable "theBoss";

if (isNull _newBoss) exitWith { 
	[_silent] spawn {
		params ["_silent"];
		sleep 5;
		private _textX = format ["The commander has resigned. There is no eligible commander."];
		if (!_silent) then {[petros,"hint",_textX, "New Commander"] remoteExec ["A3A_fnc_commsMP", 0]};
		[] remoteExec ["A3A_fnc_statistics",[teamPlayer,civilian]];
	};
};

[group theBoss, theBoss] remoteExec ["selectLeader", groupOwner group theBoss];

theBoss synchronizeObjectsAdd [HC_commanderX];
HC_commanderX synchronizeObjectsAdd [theBoss];

if (!isNil "bossHCGroupsTransfer") then
{
	[3, "Found previous HC groups, transferring.", _filename] call A3A_fnc_log;

	{ theBoss hcSetGroup [_x] } forEach bossHCGroupsTransfer;
	{
	_x setGroupOwner (groupOwner group theBoss);
	} forEach bossHCGroupsTransfer;
	bossHCGroupsTransfer = nil;
};

[3, format ["New boss %1 set.", theBoss], _filename] call A3A_fnc_log;

[_silent] spawn {
	params ["_silent"];
	sleep 5;
	private _textX = format ["%1 is the new commander of our forces. Greet them!", name theBoss];
	if (!_silent) then {[petros,"hint",_textX, "New Commander"] remoteExec ["A3A_fnc_commsMP", 0]};
	[] remoteExec ["A3A_fnc_statistics",[teamPlayer,civilian]];
};
