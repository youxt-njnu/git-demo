local util = require 'xlua.util'

local UnityEngine = CS.UnityEngine
local WidgetsManager = CS.Samuel.Widgets.WidgetsManager
local Vector3 = CS.UnityEngine.Vector3
local Ease = CS.DG.Tweening.Ease
local ButtonClickedEvent = CS.UnityEngine.UI.Button.ButtonClickedEvent

-- 编辑模式(通常用来限制交互触发)
local IsEditMode = (WidgetsManager ~= nil and WidgetsManager.Instance ~= nil and
                       WidgetsManager.Instance.IsEditMode ~= nil and
                       WidgetsManager.Instance.IsEditMode == true) and true or
                       false

-- 随机数问题
-- 1.需要设置随机数种子，然后第一个产生的总归是近似左边界的数字
-- 2.os.time() 返回的时间是秒级的， 不够精确， 而 random() 还有个毛病就是如果 seed 很小或者seed 变化很小，产生的随机序列仍然很相似
math.randomseed(tostring(os.time()):reverse():sub(1, 6))
-- 把 time返回的数值字串倒过来（低位变高位）， 再取高位6位。 这样， 即使 time变化很小， 但是因为低位变了高位， 种子数值变化却很大，就可以使伪随机序列生成的更好一些
local randMove = math.random(5)
local state = {'OnPlay', 'OnRollOver', 'OnShake', 'OnSitting', 'OnStanding'}

function Awake() print("lua Awake...") end

function Start()
    print("lua Start...")
    -- RegisterButton(button,Reset)
end

function Update()
    -- Mouse0: The Left (or primary) mouse button.
    -- Lua API: https://github.com/Tencent/xLua/blob/master/Assets/XLua/Doc/XLua_API.md
    -- CS.namespace.class(...)
    if not IsEditMode and
        UnityEngine.Input.GetKeyDown(UnityEngine.KeyCode.Mouse0) then
        -- UnityEngine.Camera.main: The first enabled Camera component that is tagged "MainCamera" (Read Only). If there is no enabled Camera component with the "MainCamera" tag, this property is null.
        -- Camera.ScreenPointToRay: https://docs.unity3d.com/ScriptReference/Camera.ScreenPointToRay.html, Returns a ray going from camera through a screen point.Resulting ray is in world space, starting on the near plane of the camera and going through position's (x,y) pixel coordinates on the screen (position.z is ignored).
        local ray = UnityEngine.Camera.main:ScreenPointToRay(UnityEngine.Input
                                                                 .mousePosition)
        -- 返回所有hits点: https://docs.unity3d.com/ScriptReference/Physics.RaycastAll.html

        local hits = UnityEngine.Physics.RaycastAll(ray)
        if hits.Length > 0 then

            for i = 0, hits.Length - 1 do
                -- 获取到所有射到的碰撞体对应游戏物体的名字
                -- print(hits[i].collider.gameObject.name)
                -- hitObj, 碰撞的物体
                local hitObj = hits[i].collider.gameObject

                if hitObj == target then
                    -- Trigger：当被过渡使用时，由控制器重置的布尔值参数（以圆形按钮表示）可使用以下 Animator 类中的SetTrigger 和 ResetTrigger从脚本为参数赋值
                    randMove = math.random(5)
                    animator:SetTrigger(state[randMove])
                    print(randMove)
                    -- 设置完trigger之后，会从anystate转换到Hi，然后Hi上面挂了一个动画，就会打招呼，招呼打完了之后回到Idle状态；
                    -- 此外，运行后，默认的是进入Idle状态
                    break
                end
            end
        end
    end
end

function OnEnable()
    print("lua OnEnable...")
    animator:SetTrigger(state[randMove])
    print(state[randMove])
end

function OnDisable() print("lua OnDisable...") end

function OnDestroy() print("lua OnDestroy") end
