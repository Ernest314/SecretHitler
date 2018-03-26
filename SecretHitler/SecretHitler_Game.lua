local CONST = SecretHitlerNS.CONST;
local game = SecretHitlerNS.game;
local game_s = SecretHitlerNS.game_s;

local util = SecretHitlerNS.util;
local comm = SecretHitlerNS.comm;

local isGameOver = false;
local isServer = false;

local function close_results()
	PlaySound(CONST.SOUND_BUTTON_CLICK);
	SecretHitler_Game_Votes:Hide();
	comm.send("ACKT" .. game.roomID .. util.pad_int(game.turn, 4));
end

local function lineup_closed()
	PlaySound(CONST.SOUND_BUTTON_CLICK);
	SecretHitler_Game_Lineup:Hide();
	SecretHitler_Game:Show();
end

local function investigate_loyalty(i)
	PlaySound(CONST.SOUND_BUTTON_CLICK);
	local msg = "INVG" .. game.roomID .. util.pad_int(i, 2);
	comm.send(msg);
	SecretHitler_Game_Investigate:Hide();
end

local function special_elect(i)
	PlaySound(CONST.SOUND_BUTTON_CLICK);
	local msg = "SELC" .. game.roomID .. util.pad_int(i, 2);
	comm.send(msg);
	SecretHitler_Game_SpecialElect:Hide();
end

local function execute(i)
	PlaySound(CONST.SOUND_BUTTON_CLICK);
	local msg = "XCTE" .. game.roomID .. util.pad_int(i, 2);
	comm.send(msg);
	SecretHitler_Game_Execute:Hide();
end

local function close_policypeek()
	PlaySound(CONST.SOUND_BUTTON_CLICK);
	SecretHitler_Game_PolicyPeek:Hide();
	comm.send("ACKT" .. game.roomID .. util.pad_int(game.turn, 4));
end

local function close_investigate()
	PlaySound(CONST.SOUND_BUTTON_CLICK);
	SecretHitler_Game_Loyalty:Hide();
	comm.send("ACKT" .. game.roomID .. util.pad_int(game.turn, 4));
end

local function count_live_players()
	return util.count(game.players_isDead, false);
end

local function send_if_alive(msg)
	local i = util.get_indexName(game.players, util.get_selfName());
	if (game.players_isDead[i] == false) then
		comm.send(msg);
	end
end

local function nominate_chancellor(i)
	PlaySound(CONST.SOUND_BUTTON_CLICK);
	local msg = "NMNT" .. game.roomID .. util.pad_int(i, 2);
	comm.send(msg);
	SecretHitler_Game_Chancellor:Hide();
end

local function vote(x)
	PlaySound(CONST.SOUND_BUTTON_CLICK);
	local msg = "VOTE" .. game.roomID .. x;
	comm.send(msg);
	SecretHitler_Game_Ballot:Hide();
end

local function update_gameMode(n)
	for i,v in ipairs(SecretHitler_Game.gameMode) do
		if (i == n) then
			v:SetTextColor(CONST.COLOR_GOOD_R, CONST.COLOR_GOOD_G, CONST.COLOR_GOOD_B);
		else
			v:SetTextColor(CONST.COLOR_NORM_R, CONST.COLOR_NORM_G, CONST.COLOR_NORM_B);
		end
	end
end

local function update_electionTracker()
	local text = "Election Tracker: " .. game.electionTracker;
	SecretHitler_Game_textElectionTracker:SetText(text);
end

local function setup_ui_role_label()
	-- TODO: add error checking?
	if (game.role == "L") then
		SecretHitler_Game_textRole:SetText("You are: Liberal");
	elseif (game.role == "F") then
		SecretHitler_Game_textRole:SetText("You are: Facist");
	elseif (game.role == "H") then
		SecretHitler_Game_textRole:SetText("You are: Hitler");
	end
end

local function next_game_state(game_state)
	local next_state = game_state;
	local states = { "ASSG",
		"PRES", "TCKT", "VOTE", "RVTE", "HCHK",
		"PCYP", "PCYC", "ENCT", "RVTO",
		"EXEC", "EXECPP", "INVG", "XCTE",
		"PRES"	-- NOTE: hack to wrap around the for loop check
	};
	for i,v in ipairs(states) do
		if (game_state == v) then
			next_state = states[i+1];
			break;
		end
	end
	return next_state;
end

local cards_L = {
	SecretHitler_Game_cardLF,
	SecretHitler_Game_cardLE,
	SecretHitler_Game_cardLD,
	SecretHitler_Game_cardLC,
	SecretHitler_Game_cardLB,
	SecretHitler_Game_cardLA,
};
local cards_F = {
	SecretHitler_Game_cardFA,
	SecretHitler_Game_cardFB,
	SecretHitler_Game_cardFC,
	SecretHitler_Game_cardFD,
	SecretHitler_Game_cardFE,
	SecretHitler_Game_cardFF,
};
-- TODO: re-hide these on cleanup
local function enact_policy(policy)
	if (policy == "L") then
		game.policiesL = game.policiesL + 1;
		cards_L[game.policiesL]:Show();
	elseif (policy == "F") then
		game.policiesF = game.policiesF + 1;
		cards_F[game.policiesF]:Show();
	end

	if (game.policiesL == 6) then
		-- TODO: reset the text here on cleanup? or unnecessary?
		SecretHitler_Game_GameOver_text:SetText("LIBERALS WIN");
		SecretHitler_Game_GameOver:Show();
	elseif (game.policiesF == 6) then
		SecretHitler_Game_GameOver_text:SetText("FACISTS WIN");
		SecretHitler_Game_GameOver:Show();
	end

	if ((isServer == true) and (game.policiesF > 3)) then
		local msg = "HCHK";
		if (game_s.players_role[game.player_chancellor] == "H") then
			msg = msg .. "Y";
		else
			msg = msg .. "N";
		end
		comm.send_t(msg);
	end
end

local function close_results()
	PlaySound(CONST.SOUND_BUTTON_CLICK);
	send_if_alive("ACKT" .. game.roomID .. util.pad_int(game.turn, 4));
	SecretHitler_Game_Votes:Hide();
end

local function discardP(policy)
	SecretHitler_Game_DiscardP:Hide();
	local msg = "DCRD" .. game.roomID;
	msg = msg .. SecretHitler_Game_DiscardP.buttonDiscard[policy]:GetText();
	comm.send(msg);
end

local function discardC(policy)
	SecretHitler_Game_DiscardC:Hide();
	local msg = "DCRD" .. game.roomID;
	msg = msg .. SecretHitler_Game_DiscardC.buttonDiscard[policy]:GetText();
	comm.send(msg);
end

local function request_veto()
	SecretHitler_Game_DiscardC:Hide();
	comm.send("RVTO" .. game.roomID);
end

local function veto(v)
	SecretHitler_Game_Veto:Hide();
	comm.send("VETO" .. game.roomID .. v);
end

local function move_president_placard()
	local msg_pres = "PRES";
	if (count_live_players() <= 5) then game_s.lastChancellor = 0; end
	msg_pres = msg_pres .. util.pad_int(game_s.lastPresident, 2);
	msg_pres = msg_pres .. util.pad_int(game_s.lastChancellor, 2);
	msg_pres = msg_pres .. util.pad_int(game_s.nextRegularCandidate, 2);
	comm.send_t(msg_pres);

	repeat
		local buf = game_s.nextRegularCandidate + 1;
		if (buf > util.table_size(game.players)) then buf = 1; end
		game_s.nextRegularCandidate = buf;
	until (game.players_isDead[game_s.nextRegularCandidate] == false)
end

local game_state = "";
local isMsgAcked = 0;
local vote_count = 0;
local function handler_comms(self, event, ...)
	if (event ~= "CHAT_MSG_CHANNEL") then return; end
	local channel_num = select(8, ...);
	if (channel_num ~= comm.channelID()) then return; end
	
	local msg = select(1, ...);
	local author = select(2, ...);
	local player_num = util.table_size(game.players);

	local cmd = string.sub(msg, 1, 4);
	local roomID = string.sub(msg, 5, 9);
	-- TODO: change if-elseif chain to an emulated switch.
	-- see: http://lua-users.org/wiki/SwitchStatement

	if (roomID ~= game.roomID) then return; end
	if (cmd == "TURN") then
		local turn = tonumber(string.sub(msg, 10, 13));
		game.turn = turn;
		local subcmd = string.sub(msg, 14, 17);
		-- TODO: add a submsg variable
		if (subcmd == "ASSG") then
			local roles = string.sub(msg, 18);
			for i,v in ipairs(game.players) do
				if (v == util.get_selfName()) then
					game.role = string.sub(roles, i, i);
					break;
				end
			end
			if ((game.role == "F") or ((game.role == "H") and (player_num <= 6))) then
				for i,v in ipairs(game.players) do
					local role = string.sub(roles, i, i);
					if (role == "F") then
						SecretHitler_Game_Lineup.textName[i]:SetTextColor(
							CONST.COLOR_BAD_R, CONST.COLOR_BAD_G, CONST.COLOR_BAD_B);
					elseif (role == "H") then
						SecretHitler_Game_Lineup.textName[i]:SetTextColor(
							CONST.COLOR_BLUE_R, CONST.COLOR_BLUE_G, CONST.COLOR_BLUE_B);
					end
				end
			end
			SecretHitler_Game_Lineup:Show();
			setup_ui_role_label();
			comm.send("ACKT" .. game.roomID .. util.pad_int(game.turn, 4));
		elseif (subcmd == "PRES") then
			update_gameMode(1);
			local i_pres = tonumber(string.sub(msg, 22, 23));
			game.player_president = i_pres;
			local label_pres = "President: " .. util.get_shortName(game.players[i_pres]);
			SecretHitler_Game_textPresident:SetText(label_pres);
			if (game.players[i_pres] == util.get_selfName()) then
				local player_num = util.table_size(game.players);
				local prev_p = tonumber(string.sub(msg, 18, 19));
				local prev_c = tonumber(string.sub(msg, 20, 21));
				for i=1,player_num do
					local label = util.get_shortName(game.players[i]);
					SecretHitler_Game_Chancellor.buttonChancellor[i]:SetText(label);
					if (((i == prev_p) or (i == prev_c)) or (i == i_pres)) then
						SecretHitler_Game_Chancellor.buttonChancellor[i]:Disable();
					else
						SecretHitler_Game_Chancellor.buttonChancellor[i]:Enable();
					end
					if (game.players_isDead[i] == true) then
						SecretHitler_Game_Chancellor.buttonChancellor[i]:Disable();
					end
				end
				for i=player_num+1,10 do
					SecretHitler_Game_Chancellor.buttonChancellor[i]:Hide();
					-- TODO: Adjust size based on player_num
				end
				SecretHitler_Game_Chancellor:Show();
			end
		elseif (subcmd == "TCKT") then
			local i_p = tonumber(string.sub(msg, 18, 19));
			local i_c = tonumber(string.sub(msg, 20, 21));
			game.player_chancellor = i_c;
			local name_p = util.get_shortName(game.players[i_p]);
			local name_c = util.get_shortName(game.players[i_c]);
			local msg_ballot = name_p .. " nominates " .. name_c;
			SecretHitler_Game_Ballot_ticket:SetText(msg_ballot);
			if (game.players_isDead[util.get_indexName(game.players, util.get_selfName())] == false) then
				SecretHitler_Game_Ballot:Show();
			end
		elseif (subcmd == "VOTE") then
			local votes = {};
			local submsg = string.sub(msg, 18);
			for i=1,player_num do
				SecretHitler_Game_Votes.textName[i]:Show();
				local name = util.get_shortName(game.players[i]);
				SecretHitler_Game_Votes.textName[i]:SetText(name);
				local vote = string.sub(submsg, i, i);
				if (vote == "Y") then
					-- TODO: make colors tables and make a function to return them unpacked
					SecretHitler_Game_Votes.textName[i]:SetTextColor(
							CONST.COLOR_GOOD_R, CONST.COLOR_GOOD_G, CONST.COLOR_GOOD_B);
				elseif (vote == "N") then
					SecretHitler_Game_Votes.textName[i]:SetTextColor(
							CONST.COLOR_BAD_R, CONST.COLOR_BAD_G, CONST.COLOR_BAD_B);
				elseif (vote == "_") then
					SecretHitler_Game_Votes.textName[i]:Hide();
					-- TODO: reset these on cleanup?
				end
			end
			for i=player_num+1,10 do
				SecretHitler_Game_Votes.textName[i]:Hide();
			end
		elseif (subcmd == "RVTE") then
			game.electionTracker = tonumber(string.sub(msg, 19, 19));
			if (game.electionTracker == 3) then
				local policy = string.sub(msg, 20, 20);
				enact_policy(policy);
				game.electionTracker = 0;
			end
			update_electionTracker();
		elseif (subcmd == "HCHK") then
			local isHitler = string.sub(msg, 18, 18);
			local name_player = util.get_shortName(game.players[game.player_chancellor]);
			local infotext = name_player;
			if (isHitler == "Y") then
				infotext = infotext .. "IS Hitler!";
				SecretHitler_Game_GameOver_text:SetText("FACISTS WIN");
				SecretHitler_Game_GameOver:Show();
			elseif (isHitler == "N") then
				infotext = infotext .. "is NOT Hitler.";
			end
			SecretHitler_Game_ChancellorID_text:SetText(infotext);
			SecretHitler_Game_ChancellorID:Show();
		elseif (subcmd == "PCYP") then
			update_gameMode(2);
			local i_self = util.get_indexName(game.players, util.get_selfName());
			if (game.player_president == i_self) then
				for i=1,3 do
					local policy = string.sub(msg, 17+i, 17+1);
					SecretHitler_Game_DiscardP.buttonDiscard[i]:SetText(policy);
				end
				SecretHitler_Game_DiscardP:Show();
			end
		elseif (subcmd == "PCYC") then
			local i_self = util.get_indexName(game.players, util.get_selfName());
			if (game.player_chancellor == i_self) then
				for i=1,2 do
					local policy = string.sub(msg, 17+i, 17+1);
					SecretHitler_Game_DiscardC.buttonDiscard[i]:SetText(policy);
				end
				local can_veto = string.sub(msg, 20, 20);
				if (can_veto == "Y") then
					SecretHitler_Game_DiscardC_buttonVeto:Enable();
				elseif (can_veto == "N") then
					SecretHitler_Game_DiscardC_buttonVeto:Disable();
				end
				SecretHitler_Game_DiscardC:Show();
			end
		elseif (subcmd == "RVTO") then
			local i_self = util.get_indexName(game.players, util.get_selfName());
			if (game.player_president == i_self) then
				SecretHitler_Game_Veto:Show();
			end
		elseif (subcmd == "VETO") then
			game.electionTracker = game.electionTracker + 1;
			if (game.electionTracker == 3) then
				game.electionTracker = 0;
				local policy = string.sub(msg, 18, 18);
				enact_policy(policy);
			end
			update_electionTracker();
		elseif (subcmd == "ENCT") then
			local p = string.sub(msg, 18, 18);
			enact_policy(p);
		elseif (subcmd == "EXEC") then
			update_gameMode(3);
			local i_self = util.get_indexName(game.players, util.get_selfName());
			if (game.player_president == i_self) then
				local exec_code = string.sub(msg, 18, 19);
				if (exec_code == "IL") then
					local investigate_str = string.sub(msg, 20);
					local player_num = util.table_size(game.players);
					for i=1,player_num do
						local can_invg = string.sub(investigate_str, i, i);
						local label = util.get_shortName(game.players[i]);
						SecretHitler_Game_Investigate.buttonInvestigate[i]:SetText(label);
						if (can_invg == "Y") then
							SecretHitler_Game_Investigate.buttonInvestigate[i]:Enable();
						elseif (can_invg == "N") then
							SecretHitler_Game_Investigate.buttonInvestigate[i]:Disable();
						end
						if (game.players_isDead[i] == true) then
							SecretHitler_Game_Investigate.buttonInvestigate[i]:Disable();
						end
					end
					for i=player_num+1,10 do
						SecretHitler_Game_Investigate.buttonInvestigate[i]:Hide();
						-- TODO: Adjust size based on player_num
					end
					SecretHitler_Game_Investigate:Show();
				elseif (exec_code == "SE") then
					local player_num = util.table_size(game.players);
					local i_self = util.get_indexName(game.players, util.get_selfName());
					for i=1,player_num do
						local label = util.get_shortName(game.players[i]);
						SecretHitler_Game_SpecialElect.buttonSpecialElect[i]:SetText(label);
						if (i == i_self) then
							SecretHitler_Game_SpecialElect.buttonSpecialElect[i]:Disable();
						else
							SecretHitler_Game_SpecialElect.buttonSpecialElect[i]:Enable();
						end
						if (game.players_isDead[i] == true) then
							SecretHitler_Game_SpecialElect.buttonSpecialElect[i]:Disable();
						end
					end
					for i=player_num+1,10 do
						SecretHitler_Game_SpecialElect.buttonSpecialElect[i]:Hide();
						-- TODO: Adjust size based on player_num
					end
					SecretHitler_Game_SpecialElect:Show();
				elseif (exec_code == "PP") then
					for i=1,3 do
						local label = string.sub(investigate_str, i, i);
						SecretHitler_Game_PolicyPeek.policy[i]:SetText(label);
					end
					SecretHitler_Game_PolicyPeek:Show();
				elseif (exec_code == "XT") then
					local player_num = util.table_size(game.players);
					local i_self = util.get_indexName(game.players, util.get_selfName());
					for i=1,player_num do
						local label = util.get_shortName(game.players[i]);
						SecretHitler_Game_Execute.buttonExecute[i]:SetText(label);
						if (i == i_self) then
							SecretHitler_Game_Execute.buttonExecute[i]:Disable();
						else
							SecretHitler_Game_Execute.buttonExecute[i]:Enable();
						end
						if (game.players_isDead[i] == true) then
							SecretHitler_Game_Execute.buttonExecute[i]:Disable();
						end
					end
					for i=player_num+1,10 do
						SecretHitler_Game_Execute.buttonExecute[i]:Hide();
						-- TODO: Adjust size based on player_num
					end
					SecretHitler_Game_Execute:Show();
				end
			end
		elseif (subcmd == "INVG") then
			local i_self = util.get_indexName(game.players, util.get_selfName());
			if (game.player_president == i_self) then
				local label = "That player is a ";
				local role = string.sub(msg, 18, 18);
				if (role == "L") then
					label = label .. "Liberal!";
				elseif (role == "F") then
					label = label .. "Facist!";
				end
				SecretHitler_Game_Loyalty_text:SetText(label);
				SecretHitler_Game_Loyalty:Show();
			end
		elseif (subcmd == "XCTE") then
			local i_ded = tonumber(string.sub(msg, 18, 19));
			game.players_isDead[i_ded] = true;
			comm.send("ACKT" .. game.roomID .. util.pad_int(game.turn, 4));
		end
	end

	if (isServer) then
		-- We already know that the room ID is correct
		if (cmd == "ACKT") then
			local turn = tonumber(string.sub(msg, 10, 13));
			if (turn == game_s.turn - 1) then
				isMsgAcked = isMsgAcked + 1;
			end

			if (isMsgAcked == count_live_players()) then
				isMsgAcked = 0;
				if (game_state == "ASSG") then
					game_state = next_game_state(game_state);
					move_president_placard();
				elseif (game_state == "RVTE") then
					local msg_pcyp = "PCYP";
					game_s.policies = {};
					for i=1,3 do
						game_s.policies[i] = util.draw(game_s.deck)
						msg_pcyp = msg_pcyp .. game_s.policies[i];
					end
					comm.send_t(msg_pcyp);
				elseif (game_state == "XCTE") then
					move_president_placard();
				end
			end

			if (isMsgAcked == 1) then
				if (game_state == "EXECPP") then
					move_president_placard();
					isMsgAcked = 0;
				elseif (game_state == "INVG") then
					move_president_placard();
					isMsgAcked = 0;
				end
			end
		elseif (cmd == "TURN") then
			local subcmd = string.sub(msg, 14, 17);
			-- if (subcmd == "") then
			-- end
		elseif (cmd == "NMNT") then
			-- TODO: check that command author is presidential candidate
			local msg_tckt = "TCKT";
			msg_tckt = msg_tckt .. util.pad_int(game.player_president, 2);
			msg_tckt = msg_tckt .. string.sub(msg, 10, 11);
			comm.send_t(msg_tckt);
			vote_count = 0;
		elseif (cmd == "VOTE") then
			local vote = string.sub(msg, 10, 10);
			local i_player = util.get_indexName(game.players, author);
			game_s.players_vote[i_player] = vote;
			vote_count = vote_count + 1;
			if (vote_count == count_live_players()) then
				local msg_vote = "VOTE";
				local yes_count = 0;
				for i=1,player_num do
					if (game.players_isDead[i] == false) then
						msg_vote = msg_vote .. game_s.players_vote[i];
					else
						msg_vote = msg_vote .. "_";
					end
					if (game_s.players_vote[i] == "Y") then
						yes_count = yes_count + 1;
					end
				end
				comm.send_t(msg_vote);
				local vote_result = "N";
				if (yes_count * 2 > count_live_players()) then
					vote_result = "Y";
				end
				local policy = "";
				if (vote_result == "N") then
					game_s.electionTracker = game_s.electionTracker + 1;
					if (game_s.electionTracker == 3) then
						policy = util.draw(game_s.deck);
						game_s.electionTracker = 0;	-- TODO: move this somewhere else?
					end
					move_president_placard();
				end
				game_state = "RVTE";
				comm.send_t("RVTE" .. vote_result .. game_s.electionTracker .. policy);
				if (vote_result == "Y") then
					game_s.lastPresident = game.player_president;
					game_s.lastChancellor = game.player_chancellor;
				end
			end
		elseif (cmd == "DCRD") then
			local discard = string.sub(msg, 10, 10);
			for i=1,util.table_size(game_s.policies) do
				if (game_s.policies[i] == discard) then
					table.remove(game_s.policies, i);
					break;
				end
			end
			if (game_state == "RVTE") then
				local msg_pcyc = "PCYC";
				for i=1,2 do msg_pcyc = msg_pcyc + game_s.policies[i]; end
				local can_veto = "N";
				if (game.policies_F == 5) then can_veto = "Y"; end
				msg_pcyc = msg_pcyc .. can_veto;
				comm.send_t(msg_pcyc);
				game_state = "PCYC";
			elseif (game_state == "PCYC") then
				local policy = game_s.policies[1];
				comm.send_t("ENCT" .. policy);
				if (policy == "L") then
					move_president_placard();
				elseif (policy == "F") then
					game_state = "EXECPP";
					local policy_num = game.policiesF + 1;	-- hasn't been enacted yet
					local player_num = util.table_size(game.players);
					local exec_code = util.get_actionCode(policy_num, player_num);
					if (exec_code == "NA") then
						move_president_placard();
					elseif (exec_code == "IL") then
						local msg_il = "";
						for i=1,util.table_size(game.players) do
							if (game_s.players_isInvestigated[i] == true) then
								msg_il = msg_il .. "N";
							else
								msg_il = msg_il .. "Y";
							end
						end
						comm.send_t("EXECIL" .. msg_il);
					elseif (exec_code == "SE") then
						comm.send_t("EXECSE");
					elseif (exec_code == "PP") then
						local msg_peek = "";
						if (util.table_size(game_s.deck) < 3) then
							util.setup_policies(game_s.deck);
						end
						for i=1,3 do
							msg_peek = msg_peek .. game_s.deck[i];
						end
						comm.send_t("EXECPP" .. msg_peek);
					elseif (exec_code == "XT") then
						comm.send_t("EXECXT");
					end
				end
			end
		elseif (cmd == "RVTO") then
			comm.send_t("RVTO");
		elseif (cmd == "VETO") then
			local veto = string.sub(msg, 10, 10);
			if (veto == "Y") then
				game_s.electionTracker = game_s.electionTracker + 1;
				local policy = "";
				if (game_s.electionTracker == 3) then
					policy = util.draw(game_s.deck);
					game_s.electionTracker = 0;
				end
				comm.send_t("VETO" .. policy);
			elseif (veto == "N") then
				local msg_pcyc = "PCYC";
				for i=1,2 do msg_pcyc = msg_pcyc + game_s.policies[i]; end
				msg_pcyc = msg_pcyc .. "N";
				comm.send_t(msg_pcyc);
				game_state = "PCYC";
			end
		elseif (cmd == "INVG") then
			local i_player = tonumber(string.sub(msg, 10, 11));
			local party_L = game_s.players_role[i_player];
			if (party_L == "H") then party_L = "F"; end
			comm.send_t("INVG" .. party_L);
			game_state = "INVG";
		elseif (cmd == "SELC") then
			local i_player = tonumber(string.sub(msg, 10, 11));
			local msg_pres = "PRES";
			msg_pres = msg_pres .. "0000";
			msg_pres = msg_pres .. util.pad_int(i_player, 2);
			comm.send_t(msg_pres);
		-- TODO: undo these changes to protocol, and use a single "EXEC" subcmd
		-- TODO: consolidate executive action UI (3 in 1)
		elseif (cmd == "EXEC") then	-- TODO: rename this command to "XCTE"...
			local i_player = string.sub(msg, 10, 11);
			comm.send_t("XCTE" .. i_player);
			game_state = "XCTE";
			-- TODO: wait for everyone to ACK this!
		end
	end
end

-- TODO: add cleanup() and cleanup_s() functions

local function init()
	-- Initialize variables
	-- TODO: initialize the rest
	for i,v in ipairs(game.players) do
		game.players_isDead[i] = false;
	end

	-- Enable veto button later
	SecretHitler_Game_DiscardC_buttonVeto:Disable();

	-- Disable all policy peek "buttons"
	for i=1,3 do
		SecretHitler_Game_PolicyPeek.policy[i]:Disable();
	end

	-- Set lineup names
	for i,v in ipairs(game.players) do
		local name = util.get_shortName(v);
		SecretHitler_Game_Lineup.textName[i]:SetText(name);
		SecretHitler_Game_Lineup.textName[i]:Show();
	end
	-- TODO: resize parent window depending on number of players

	-- Set action labels on facist track
	for i=1,6 do
		local player_num = util.table_size(game.players);
		local label = util.get_actionText(i, player_num);
		SecretHitler_Game.textAction[i]:SetText(label);
	end

	-- TODO: Should we show this immediately, or after the lineup is closed?
	-- SecretHitler_Game:Show();

	SecretHitler_Game:RegisterEvent("CHAT_MSG_CHANNEL");
	SecretHitler_Game:SetScript("OnEvent", handler_comms);
end

local function init_s()
	isServer = true;

	for i,v in ipairs(game_s.players) do
		game_s.players_vote[i] = "";
		game_s.players_isInvestigated[i] = false;
	end

	game_s.nextRegularCandidate = 1;

	-- Set up policy deck
	util.setup_policies(game_s.deck);

	-- Set up player roles
	local player_num = util.table_size(game_s.players);
	game_s.players_role[1] = "H";
	if (player_num <= 6) then
		for i=1,1 do table.insert(game_s.players_role, "F"); end
		for i=1,player_num-2 do table.insert(game_s.players_role, "L"); end
	elseif (player_num <=8) then
		for i=1,2 do table.insert(game_s.players_role, "F"); end
		for i=1,player_num-3 do table.insert(game_s.players_role, "L"); end
	elseif (player_num <= 10) then
		for i=1,3 do table.insert(game_s.players_role, "F"); end
		for i=1,player_num-4 do table.insert(game_s.players_role, "L"); end
	end
	game_s.players_role = util.shuffle(game_s.players_role);

	-- Broadcast player roles
	game_s.turn = 1;
	game_state = "ASSG";
	local msg_roles = "ASSG";
	for i,v in ipairs(game_s.players_role) do
		msg_roles = msg_roles .. v;
	end
	comm.send_t(msg_roles);
end

SecretHitlerNS.Game = {
	lineup_closed = lineup_closed,
	investigate_loyalty = investigate_loyalty,
	special_elect = special_elect,
	execute = execute,
	close_policypeek = close_policypeek,
	close_investigate = close_investigate,
	init = init,
	init_s = init_s,
	nominate_chancellor = nominate_chancellor,
	vote = vote,
	close_results = close_results,
	discardP = discardP,
	discardC = discardC,
	request_veto = request_veto,
	veto = veto,
};
