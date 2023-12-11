/*
 * Name:	Hidden
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

scriptName "Hidden";

if isServer then {                  
OT_id_array = [];                  
OT_id_array = parseSimpleArray (loadFile "mapScripts\hidden_array.sqf");                  
OT_replace_Walls = (["ot_replace_walls", 0] call BIS_fnc_getParamValue) == 1;   
private _walls = parseSimpleArray (loadFile "mapScripts\walls_array.sqf");   
private _wallslist = _walls apply {_x#0};   
if !(OT_replace_Walls) then {                  
OT_id_array append _walls;                  
};               
               
_exclude = ["1119150","1119142","1118837","1119719","1119700","1120036","1119547","1119151","1119141","1119725","1119703","1120035","1120131","1119546","1119560","1119536","1119152","1118845","1119724","1119460","1119702","1120136","1119743","1119545","1119723","1120137","1119712","1119544","1119534","1119722","1120134","1119790","1119730","1119713","1119745","1119535","1118846","1119721","1120017","1120135","1120109","1119811","1119731","1119720","1119710","1119744","1119104","1119459","1120107","1120108","1119810","1119732","1119709","1119711","1119458","1119733","1120019","1120138","1119708","1119716","1119746","1119149","1120018","1120139","1119812","1119697","1119717","1119148","1119696","1119435","1119714","1119147","1119695","1119455","1119705","1119715","1119154","1119146","1119486","1119704","1120020","1120110","1119543","1119145","1119457","1120021","1120101","1120111","1119808","1119729","1119557","1119558","1119542","1119156","1119144","1118853","1119456","1120022","1120132","1120100","1119809","1119728","1119718","1119559","1119533","1119143","1119701","1120011","1120133","1119727","493980"];               
                 
{                  
 _x params ["_model","_args"];                  
 _args params ["_replacement", "_dir", "_height", "_idcoords"];            
 {                  
  _x params ["_id", "_coords", "_pitchbank"];                  
  private _obj = call compile (str(_coords) + " nearestObject " + _id);                 
  if (_id in _exclude or {isObjectHidden _obj} or {_model isEqualTo "t_fraxinusav2s_f.p3d"}) then {continue};           
            
  if !(isNull _obj) then {                  
   private _objdir = getdir _obj;                  
   private _objheight = [getposATL _obj select 2, 0] select (_model in ["grave_v1_f.p3d","grave_v2_f.p3d","grave_v3_f.p3d"]);                
           
   if (_model in ["cages_f.p3d","barrelwater_f.p3d","len_bag2.p3d","bench_01_f.p3d","bench_02_f.p3d","barrelsand_f.p3d","stallwater_f.p3d","t_phoenixc3s_f.p3d","t_phoenixc1s_f.p3d","bucket_f.p3d","crateswooden_f.p3d","basket_f.p3d"]) then {                  
     _coords set [2, 0];                  
 if (_model isEqualTo "crateswooden_f.p3d") then {           
  _replacement = ["Land_WoodenCrate_01_stack_x5_F","Land_WoodenCrate_01_stack_x3_F"] select ((parsenumber _id) mod 2);           
 };           
       } else {                 
                  _coords set [2, _objheight - _height];               
       };              
        
       if (_model in ["sacks_goods_f.p3d","sack_f.p3d"]) then {           
    _obj setposATL [_coords#0, _coords#1, 0];               
           continue;                 
       } else {               
                 
    _obj hideObjectGlobal true;       
 _obj allowdamage false;           
    if (_model in ["wpp_turbine_v1_f.p3d","wpp_turbine_v2_f.p3d"]) then {              
 _obj setdamage 1;              
 _obj enablesimulationGlobal true;              
    } else {              
 _obj enablesimulationGlobal false;              
    };              
              
   if ((_model in ["t_phoenixc3s_f.p3d","t_phoenixc1s_f.p3d"] && {surfaceType _coords in ["#GdtBeach","#GdtConcrete"]}) or {_model in ["tableplastic_01_f.p3d"] && {abs(_pitchbank#0) > 30 or abs(_pitchbank#1) > 30}} or {_id in ["1119969","1119968","1119963","1119970","1119962","1119967","1119966","1119965","1119964","1119752","1063921","1063922","525992"]}) then {continue};               
   if (_replacement != "")  then {                
              private _simpletree = if ("p3d" in _model && {!(_replacement isEqualTo "Land_Mil_Barracks_EP1")} && {!(_model in ["grave_v1_f.p3d","grave_v2_f.p3d","grave_v3_f.p3d"])}) then {createSimpleObject [_replacement, _coords, [false,true] select (_model in _wallslist)]} else {createVehicle [_replacement, _coords, [], 0, "CAN_COLLIDE"]};               
              if ((getposATL _simpletree) select 2 > 0.1) then {_simpletree setposATL [getposATL _simpletree select 0, getposATL _simpletree select 1, 0]} else {_simpletree setposATL _coords};                            
              _simpletree setDir (_objdir + _dir);                                  
              if (_replacement isEqualTo "Land_bthbc_haybale" or _replacement isEqualTo "land_fow_WoodPile") then {                                 
                  _simpletree setVectorUp (surfaceNormal (getposATL _x));                                  
              } else {                                  
                  [_simpletree, _pitchbank select 0, _pitchbank select 1] call BIS_fnc_setPitchBank;                                 
              };                  
          if (_model in ["t_fraxinusav2s_f.p3d","t_phoenixc3s_f.p3d"] && {getposATL _simpletree select 2 > 0.5}) then {                    
              _simpletree setposATL [getposATL _simpletree select 0, getposATL _simpletree select 1, 0.5];                    
          };                
                  
     if (_model isEqualTo "grave_v3_f.p3d") then {                 
   private _krestpos = (_simpletree modelToWorld [0,1.1,-0.15]);                 
   private _krest = createVehicle [["Land_Church_tomb_1","Land_Church_tomb_2","Land_Church_tomb_3"] select ((_foreachindex + 1) mod 3), _krestpos, [], 0, "CAN_COLLIDE"];                 
   _krest setdir (getdir _simpletree) + 180;                 
   _krest setVectorUp (surfaceNormal _krestpos);                 
   _krest enableDynamicSimulation true;                
     };                 
                 
              _simpletree enableDynamicSimulation true;                    
   };                  
   };                  
  };                  
 } foreach _idcoords;                  
} foreach OT_id_array;                  
OT_Hidden_finished = true;               
OT_id_array = [];                  
};

