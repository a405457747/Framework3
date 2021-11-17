-------------------------------------------------------
-- author : sky_allen
--  email : 894982165@qq.com
--   time : 2021/10/14 16:52:15
-------------------------------------------------------

---@class slotsUI4
local slotsUI4 = class('slotsUI4', require("base.machine.slotsUI3"))

function slotsUI4:ctor(lv)
    slotsUI4.super.ctor(self, lv)
end

function slotsUI4:spinStart()
    slotsUI4.super.spinStart(self);
end

function slotsUI4:spinOver()
    slotsUI4.super.spinOver(self);
end

function slotsUI4:initWheels()

    local luaMonos = array2table(self.go.transform:Find("Image/Image"), RectTransform, false);
    self.wheels = {};
    local allSprites = self:loadAllSprite();
    local allSpritesNames = table.selectItems(allSprites, "name");
    slotsManage.SetAllSpritesNames(allSpritesNames);--设置这个仅仅是为了校验一下名字而已
    for i, v in ipairs(luaMonos) do
        local mono = v:GetComponent(typeof(CS.LuaMono));
        table.insert(self.wheels, mono.TableIns);
        local SPPoolPart = nil;
        if i == 1 then
            SPPoolPart = self:partSPPoolRemoveSome(allSprites, {})
            self.SPPoolPartCommom = table.selectItems(table.copy(SPPoolPart), "name");
        elseif i == 2 then
            SPPoolPart = self:partSPPoolRemoveSome(allSprites, {})
        elseif i == 3 then
            SPPoolPart = self:partSPPoolRemoveSome(allSprites, {})
        end

        self.wheels[i]:init(SPPoolPart);
    end

    self.reSpinGo = self.go.transform:Find("Image/ReSpin").gameObject;
end

function slotsUI4:getReWindData2(baseNum)
    local key = nil;
    if math.ratio(0.5) then
        key = tostring(baseNum * 2);
        print("赌赢了是", baseNum * 2);
    else
        key = tostring(0);
        print("输了是", 0);
    end
    return slotsManage.curMachine:GetRandomWriteDataByKey(key);
end

function slotsUI4:getReWindData1(baseNum)
    return slotsManage.curMachine:GetRandomWriteDataByKey(tostring(baseNum));
end

function slotsUI4:rollAll()
    local Bets = { 0, 1, 2, 3, 5, 6, 7.5, 10, 12.5, 15, 20, 25, 30, 40, 500 }; --todo 这里是硬编码，如果倍率改了就不对了
    local smallBet = { 1, 3, 5, 7.5, 10, 12.5, 15, 20 };
    local bigBet = { 2, 6, 10, 15, 20, 25, 30, 40 }

    assert(table.isSubset(Bets, smallBet));
    assert(table.isSubset(Bets, bigBet));

    local smallTemp = {}
    for i, v in ipairs(smallBet) do
        smallTemp[i] = v * 2;
    end

    assert(table.contentsEqual(smallTemp, bigBet));

    local matrixAboutTemp;
    local curMachine = slotsManage.curMachine;
    local isReSpin = false;
    local multiplicationNum = 2;--这里模式包括第一次总共多少次呢。
    local select_bNum = 0;

    if not WRITE_DATA_MODE then
        matrixAboutTemp = curMachine:getRandomMatrixAbout();

        local totalBet = table.sum(table.csv2table(matrixAboutTemp["c"]));

        local ratio = 0.2;
        if RESPIN_QUICK then
            --这里公用了一个变量但是我认为不要紧的
            ratio = 1;
        end

        print(totalBet, "totalBet,,,")

        local reSpinJudge = function(bNum)
            if (totalBet == (bNum * multiplicationNum)) and math.ratio(ratio) then
                isReSpin = true;

                if isReSpin then
                    matrixAboutTemp = self:getReWindData1(bNum);
                    select_bNum = bNum;
                end
            end
        end

        for i, v in ipairs(smallBet) do
            reSpinJudge(v);
        end
    end

    local waitCost = 0.5;
    local s = cs_coroutine.start(function()
        rotate = true;

        if isReSpin then

            coroutine.yield(cs_coroutine.start(function()
                slotsManage.R2Change(R2)--改变时间这里应该对该修改的声音进行重置
                slotsManage.R1Change(R1 / 2)

                local matrix = nil;--一直都是直观的
                local matrixAbout = matrixAboutTemp;--这个里面保护图案还有其他信息
                if WRITE_DATA_MODE then
                    local tempMatrix;
                    local count = 0;
                    local WildPatterns;
                    repeat
                        self:randomSetImage();--把隐藏的也设置了但是没有关系
                        tempMatrix = self:getMapPatternNames();--从直观的地方获取名字
                        local mid = curMachine:fixedMatrixMidRow(tempMatrix);-- 冗余了但是没办法
                        WildPatterns = curMachine:WildPatterns(mid);
                        count = count + 1;
                    until ((#WildPatterns ~= 2));
                    --print("count:", count)
                    matrix = tempMatrix;
                else
                    matrix = matrixAbout["a"]--得到的是玩家直观的;
                end
                if PATTERNS_QUICK then
                    matrix = self:quickPatterns();
                end

                local nearMissLineTable = curMachine:fixedMatrixMidRow(matrix);--获取nearMiss那条线默认是中间条
                local nearMiss = (math.ratio(NEAR_MISS_RATIO)) and (curMachine:isNearMiss(nearMissLineTable));

                for i, v in ipairs(self.wheels) do
                    self:roll(i, true);
                end

                coroutine.yield(WaitForSeconds(R1 / 2))
                coroutine.yield(WaitForSeconds(slotsManage.R1));

                for i, v in ipairs(self.wheels) do
                    self:roll(i, false, self:matrixChange(matrix))
                    if i == self:nearMissOffset() then

                        --要转到第三个之前的时候
                        if nearMiss then
                            self:nearMissSuccess();
                            coroutine.yield(WaitForSeconds(R6))
                        else
                            coroutine.yield(WaitForSeconds(slotsManage.R2))
                        end
                    else
                        coroutine.yield(WaitForSeconds(slotsManage.R2))
                    end
                end

                local totalBet = nil;

                if WRITE_DATA_MODE then
                    totalBet = curMachine:calculateLines(matrix);
                else
                    totalBet = table.sum(table.csv2table(matrixAbout["c"]));
                end

                local isWin = (totalBet ~= 0);

                if not WRITE_DATA_MODE then
                    local hightBetLv = curMachine:HightBetLv(totalBet);
                    if hightBetLv ~= 0 then
                        playPanel:showHightWinImage(hightBetLv);
                        audio.PlaySound("CreditsRollUpHeightWin");
                    else
                        if isWin then
                            audio.PlaySound("CreditsRollUp");
                        end
                    end
                end

                sendEvent(SPIN_OVER, isWin, slotsManage.getTotalAward(totalBet))
                if isWin then
                    self:winShowLightBox(true);
                end

                local fixedWinAnimalDic = nil;
                if WRITE_DATA_MODE then
                    fixedWinAnimalDic = curMachine.fixedWinAnimalDic;--动画相关
                else
                    fixedWinAnimalDic = matrixAbout["b"];
                end

                if table.hash_count(fixedWinAnimalDic) > 0 then
                    self.awardAnimals = cs_coroutine.start(function()
                        while true do
                            for i, v in pairs(fixedWinAnimalDic) do
                                local completeMatrix = v;
                                self:lineAnim(tonumber(i), false);
                                for i1, v1 in ipairs(completeMatrix) do
                                    for i2, v2 in ipairs(v1) do
                                        if v2 == 1 then
                                            self.mapPatterns[i1][i2]:awardAnim();
                                        end
                                    end
                                end
                                coroutine.yield(WaitForSeconds(AWARD_ANIM_DELAY2));
                                self:lineAnim(tonumber(i), true);
                            end
                        end
                    end)
                end
            end))
            coroutine.yield(WaitForSeconds(waitCost));

            for i = 1, (multiplicationNum - 1) do
                self:stopAllAnimal(); -- 这里停止不冗余了

                self:rewindAnimls();
                coroutine.yield(WaitForSeconds(RE_WIND_COST));
                self.reSpinGo:SetActive(true);
                audio.PlaySound("Music_Replay_Spin");
                coroutine.yield(WaitForSeconds(waitCost));
                self.reSpinGo:SetActive(false);

                coroutine.yield(cs_coroutine.start(function()
                    slotsManage.R2Change(R2)--改变时间这里应该对该修改的声音进行重置
                    slotsManage.R1Change(R1 / 2)

                    local matrix = nil;--一直都是直观的
                    local matrixAbout = self:getReWindData2(select_bNum);--这个里面保护图案还有其他信息
                    if WRITE_DATA_MODE then
                        local tempMatrix;
                        local count = 0;
                        local WildPatterns;
                        repeat
                            self:randomSetImage();--把隐藏的也设置了但是没有关系
                            tempMatrix = self:getMapPatternNames();--从直观的地方获取名字
                            local mid = curMachine:fixedMatrixMidRow(tempMatrix);-- 冗余了但是没办法
                            WildPatterns = curMachine:WildPatterns(mid);
                            count = count + 1;
                        until ((#WildPatterns ~= 2));
                        --print("count:", count)
                        matrix = tempMatrix;
                    else
                        matrix = matrixAbout["a"]--得到的是玩家直观的;
                    end
                    if PATTERNS_QUICK then
                        matrix = self:quickPatterns();
                    end

                    local nearMissLineTable = curMachine:fixedMatrixMidRow(matrix);--获取nearMiss那条线默认是中间条
                    local nearMiss = (math.ratio(NEAR_MISS_RATIO)) and (curMachine:isNearMiss(nearMissLineTable));
                    local midRow = curMachine:GetMidRow(matrix);

                    audio.PlaySound("Music_Replay_Rewind");
                    for i, v in ipairs(self.wheels) do
                        self:roll(i, true);
                    end

                    coroutine.yield(WaitForSeconds(2))
                    --[[                    coroutine.yield(WaitForSeconds(R1 / 2))
                                        coroutine.yield(WaitForSeconds(slotsManage.R1));]]

                    for i, v in ipairs(self.wheels) do

                        self:roll(i, false, self:matrixChange(matrix))

                        if i == self:nearMissOffset() then

                            --要转到第三个之前的时候
                            if nearMiss then
                                self:nearMissSuccess();
                                coroutine.yield(WaitForSeconds(R6))
                            else
                                coroutine.yield(WaitForSeconds(slotsManage.R2))
                            end
                        else
                            coroutine.yield(WaitForSeconds(slotsManage.R2))
                        end
                    end

                    local totalBet = nil;

                    if WRITE_DATA_MODE then
                        totalBet = curMachine:calculateLines(matrix);
                    else
                        totalBet = table.sum(table.csv2table(matrixAbout["c"]));
                    end

                    local isWin = (totalBet ~= 0);

                    if not WRITE_DATA_MODE then
                        local hightBetLv = curMachine:HightBetLv(totalBet);
                        if hightBetLv ~= 0 then
                            playPanel:showHightWinImage(hightBetLv);
                            audio.PlaySound("CreditsRollUpHeightWin");
                        else
                            if isWin then
                                audio.PlaySound("CreditsRollUp");
                            end
                        end
                    end

                    sendEvent(SPIN_OVER, isWin, slotsManage.getTotalAward(totalBet))
                    if isWin then
                        self:winShowLightBox(true);
                    end

                    local fixedWinAnimalDic = nil;
                    if WRITE_DATA_MODE then
                        fixedWinAnimalDic = curMachine.fixedWinAnimalDic;--动画相关
                    else
                        fixedWinAnimalDic = matrixAbout["b"];
                    end

                    if table.hash_count(fixedWinAnimalDic) > 0 then
                        self.awardAnimals = cs_coroutine.start(function()
                            while true do
                                for i, v in pairs(fixedWinAnimalDic) do
                                    local completeMatrix = v;
                                    self:lineAnim(tonumber(i), false);
                                    for i1, v1 in ipairs(completeMatrix) do
                                        for i2, v2 in ipairs(v1) do
                                            if v2 == 1 then
                                                self.mapPatterns[i1][i2]:awardAnim();
                                            end
                                        end
                                    end
                                    coroutine.yield(WaitForSeconds(AWARD_ANIM_DELAY2));
                                    self:lineAnim(tonumber(i), true);
                                end
                            end
                        end)
                    end
                end))
                coroutine.yield(WaitForSeconds(waitCost));
            end
        else
            coroutine.yield(cs_coroutine.start(function()
                slotsManage.R2Change(R2)--改变时间这里应该对该修改的声音进行重置
                slotsManage.R1Change(R1 / 2)

                local matrix = nil;--一直都是直观的
                local matrixAbout = matrixAboutTemp;--这个里面保护图案还有其他信息
                if WRITE_DATA_MODE then
                    local tempMatrix;
                    local count = 0;
                    local WildPatterns;
                    repeat
                        self:randomSetImage();--把隐藏的也设置了但是没有关系
                        tempMatrix = self:getMapPatternNames();--从直观的地方获取名字
                        local mid = curMachine:fixedMatrixMidRow(tempMatrix);-- 冗余了但是没办法
                        WildPatterns = curMachine:WildPatterns(mid);
                        count = count + 1;
                    until ((#WildPatterns ~= 2));
                    --print("count:", count)
                    matrix = tempMatrix;
                else
                    matrix = matrixAbout["a"]--得到的是玩家直观的;
                end
                if PATTERNS_QUICK then
                    matrix = self:quickPatterns();
                end

                local nearMissLineTable = curMachine:fixedMatrixMidRow(matrix);--获取nearMiss那条线默认是中间条
                local nearMiss = (math.ratio(NEAR_MISS_RATIO)) and (curMachine:isNearMiss(nearMissLineTable));

                for i, v in ipairs(self.wheels) do
                    self:roll(i, true);
                end

                coroutine.yield(WaitForSeconds(R1 / 2))
                coroutine.yield(WaitForSeconds(slotsManage.R1));

                for i, v in ipairs(self.wheels) do
                    self:roll(i, false, self:matrixChange(matrix))
                    if i == self:nearMissOffset() then

                        --要转到第三个之前的时候
                        if nearMiss then
                            self:nearMissSuccess();
                            coroutine.yield(WaitForSeconds(R6))
                        else
                            coroutine.yield(WaitForSeconds(slotsManage.R2))
                        end
                    else
                        coroutine.yield(WaitForSeconds(slotsManage.R2))
                    end
                end

                local totalBet = nil;

                if WRITE_DATA_MODE then
                    totalBet = curMachine:calculateLines(matrix);
                else
                    totalBet = table.sum(table.csv2table(matrixAbout["c"]));
                end

                local isWin = (totalBet ~= 0);

                if not WRITE_DATA_MODE then
                    local hightBetLv = curMachine:HightBetLv(totalBet);
                    if hightBetLv ~= 0 then
                        playPanel:showHightWinImage(hightBetLv);
                        audio.PlaySound("CreditsRollUpHeightWin");
                    else
                        if isWin then
                            audio.PlaySound("CreditsRollUp");
                        end
                    end
                end

                sendEvent(SPIN_OVER, isWin, slotsManage.getTotalAward(totalBet))
                if isWin then
                    self:winShowLightBox(true);
                end

                local fixedWinAnimalDic = nil;
                if WRITE_DATA_MODE then
                    fixedWinAnimalDic = curMachine.fixedWinAnimalDic;--动画相关
                else
                    fixedWinAnimalDic = matrixAbout["b"];
                end

                if table.hash_count(fixedWinAnimalDic) > 0 then
                    self.awardAnimals = cs_coroutine.start(function()
                        while true do
                            for i, v in pairs(fixedWinAnimalDic) do
                                local completeMatrix = v;
                                self:lineAnim(tonumber(i), false);
                                for i1, v1 in ipairs(completeMatrix) do
                                    for i2, v2 in ipairs(v1) do
                                        if v2 == 1 then
                                            self.mapPatterns[i1][i2]:awardAnim();
                                        end
                                    end
                                end
                                coroutine.yield(WaitForSeconds(AWARD_ANIM_DELAY2));
                                self:lineAnim(tonumber(i), true);
                            end
                        end
                    end)
                end
            end))
        end

        rotate = false;
        if auto then
            coroutine.yield(WaitForSeconds(R5));
            playPanel:spinButtonAction2()
        end
    end)
end

return slotsUI4
