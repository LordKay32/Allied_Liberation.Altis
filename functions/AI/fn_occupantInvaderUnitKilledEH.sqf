params ["_victim", "_killer"];

//Stops the unit from spawning things
if (_victim getVariable ["spawner",false]) then
{
	_victim setVariable ["spawner",nil,true]
};

//Gather infos, trigger timed despawn
private _victimGroup = group _victim;
private _victimSide = side (group _victim);
[_victim] spawn A3A_fnc_postmortem;

if (_victimSide == Occupants) then {aggressionOccupants = aggressionOccupants - 0.1} else {aggressionInvaders = aggressionInvaders - 0.1};
[] call A3A_fnc_calculateAggression;

if (side (group _killer) == teamPlayer) then
{
	occupantKilled = occupantKilled + 1;
	publicVariable "occupantKilled";
	if (typeName _killer != "OBJECT") exitWith {};
    if (isPlayer _killer) then
    {
    	occupantKilledByPlayers = occupantKilledByPlayers + 1;
    	publicVariable "occupantKilledByPlayers";
        [1,_killer] call A3A_fnc_playerScoreAdd;
        if (captive _killer) then
        {
            if (_killer distance _victim < distanceSPWN) then
            {
                [_killer,false] remoteExec ["setCaptive",0,_killer];
                _killer setCaptive false;
            };
        };
        _killer addRating 1000;
    };
    if (vehicle _killer isKindOf "StaticMortar") then
    {
        {
            if ((_x distance _victim < 300) and (captive _x)) then
            {
                [_x,false] remoteExec ["setCaptive",0,_x];
                _x setCaptive false;
            };
        } forEach (call A3A_fnc_playableUnits);
    };
	if (count weapons _victim < 1 && !(_victim getVariable ["isAnimal", false])) then
    {
        //This doesn't trigger for dogs, only for surrendered units
        [
            3,
            "Rebels killed a surrendered unit",
            "aggroEvent",
            true
        ] call A3A_fnc_log;
	}
	else 
	{
		[-1,1,getPos _victim] remoteExec ["A3A_fnc_citySupportChange",2];
	};
}
else
{
	if (_victimSide == Occupants) then
	{
		[-0.25,0,getPos _victim] remoteExec ["A3A_fnc_citySupportChange",2];
	}
	else
	{
		[0.25,0,getPos _victim] remoteExec ["A3A_fnc_citySupportChange",2];
	};
};

private _victimLocation = _victim getVariable "markerX";
private _victimWasGarrison = true;
if (isNil "_victimLocation") then
{
    _victimLocation = _victim getVariable ["originX",""];
    _victimWasGarrison = false
};

if (_victimLocation != "") then
{
	if (sidesX getVariable [_victimLocation,sideUnknown] == _victimSide) then
	{
		[_victim getVariable "unitType",_victimSide,_victimLocation,-1] remoteExec ["A3A_fnc_garrisonUpdate",2];
		if (_victimWasGarrison) then
        {
            [_victimLocation,_victimSide] remoteExec ["A3A_fnc_zoneCheck",2]
        };
	};
};

[_victimGroup,_killer] spawn A3A_fnc_AIreactOnKill;
