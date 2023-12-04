require "lua-string"

local linq = require("lazylualinq")
local client = require("client")

return {
    schematic = {},
    init = function(self, day)
        local rawSchematic = client:getDayInput(day):trim():split("\n")

        self.schematic = linq(rawSchematic)
            :selectMany(function(line, id)
                local candidates = setmetatable({}, table)
        
                local endIndex = 0
                while true do
                    local startIndex, number
                    startIndex, endIndex, number = line:find("(%d+)", endIndex + 1)
                    if startIndex == nil then
                        break
                    end
        
                    candidates:insert({
                        line = id,
                        first = startIndex,
                        last = endIndex,
                        number = tonumber(number),
                    })
                end
        
                return candidates
            end)
            :select(function(partNumberCandidate)
                for y = partNumberCandidate.line - 1, partNumberCandidate.line + 1 do
                    for x = partNumberCandidate.first - 1, partNumberCandidate.last + 1 do
                        local intersectsNumber = y == partNumberCandidate.line
                            and x >= partNumberCandidate.first
                            and x <= partNumberCandidate.last
        
                        if y >= 1 and y <= #rawSchematic and not intersectsNumber then
                            local char = rawSchematic[y]:sub(x, x)
                            if #char > 0 and char ~= "." then
                                return {
                                    line = partNumberCandidate.line,
                                    start = partNumberCandidate.first,
                                    last = partNumberCandidate.last,
                                    number = partNumberCandidate.number,
                                    part = {
                                        x = x,
                                        y = y,
                                        type = char
                                    }
                                }
                            end
                        end
                    end
                end
        
                return partNumberCandidate
            end)
            :where(function(partCandidate) return partCandidate.part ~= nil end)
            :toArray()
    end,
    puzzle1 = function(self)
        return linq(self.schematic)
            :sum(function(partNumber) return partNumber.number end)
    end,
    puzzle2 = function(self)
        local gearTypeCandidates = {}

        for _, part in pairs(self.schematic) do
            if part.part.type == "*" then
                local key = ("%d-%d"):format(part.part.x, part.part.y)
                local candidate = gearTypeCandidates[key]
                if candidate == nil then
                    candidate = {}
                    gearTypeCandidates[key] = candidate
                end

                table.insert(candidate, part)
            end
        end

        return linq(gearTypeCandidates)
            :where(function(candidate) return #candidate == 2 end)
            :select(function(partNumbers) return partNumbers[1].number * partNumbers[2].number end)
            :sum()
    end,
}