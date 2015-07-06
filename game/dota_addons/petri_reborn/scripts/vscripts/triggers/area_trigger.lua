function OnStartTouch(trigger)
 	trigger.activator.currentArea = trigger.caller
end
 
function OnEndTouch(trigger)
	trigger.activator.currentArea = nil
end

function Activate(...)
	print("Area activated")
end