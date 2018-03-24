local CONST = SecretHitlerNS.CONST;

SecretHitlerNS.game = {
	roomID = "",	-- set in lobby
	roomKey = 0,	-- set in lobby
	turn = 0,
	host = "",		-- set in lobby
	players = {},	-- set in lobby
	players_isDead = {},
	player_president = 0,
	player_chancellor = 0,
	electionTracker = 0,
	role = "",
	policiesL = 0,
	policiesF = 0,
};

SecretHitlerNS.game_s = {
	roomID = "",	-- set in lobby
	roomKey = 0,	-- set in lobby
	turn = 0,
	deck = {},
	players = {},	-- set in lobby
	players_vote = {},
	players_role = {},
	players_isInvestigated = {},
	electionTracker = 0,	-- TODO: get rid of this var
	policies = {},
	nextRegularCandidate = 0,	-- not incl. special election
	lastPresident = 0,
	lastChancellor = 0,
};
