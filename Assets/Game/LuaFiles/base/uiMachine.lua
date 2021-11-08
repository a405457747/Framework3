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
    self.go = playPanel.go.transform:Find("Image" .. self.lv).gameObject;
    self.lines = array2table(self.go.transform:Find("Image/GameObject"));
    self.go:GetComponent("Image").sprite = AF:LoadSprite("bg" .. self.lv);
end

function uiMachine:initWheels()
    local luaMonos = array2table(self.go.transform:Find("Image/Image"), RectTransform, false);
    self.wheels = {};
    local allSprites = self:loadAllSprite();
    local allSpritesNames = table.selectItems(allSprites, "name");
    slotsManage.SetAllSpritesNames(allSpritesNames);--设置这个仅仅是为了校验一下名字而已
    for i, v in ipairs(luaMonos) do
        table.insert(self.wheels, v:GetComponent(typeof(CS.LuaMono)).TableIns);
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
    self.mapPatterns = self:getMapPatterns();--玩家直观的
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

function uiMachine:partSPPoolRemoveSome(allSprites, fT)
    slotsManage.SpritesNameCheck(fT);

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
    table.insert(res, AF:LoadSprite("Empty"))

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

    for i, v in ipairs(matrix) do
        res[i] = {};
    end

    for i, v in ipairs(matrix) do
        for i2, v2 in ipairs(v) do
            res[i2][i] = v2;
        end
    end

    return res;
end

function uiMachine:spinStart()
    if self.awardAnimals then
        cs_coroutine.stop(self.awardAnimals);
        self:lineAnimReset();
    end

    self:rollAll();
end

function uiMachine:spinOver()
end

--todo 后面开始弄成小函数吧
function uiMachine:rollAll()
    local s = cs_coroutine.start(function()
        rotate = true;

        slotsManage.R2Change(R2)--改变时间
        slotsManage.R1Change(R1 / 2)

        local rdmReadDataMatrixIntuitive = slotsManage.curMachine:getRandomMatrix()--得到的是玩家直观的;
        local matrix = rdmReadDataMatrixIntuitive;
        if PATTERNS_QUICK then
            matrix = {
                { "s3", "w4", "b3" },
                { "w2", "w3", "w2" },
                { "s2", "b2", "b2" },
            }
        end
        if WRITE_DATA_MODE then
            -- todo 下次写入还需要验证下这里对不对
            self:randomSetImage();--把隐藏的也设置了但是没有关系
            matrix = self:getMapPatternNames();--从直观的地方获取名字
        end

        local nearMissLineTable = slotsManage.curMachine:fixedMatrixMidRow(matrix);--获取nearMiss那条线默认是中间条
        local nearMiss = (math.ratio(NEAR_MISS_RATIO)) and (slotsManage.curMachine:isNearMiss(nearMissLineTable));

        for i, v in ipairs(self.wheels) do
            self:roll(i, true);
        end

        coroutine.yield(WaitForSeconds(R1 / 2))
        coroutine.yield(WaitForSeconds(slotsManage.R1));

        for i, v in ipairs(self.wheels) do
            self:roll(i, false, self:matrixChange(matrix))
            if i == (#self.wheels - 1) then
                --要转到第三个之前的时候
                if nearMiss then
                    coroutine.yield(WaitForSeconds(slotsManage.R2 * 3))
                    print("nearMiss success")
                else
                    coroutine.yield(WaitForSeconds(slotsManage.R2))
                end
            else
                coroutine.yield(WaitForSeconds(slotsManage.R2))
            end
        end

        local totalBet = slotsManage.curMachine:calculateLines(matrix);
        local hightBetLv = slotsManage.curMachine:HightBetLv(totalBet);
        if hightBetLv ~= 0 then
            playPanel:showHightWinImage(hightBetLv);
        end
        -- print("playPanel:showHightWinImage", hightBetLv)
        sendEvent(SPIN_OVER, totalBet ~= 0, slotsManage.getTotalAward(totalBet))
        rotate = false;

        local winAnimalDic = slotsManage.curMachine.winAnimalDic;--动画相关
        if table.hash_count(winAnimalDic) > 0 then
            --print(B)
            self.awardAnimals = cs_coroutine.start(function()
                while true do
                    for i, v in pairs(winAnimalDic) do
                        local winAnimal = table.copy(v);
                        local completeMatrix = table.copyMatrix(slotsManage.curMachine.LineNumberMatrix[i]);--这是动画矩阵

                        --todo 遍历矩阵 machine:calculateLines的方式务必保持一致
                        for i1, v1 in ipairs(completeMatrix) do
                            for i2, v2 in ipairs(v1) do
                                if completeMatrix[i1][i2] == 1 then
                                    local rmVal = table.removeFirst(winAnimal);
                                    completeMatrix[i1][i2] = rmVal and 1 or 0;
                                end
                            end
                        end

                        assert(#winAnimal == 0);

                        self:lineAnim(tonumber(i), false);

                        --table.print_nest_arr(completeMatrix);
                        for i1, v1 in ipairs(completeMatrix) do
                            --得到动画矩阵后再播放单个的
                            for i2, v2 in ipairs(v1) do
                                if v2 == 1 then
                                    self.mapPatterns[i1][i2]:awardAnim();
                                end
                            end
                        end
                        --print("---------------------")
                        coroutine.yield(WaitForSeconds(AWARD_ANIM_DELAY2));

                        self:lineAnim(tonumber(i), true);
                    end
                end
            end)
            -- print(B)
        end

        -- print("auto", auto)--继续相关
        if auto then
            coroutine.yield(WaitForSeconds(0.33));
            playPanel:spinButtonAction2()
        else
        end
    end)
end


function uiMachine:SetImageByName(nameLists)
    --这个要非直观的3x3
    for i, v in ipairs(self.wheels) do
        v:SetImageByName(nameLists[i]);
    end
end

function uiMachine:roll(index, isStart, mC)
    local wheel = self.wheels[index];
    if isStart then
        wheel:spinStart();
    else
        wheel:spinOver();
        wheel:SetImageByName(mC[index]);
    end
end

return uiMachine
