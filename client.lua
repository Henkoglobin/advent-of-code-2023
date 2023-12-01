local httpRequest = require("http.request")
local httpCookie = require("http.cookie")

return {
    setCache = function(self, day, puzzleInput)
        local f = io.open(".cache/" .. day, "w+")
        if f == nil then
            os.execute("mkdir .cache")
            f = assert(io.open(".cache/" .. day, "w+"))
        end
        f:write(puzzleInput)
        f:close()
    end,
    getCache = function(self, day)
        local f = io.open(".cache/" .. day, "r")
        if f == nil then
            return nil
        end
        
        local puzzleInput = f:read("*a")
        f:close()

        return puzzleInput
    end,
    getToken = function(self)
        local f = io.open(".token", "r")
        local token = f:read("*l")
        f:close()
        return token
    end,
    getDayInput = function(self, day)
        local cachedInput = self:getCache(day)
        if cachedInput ~= nil then
            print("Got puzzle input form cache!")
            return cachedInput
        end

        local uri = ("https://adventofcode.com/2023/day/%d/input"):format(day)
        local request = httpRequest.new_from_uri(uri)

        request.cookie_store:store(
            "adventofcode.com",
            "/",
            true,
            true,
            nil,
            "session",
            self:getToken(),
            {}
        )

        local headers, stream = assert(request:go())
        local body = assert(stream:get_body_as_string())

        self:setCache(day, body)

        return body
    end,
}