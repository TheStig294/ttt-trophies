-- Anything put into this table will be saved, used for stats tracked by certain trophies to unlock
TTTTrophies.stats = {}

-- Create stats file if it doesn't exist
if file.Exists("ttt/trophystats.txt", "DATA") then
    local fileContent = file.Read("ttt/trophystats.txt")
    TTTTrophies.stats = util.JSONToTable(fileContent) or {}
else
    file.CreateDir("ttt")
    file.Write("ttt/trophystats.txt", TTTTrophies.stats)
end

-- Record all stats in the stats file when server shuts down/changes maps
hook.Add("ShutDown", "TTTTrophiesSaveStats", function()
    local fileContent = util.TableToJSON(TTTTrophies.stats, true)
    file.Write("ttt/trophystats.txt", fileContent)
end)