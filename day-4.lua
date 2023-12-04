require "lua-string"

local linq = require("lazylualinq")
local client = require("client")

return {
    cards = {},
    init = function(self, day)
        self.cards = linq(client:getDayInput(day):trim():split("\n"))
            :select(function(line, i)
                local cardId, winningDef, numbersDef = line:match("Card ([%s%d]+): ([^|]+)| (.+)")

                local winningNumbers = linq(winningDef:trim():split("%s+", true))
                    :select("n => tonumber(n)")
                    :toArray()
                local ownNumbers = linq(numbersDef:trim():split("%s+", true))
                    :select("n => tonumber(n)")
                    :toArray()

                return { id = cardId, winningNumbers = winningNumbers, ownNumbers = ownNumbers }
            end)
    end,
    puzzle1 = function(self) 
        return self.cards:sum(function(v) 
            local count = linq(v.ownNumbers):count(function(num)
                return linq(v.winningNumbers):any(function(w) return w == num end)
            end)

            return count > 0 and math.tointeger(math.pow(2, count - 1)) or 0
        end)
    end,
    puzzle2 = function(self)
        local originalCards = self.cards:toArray()

        local processed = 0
        local queue = setmetatable({}, table)

        for _, card in ipairs(originalCards) do
            processed = processed + 1

            local numMatches = linq(card.winningNumbers):count(function(num)
                return linq(card.ownNumbers):any(function(n) return n == num end)
            end)

            for i = 1, numMatches do
                print(card.id, " has ", numMatches, "matches , now adding ", card.id + i)
                queue:insert(originalCards[card.id + i])
            end
        end

        -- This is q QnD Brute Force solution; we could also try to build up a some kind of tree of duplicating
        -- cards, but this works and just takes a few minutes, so... ㄟ( ▔, ▔ )ㄏ
        while #queue > 0 do
            local card = queue:remove()

            processed = processed + 1

            local numMatches = linq(card.winningNumbers):count(function(num)
                return linq(card.ownNumbers):any(function(n) return n == num end)
            end)

            for i = 1, numMatches do
                queue:insert(originalCards[card.id + i])
            end

            print(
                card.id, " has ", numMatches, "matches",
                "remaining queue length ", #queue,
                "currently processed", processed
            )
        end

        return processed
    end
}