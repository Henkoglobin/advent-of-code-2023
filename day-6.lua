require "lua-string"

local linq = require("lazylualinq")
local client = require("client")

return {
    day = 0,
    init = function(self, day)
       self.day = day
    end,
    puzzle1 = function(self)
        local rawData = client:getDayInput(self.day):trim():split("\n")

        local times = linq(rawData[1]:split("%s+", true)):skip(1):select("v => tonumber(v)"):toArray()
        local distances = linq(rawData[2]:split("%s+", true)):skip(1):select("v => tonumber(v)"):toArray()

        return linq(times):zip(linq(distances), function(time, _, distance)
            return { time = time, distance = distance }
        end):select(self.solveRace):aggregate(1, "a, b => a * b")
    end,
    puzzle2 = function(self)
        local rawData = client:getDayInput(self.day):trim():split("\n")
        local time = tonumber((rawData[1]:match("Time:%s*([%d%s]+)"):gsub("%s", "")))
        local distance = tonumber((rawData[2]:match("Distance:%s*([%d%s]+)"):gsub("%s", "")))
        
        return self.solveRace({ time = time, distance = distance }, 1)
    end,
    solveRace = function(race, i) 
        local p, q = -race.time, race.distance + 0.1
        local c1 = -p / 2 + math.sqrt((p / 2) * (p / 2) - q)
        local c2 = -p / 2 - math.sqrt((p / 2) * (p / 2) - q)
        
        return math.floor(c1) - math.ceil(c2) + 1
    end,
}