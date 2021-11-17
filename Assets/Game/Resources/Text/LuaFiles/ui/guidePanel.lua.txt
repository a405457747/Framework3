-------------------------------------------------------
-- author : sky_allen                                                                                                                  
--  email : 894982165@qq.com      
--   time : 2021/10/13 18:42:21                                                                                           
-------------------------------------------------------

---@class guidePanel
local guidePanel = class('guidePanel', popui)

function guidePanel:init()
    guidePanel.super.init(self)
    print("guidePanel init")
end

function guidePanel:show()
    guidePanel.super.show(self);

   -- print("guidePanel show lv:" .. slotsManage.curMachine.lv);
    local lv = slotsManage.curMachine.lv;
    local s = AF:LoadSprite("g" .. lv);
    self:guideMainImageRefresh(s);
end

--auto

function guidePanel:ctor(go, tier)
    guidePanel.super.ctor(self, go, tier)
    self.guideMainImage = self.go.transform:Find("Image/GuideScrollView/Viewport/Content/guideMainImage"):GetComponent('Image');


end

function guidePanel:guideMainImageRefresh(t)
    self.guideMainImage.sprite = t;
end

return guidePanel
