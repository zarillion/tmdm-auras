local aura_env = aura_env

aura_env.dosages = {}

aura_env.assignments = {
    [6] = {},
    [4] = {},
    [3] = {},
    [7] = {}
}

aura_env.locked = {
    [6] = {}, -- SQUARE
    [4] = {}, -- TRIANGLE
    [3] = {}, -- DIAMOND
    [7] = {}, -- CROSS
}

aura_env.MRT = function()
    if C_AddOns.IsAddOnLoaded("MRT") and _G.VExRT.Note.Text1 then
        local function startswith(s, start)
            return s:sub(1, #start) == start
        end

        aura_env.locked = {
            [6] = {}, -- SQUARE
            [4] = {}, -- TRIANGLE
            [3] = {}, -- DIAMOND
            [7] = {}, -- CROSS
        }

        local list = false
        local text = _G.VExRT.Note.Text1

        for line in text:gmatch('[^\r\n]+') do
            local marker = nil

            line = strtrim(line)
            if strlower(line) == "eggstart" then
                list = true
            elseif strlower(line) == "eggend" then
                list = false
            end

            if list then
                if startswith(line, "{square}") then
                    marker = 6
                elseif startswith(line, "{triangle}") then
                    marker = 4
                elseif startswith(line, "{diamond}") then
                    marker = 3
                elseif startswith(line, "{cross}") then
                    marker = 7
                end

                if marker ~= nil then
                    for name in line:gmatch("|c%x%x%x%x%x%x%x%x([^|]+)|") do
                        table.insert(aura_env.locked[marker], name)
                    end
                end
            end
        end
    end
end
