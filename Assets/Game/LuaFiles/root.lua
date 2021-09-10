-------------------------------------------------------
-- author : sky_allen                                                                                                                  
--  email : 894982165@qq.com      
--   time : 2021/9/2 16:17:39                                                                                           
-------------------------------------------------------

---@class root
root = class('root')

---@type save
save = nil;
---@type audio
audio = nil;

GameGo = GameObject.Find("Game");
local canvasT = GameGo.transform:Find("Canvas");
local uis = {}
local systems = {}

function root:ctor()

end

function root.set_tier(go, tier)
    local p = canvasT:Find(tier);
    go.transform:SetParent(p, false);
end

function root:Awake()
    self:init();
end

function root:Update()

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
    print("by root init :" .. _VERSION)

    save = root.add_sys("save");
    audio = root.add_sys("audio");
end

function root.add_sys(name)
    local ins = require("sys." .. name)
    table.insert(systems, ins);
    ins.init()
    return ins;
end

function root.add_ui(name)
    local go = af:LoadPanel(name);
    local go2 = UnityEngine.GameObject.Instantiate(go);
    go2.name = name;
    local ui_class = require("ui." .. name);
    local ui_ins = ui_class.new(go2, "Default");
    ui_ins:init();
    table.insert(uis, ui_ins);
    return ui_ins;
end

return root