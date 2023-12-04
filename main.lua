-- lua-string breaks the parsing in http if required before http, so we make sure to (indirectly) require 
-- http here before ever requiring lua-string
local client = require("client")

-- Some convenience for the puzzles
table.__index = table

local function main(day)
    if day and not day:match("^%d+$") then
        print("Parameter 1 must be a number, if it's present.")
        return
    elseif not day then
        day = os.date("*t").day
    end

    local ok, puzzles = pcall(require, "day-" .. day)

    if not ok then
        local err = puzzles

        print(("There's no solution for day '%s' (yet): %s"):format(day, err))
        return
    end

    local ok, err = pcall(puzzles.init, puzzles)
    if not ok then
        print(("Initialization of day %s failed: %s"):format(day, err))
        return
    end

    print(("Answer for day %s, puzzle 1: %s"):format(day, puzzles:puzzle1()))

    if puzzles.puzzle2 then
        print(("Answer for day %s, puzzle 2: %s"):format(day, puzzles:puzzle2()))
    else
        print(("There's no solution for day %s, puzzle 2 yet."):format(day))
    end
end

main(...)