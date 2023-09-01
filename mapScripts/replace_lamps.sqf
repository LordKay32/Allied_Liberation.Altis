myBuildings = [["Land_LampSolar_F","Land_Lampazel",0,0],["Land_LampAirport_off_F","Land_Lampazel",90,0],["Land_LampStreet_F","Land_Lamp_Small_EP1",0,0],["Land_Lampa_sidl","Land_Lamp_Small_EP1",270,0],["Land_LampStreet_small_F","Land_Lamp_Small_EP1",270,0],["Land_LampDecor_F","Land_Lamp_Small_EP1",90,0],["Land_LampHarbour_F","Land_Lamp_Small_EP1",0,0],["Land_LampHalogen_F","Land_Lamp_Small_EP1",270,0]                        ];   
 
for "_i" from 0 to(count myBuildings-1) do { 
 
    _CurrentBuilding   = (myBuildings select _i) select 0; 
    _ReplacementBuilding = (myBuildings select _i) select 1;  
    _DirectionOffset   = (myBuildings select _i) select 2;  
     
 
    { 
        systemchat format["getPosATL: %2 getDir: %4 _CurrentBuilding %5",getpos _x, getPosATL _x, getPosASL _x, getdir _x, _x];  
        diag_log format["getPosATL: %1 getDir: %2 _CurrentBuilding %3 _ReplacementBuilding %4 _x %5", getPosATL _x, getdir _x, _CurrentBuilding, _ReplacementBuilding, _x];  
        hideObjectGlobal  _x; 
     
        _myReplacement = createVehicle [_ReplacementBuilding, getPosATL _x, [], 0, "CAN_COLLIDE"]; 
        _myReplacement setDir (getdir _x) + _DirectionOffset; 
        _myReplacement setPosATL (getPosATL _x) ; 
    } forEach nearestObjects [[worldSize/2, worldSize/2], [_CurrentBuilding], 30000]; 
 
 
}; 
sleep 0.1;
OT_lamps = true;