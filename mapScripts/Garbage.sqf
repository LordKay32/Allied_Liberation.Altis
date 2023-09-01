_junk = ["SIGN","GARBAGE","WRECK","TYRES","TOILET","JUNKPILE","FISHINGGEAR","CRABCAGES","TRANSMITTER","TOURISM","SHIPWRECK"]; 
{ 
_item = _x; 
if ({(toUpper(str _item) find _x >=0)} count _junk > 0) then { 
  hideObjectGlobal  _item; 
_item enableSimulationGlobal false; 
}; 
} foreach nearestTerrainObjects [[worldSize/2, worldSize/2], ["HIDE"], 30000];
OT_garbage = true;

