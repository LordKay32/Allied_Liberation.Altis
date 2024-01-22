/*
    Author: [Håkon]
    Description:
        logs argument as text

    Argument: <Array> Texts to log

    Return Value:
    <nil>

    Scope: Any
    Environment: Any
    Public: Yes
    Dependencies:

    Example: "Some string to log" call A3A_fnc_localLog;

    License: MIT License
*/
if (typeName _this == "ARRAY") then {
  {diag_log text _x} forEach _this;
}else{
  diag_log _this ;
};
