_location = [worldSize/2, worldSize/2]; 
_objects = ["POWERSOLAR","TRANSMITTER","POWERWAVE","TOURISM","POWERWIND","SHIPWRECK","POWER LINES"]; _radius = 30000; _terrainobjects = nearestTerrainObjects [_location,_objects,_radius]; {hideObjectGlobal _x; _x enableSimulationGlobal false} foreach _terrainobjects;
OT_power = true;