-------------------------------------------------------
-- author : sky_allen                                                                                                                  
--  email : 894982165@qq.com      
--   time : 2021/10/14 13:36:19                                                                                           
-------------------------------------------------------

---@class slotsMachine4
local slotsMachine4 = class('slotsMachine4', require("base.machine.slotsMachine3"))

function slotsMachine4:ctor(lv)
    slotsMachine4.super.ctor(self, lv);
end

function slotsMachine4:initMachineUI()
    slotsMachine4.super.initMachineUI(self);
end

function slotsMachine4:spinStart()
    slotsMachine4.super.spinStart(self)
end

function slotsMachine4:spinOver()
    slotsMachine4.super.spinOver(self)
end

function slotsMachine4:nearMissCheck()
    local awardPool = { "s2", "s3", "w2" };
    slotsManage.SpritesNameCheck(awardPool);
    return awardPool;
end

function slotsMachine4:calculateNotWild(v)
    --每一行不是wild的判断中奖
    if self:allSameAward(v, "s3") then
        return 20;
    elseif self:allSameAward(v, "s2") then
        return 15;
    elseif self:allSameAward(v, "s1") then
        return 12.5;
    elseif self:ABCAward(v, "s3", "s2", "s1") then
        return 10;
    elseif self:allSameAward(v, "b3") then
        return 7.5;
    elseif self:allSameAward(v, "b2") then
        return 5;
    elseif self:allSameAward(v, "b1") then
        return 3;
    elseif self:combinationAward(v, { "b1", "s1" }) then
        return 3;
    elseif self:combinationAward(v, { "b1", "b2", "b3" }) then
        return 1;
    else
        return 0;
    end
end

function slotsMachine4:mainWhetherWinning(finalPatterns, argTableKeys)
    --根据图案获得中奖倍率
    local resRatio = {};
    self.winAnimalDic = {};
    local winAnimalDic = self.winAnimalDic;--key是第几线而已呢
    for i, v in ipairs(self.winningPatterns) do
        local ratio = 0;
        local wildPatternTable, NotWildPatternTable = self:WildPatterns(v);
        local wildCount = #wildPatternTable;
        local argTableKey = argTableKeys[i];
        local animalData = nil;

        local winAnimalRowFill = function(needAnimalData)

            if needAnimalData == nil then
                needAnimalData = false;
            end

            if ratio ~= 0 then
                if needAnimalData then
                    winAnimalDic[argTableKey] = animalData;
                else
                    winAnimalDic[argTableKey] = self:winAnimalRowBoolean();
                end
            end
        end

        if wildCount > 0 then
            if self:allSameAward(v, "w2") then
                ratio = 500;
                winAnimalRowFill();

            elseif (wildCount == 1) or (wildCount == 2) then
                local baseRatio = self:wildBaseRatio(wildPatternTable);
                local copyV = table.copy(v);
                animalData = self:fixedCopyV(copyV, NotWildPatternTable);

                local addRatio;
                local fixedCalculateNotWild = self:calculateNotWild(copyV);
                if fixedCalculateNotWild ~= 0 then
                    addRatio = fixedCalculateNotWild;
                else
                    addRatio = 0;
                end

                ratio = baseRatio * addRatio;
                winAnimalRowFill();

            else
                ratio = 0;
                winAnimalRowFill();
                print("waring:", "什么情况会走这里呢")
            end
        else
            ratio = self:calculateNotWild(v);
            winAnimalRowFill();
        end

        table.insert(resRatio, ratio);
        print("machine perRatio:", ratio);
    end
    return resRatio;
end

return slotsMachine4
