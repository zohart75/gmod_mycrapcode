local PLAYER = FindMetaTable("Player")

local query, str, json, unjson = sql.Query, sql.SQLStr, util.TableToJSON, util.JSONToTable

hook.Add("Initialize", "Metadata.Create", function()
	query("CREATE TABLE IF NOT EXISTS metadata(info, key, type, value)")
end)

hook.Add("PlayerInitialSpawn", "Metadata.Load", function(ply)
	local info = ply:SteamID().."["..ply:Name().."]"

	local data = query("SELECT * FROM metadata WHERE info = "..str(info))

	if (!data) then goto ended end

	for _, v in pairs(data) do
		ply:SetNWString("metadata_"..v.key, v.value)
	end

	::ended::
	hook.Call("MetadataLoaded", nil, ply)
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

--[[ No Meta ]]

function SetMetadata(ply, key, value)
    if (!ply or !key or !value) then return end

    local info = ply:SteamID().."["..ply:Name().."]"
    local type = type(value)

    value = istable(value) and json(value) or tostring(value)

    ply:SetNWString("metadata_"..key, value)

    local data = query("SELECT * FROM metadata WHERE info = "..str(info).." AND key = "..str(key))
    if (data) then
        query("UPDATE metadata SET type = "..str(type)..", value = "..str(value).." WHERE info = "..str(info))
    else
        query("INSERT INTO metadata(info, key, type, value) VALUES("..str(info)..", "..str(key)..", "..str(type)..", "..str(value)..")")
    end
end

function DeleteMetadata(ply, key)
	if (!ply or !key) then return end

	local info = ply:SteamID().."["..ply:Name().."]"

	ply:SetNWString("metadata_"..key, nil)

	local data = query("SELECT * FROM metadata WHERE info = "..str(info).." AND key = "..str(key))
	if (data) then
		query("DELETE FROM metadata WHERE info = "..str(info).." AND key = "..str(key))
	end
end

function GetMetadata(ply, key)
	if (!ply or !key) then return end
	local info = ply:SteamID().."["..ply:Name().."]"

	local data = query("SELECT * FROM metadata WHERE info = "..str(info).." AND key = "..str(key))
	if (data) then
		local val = sql.QueryValue("SELECT value FROM metadata WHERE info = "..str(info).." AND key = "..str(key))
		return (data[1].type == "table" and unjson(val) or val)
	end
end
