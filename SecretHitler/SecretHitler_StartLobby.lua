local CONST = SecretHitlerNS.CONST;
local game = SecretHitlerNS.game;
local game_s = SecretHitlerNS.game_s;

local util = SecretHitlerNS.util;
local comm = SecretHitlerNS.comm;

local isBroadcasting = {};
local function broadcast_lobby(ID)
	if (isBroadcasting[ID] == true) then
		-- TODO: only broadcast if frame isn't hidden
		local msg = "ADVR" .. ID;
		msg = msg .. util.pad_int(util.table_size(game_s.players), 2);
		comm.send(msg);
		C_Timer.After(CONST.BROADCAST_DELAY, function()
			broadcast_lobby(ID);
		return; end);
	end
end

local playerLabels = {};	-- can't populate until init()
local function add_player(player_name)
	table.insert(game_s.players, player_name);
	local player_num = util.table_size(game_s.players);

	playerLabels[player_num]:Show();
	playerLabels[player_num]:SetText(player_name);
	
	local ui_capacity = SecretHitler_StartLobby_textRoomCapacity;
	if (player_num < 5) then
		local counter = (util.pad_int(player_num, 2)) .. "/05";
		ui_capacity:SetText(counter);
		ui_capacity:SetTextColor(CONST.COLOR_BAD_R, CONST.COLOR_BAD_G, CONST.COLOR_BAD_B);
	elseif (player_num <= 10) then
		local counter = tostring(util.pad_int(player_num, 2)) .. "/" .. tostring(util.pad_int(player_num, 2));
		ui_capacity:SetText(counter);
		ui_capacity:SetTextColor(CONST.COLOR_GOOD_R, CONST.COLOR_GOOD_G, CONST.COLOR_GOOD_B);
	end	-- TODO: add `else` error check here?

	local ui_full = SecretHitler_StartLobby_textRoomFull;
	if (player_num < 10) then
		ui_full:SetText("OPEN");
		ui_full:SetTextColor(CONST.COLOR_GOOD_R, CONST.COLOR_GOOD_G, CONST.COLOR_GOOD_B);
	else
		ui_full:SetText("FULL");
		ui_full:SetTextColor(CONST.COLOR_BAD_R, CONST.COLOR_BAD_G, CONST.COLOR_BAD_B);
	end

	if (player_num == 10) then
		isBroadcasting[game_s.roomID] = false;
	end
end


-- TODO: unregister this handler when not used anymore
local player_ready = {};
local player_ready_num = 0;
local function handler_comms(self, event, ...)
	if (event ~= "CHAT_MSG_CHANNEL") then return; end
	local channel_num = select(8, ...);
	if (channel_num ~= comm.channelID()) then return; end
	
	local msg = select(1, ...);
	local author = select(2, ...);
	local player_num = util.table_size(game_s.players);

	local cmd = string.sub(msg, 1, 4);
	local roomID = string.sub(msg, 5, 9);
	-- TODO: change if-elseif chain to an emulated switch.
	-- see: http://lua-users.org/wiki/SwitchStatement

	if (roomID ~= game.roomID) then return; end
	if (cmd == "JOIN") then
		local hash = string.sub(msg, 10, 15);
		if (util.is_authed(hash, game_s.roomKey) and player_num < 10) then
			local response = "CFRM" .. game_s.roomID .. author;
			comm.send(response);
			add_player(author);
			-- TODO: add check to make sure player is unique
		else
			local response = "RJCT" .. game_s.roomID .. author;
			comm.send(response);
		end
	elseif (cmd == "ACKR") then
		for i,v in ipairs(game_s.players) do
			-- TODO: do we need the check against `player_ready == false`?
			if (author == v and player_ready[i] ~= true) then
				player_ready[i] = true;
				player_ready_num = player_ready_num + 1;
				break;
			end
		end
		if (player_ready_num == player_num) then
			-- init() has callbacks that need to be started before init_s()
			SecretHitlerNS.Game.init();
			SecretHitlerNS.Game.init_s();
		end
	end
end

local function cleanup(doResetGlobals)
	-- Stop broadcasting lobby
	isBroadcasting[game_s.roomID] = false;

	-- Clear player names on UI
	for i,fontstring in ipairs(playerLabels) do
		fontstring:SetText("");
		fontstring:Hide();
	end

	if (doResetGlobals) then
		-- Reset global variables
		game_s.roomID = "";
		game_s.roomKey = 0;
		game_s.turn = 0;
		game_s.deck = {};
		game_s.players = {};
		game_s.players_vote = {};
		game_s.players_role = {};
		game_s.players_isInvestigated = {};
		game_s.electionTracker = 0;
		game_s.policies = {};
		game_s.nextRegularCandidate = 0;
		game_s.lastPresident = 0;
		game_s.lastChancellor = 0;

		game.roomID = "";
		game.roomKey = 0;
		game.turn = 0;
		game.host = "";
		game.players = {};
		game.players_isDead = {};
		game.player_president = 0;
		game.player_chancellor = 0;
		game.electionTracker = 0;
		game.role = "";
		game.policiesL = 0;
		game.policiesF = 0;
	end

	-- Hide current window
	SecretHitler_StartLobby:Hide();
end

local function init()
	cleanup(true);	-- TODO: Should this be here?
	playerLabels = {
		SecretHitler_StartLobby_textPlayerA,
		SecretHitler_StartLobby_textPlayerB,
		SecretHitler_StartLobby_textPlayerC,
		SecretHitler_StartLobby_textPlayerD,
		SecretHitler_StartLobby_textPlayerE,
		SecretHitler_StartLobby_textPlayerF,
		SecretHitler_StartLobby_textPlayerG,
		SecretHitler_StartLobby_textPlayerH,
		SecretHitler_StartLobby_textPlayerI,
		SecretHitler_StartLobby_textPlayerJ,
	};
	SecretHitler_StartLobby:Show();

	-- Initialize UI
	SecretHitler_StartLobby_textHost:SetTextColor(
			CONST.COLOR_GOOD_R, CONST.COLOR_GOOD_G, CONST.COLOR_GOOD_B);
	
	SecretHitler_StartLobby_textRoomCapacity:SetText("00/05");
	SecretHitler_StartLobby_textRoomCapacity:SetTextColor(
			CONST.COLOR_BAD_R, CONST.COLOR_BAD_G, CONST.COLOR_BAD_B);

	SecretHitler_StartLobby_textRoomFull:SetTextColor(
			CONST.COLOR_GOOD_R, CONST.COLOR_GOOD_G, CONST.COLOR_GOOD_B);

	-- Set up lobby parameters
	game_s.roomID = util.pad_int(math.random(0, 100000), 5);
	game_s.roomKey = math.random(10, 1000);	-- 3 digit key
	-- starting at 10 is arbitrary, but is needed to prevent attacks
	game.roomID = game_s.roomID;
	game.roomKey = game_s.roomKey;
	game.host = util.get_selfName();

	SecretHitler_StartLobby_textRoomID:SetText(game_s.roomID);
	SecretHitler_StartLobby_textRoomKey:SetText(util.pad_int(game_s.roomKey, 3));

	-- Start advertising lobby
	JoinPermanentChannel(CONST.CHANNEL_NAME);
	isBroadcasting[game_s.roomID] = true;
	broadcast_lobby(game_s.roomID);

	-- Handle lobby join requests
	SecretHitler_StartLobby:RegisterEvent("CHAT_MSG_CHANNEL");
	SecretHitler_StartLobby:SetScript("OnEvent", handler_comms);

	-- Join own lobby
	comm.req_join(game_s.roomID, game_s.roomKey);
end

-- TODO: Add error handling/syncing for missed messages.
local function buttonDisband_clicked()
	local msg_disband = "DSBD" .. game_s.roomID;
	comm.send(msg_disband);
	cleanup(true);
	SecretHitler_Splash:Show();	-- No need to forward declare XML globals
end

local function buttonStart_clicked()
	-- Send ready check
	local player_num = util.table_size(game_s.players);
	for i=1, player_num do
		player_ready.i = false;
	end
	local msg_RCHK = "RCHK" .. game_s.roomID .. util.pad_int(player_num, 2);
	comm.send(msg_RCHK);

	-- Broadcast shuffled list of players
	game_s.players = util.shuffle(game_s.players);
	for i=1, player_num do
		local msg_LSTN = "LSTN" .. game_s.roomID .. util.pad_int(i, 2)
		msg_LSTN = msg_LSTN .. game_s.players[i];
		comm.send(msg_LSTN);
	end
	game.players = game_s.players;

	comm.send("ACKR" .. game_s.roomID);

	cleanup(false);
end

SecretHitlerNS.StartLobby = {
	init = init,
	buttonDisband_clicked = buttonDisband_clicked,
	buttonStart_clicked = buttonStart_clicked,
};
