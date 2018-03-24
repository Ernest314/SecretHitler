local CONST = SecretHitlerNS.CONST;
local util = SecretHitlerNS.util;

-- Register slash command for showing splash screen.
SLASH_SECRETHITLER1 = '/secrethitler';
local function slash_handler(msg, editBox)
	SecretHitler_Splash:Show();
	-- TODO: add error handling if games/lobbies are already open
end
SlashCmdList["SECRETHITLER"] = slash_handler;

-- XML button click event handlers.
local function buttonStart_clicked()
	SecretHitler_Splash:Hide();
	SecretHitlerNS.StartLobby.init();
end

local function buttonJoin_clicked()
	SecretHitler_Splash:Hide();
	SecretHitlerNS.JoinLobby.init();
end

local function buttonManual_clicked()
end

local function buttonTips_clicked()
end

-- Export interfact to global namespace.
SecretHitlerNS.Splash = {
	buttonStart_clicked = buttonStart_clicked,
	buttonJoin_clicked = buttonJoin_clicked,
	buttonManual_clicked = buttonManual_clicked,
	buttonTips_clicked = buttonTips_clicked,
};
