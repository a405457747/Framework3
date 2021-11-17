-------------------------------------------------------
-- author : sky_allen                                                                                                                  
--  email : 894982165@qq.com      
--   time : 2021/9/28 11:41:29                                                                                           
-------------------------------------------------------

---@class slotsManage
local slotsManage = class('slotsManage')

local betLv = 1;
local maxLv = 4;
local minLv = 1;
local curBet = 0;

slotsManage.curMachine = nil;
slotsManage.configEnum = nil;
local configs = { "S", "M", "L" }
--todo 100的舍入法可能会有问题在计算方面我感觉。

function slotsManage.init()
    print("slots init")
    addEvent(SPIN_START, function()
        --print("slotsManage SPIN_START")
        slotsManage.CtrlConfigEnum();
        slotsManage.curMachine:spinStart();
    end)
    addEvent(SPIN_OVER, function(bet)
        -- print("slotsManage SPIN_OVER")
        slotsManage.curMachine:spinOver()

    end)
    addEvent(LOAD_OVER, function()
        slotsManage.setBet()
    end)
    addEvent(WILL_PLAY, function(i)
        slotsManage.curMachineInit(i);
    end)
end

function slotsManage.SetAllSpritesNames(t)
    slotsManage.AllSpritesNames = t;
end

function slotsManage.getRandomAllSpritesName()
    return table.get_random_item(slotsManage.AllSpritesNames);
end

function slotsManage.SpritesNameCheck(...)

    local arg = { ... }
    local res = {};

    for i, v in ipairs(arg) do
        local content = v;
        if type(content) == "string" then
            table.insert(res, content);
        elseif type(content) == "table" then
            table.add_range(res, content);
        else
            error("Invalid type!")
        end
    end

    -- print("SpritesNameCheck")
    local allTypeCheck = table.checkAllType(res, "string");
    if allTypeCheck == false then
        error("check error");
    end

    -- local res = table.distinct(res);--这里我感觉不是必须去重

    local distinctCheck = (#table.distinct(res)) == #res;
    if distinctCheck == false then
        error("check error");
    end

    --table.print_arr(res, A);
    --table.print_arr(slotsManage.AllSpritesNames, B);
    local subCheck = table.isSubset(slotsManage.AllSpritesNames, res);
    if subCheck == false then
        error("check error")
    end
    return res;
end

function slotsManage.ChangeConfigEnum(str)
    local t1 = table.copy(configs);
    table.insert(t1, "T");
    local a, _ = table.find(t1, function(item)
        return item == str
    end)
    assert(a ~= nil, "ConfigEnum have Error!");

    print("slotsManage ConfigEnum Now is : " .. str)
    slotsManage.configEnum = str;
end

function slotsManage.CtrlConfigEnum()
    if LEVEL_CONFIG_TEST then
        slotsManage.ChangeConfigEnum("T");
        return ;
    end
    slotsManage.ChangeConfigEnum(table.get_random_item(configs));
end

function slotsManage.GetConfigEnum()
    return slotsManage.configEnum;
end

function slotsManage.R2Change(f)
    slotsManage.R2 = f;
end
function slotsManage.R1Change(f)
    slotsManage.R1 = f;
end

function slotsManage.curMachineInit(i)
    slotsManage.curMachine = require("base.machine.slotsMachine" .. tostring(i)).new(i);
    print(slotsManage.curMachine, "slotsManage.curMachine")
    --print("will paly2")
    slotsManage.curMachine:initMachineUI();
end

function slotsManage.getTotalAward(bet)
    return curBet / (#slotsManage.curMachine.matrixTable) * bet;
end

function slotsManage.changeBetLv(n)
    --todo 更友好的体验，点击其他按键也要停下来暂时不做
    if rotate then
        return ;
    end

    if n == 1 then
        if betLv < maxLv then
            betLv = betLv + 1;
        end
    else
        if betLv > minLv then
            betLv = betLv - 1;
        end
    end
    slotsManage.setBet();
    playPanel:betTextRefresh2()
end

function slotsManage.setBet()
    local liteChip = data.chip * 0.1;
    local baseNum = 100;
    local perLite = math.max(baseNum, liteChip / maxLv);
    local chipAbout = betLv * perLite;
    local lvAbout = baseNum * level.curLV() + chipAbout * 0.1;
    local res = chipAbout + lvAbout;
    local intRes = integer(res);
    --print("curLv", level.curLV(), "chipAbout", chipAbout, "lvAbout", lvAbout,"initRes",intRes);
    curBet = intRes;
end

function slotsManage.getBet()
    return curBet;
end

function slotsManage.getPig()
    local res = slotsManage.getBet() * 0.1;
    return integer(res, 1)
end

return slotsManage
