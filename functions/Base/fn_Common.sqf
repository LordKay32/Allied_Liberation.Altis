/*
 * Name:	common
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

scriptName "common";

if isServer then {                    
OT_replace_Walls = (["ot_replace_walls", 0] call BIS_fnc_getParamValue) == 1;                     
OT_common_array = [];                     
if ("gm_xx_civ_bicycle_01" isKindof "LandVehicle") then {                     
 OT_common_array = parseSimpleArray (loadFile "mapScripts\common_array_gm.sqf");                      
} else {                     
 OT_common_array = parseSimpleArray (loadFile "mapScripts\common_array.sqf");                     
};                   
                   
OT_common_array append (parseSimpleArray (loadFile "mapScripts\common_array_houses.sqf"));                
                     
private _exclude = if OT_replace_Walls then {["Land_City_Gate_F"]} else {[]};                    
private _bases = [[10009.6,11242,0],[3909.92,12294.4,0],[6198.12,16206,0],[23553.1,21126.4,0],[21034.5,19287.1,0],[12805.9,16672.5,0],[16611.6,19009.5,0],[17419.6,13190.1,0],[12285.5,8891.48,0],[19322,16545.2,0],[16651.2,12307.5,0],[9967.93,19355.9,0],[8746.56,17465.5,0],[20068.2,6707.49,0],[14273.5,13007.8,0],[23028.6,7245.26,0],[11206.3,8701.43,0],[16084.7,16985.9,0],[14211.6,21226.4,0],[8265.21,10057.1,0],[12478.8,15196.4,0],[7893.43,14619.9,0],[17869,11731.4,0],[20352.4,18770.8,0],[18716.9,10220,0],[4539.13,15422,0],[25299,21795.9,0],[9494.06,19330.1,0],[14233.3,16208.8,0],[11602.5,11867.6,0],[9188.04,21591.5,0],[20837.9,7256.01,0],[26817.6,24579.7,0],[20605,20114.3,0]];                    
private _tower1 = [14327.8,13013.7] nearestObject 884523;                         
private _tower2 = [16638.6,12316.0] nearestObject 927204;                         
private _tower3 = [16561.7,18959.8] nearestObject 469744;                         
private _tower4 = [4616.19,15477.5] nearestObject 1074446;                    
                    
private _objexclude = ["884436","882719","541914","1345261","787989","1779017","1779000","524402","525882","1119477","1125694","1282825","1074507","1282977","1282978","523007","523006","524148","1063939"];                    
                               
{                   
 _x params ["_model","_args"];                     
 _args params ["_replacement", "_simple", "_dir", "_height", "_idcoords"];                   
 private _idarray = createHashMap;                    
 {                     
  _x params ["_id", "_coords", "_pitchbank",["_onslope",false]];                   
  _currentdir = _dir;                   
  _currentheight = _height;                   
  if (_id in _idarray) then {diag_log format ["Overthrow: Found duplicated id %1 for type %2",_id,_replacement]; continue} else {_idarray set [_id,nil]};                   
                   
  private _obj = call compile (str(_coords) + " nearestObject " + _id);                   
  if (isObjectHidden _obj or {typeof _obj != _model}) then {continue};                    
  private _objdir = getdir _obj;                     
  private _objheight = getposATL _obj select 2;                    
  private _currentreplacement = _replacement;                   
  private _downed = false;                   
   if (_currentreplacement in ["Land_Lampazel","Land_Lamp_Small_EP1"]) then {                    
    _obj setDamage 0.95;                    
   } else {                    
     _obj allowDamage false;                    
   };                    
  _obj hideObjectGlobal true;                                
 if (_model in ["Land_Runway_PAPI","Land_Runway_PAPI_1","Land_Runway_PAPI_2","Land_Runway_PAPI_3","Land_Runway_PAPI_4"]) then {            
  _obj setdamage 1;              
  _obj enablesimulationGlobal true;             
 } else {            
  if (isDedicated) then {                  
    _obj enableSimulationGlobal false;                    
   };            
 };            
                    
  if (_id in _objexclude) then {_currentreplacement = ""};                    
  if (_model == "Land_Factory_Main_F" && {_obj distance2D [6222.22,16281.4,0] < 500}) then {_currentreplacement = ""};                    
  if (_model == "Land_Research_house_V1_F" && {_obj distance2D [21034.5,19287.1,0] < 500}) then {_currentreplacement = ""};                    
  if (_currentreplacement in ["land_hlaska","campeast"] && {((_bases findif {_obj distance2D _objectpos < 300}) isEqualTo -1)}) then {_currentreplacement = ""};                    
  if (_currentreplacement in ["Land_Lampazel", "Land_Lamp_Small_EP1"] && {surfaceIsWater _coords}) then {_currentreplacement = ""};                    
                        
  if (_currentreplacement != "" && {!(_model in _exclude)}) then {                     
   private _myReplacement = objNull;                   
  if (_replacement == "Land_Sara_domek02") then {                   
     _currentheight = _currentheight + 3.2;                   
     _downed = true;                   
   };                   
   _coords set [2, _objheight - _currentheight];                     
   if (_id isEqualTo "1068077") then {_currentreplacement = "Land_Sara_domek02"; _currentdir = _currentdir + 90};          
   if (_simple isEqualType true && {_simple}) then {                   
    _myReplacement = createSimpleObject [_currentreplacement, _coords];                                 
   } else {                   
    _myReplacement = createVehicle [_currentreplacement, _coords, [], 0, "CAN_COLLIDE"];                    
   };                    
                   
    if (_obj isEqualTo _tower1) then {                         
        _currentdir = _currentdir + 135;                         
    };                         
    if (_obj isEqualTo _tower2) then {                         
        _currentdir = _currentdir + 90;                         
    };                         
    if (_obj isEqualTo _tower3) then {                         
        _currentdir = _currentdir - 45;                         
    };                    
              
                   
    if (_onslope) then {                   
    _coords set [2, [_objheight - 0.3, 0] select (_currentreplacement == "Land_ZalChata")];                   
    };               
   if (_id isEqualTo "1402894") then {_coords set [2, 0.12]};           
   if (_id isEqualTo "1068077") then {_coords set [2, -1]};       
   _myReplacement setdir (_objdir + _currentdir);                     
   _myReplacement setPosATL _coords;                              
   if (count _pitchbank == 3) then {                     
    _myReplacement setVectorUp _pitchbank;                                   
   } else {                                
    [_myReplacement, _pitchBank select 0, _pitchBank select 1] call BIS_fnc_setPitchBank;                     
   };                     
   if (_currentreplacement in ["Land_Lampazel", "Land_Lamp_Small_EP1"]) then {                    
    _myReplacement enableDynamicSimulation true;                      
   };                   
   if (_downed or {_currentreplacement isEqualTo "Land_Sara_domek02"}) then {                   
       _myReplacement addEventHandler ["Killed",{                   
  params ["_obj"];                   
  _pos = getposATL _obj;                   
  _obj removeEventHandler ["Killed", _thisEventHandler];                   
  [{                   
   params ["_obj","_pos"];                   
   _ruins = (_pos nearObjects ["Ruins", 3]);                   
   if (count _ruins > 0) then {                   
    _ruins = _ruins#0;         
 private _delta = [3.2, 0] select (typeof _obj isEqualTo "Land_Sara_domek02");         
    _ruins setpos [_pos#0,_pos#1,(_pos#2) + _delta];                   
    _static = spawner getvariable ["OT_destroyedstatic",[]];         
 _ruins setvectorup [0,0,1];         
 if (typeof _obj isEqualTo "Land_Sara_domek02") then {         
  _ruins setposATL (_ruins modelToWorld [0,2,0]);         
 };         
    private _ids = _obj call {                   
     private _value = [];                   
     private _objectpos = [(getpos (param [0, objNull]))#0, (getpos (param [0, objNull]))#1, 0];                   
     private _obj = str(param [0, objNull]);                    
     private _id = -1;                    
     private _find = ((_obj find "#") + 2);                    
     if (_find > 1) then {                   
      private _len = ((_obj find ":") - _find);                     
      _id = _obj select [_find, _len];                    
      _value = [_id, _objectpos];                    
     };                    
     _value                   
    };                   
    _static pushback [_ids, damage _obj, true, typeof _obj];                   
    spawner setvariable ["OT_destroyedstatic",_static];                   
   };                   
  }, [_obj,_pos], 5] call CBA_fnc_waitAndExecute;                   
       }];                   
   };                   
  };                     
 } foreach _idcoords;                     
} forEach OT_common_array;                                  
OT_Common_finished = true;                                               
OT_common_array = [];                    
};

