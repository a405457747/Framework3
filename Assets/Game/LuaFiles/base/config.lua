-------------------------------------------------------
-- author : sky_allen                                                                                                                  
--  email : 894982165@qq.com      
--   time : 2021/9/26 14:39:58                                                                                           
-------------------------------------------------------

AWARD_ANIM_DELAY1 = 1;
AWARD_ANIM_DELAY2 = 1.25;

A = string.rep("A", 13);
B = string.rep("B", 13);

NEAR_MISS_RATIO = 0.3;

NET_TIMEOUT = 4;

TIP_SAVE = 2;
TIP_LEAVE = 0.5;

GIGITAL_SLOW = 1.5-- 数字缓动时间
POP_SLOW = 1 / 5
BTN_SCALE = 1 / 20;
FLY_DELAY = 0.035;

SECOND = 1;
MINUTE = SECOND * 60;
HOUR = MINUTE * 60;
DAY = HOUR * 24;
WEEK = DAY * 7;

ANDROID_CHANEL = create_enum_table({ "Google", "Amazon" })
CHANEL = ANDROID_CHANEL.Google;

LANGUAGE_KEY = "English";

--CHECK_DATA_RIGHT = true;
QUICK_NEARMISS = false;
LOAD_QUICK = true;
LEVEL_CONFIG_TEST = true;
GAPBONUS_QUICK = false;
LOGIN_QUICK = false;
PATTERNS_QUICK = true;
LOSE_QUICK = false;
WRITE_DATA_MODE = true;
ANALYSIS = false;
LOCK_QUICK=true;

R1 = 1.2;--旋转方面的时间
R2 = 0.4;
R3 = 0.15;
R4 = 1;--hold的检查时长
R5 = 0.33;

local rSpeed = 2;
if WRITE_DATA_MODE then
    R1 = R1 / rSpeed;
    R2 = R2 / rSpeed;
    R3 = R3 / rSpeed;
    R4 = R4 / rSpeed;
    R5 = R5 / rSpeed;
end

if QUICK_NEARMISS then
    NEAR_MISS_RATIO = 1
else
    NEAR_MISS_RATIO = 0.3;
end