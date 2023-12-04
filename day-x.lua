require "lua-string"

local linq = require("lazylualinq")
local client = require("client")

return {
    init = function(self, day)
        local rawData = client:getDayInput(day):trim()
    end,
    puzzle1 = function(self)
        return 0
    end,
    puzzle2 = function(self)
        return 0
    end,
}