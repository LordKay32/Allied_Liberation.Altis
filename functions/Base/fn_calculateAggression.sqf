params [["_silent", false]];

/*  Calculates the current aggression values and levels

    Execution on: Server

    Scope: Internal

    Params:
        None

    Returns:
        Nothing
*/
_newOccupantsValue = aggressionOccupants;
_newInvadersValue = aggressionInvaders;

//Limit them to 0 - 100
_newOccupantsValue = ((_newOccupantsValue min 100) max 0);
_newInvadersValue = ((_newInvadersValue min 100) max 0);

aggressionOccupants = _newOccupantsValue;
aggressionInvaders = _newInvadersValue;
publicVariable "aggressionOccupants";
publicVariable "aggressionInvaders";

private _levelBoundsOccupants = [((aggressionLevelOccupants - 1) * 20) - 2.5, aggressionLevelOccupants * 20 + 2.5];
private _levelBoundsInvaders = [((aggressionLevelInvaders - 1) * 20) - 2.5, aggressionLevelInvaders * 20 + 2.5];

private _notificationText = "";
private _levelsChanged = false;

//occupants
switch (true) do {
    case (!areOccupantsDefeated && {_newOccupantsValue < (_levelBoundsOccupants select 0)}): {
        aggressionLevelOccupants = ((ceil (_newOccupantsValue / 20)) min 5) max 1;
        publicVariable "aggressionLevelOccupants";
        _notificationText = format ["%1 initiative level reduced to %2<br/>", nameOccupants, [aggressionLevelOccupants] call A3A_fnc_getAggroLevelString];
        _levelsChanged = true;
    };
    case (!areOccupantsDefeated && {_newOccupantsValue > (_levelBoundsOccupants select 1)}): {
        aggressionLevelOccupants = ((ceil (_newOccupantsValue / 20)) min 5) max 1;
        publicVariable "aggressionLevelOccupants";
        _notificationText = format ["%1 initiative level increased to %2<br/>", nameOccupants, [aggressionLevelOccupants] call A3A_fnc_getAggroLevelString];
        _levelsChanged = true;
    };
};

//invaders
switch (true) do {
    case (!areInvadersDefeated && {_newInvadersValue < (_levelBoundsInvaders select 0)}): {
        aggressionLevelInvaders = ((ceil (_newInvadersValue / 20)) min 5) max 1;
        publicVariable "aggressionLevelInvaders";
        _notificationText = format ["%1%2 initiative level reduced to %3", _notificationText, nameInvaders, [aggressionLevelInvaders] call A3A_fnc_getAggroLevelString];
        _levelsChanged = true;
    };
    case (!areInvadersDefeated && {_newInvadersValue > (_levelBoundsInvaders select 1)}): {
        aggressionLevelInvaders = ((ceil (_newInvadersValue / 20)) min 5) max 1;
        publicVariable "aggressionLevelInvaders";
        _notificationText = format ["%1%2 initiative level increased to %3<br/>", _notificationText, nameInvaders, [aggressionLevelInvaders] call A3A_fnc_getAggroLevelString];
        _levelsChanged = true;
    };
};

if(_levelsChanged) then {
    //Updating HUDs of players
    [] remoteExec ["A3A_fnc_statistics", [teamPlayer, civilian]];
    if(!_silent) then {
        //If not load progress, show message for everyone
        _notificationText = format ["<t size='0.6' color='#C1C0BB'>Initiative level changed<br/> <t size='0.5' color='#C1C0BB'><br/>%1", _notificationText];
        [petros, "income", _notificationText] remoteExec ["A3A_fnc_commsMP", [teamPlayer, civilian]];
    };
};
