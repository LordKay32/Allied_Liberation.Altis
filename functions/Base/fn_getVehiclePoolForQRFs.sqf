/*  Returns a weighted and balanced vehicle pool for the given side and filter

    Execution on: All

    Scope: External

    Params:
        _side: SIDE : The side for which the vehicle pool should be used
        _filter: ARRAY of STRINGS : The bases classes of units that should be filtered out (for example ["LandVehicle"] or ["Air"])

    Returns:
        _vehiclePool: ARRAY : [vehicleName, weight, vehicleName2, weight2]
*/

params ["_side", ["_filter", []]];

private _fileName = "getVehiclePoolForQRFs";
private _vehicleSelection = [];

[3, format ["Now searching for QRF vehicle pool for %1 with filter %2", _side, _filter], _fileName] call A3A_fnc_log;
//In general is Invaders always a bit less chill than the occupants, they will use heavier vehicles more often and earlier
switch (tierWar) do
{
    //General idea: Send only ground units as players should be able to loot and grab the crate before the enemy arrives with a QRF
    // JJ: As of 2.3-prerelease, this function is always called with either an air or ground filter, so air/ground balancing is not valid
    case (1):
    {
        if(_side == Occupants) then
        {
            _vehicleSelection =
            [
                [vehNATOLightArmed, 25],
                [vehNATOTrucks, 15],
                [vehNATOAPC, 45],
                [vehNATOTanks, 15]
            ];
        };
        if(_side == Invaders) then
        {
            _vehicleSelection =
            [
                [vehCSATTrucks, 5],
                [vehCSATLightArmed, 25],
                [vehCSATAPC, 45],
                [vehCSATAA, 5],
                [vehCSATTanks, 20]
            ];
        };
    };
    //General idea: Enemies get airborne, police units are reduced and replaced by military units
    case (2):
    {
        if(_side == Occupants) then
        {
            _vehicleSelection =
            [
                [vehNATOLightArmed, 25],
                [vehNATOTrucks, 15],
                [vehNATOAPC, 45],
                [vehNATOTanks, 15]
            ];
        };
        if(_side == Invaders) then
        {
            _vehicleSelection =
            [
                [vehCSATTrucks, 5],
                [vehCSATLightArmed, 25],
                [vehCSATAPC, 45],
                [vehCSATAA, 5],
                [vehCSATTanks, 20]
            ];
        };
    };
    //General idea: No police units any more, armed vehicles and first sightings of APCs
    case (3):
    {
        if(_side == Occupants) then
        {
            _vehicleSelection =
            [
                [vehNATOTrucks, 10],
                [vehNATOLightArmed, 20],
                [vehNATOAPC, 50],
                [vehNATOAA, 5],
                [vehNATOTanks, 15]
            ];
        };
        if(_side == Invaders) then
        {
            _vehicleSelection =
            [
                [vehCSATTrucks, 5],
                [vehCSATLightArmed, 25],
                [vehCSATAPC, 40],
                [vehCSATAA, 5],
                [vehCSATTanks, 25]
            ];
        };
    };
    //General idea: Unarmed vehicles vanish, trucks start to get replaced by APCs, first sighting of transport helicopters
    case (4):
    {
        if(_side == Occupants) then
        {
            _vehicleSelection =
            [
                [vehNATOTrucks, 10],
                [vehNATOLightArmed, 20],
                [vehNATOAPC, 50],
                [vehNATOAA, 5],
                [vehNATOTanks, 15]
            ];
        };
        if(_side == Invaders) then
        {
            _vehicleSelection =
            [
                [vehCSATTrucks, 5],
                [vehCSATLightArmed, 25],
                [vehCSATAPC, 40],
                [vehCSATAA, 5],
                [vehCSATTanks, 25]
            ];
        };
    };
    //General idea: Get rid of any unarmed vehicle, Invaders start to bring the big guns
    case (5):
    {
        if(_side == Occupants) then
        {
            _vehicleSelection =
            [
                [vehNATOTrucks, 10],
                [vehNATOLightArmed, 15],
                [vehNATOAPC, 50],
                [vehNATOAA, 5],
                [vehNATOTanks, 20]
            ];
        };
        if(_side == Invaders) then
        {
            _vehicleSelection =
            [
                [vehCSATTrucks, 5],
                [vehCSATLightArmed, 20],
                [vehCSATAPC, 40],
                [vehCSATAA, 10],
                [vehCSATTanks, 25]
            ];
        };
    };
    //General idea: No light vehicles any more, Invaders start to bring attack helicopter
    case (6):
    {
        if(_side == Occupants) then
        {
            _vehicleSelection =
            [
                [vehNATOTrucks, 10],
                [vehNATOLightArmed, 15],
                [vehNATOAPC, 50],
                [vehNATOAA, 5],
                [vehNATOTanks, 20]
            ];
        };
        if(_side == Invaders) then
        {
            _vehicleSelection =
            [
                [vehCSATTrucks, 5],
                [vehCSATLightArmed, 20],
                [vehCSATAPC, 40],
                [vehCSATAA, 10],
                [vehCSATTanks, 25]
            ];
        };
    };
    //General idea: Getting rid of light helis, Invaders start the endgame
    case (7):
    {
        if(_side == Occupants) then
        {
            _vehicleSelection =
            [
                [vehNATOTrucks, 5],
                [vehNATOLightArmed, 10],
                [vehNATOAPC, 50],
                [vehNATOAA, 10],
                [vehNATOTanks, 25]
            ];
        };
        if(_side == Invaders) then
        {
            _vehicleSelection =
            [
                [vehCSATTrucks, 5],
                [vehCSATLightArmed, 10],
                [vehCSATAPC, 40],
                [vehCSATAA, 10],
                [vehCSATTanks, 30]
            ];
        };
    };
    //General idea, Occupants start to throw in everything, Invaders upgrade to maximum
    case (8):
    {
        if(_side == Occupants) then
        {
            _vehicleSelection =
            [
                [vehNATOTrucks, 5],
                [vehNATOLightArmed, 10],
                [vehNATOAPC, 50],
                [vehNATOAA, 10],
                [vehNATOTanks, 25]
            ];
        };
        if(_side == Invaders) then
        {
            _vehicleSelection =
            [
                [vehCSATTrucks, 5],
                [vehCSATLightArmed, 10],
                [vehCSATAPC, 40],
                [vehCSATAA, 10],
                [vehCSATTanks, 30]
            ];
        };
    };
    //General idea: Occupants get access to all, invaders start to heavily rely on tanks and attack helis
    case (9):
    {
        if(_side == Occupants) then
        {
            _vehicleSelection =
            [
                [vehNATOTrucks, 5],
                [vehNATOLightArmed, 5],
                [vehNATOAPC, 50],
                [vehNATOAA, 10],
                [vehNATOTanks, 30]
            ];
        };
        if(_side == Invaders) then
        {
            _vehicleSelection =
            [
                [vehCSATTrucks, 5],
                [vehCSATLightArmed, 5],
                [vehCSATAPC, 45],
                [vehCSATAA, 10],
                [vehCSATTanks, 35]
            ];
        };
    };
    //General idea: Occupants finish with a focus on infantry units supported by combat vehicles, while Invaders tend to use heavy armor
    case (10):
    {
        if(_side == Occupants) then
        {
            _vehicleSelection =
            [
                [vehNATOTrucks, 5],
                [vehNATOLightArmed, 5],
                [vehNATOAPC, 40],
                [vehNATOAA, 10],
                [vehNATOTanks, 40]
            ];
        };
        if(_side == Invaders) then
        {
            _vehicleSelection =
            [
                [vehCSATTrucks, 5],
                [vehCSATLightArmed, 5],
                [vehCSATAPC, 45],
                [vehCSATAA, 10],
                [vehCSATTanks, 35]
            ];
        };
    };
};

//Use this function to filter out any unwanted elements
_fn_checkElementAgainstFilter =
{
    params ["_element", "_filter"];

    private _passed = true;
    {
        if(_element isKindOf _x) exitWith
        {
            _passed = false;
            [
                3,
                format ["%1 didnt passed filter %2", _element, _x],
                _fileName
            ] call A3A_fnc_log;
        };
    } forEach _filter;

    _passed;
};

//Break unit arrays down to single vehicles
private _vehiclePool = [];
{
    if((_x select 0) isEqualType []) then
    {
        private _points = 0;
        private _vehicleCount = count (_x select 0);
        if(_vehicleCount != 0) then
        {
            _points = (_x select 1)/_vehicleCount;
        }
        else
        {
            [1, "Found vehicle array with no defined vehicles!", _fileName] call A3A_fnc_log;
        };
        {
            if(([_x, _filter] call _fn_checkElementAgainstFilter) && {[_x] call A3A_fnc_vehAvailable}) then
            {
                _vehiclePool pushBack _x;
                _vehiclePool pushBack _points;
            };
        } forEach (_x select 0);
    }
    else
    {
        if(([_x select 0, _filter] call _fn_checkElementAgainstFilter) && {[_x select 0] call A3A_fnc_vehAvailable}) then
        {
            _vehiclePool pushBack (_x select 0);
            _vehiclePool pushBack (_x select 1);
        };
    };
} forEach _vehicleSelection;

[
    3,
    format ["For %1 and war level %2 selected units are %3, filter was %4", _side, tierWar, _vehiclePool, _filter],
    _fileName
] call A3A_fnc_log;

_vehiclePool;
