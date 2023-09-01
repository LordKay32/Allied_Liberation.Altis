private _fileName = "fn_unit_selectInfantryTier";

private _infantry = _this;

switch (true) do {
    case (tierWar < 6):
    {
        _infantry select 0
    };
    case (tierWar > 5):
    {
        _infantry select 1
    };
    default {
        [1, "Something went wrong.", _fileName] call A3A_fnc_log;
    }
};