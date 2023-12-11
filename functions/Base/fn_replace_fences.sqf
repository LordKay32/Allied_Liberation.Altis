/*
 * Name:	replace_fences
 * Date:	11/12/2023
 * Version: 1.0
 * Author:  %AUTHOR%
 *
 * Description:
 * %DESCRIPTION%
 *
 * Parameter(s):
 * _PARAM1 (TYPE): - DESCRIPTION.
 * _PARAM2 (TYPE): - DESCRIPTION.
 */

scriptName "replace_fences";

OT_replace_Walls = (["ot_replace_walls", 0] call BIS_fnc_getParamValue) == 1;   
if (OT_replace_Walls && isServer) then {  
OT_fences_array = [];  
OT_fences_array = parseSimpleArray (loadFile "mapScripts\fences_array.sqf");                   
    
{  
 _x params ["_model","_args"];  
 _args params ["_replacement", "_directionoffset", "_idcoords"];  
 {  
  _x params ["_id", "_coords"];  
  private _obj = call compile (str(_coords) + " nearestObject " + _id);  
  private _objdir = getdir _obj;  
  private _objheight = getposATL _obj select 2;  
  private _d = _objheight;  
  if (_d < 0 or _d > 0.3) then {_d = 0};  
  if (_replacement != "") then {  
   _coords set [2, _objheight];  
              if (_model in ["city_8m_f.p3d","city_8md_f.p3d","city2_8md_f.p3d","city2_8m_f.p3d"]) then {  
                  private _replacement1 = createSimpleObject [_replacement, _coords];  
                  private _replacement2 = createSimpleObject [_replacement, _coords];  
                  private _replacement3 = createSimpleObject [_replacement, _coords];  
                  private _replacement4 = createSimpleObject [_replacement, _coords];  
                  _replacement1 setdir (_objdir + _directionoffset);  
                  _replacement2 setdir (_objdir + _directionoffset);  
                  _replacement3 setdir (_objdir + _directionoffset);  
                  _replacement4 setdir (_objdir + _directionoffset);  
                  _replacement1 setpos [(_obj modelToWorld [0.62,0.2,0]) select 0,(_obj modelToWorld [0.62,0.2,0]) select 1,1];   
                  _replacement2 setpos [(_obj modelToWorld [-0.95,0.2,0]) select 0,(_obj modelToWorld [-0.95,0.2,0]) select 1,1];   
                  _replacement3 setpos [(_obj modelToWorld [2.5,0.2,0]) select 0,(_obj modelToWorld [2.5,0.2,0]) select 1,1];  
                  _replacement4 setpos [(_obj modelToWorld [-2.55,0.2,0]) select 0,(_obj modelToWorld [-2.55,0.2,0]) select 1,1];  
                  _replacement1 enableDynamicSimulation true;  
                  _replacement2 enableDynamicSimulation true;  
                  _replacement3 enableDynamicSimulation true;  
                  _replacement3 enableDynamicSimulation true;  
              };   
              if (_model in ["city_4m_f.p3d","city2_4m_f"]) then {  
                  private _replacement1 = createSimpleObject [_replacement, _coords];  
                  private _replacement2 = createSimpleObject [_replacement, _coords];  
                  _replacement1 setdir (_objdir + 175);  
                  _replacement2 setdir (_objdir + 175);  
                  _replacement1 setpos [(_obj modelToWorld [0.785,0,0]) select 0,(_obj modelToWorld [0.785,0,0]) select 1,1];   
                  _replacement2 setpos [(_obj modelToWorld [-0.785,-0.15,0]) select 0,(_obj modelToWorld [-0.785,-0.15,0]) select 1,1];  
                  _replacement1 enableDynamicSimulation true;  
                  _replacement2 enableDynamicSimulation true;  
              };   
              if (_model == "city_gate_f.p3d") then {  
                  private _replacement = createSimpleObject [_replacement, _coords];  
                  _replacement setdir (_objdir + 185);  
                  _replacement setpos [(_obj modelToWorld [0.9,-0.1,0.020153]) select 0,(_obj modelToWorld [0.9,-0.1,0.020153]) select 1,1];   
                  _replacement enableDynamicSimulation true;  
                  private _gate = createVehicle ["Land_bthbc_gate_residential_1_4", [(_obj modelToWorld [-1.15,0.1,-0.0280151]) select 0,(_obj modelToWorld [-1.09,0.1,-0.0280151]) select 1,0], [], 0, "CAN_COLLIDE"];    
                  _gate enableDynamicSimulation true;  
                  _gate setdir (_objdir + 3);  
                };  
    _obj hideObjectGlobal true;             
  };  
 } foreach _idcoords;  
} forEach OT_fences_array;   
  
OT_fences_array = [];  
replace_fences remoteExecCall ["deleteVehicle", replace_fences];   
};  


