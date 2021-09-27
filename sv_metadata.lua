local PLAYER = FindMetaTable("Player")

local query, str, json, unjson = sql.Query, sql.SQLStr, util.TableToJSON, util.JSONToTable

hook.Add("Initialize", "Metadata.Create", function()
	query("CREATE TABLE IF NOT EXISTS metadata(info, key, type, value)")
end)

function PLAYER:SetMetadata(key, value)
    if (!key or !value) then return end

    local info = self:SteamID().."["..self:Name().."]"
    local type = type(value)

    value = istable(value) and json(value) or tostring(value)

    self:SetNWString("metadata_"..key, value)

    local data = query("SELECT * FROM metadata WHERE info = "..str(info).." AND key = "..str(key))
    if (data) then
        query("UPDATE metadata SET type = "..str(type)..", value = "..str(value).." WHERE info = "..str(info))
    else
        query("INSERT INTO metadata(info, key, type, value) VALUES("..str(info)..", "..str(key)..", "..str(type)..", "..str(value)..")")
    end
end

function PLAYER:DeleteMetadata(key)
	if (!key) then return end

	local info = self:SteamID().."["..self:Name().."]"

	self:SetNWString("metadata_"..key, nil)

	local data = query("SELECT * FROM metadata WHERE info = "..str(info).." AND key = "..str(key))
	if (data) then
		query("DELETE FROM metadata WHERE info = "..str(info).." AND key = "..str(key))
	end
end

function PLAYER:GetMetadata(key)
	if (!key) then return end
	local info = self:SteamID().."["..self:Name().."]"

	local data = query("SELECT * FROM metadata WHERE info = "..str(info).." AND key = "..str(key))
	if (data) then
		local val = sql.QueryValue("SELECT value FROM metadata WHERE info = "..str(info).." AND key = "..str(key))
		return (data[1].type == "table" and unjson(val) or val)
	end
end