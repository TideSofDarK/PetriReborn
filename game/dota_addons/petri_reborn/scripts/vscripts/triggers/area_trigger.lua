function OnStartTouch(trigger)
 	Timers:CreateTimer(0.03, function ()
 		trigger.activator.currentArea = trigger.caller
 	end)
end
 
function OnEndTouch(trigger)
	trigger.activator.currentArea = nil
end

function Activate(...)
	print("Area activated")
end