-------------------------------------------------------
-- author : sky_allen                                                                                                                  
--  email : 894982165@qq.com      
--   time : 2021/10/14 13:36:19                                                                                           
-------------------------------------------------------

---@class slotsMachine1
local slotsMachine1 = class('slotsMachine1', require("base.machine"))

function slotsMachine1:ctor(lv)
    slotsMachine1.super.ctor(self, lv);
end

function slotsMachine1:initMachineUI()
    slotsMachine1.super.initMachineUI(self);
end

function slotsMachine1:spinStart()
    slotsMachine1.super.spinStart(self)
end

function slotsMachine1:spinOver()
    slotsMachine1.super.spinOver(self)
end

return slotsMachine1
