-------------------------------------------------------
-- author : sky_allen                                                                                                                  
--  email : 894982165@qq.com      
--   time : 2021/10/20 18:40:19                                                                                           
-------------------------------------------------------

---@class spinButton
local spinButton = class('spinButton')

function spinButton:setImg(name)
    self.img.sprite = AF:LoadSprite(name);
end

local reduceSuccess = false;
local isDown = false;
local timer = 0;
local targetTime = R4

function spinButton:Start()
    self.img = self.transform:GetComponent(typeof(Image));
    local btn = self.transform:GetComponent("Button");
    btn.onClick:RemoveAllListeners();

end

function spinButton:longPress()
    if not auto then
        if reduceSuccess then
            auto = true; --循环要等待所以携程结束,必须这样本身复杂度挺高的了，想早点下班就不要乱改
            self:setImg("auto");
        end
    else
    end
    --print("long press")
end

function spinButton:Update()
    if isDown then
        timer = timer + Time.deltaTime;
        if timer >= targetTime then
            self:longPress();
            timer = 0;
        end
    else
        timer = 0;
    end
end

function spinButton:OnPointerClick(eventData)
end

function spinButton:OnPointerDown(eventData)
    isDown = true;

    if not auto then
        if rotate then
            slotsManage.R2Change(0.001);
            slotsManage.R1Change(0.001);
        else
            self:setImg("spin2");
            reduceSuccess = playPanel:spinButtonAction2()
        end
    else
        auto = false;
        self:setImg("spin2")
    end

end

function spinButton:OnPointerUp(eventData)
    isDown = false;

    if not auto then
        self:setImg("spin1");
    else
    end

end

return spinButton
