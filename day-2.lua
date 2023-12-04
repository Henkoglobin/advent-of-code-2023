require "lua-string"

local linq = require("lazylualinq")
local client = require("client")

return {
    games = {},
    init = function(self)
        self.games = linq(client:getDayInput("2"):trim():split("\n"))
            :select(function(line)
                local gameId, sampleDefs = line:match("Game ([%s%d]+): (.+)")
                local samples = linq(sampleDefs:split("; ")):select(function(sampleDef)
                    return linq(sampleDef:split(", ")):select(function(colorSampleDef)
                        local numStr, color = colorSampleDef:match("(%d+) (%w+)")
                        return {
                            color = color,
                            count = tonumber(numStr)
                        }
                    end):toArray()
                end):toArray()

                return {
                    id = tonumber(gameId),
                    samples = samples,
                }
            end)
            :toArray()
    end,
    game1Limits = {
        red = 12,
        green = 13,
        blue = 14,
    },
    puzzle1 = function(self)
        local possibleGames = linq(self.games)
            :where(function(game)
                return linq(game.samples):all(function(sample)
                    return linq(sample):all(function(colorSample)
                        local limit = self.game1Limits[colorSample.color]
                        return colorSample.count <= limit
                    end)
                end)
            end)
            :sum(function(game) 
                return game.id 
            end)

        return possibleGames
    end,
    puzzle2 = function(self)
        return linq(self.games)
            :select(function(game)
                local set = { red = 0, green = 0, blue = 0 }

                for _, sample in pairs(game.samples) do
                    for _, colorSample in pairs(sample) do
                        set[colorSample.color] = math.max(set[colorSample.color], colorSample.count)
                    end
                end

                return set
            end)
            :sum(function(set)
                return set.red * set.green * set.blue
            end)
    end,
}