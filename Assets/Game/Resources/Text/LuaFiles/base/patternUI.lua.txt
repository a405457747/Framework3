-------------------------------------------------------
-- author : sky_allen                                                                                                                  
--  email : 894982165@qq.com      
--   time : 2021/10/18 11:03:39                                                                                           
-------------------------------------------------------

---@class patternUI
local patternUI = class('patternUI')
local ratio = 0.68;
-- 请注意patternUI表示的主要图片的父类哦
function patternUI:ctor()
end

function patternUI:Start()

end

function patternUI:init(spritePool, pH, wheelUI, first, second)
    self.isStop = true;
    self.rect = self.transform:GetComponent(typeof(RectTransform));

    self.wheelUI = wheelUI;
    self:setHeight(pH);
    self:setAnchoredPositionY(self.wheelUI:GetPos(string.get_pure_number(self.transform.gameObject.name)))

    self.curY = self.rect.anchoredPosition.y;
    self.initY = self.curY;
    self.spinSpeed = pH / 4;--这里不能超过规定高度

    self.spritePool = spritePool;
    self:randomSetImage()

    self.first = first;
    self.second = second;
    self.uiEffect = self.transform:Find("Image"):GetComponent(typeof(CS.Coffee.UIEffects.UIEffect))
    -- print("f,s", self.first, self.second);
end

function patternUI:setHeight(number)
    local v2 = Vector2(200, number);
    self.rect.sizeDelta = v2;
end

function patternUI:GetPatternImage()
    return self.transform:Find("Image"):GetComponent(typeof(Image));
end

function patternUI:GetPatternImageName()
    --return table.get_random_item(self.spritePool).name;
    return self:GetPatternImage().sprite.name;
end

function patternUI:awardAnim()
    local imgTrans = self:GetPatternImage().transform;
    local s = DOTween.Sequence();
    local offset = 0.125;
    local totalTime = AWARD_ANIM_DELAY1;
    s:Append(imgTrans:DOScale(offset, totalTime / 2):SetRelative(true):SetEase(Ease.InOutBounce));
    s:Append(imgTrans:DOScale(-offset, totalTime / 2):SetRelative(true):SetEase(Ease.InOutBounce));
end

function patternUI:rewindAnim(isLate)
    local imgTrans = self:GetPatternImage().transform;
    local s = DOTween.Sequence();
    local offsetAmount = 25;
    local offset;
    local totalTime = RE_WIND_COST;
    local totalCount = 50;
    assert(totalCount % 2 == 0);
    local perCost = totalTime / totalCount;

    for i = 1, totalCount do
        if i % 2 == 0 then
            offset = isLate and offsetAmount or -offsetAmount;
        else
            offset = isLate and -offsetAmount or offsetAmount;
        end

        if i % 2 == 0 then
            offsetAmount = -offsetAmount;
        end
        s:Append(imgTrans:DOAnchorPosY(offset, perCost):SetRelative(true));
    end
end

function patternUI:SetImageByName(name)
    --这里查找一遍，仅仅是为了校验而已
    local s = nil;
    for i, v in ipairs(self.spritePool) do
        if v.name == name then
            s = v;
            break ;
        end
    end

    if s == nil then
        error("The sprite don't find in self.spritePool name is " .. name)
    end

    self:SetImage(s);
end

function patternUI:SetImage(s)
    self:GetPatternImage() .sprite = s;
    self:GetPatternImage():SetNativeSize();
    self:IamgeResetLocalScale();
end

function patternUI:IamgeResetLocalScale()
    self:GetPatternImage().transform.localScale = Vector3.one * ratio;
end

function patternUI:randomSetImage()
    self:SetImage(table.get_random_item(self.spritePool))
end

function patternUI:spinStart()
    self.isStop = false;
    self.uiEffect.blurFactor = 1;
    --  print("spinStart")
end

function patternUI:spinOver()
    self.isStop = true;
    self.uiEffect.blurFactor = 0;

    self.rect.anchoredPosition = Vector2(self.rect.anchoredPosition.x, self.initY);

    local s = DOTween.Sequence()
    local offset = 70

    s:Append(self.rect:DOAnchorPosY(-offset, R3 / 2):SetRelative(true))
    s:Append(self.rect:DOAnchorPosY(offset, R3 / 2):SetRelative(true))
    --[[    s:OnComplete(function()
            print(Time.time, "gird")
        end)]]
end

function patternUI:setAnchoredPositionY(f)
    self.rect.anchoredPosition = Vector2(self.rect.anchoredPosition.x, f);
end

--  偏移起来不能够统一，不知道原因，已经尽力了
function patternUI:Update()

    if WRITE_DATA_MODE then
        return ;
    end

    if self.isStop then
        return ;
    end

    self.curY = self.curY - self.spinSpeed;
    if self.curY <= self.first then
        self:randomSetImage();
        self.curY = self.second;
    end

    self:setAnchoredPositionY(self.curY)
end

return patternUI
