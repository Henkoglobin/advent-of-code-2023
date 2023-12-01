require "lua-string"

local linq = require("lazylualinq")
local client = require("client")
local rex = require("rex_pcre2")

return {
    init = function(self) end,
    puzzle1 = function(self)
        return linq(client:getDayInput(1):trim():split("\n"))
            :select(function(line)
                return linq.iterator(line:gmatch("%d")):toArray()
            end)
            :select(function(linechars)
                return tonumber(linechars[1]) * 10 + tonumber(linechars[#linechars])
            end)
            :sum()
    end,
    puzzle2 = function(self)
        return linq(client:getDayInput(1):trim():split("\n"))
            :select(function(line) 
                return linq(
                    rex.match(
                        line, 
                        "(\\d|one|two|three|four|five|six|seven|eight|nine)"
                    ),
                    rex.match(
                        line, 
                        ".+(\\d|one|two|three|four|five|six|seven|eight|nine)"
                    )
                ):toArray()
            end)
            :select(function(lineDigits)
                return 10 * self:parseDigit(lineDigits[1]) + self:parseDigit(lineDigits[#lineDigits])
            end)
            :sum()

    end,
    digitLookup = {
        one = 1,
        two = 2,
        three = 3,
        four = 4,
        five = 5,
        six = 6,
        seven = 7,
        eight = 8,
        nine = 9,
    },
    parseDigit = function(self, digitString) 
        return self.digitLookup[digitString] or tonumber(digitString)
    end,
}