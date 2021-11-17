-------------------------------------------------------
-- author : sky_allen                                                                                                                  
--  email : 894982165@qq.com      
--   time : 2021/10/14 16:50:53                                                                                           
-------------------------------------------------------

---@class uiMachine
local uiMachine = class('uiMachine')

-- 尽量用动态生成UI减少工作时间
function uiMachine:ctor(lv)

    self:initBaseData(lv)

    self:initWheels();

    self:mapPatternsInit()
    --[[    local nameT = self:getMapPatternNames();
        table. print_nest_arr(nameT);]]
    print("uiMachine ctor")
end
function uiMachine:initBaseData(lv)
    self.lv = lv;
    self.go = playPanel.go.transform:Find("lvGameObject/Image" .. self.lv).gameObject;
    self.lines = array2table(self.go.transform:Find("Image/GameObject"));
    self.go:GetComponent("Image").sprite = AF:LoadSprite("bg" .. self.lv);
end

function uiMachine:initWheels()

    print("uiMachine initWheels")
    --playPanel:lvChildsShow()

    local luaMonos = array2table(self.go.transform:Find("Image/Image"), RectTransform, false);
    self.wheels = {};
    local allSprites = self:loadAllSprite();
    local allSpritesNames = table.selectItems(allSprites, "name");
    slotsManage.SetAllSpritesNames(allSpritesNames);--设置这个仅仅是为了校验一下名字而已
    for i, v in ipairs(luaMonos) do
        --local TableIns = v:GetComponent(typeof(CS.LuaMono)).TableIns;
        local mono = v:GetComponent(typeof(CS.LuaMono));
        --print(mono.gameObject.activeInHierarchy, "tableIns")
        table.insert(self.wheels, mono.TableIns);
        -- print(mono.TableIns, "mono.TableIns")
        local SPPoolPart = nil;
        if i == 1 then
            SPPoolPart = self:partSPPoolRemoveSome(allSprites, { "w3", "w4", "w5" })
        elseif i == 2 then
            SPPoolPart = self:partSPPoolRemoveSome(allSprites, { "w2" })
        elseif i == 3 then
            SPPoolPart = self:partSPPoolRemoveSome(allSprites, { "w3", "w4", "w5" })
        end
        self.wheels[i]:init(SPPoolPart);
    end
end

function uiMachine:mapPatternsInit()
    --print("map init a ")
    self.mapPatterns = self:getMapPatterns();--玩家直观的
end

function uiMachine:rewindAnimls()
    local mid = slotsManage.curMachine:fixedMatrixMidRow(self.mapPatterns);
    for i, v in ipairs(mid) do
        if i % 2 == 0 then
            v:rewindAnim(false);
        else
            v:rewindAnim(true)
        end

    end
end

--中奖线UI的动画
function uiMachine:lineAnim(index, isOver)
    local line = self.lines[index];
    local img = line.transform:Find("Image"):GetComponent("Image");
    if isOver then
        img.fillAmount = 0;
    else
        img.fillAmount = 1;
    end
end

function uiMachine:lineAnimReset()
    for i, v in ipairs(self.lines) do
        self:lineAnim(i, true);
    end
end

function uiMachine:winShowLightBox(show)
    for i, v in ipairs(self.wheels) do
        v:showLightBox(show)
    end
end

function uiMachine:partSPPoolRemoveSome(allSprites, fT)
    if #fT > 0 then
        slotsManage.SpritesNameCheck(fT);
    end

    local sp = table.copy(allSprites);

    for i, v in ipairs(fT) do
        local sv, si = table.find(sp, function(item)
            return item.name == v
        end)
        if si == nil then
            error("Double check don't find!!!!")
        else
            table.remove(sp, si);
        end
    end
    return sp;
end

function uiMachine:loadAllSprite()
    local arr = AF:LoadSprites(self.lv);

    local res = {}
    for i = 1, arr.Length do
        local s = arr[i - 1];
        table.insert(res, s);
        assert(string.haveEmpty(s.name) == false, "The image name have empty char!");
    end
    table.insert(res, AF:LoadSprite("em"))

    return res;
end

function uiMachine:randomSetImage()
    for i, v in ipairs(self.wheels) do
        v:randomSetImage();
    end
end

function uiMachine:getMapPatterns()
    local bigT = {};
    for i, v in ipairs(self.wheels) do
        local t = v:getPatterns();
        table.insert(bigT, t);
    end

    -- print(#bigT,"sksksksksksk")
    -- table.print_nest_arr(bigT,"BBBBGGGTTT")

    return self:matrixChange(bigT);
end

function uiMachine:getMapPatternNames()
    local res = {};
    for i, v in ipairs(self.mapPatterns) do
        res[i] = {};
        for i1, v1 in ipairs(v) do
            res[i][i1] = v1:GetPatternImageName();
        end
    end
    return res;
end

function uiMachine:matrixChange(matrix)
    local res = {};

    local len = #matrix[1];

    for i = 1, len do
        res[i] = {};
    end

    for i, v in ipairs(matrix) do
        for i2, v2 in ipairs(v) do
            res[i2][i] = v2;
        end
    end

    return res;
end

function uiMachine:stopAllAnimal()
    if self.awardAnimals then
        cs_coroutine.stop(self.awardAnimals);
        self:lineAnimReset();
        self:winShowLightBox(false);
        print("停止了携程")
    end
end

function uiMachine:spinStart()
    self:stopAllAnimal();

    self:rollAll();
end

function uiMachine:spinOver()
end

function uiMachine:quickPatterns()
    return {
        { "s3", "b1", "b3" },
        { "s4", "b2", "s4" },
        { "s2", "b2", "b2" },
    };
end

function uiMachine:nearMissOffset()
    return (#self.wheels - 1);
end

function uiMachine:nearMissSuccess()
    audio.PlaySound("AnticipationBuildup");
    local nearMissOffset = self:nearMissOffset();
    local EffectOffset = nearMissOffset + 1;
    self.wheels[EffectOffset]:showLightBox(true);
    print("nearMiss success start offsetAbout ist :", nearMissOffset);
    cs_coroutine.start(function()
        coroutine.yield(WaitForSeconds(R6))
        self.wheels[EffectOffset]:showLightBox(false);
    end)
end

-- todo 每次写入都要验证下WRITE_DATA_MODE这里对不对
function uiMachine:rollAll()
    local s = cs_coroutine.start(function()
        rotate = true;

        slotsManage.R2Change(R2)--改变时间这里应该对该修改的声音进行重置
        slotsManage.R1Change(R1 / 2)

        local curMachine = slotsManage.curMachine;
        local matrix = nil;--一直都是直观的
        local matrixAbout = nil;--这个里面保护图案还有其他信息
        if WRITE_DATA_MODE then
            self:randomSetImage();--把隐藏的也设置了但是没有关系
            matrix = self:getMapPatternNames();--从直观的地方获取名字
        else
            matrixAbout = curMachine:getRandomMatrixAbout();
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
        rotate = false;

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

        if auto then
            coroutine.yield(WaitForSeconds(R5));
            playPanel:spinButtonAction2()
        end
    end)
end

function uiMachine:SetImageByName(nameLists)
    --这个要非直观的3x3
    for i, v in ipairs(self.wheels) do
        v:SetImageByName(nameLists[i]);
    end
end

function uiMachine:roll(index, isStart, mC, playReelStop)
    local wheel = self.wheels[index];
    if isStart then
        wheel:spinStart();
    else
        if playReelStop == nil then
            audio.PlaySound("Reel_Stop")
        end

        wheel:spinOver();
        wheel:SetImageByName(mC[index]);
    end
end

return uiMachine
