-- UNIVERSAL SCRIPT LOADER & FETCHER 

--[[
    Credits & Development:
    - Initial script by DOZE/Soulja/UILib.
]]

---------------------------------------------------------------------
-- Configuration Table
---------------------------------------------------------------------
local Config = {
    Url = "website here",
    AutoExecute = false,
    CopyToClipboard = true,
    Verbose = true,
    MaxRetries = 3,
    RetryDelay = 2,
}

---------------------------------------------------------------------
-- Services and Initial Validation
---------------------------------------------------------------------
if not HttpGet then
    warn("❌ Critical Error: HttpGet is not available in this environment. The script cannot function.")
    return
end

local originalUrl = Config.Url
if originalUrl then originalUrl = originalUrl:match("^%s*(.-)%s*$") end

if not originalUrl or originalUrl == "" or originalUrl == "website here" then
    warn("❌ URL is empty or hasn't been changed. Please configure the script.")
    return
end

if Config.AutoExecute and Config.Verbose then
    warn("⚠️ AutoExecute is enabled. Only use this with a URL from a trusted source.")
end

local finalUrl = originalUrl
local handlerOrder = { "gist.github.com", "github.com", "gitlab.com", "bitbucket.org", "pastebin.com", "paste.ee", "rentry.co", "controlc.com", "scriptblox.com", "haxhell.com" }
local urlHandlers = {
    ["github.com"] = function(url) if not url:match("raw.githubusercontent.com") then return url:gsub("github.com", "raw.githubusercontent.com"):gsub("/blob/", "/") end; return url end,
    ["gist.github.com"] = function(url) if not url:match("gist.githubusercontent.com") then local u, g = url:match("gist.github.com/([^/]+)/([%w%d]+)"); if u and g then return ("https://gist.githubusercontent.com/%s/%s/raw/"):format(u, g) end end; return url end,
    ["gitlab.com"] = function(url) if not url:match("/-/raw/") and url:match("/-/blob/") then return url:gsub("/-/blob/", "/-/raw/") end; return url end,
    ["bitbucket.org"] = function(url) if url:match("/src/") and not url:match("/raw/") then return url:gsub("/src/", "/raw/") end; return url end,
    ["pastebin.com"] = function(url) if not url:match("/raw/") then local id = url:match("pastebin.com/([%w%d]+)"); if id then return "https://pastebin.com/raw/"..id end end; return url end,
    ["paste.ee"] = function(url) if not url:match("/r/") and url:match("/p/") then return url:gsub("/p/", "/r/") end; return url end,
    ["rentry.co"] = function(url) if not url:match("/raw/") then local id = url:match("rentry.co/([%w%d]+)"); if id then return "https://rentry.co/raw/"..id end end; return url end,
    ["controlc.com"] = function(url) if not url:match("/download/") then local id = url:match("controlc.com/([%w%d]+)"); if id then return "https://controlc.com/download/"..id end end; return url end,
    ["scriptblox.com"] = function(url) if not url:match("rawscripts.net") then local path = url:match("scriptblox.com/script/(.+)") if path then return "https://rawscripts.net/raw/" .. path end end return url end,
    ["haxhell.com"] = function(url) if not url:match("/raw/") and url:match("/script/") then return url:gsub("/script/", "/raw/") end return url end,
}

for _, domain in ipairs(handlerOrder) do
    if originalUrl:match("^https?://[^/]*" .. domain) then
        local handler = urlHandlers[domain]
        local convertedUrl = handler(originalUrl)
        if convertedUrl and convertedUrl ~= originalUrl then
            finalUrl = convertedUrl
            if Config.Verbose then print("✅ Converted URL using handler for: " .. domain) end
            break
        end
    end
end

local scriptContent, success, final_error = nil, false, "Unknown error"

for attempt = 1, Config.MaxRetries do
    if Config.Verbose then print(("Fetching from final URL: %s (Attempt %d/%d)"):format(finalUrl, attempt, Config.MaxRetries)) end
    local s, r = pcall(function() return HttpGet(finalUrl) end)
    if s then
        success, scriptContent = true, r
        break
    else
        final_error = tostring(r)
        if attempt < Config.MaxRetries then
            if Config.Verbose then warn(("⚠️ Fetch failed. Retrying in %d seconds..."):format(Config.RetryDelay)) end
            task.wait(Config.RetryDelay)
        end
    end
end

if success then
    if Config.Verbose then print("✅ Fetch successful!") end

    if type(scriptContent) ~= "string" then
        warn(("❌ Fetch error: The server returned an invalid response type (expected string, got %s)."):format(type(scriptContent)))
        return
    end
    
    -- 1. Comprehensive line ending normalization: Handles \r\n (Windows), \r (old Mac), and ensures consistent \n.
    scriptContent = scriptContent:gsub("\r\n", "\n"):gsub("\r", "\n")

    if not scriptContent or scriptContent:gsub("%s", "") == "" then
        warn("⚠️ Fetch was successful, but the returned script content is empty.")
        return
    end
    
    -- 2. Case-insensitive HTML detection for maximum robustness.
    local contentLower = scriptContent:lower()
    if contentLower:find("<html") or contentLower:find("<!doctype") then
        warn("❌ Execution blocked: The fetched content is an HTML page, not a Lua script. This is likely an access-denied page.")
        return
    end

    if #scriptContent < 50 and Config.Verbose then
        warn("⚠️ The fetched script is unusually small. Please verify it's the correct content.")
    end

    if Config.CopyToClipboard then
        if not setclipboard then if Config.Verbose then warn("⚠️ Clipboard API (setclipboard) is not available.") end
        else setclipboard(scriptContent); if Config.Verbose then print("📋 Script copied to clipboard.") end
        end
    end

    if Config.AutoExecute then
        if not loadstring then warn("❌ Execution failed: loadstring is not available.")
        else
            if Config.Verbose then print("▶️ Attempting to execute script...") end
            warn("🚨 Executing script with full executor permissions.")
            local s, f = pcall(loadstring(scriptContent))
            if s and typeof(f) == "function" then
                local execSuccess, execError = pcall(f)
                if not execSuccess then
                    warn("❌ Script executed but threw an error: " .. tostring(execError))
                else
                    -- 3. CRITICAL SYNTAX FIX: Replaced the invalid "else if" with a proper nested "if".
                    if Config.Verbose then
                        print("✔️ Script executed successfully.")
                    end
                end
            else
                warn("⚠️ Fetched content is not a valid script and cannot be executed.")
            end
        end
    end
else
    warn(("❌ Failed to fetch script after %d attempts. Final error: %s"):format(Config.MaxRetries, final_error))
end
