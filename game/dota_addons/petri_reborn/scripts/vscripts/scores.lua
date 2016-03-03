GameMode.SCORE_TIMINGS = {}
GameMode.SCORE_TIMINGS[1] = 4
GameMode.SCORE_TIMINGS[2] = 12
GameMode.SCORE_TIMINGS[3] = 20
GameMode.SCORE_TIMINGS[4] = 28
GameMode.SCORE_TIMINGS[5] = 35

function GameMode:TimingScores( )
	for i=1,#GameMode.SCORE_TIMINGS do
		Timers:CreateTimer((GameMode.SCORE_TIMINGS[i] * 60),
		    function()
		    	for k,v in pairs(GameMode.villians) do
		    		v.petrosyanScore = v.petrosyanScore + GetPetriBonusScore( v.allEarnedGold, i )

		    		print(v:GetUnitName(), v.petrosyanScore)
		    	end
		    	for k,v in pairs(GameMode.kvns) do
		    		v.kvnScore = v.kvnScore + GetKVNBonusScore( v.allEarnedGold, i-1 )
		    	end
		    end
		)
	end
end

function GetPetriBonusScore( gold, modifier )
	local basic_gold = 0 
	if modifier > 1 then
		basic_gold = 1192
	end
	return (gold - basic_gold) * (#GameMode.SCORE_TIMINGS - (modifier-1))
end

function GetKVNBonusScore( gold, modifier )
	return (gold-1) * modifier
end