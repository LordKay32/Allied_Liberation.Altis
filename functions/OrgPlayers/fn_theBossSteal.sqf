#define MONEY_AMOUNT 500

_resourcesFIA = server getVariable "resourcesFIA";
if (_resourcesFIA < MONEY_AMOUNT) exitWith {
    [
        "FAIL",
        "Command Points Transfer",
        parseText format ["There are not enough command points in the pool to transfer.", nameTeamPlayer],
        30
    ] spawn SCRT_fnc_ui_showMessage;
};

server setvariable ["resourcesFIA", _resourcesFIA - MONEY_AMOUNT, true];
[-2,theBoss] call A3A_fnc_playerScoreAdd;
[MONEY_AMOUNT] call A3A_fnc_resourcesPlayer;

[
    "SUCCESS",
    "Command Points Transfer",
    parseText format ["You have taken %1%3 from the %2 command points pool.", str MONEY_AMOUNT, nameTeamPlayer, currencySymbol],
    15
] spawn SCRT_fnc_ui_showMessage;