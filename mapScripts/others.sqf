myBuildings = [["Land_Slum_House01_F","Land_WW2_Shed_W01",180,0]];                   
                
for "_i" from 0 to(count myBuildings-1) do {                
                
    _CurrentBuilding   = (myBuildings select _i) select 0;                
    _ReplacementBuilding = (myBuildings select _i) select 1;                 
    _DirectionOffset   = (myBuildings select _i) select 2;              
    _HeightOffset   = (myBuildings select _i) select 3;                  
                    
                
    {                
        systemchat format["getPosATL: %2 getDir: %4 _CurrentBuilding %5",getpos _x, getPosATL _x, getPosASL _x, getdir _x, _x];                 
        diag_log format["getPosATL: %1 getDir: %2 _CurrentBuilding %3 _ReplacementBuilding %4 _x %5", getPosATL _x, getdir _x, _CurrentBuilding, _ReplacementBuilding, _x];                 
        hideObjectGlobal  _x;                
                    
        _myReplacement = createVehicle [_ReplacementBuilding, getPosATL _x, [], 0, "CAN_COLLIDE"];                
        _myReplacement setDir (getdir _x) + _DirectionOffset;                
        _myReplacement setPosATL [getPosATL _x select 0, getPosATL _x select 1, (getPosATL _x select 2) - _HeightOffset];                  
                             
        _myReplacement enableSimulationGlobal false;               
    } forEach nearestObjects [[worldSize/2, worldSize/2], [_CurrentBuilding], 30000];                
                
                
};                

sleep 0.1;
OT_others = true;