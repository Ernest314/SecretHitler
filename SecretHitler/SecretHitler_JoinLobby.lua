local CONST = SecretHitlerNS.CONST;
local game = SecretHitlerNS.game;

local util = SecretHitlerNS.util;
local comm = SecretHitlerNS.comm;

-- TODO: unregister this handler when not used anymore
local player_num = 0;
local function handler_comms(self, event, ...)
	if (event ~= "CHAT_MSG_CHANNEL") then return; end
	local channel_num = select(8, ...);
	if (channel_num ~= comm.channelID()) then return; end

	local msg = select(1, ...);
	local author = select(2, ...);

	local cmd = string.sub(msg, 1, 4);
	local roomID = string.sub(msg, 5, 9);
	-- TODO: change if-elseif chain to an emulated switch.
	-- see: http://lua-users.org/wiki/SwitchStatement

	if (roomID ~= game.roomID) then return; end
	if (cmd == "CFRM") then
		local name = string.sub(msg, 10);
		if (name == util.get_selfName()) then
			game.host = author;
			SecretHitler_JoinLobby_buttonJoin:SetText("Joined!");
		end
	elseif (cmd == "RJCT") then
		local name = string.sub(msg, 10);
		if (name == util.get_selfName()) then
			SecretHitler_JoinLobby_buttonJoin:SetText("Rejected");
			-- 3 seconds is pretty random tbh
			C_Timer.After(3, function()
				SecretHitler_JoinLobby_buttonJoin:SetText("Join");
				SecretHitler_JoinLobby_buttonJoin:Enable();
			return; end);
		end
	elseif ((cmd == "DSBD") and (game.host == author)) then
		SecretHitler_JoinLobby_buttonJoin:SetText("Disbanded!");
		C_Timer.After(3, function()
			SecretHitler_JoinLobby_buttonJoin:SetText("Join");
			SecretHitler_JoinLobby_buttonJoin:Enable();
		return; end);
	elseif ((cmd == "RCHK") and (game.host == author)) then
		player_num = tonumber(string.sub(msg, 10, 11));
	elseif ((cmd == "LSTN") and (game.host == author)) then
		local i = tonumber(string.sub(msg, 10, 11));
		local name = string.sub(msg, 12);
		game.players[i] = name;
		if (i == player_num) then
			comm.send("ACKR" .. game.roomID);
			SecretHitlerNS.Game.init();
			SecretHitler_JoinLobby:Hide();
		end
	end
end

local function cleanup()
	SecretHitler_JoinLobby_textboxRoomID:SetText("");
	SecretHitler_JoinLobby_textboxRoomKey:SetText("");

	SecretHitler_JoinLobby_buttonJoin:SetText("Join");
	SecretHitler_JoinLobby_buttonJoin:Enable();
end

local function init()
	cleanup();

	JoinPermanentChannel(CONST.CHANNEL_NAME);

	SecretHitler_JoinLobby:RegisterEvent("CHAT_MSG_CHANNEL");
	SecretHitler_JoinLobby:SetScript("OnEvent", handler_comms);
	
	SecretHitler_JoinLobby:Show();
end

local function buttonJoin_clicked()
	game.roomID = util.pad_int(SecretHitler_JoinLobby_textboxRoomID:GetNumber(), 5);
	game.roomKey = SecretHitler_JoinLobby_textboxRoomKey:GetNumber();
	comm.req_join(game.roomID, game.roomKey);

	SecretHitler_JoinLobby_buttonJoin:Disable();
	SecretHitler_JoinLobby_buttonJoin:SetText("Joining...");
	-- All the timings are pretty random tbh
	C_Timer.After(5, function()
		if (SecretHitler_JoinLobby_buttonJoin:GetText() == "Joining...") then
			SecretHitler_JoinLobby_buttonJoin:SetText("No Response");
			C_Timer.After(3, function()
				SecretHitler_JoinLobby_buttonJoin:SetText("Join");
				SecretHitler_JoinLobby_buttonJoin:Enable();
			return; end);
		end
	return; end);
end

SecretHitlerNS.JoinLobby = {
	init = init,
	cleanup = cleanup,
	buttonJoin_clicked = buttonJoin_clicked,
};
