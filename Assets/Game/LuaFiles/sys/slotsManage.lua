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

function slotsManage.init()
    print("slots init")
    addEvent(SPIN_START, function()
        print("slotsManage SPIN_START")
        slotsManage.curMachine:spinStart();
    end)
    addEvent(SPIN_OVER, function(bet)
        print("slotsManage SPIN_OVER")
        slotsManage.curMachine:spinOver()
    end)
    addEvent(LOAD_OVER, function()
        slotsManage.setBet()
    end)
    addEvent(WILL_PLAY, function(i)
        slotsManage.curMachineInit(i);
    end)
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

function slotsManage.getWin()

end

function slotsManage.setBet()
    -- todo 取整要整50呢？
    local liteChip = data.chip * 0.1;
    local baseNum = 50;
    local perLite = math.max(baseNum, liteChip / maxLv);
    local chipAbout = betLv * perLite;
    local lvAbout = baseNum * level.curLV() + chipAbout * 0.1;
    local res = chipAbout + lvAbout;
    local intRes = integer10(res);
    --print("curLv", level.curLV(), "chipAbout", chipAbout, "lvAbout", lvAbout,"initRes",intRes);
    curBet = intRes;
end

function slotsManage.getBet()
    return curBet;
end

function slotsManage.getPig()
    -- todo 也许注意取整呢
    return slotsManage.getBet() * 0.1;
end

return slotsManage
