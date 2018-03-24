local CONST = SecretHitlerNS.CONST;

---------------------
-- Table functions --
---------------------

-- Count the number of (contiguous?) entries in a table.
local function table_size(T)
	local count = 0;
	for _ in pairs(T) do
		count = count + 1;
	end
	return count;
end

-- Count the entries matching the input.
local function count(T, x)
	local n = 0;
	for i=1,table_size(T) do
		if (T[i] == x) then n = n + 1; end
	end
	return n;
end

-- Shuffles the entries of a table.
local function shuffle(T)
	-- we start from 1 and go to size-1 because we use 2 numbers each time
	local t = table_size(T);
	for i=1, t-1 do
		local j = math.random(1, t);
		buf = T[i];
		T[i] = T[j];
		T[j] = buf;
	end
	return T;
end

-- Reshuffles policy deck.
local function setup_policies(T)
	for i=1,6  do T[i] = "L"; end
	for i=1,11 do T[i] = "F"; end
	T = shuffle(T);
end

-- Draws and discards the top entry of a table.
local function draw(T)
	if (table_size(T) < 3) then
		setup_policies(T);
	end
	local card = T[1];
	table.remove(T, 1);
	return card;
end

----------------------
-- String functions --
----------------------

-- Pad the left side of an int `x` with "0", to a total length of `max_len`.
local function pad_int(x, max_len)
	local buf = tostring(x);
	for i = buf:len(), max_len-1 do
		buf = "0" .. buf;
	end
	return buf;
end

-- A hash function for generating auth hashes to share between server/client.
local function minihash(key, salt, reps)
	local output = key;
	for i = 1, reps do
		output = bit.lshift(output, 2) + output;
		output = bit.bxor(output, salt);
		output = output % 512;
	end
	return output;
end

-- Calculates a salted hash to use for authentication.
local function get_authStr(key)
	-- starting at 100 is arbitrary, but is needed to prevent attacks
	local salt = math.random(100, 1000);
	local hash = minihash(key, salt, CONST.HASH_REPS);
	return pad_int(salt, 3) .. pad_int(hash, 3);
end

-- Authenticates the client's hash.
local function is_authed(hash, key)
	local salt = tonumber(string.sub(hash, 1, 3));
	local hash_client = tonumber(string.sub(hash, 4, 6));
	local hash_server = minihash(key, salt, CONST.HASH_REPS);

	if (salt < 100 or salt > 1000) then
		return false;
	end
	return (hash_client == hash_server);
end

--------------------
-- Name functions --
--------------------

-- Returns the "CharacterName-ServerName" of the player.
local function get_selfName()
	name = GetUnitName("player", true) .. "-" .. GetRealmName();
	name = gsub(name, "%s+", "");
	return name;
end

-- Returns the "CharacterName" of a "CharacterName-ServerName" string.
local function get_shortName(name)
	local shortName = "";
	local i_end = string.find(name, "-") - 1;
	if (i_end == nil) then
		shortName = name;
	else
		shortName = string.sub(name, 1, i_end);
	end
	return shortName;
end

-- TODO: rename to `get_index(T, x)`
-- Returns the index of a "CharacterName-ServerName" in `players`.
local function get_indexName(players, name)
	local index = 0;
	for i,v in ipairs(players) do
		if (v == name) then
			index = i; break;
		end
	end
	return index;
end

-------------------------
-- Game info functions --
-------------------------

-- Returns the action code for an action on the facist track.
local function get_actionCode(n, player_num)
	local codes_A = {"NA", "NA", "PP", "XT", "XT", "NA"};
	local codes_B = {"NA", "IL", "SE", "XT", "XT", "NA"};
	local codes_C = {"IL", "IL", "SE", "XT", "XT", "NA"};
	if (player_num <= 6) then
		return codes_A[n];
	elseif (player_num <= 8) then
		return codes_B[n];
	elseif (player_num <= 10) then
		return codes_C[n];
	end
end

-- Returns the name for an action on the facist track.
local function get_actionText(n, player_num)
	local code = get_actionCode(n, player_num);
	local text = {
		["NA"]	= "",
		["IL"]	= "Investigate|nLoyalty",
		["SE"]	= "Special|nElection",
		["PP"]	= "Policy|nPeek",
		["XT"]	= "Execution"
	}
	return text[code];
end

----------------------
-- Export interface --
----------------------

SecretHitlerNS.util = {
	table_size = table_size,
	count = count;
	shuffle = shuffle,
	setup_policies = setup_policies,
	draw = draw,
	pad_int = pad_int,
	minihash = minihash,
	get_authStr = get_authStr,
	is_authed = is_authed,
	get_selfName = get_selfName,
	get_shortName = get_shortName,
	get_indexName = get_indexName,
	get_actionCode = get_actionCode,
	get_actionText = get_actionText,
};
