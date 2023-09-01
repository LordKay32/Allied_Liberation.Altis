
["DynamicBlur", 400, [5]] spawn 
{ 
params ["_name", "_priority", "_effect", "_handle"]; 
while { 
_handle = ppEffectCreate [_name, _priority]; 
_handle < 0;
} do { 
_priority = _priority + 1; 
}; 
_handle ppEffectEnable true; 
_handle ppEffectAdjust _effect; 
_handle ppEffectCommit 300;  

waitUntil {!(player getVariable ["incapacitated",false])};
_handle ppEffectEnable false;
ppEffectDestroy _handle;
};

["ColorCorrections", 1500, [1, 0.4, 0, [1, 0, 0, 0], [1, 0, 0, 0], [1, 0, 0, 0]]] spawn 
{ 
params ["_name", "_priority", "_effect", "_handle"]; 
while { 
_handle = ppEffectCreate [_name, _priority]; 
_handle < 0;
} do { 
_priority = _priority + 1; 
}; 
_handle ppEffectEnable true; 
_handle ppEffectAdjust _effect; 
_handle ppEffectCommit 300; 

waitUntil {sleep 0.1; !(player getVariable ["incapacitated",false])};
_handle ppEffectEnable false;
ppEffectDestroy _handle;
};