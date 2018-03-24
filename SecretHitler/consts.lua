-- This file includes global "constants" (by convention only, since Lua has no
-- actual immutable types) used by the addon.

local CONST = {
	VERSION = "1.0.0",
	CHANNEL_NAME = "extSecretHitler1",
	HASH_REPS = 4,
	BROADCAST_DELAY = 6, -- seconds
	SOUND_FRAME_OPEN   = "839",	-- "igCharacterInfoOpen"
	SOUND_FRAME_CLOSE  = "840",	-- "igCharacterInfoClose"
	SOUND_BUTTON_CLICK = "852",	-- "igMainMenuOption"
	-- Colors for UI elements.
	COLOR_GOOD_R = "0.00", COLOR_GOOD_G = "0.83", COLOR_GOOD_B = "0.20",
	COLOR_BAD_R  = "0.83", COLOR_BAD_G  = "0.21", COLOR_BAD_B  = "0.07",
	COLOR_NORM_R = "0.94", COLOR_NORM_G = "0.94", COLOR_NORM_B = "0.94",
	COLOR_BLUE_R = "0.04", COLOR_BLUE_G = "0.31", COLOR_BLUE_B = "0.83",
};

SecretHitlerNS.CONST = CONST;
