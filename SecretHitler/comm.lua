local CONST = SecretHitlerNS.CONST;
local game_s = SecretHitlerNS.game_s;

local util = SecretHitlerNS.util;

------------------------------------
-- Simple communication functions --
------------------------------------

-- Fetches the numeric ID of the extension chat channel.
local function channelID()
	local comm_ch_ID, comm_ch_name, comm_instance_ID = GetChannelName(CONST.CHANNEL_NAME);
	return comm_ch_ID;
end

-- A wrapper for sending messages on the extension chat channel.
local function send(msg)
	JoinPermanentChannel(CONST.CHANNEL_NAME);	-- TODO: Should this be here?
	SendChatMessage(msg, "CHANNEL", nil, channelID());
end

---------------------------------------
-- Composite communication functions --
---------------------------------------

-- Sends a properly formatted join request to a lobby.
local function req_join(roomID, roomKey)
	local req = "JOIN" .. util.pad_int(roomID, 2);
	req = req .. util.get_authStr(roomKey);
	send(req);
end

-- Sends an automatically incrementing turn broadcast.
local function send_t(msg)
	local prefix = "TURN" .. game_s.roomID;
	prefix = prefix .. util.pad_int(game_s.turn, 4);
	send(prefix .. msg);
	game_s.turn = game_s.turn + 1;
end

----------------------
-- Export interface --
----------------------

SecretHitlerNS.comm = {
	channelID = channelID,
	send = send,
	req_join = req_join,
	send_t = send_t,
};
