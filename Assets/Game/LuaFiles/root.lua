-------------------------------------------------------
-- author : sky_allen                                                                                                                  
--  email : 894982165@qq.com      
--   time : 2021/9/2 16:17:39                                                                                           
-------------------------------------------------------

require("functions.functions");
Language = require("data.Language")
require("base.config")
require("functions.kit");
sys = require("base.sys")
ui = require("base.ui")
popui = require("base.popui")
require("functions.event2")
cs_coroutine = (require 'functions.cs_coroutine');
require("functions.objPool")
weight = (require("functions.weight"));

---@class root
root = class('root')
---@type save
save = false;
---@type audio
audio = false;
---@type timeManage
timeManage = false;
---@type shop
shop = false
---@type slotsManage
slotsManage = false;
---@type level
level = false;
---@type thingFly
thingFly = false;
---@type lobbyPanel
lobbyPanel = false;
---@type barPanel
barPanel = false;
---@type playPanel
playPanel = false;
---@type settingPanel
settingPanel = false;
---@type buyPanel
buyPanel = false;
---@type pigPanel
pigPanel = false;
---@type tipPanel
tipPanel = false;
---@type loginPanel
loginPanel = false;
---@type netPanel
netPanel = false;
---@type guidePanel
guidePanel = false;
pig2Panel = false;
---@type ad;
ad = false;
---@type evaluatePanel
evaluatePanel = false;
GameGo = GameObject.Find("Game");
data = false;
channels = create_enum_table({ "google", "amazon", "apple" })

local canvasT = GameGo.transform:Find("Canvas");
local uis = {}
local systems = {}

function root:Start()
    self:init();
end

function root:Update()

    if UnityEngine.Input.GetKeyDown(UnityEngine.KeyCode.A) then

        --[[        self.x = { "a", "b", "c" };
                local t = self.x;
                table.filterItems(t, { "b" });
                table.print_arr(self.x);]]

        --[[        local t = {
                    { "w1", "w1", "w1" },
                    { "w1", "w1", "w1" },
                    { "w1", "w1", "w1" },
                }
                local t2 = {
                    { "w2", "w2", "w2" },
                    { "w1", "w1", "w1" },
                    { "w1", "w1", "w1" },
                }
                local t3 = {
                    { "w3", "w3", "w3" },
                    { "w1", "w1", "w1" },
                    { "w1", "w1", "w1" },
                }
                local bigT = {};
                table.insert(bigT, t);
                table.insert(bigT, t2);
                table.insert(bigT, t3);

                CS.IOHelpLua.CreateTemp(string.serialize(bigT));
                ]]
        -- evaluatePanel:show()

       -- slotsManage.curMachine:dataWrite()

        print("press key a")
    end
    if UnityEngine.Input.GetKeyDown(UnityEngine.KeyCode.S) then
        --[[        local txt = AF:LoadTextAsset("Lv1/1")
                local g = string.unserialize(txt.text);

                for i, v in ipairs(g) do
                    table.print_nest_arr(v);
                end]]


       slotsManage.curMachine:getWeightItem();
    end

    for i, v in pairs(systems) do
        if v.frame then
            v.frame()
        end
    end

    for i, v in pairs(uis) do
        if v.is_show then
            v:frame()
        end
    end
end

function root:init()
    setmetatable(_G, {
        __index = function(t, _)
            error("read nil value " .. _, 2)
        end,
        __newindex = function(t, _)
            error("write nil value " .. _, 2)
        end
    });

    print "root init"

    save = root.add_sys("save");
    audio = root.add_sys("audio");
    timeManage = root.add_sys("timeManage");
    slotsManage = root.add_sys("slotsManage");
    shop = root.add_sys("shop");
    level = root.add_sys("level");
    thingFly = root.add_sys("thingFly")
    ad = root.add_sys("ad");

    root.add_ui("loadPanel");
    lobbyPanel = root.add_ui("lobbyPanel");
    barPanel = root.add_ui("barPanel");
    playPanel = root.add_ui("playPanel")
    settingPanel = root.add_ui("settingPanel");
    buyPanel = root.add_ui("buyPanel")
    pigPanel = root.add_ui("pigPanel")
    tipPanel = root.add_ui("tipPanel")
    loginPanel = root.add_ui("loginPanel");
    netPanel = root.add_ui("netPanel")
    guidePanel = root.add_ui("guidePanel")
    pig2Panel = root.add_ui("pig2Panel");
    evaluatePanel = root.add_ui("evaluatePanel")

    --todo 赢家、结算、评价界面

end

function root.set_tier(go, tier)
    go.transform:SetParent(canvasT:Find(tier), false);
end

function root.add_sys(name)
    local ins = require("sys." .. name)
    table.insert(systems, ins);
    ins.init()
    return ins;
end

function root.add_ui(name)
    local go2 = UnityEngine.GameObject.Instantiate(AF:LoadPanel(name));
    go2.name = name;
    local ui_class = require("ui." .. name);
    local ui_ins = ui_class.new(go2, "Default");
    ui_ins:init();
    table.insert(uis, ui_ins);
    return ui_ins;
end

return root;