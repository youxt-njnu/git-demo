local util = require 'xlua.util'

local UnityEngine = CS.UnityEngine
local WidgetsManager = CS.Samuel.Widgets.WidgetsManager
local Vector3 = CS.UnityEngine.Vector3
local Ease = CS.DG.Tweening.Ease
local ButtonClickedEvent = CS.UnityEngine.UI.Button.ButtonClickedEvent
local Time = UnityEngine.Time
local UI = CS.UnityEngine.UI
local DOTween = CS.DG.Tweening.DOTween
local Tweening = CS.DG.Tweening

-- 编辑模式(通常用来限制交互触发)
local IsEditMode = (WidgetsManager ~= nil and WidgetsManager.Instance ~= nil and
                       WidgetsManager.Instance.IsEditMode ~= nil and
                       WidgetsManager.Instance.IsEditMode == true) and true or
                       false

-- new start
local lightCpnt = nil
local speed = 30
local clickRotate = false
local duration = 4
local lionRT = lion:GetComponent(typeof(UnityEngine.RectTransform))
-- new end

function Awake() print("lua Awake...") end

function Start()
    print("lua Start...")

    -- new start
    -- print("injected object is:",lightObject)
    -- 将dierectional light挂到脚本上，然后获取得到他的Light组件
    HelloAni()
    lightCpnt = lightObject:GetComponent(typeof(UnityEngine.Light))
    RegisterButton(RotateBtn, RotateColor)
    RegisterButton(ScaleBtn, ScaleXY)
    RegisterButton(ResetBtn, ResetTransform)
    -- new end

    -- RegisterButton(button,Reset)
end

-- 可以在update里做逐帧动画，也可以使用unity自带的界面里自己制作，也可以通过DOTween里的方法来做动画
-- update里面如果有逐帧执行的，最好不要写local这种变量
function Update()
    -- 针对逐帧的动画，需要在外面设置一个bool值控制其播放
    if (clickRotate == true) then
        -- 进行自转
        lion.transform:Rotate(Vector3.up * Time.deltaTime * speed)
        -- 更改light的颜色
        lightCpnt.color = UnityEngine.Color(
                              UnityEngine.Mathf.Sin(Time.time) / 2 + 0.2,
                              UnityEngine.Mathf.Sin(Time.time) / 2,
                              UnityEngine.Mathf.Sin(Time.time) / 2 + 0.5, 1)
    end
    -- 鼠标左键点击后，触发动画
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
                    animator:SetTrigger('SayHi')
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
    Reset()
end

function OnDisable() print("lua OnDisable...") end

function OnDestroy() print("lua OnDestroy") end

-- reference
function Reset()
    -- DoTween
    animator.transform.localScale = Vector3.zero
    animator.transform:DOScale(Vector3.one * 2, .5):SetEase(Ease.OutBounce)
        :SetDelay(1)
    tip.transform.localScale = Vector3.zero
    tip.transform:DOScale(Vector3.one * .002, .3):SetEase(Ease.OutBounce)
        :SetDelay(1.4)
end

-- new start
-- 需要把button的button组件，拖拽到脚本上面去
function RotateColor()
    -- 每次取反，可以实现点击旋转或点击暂停
    -- clickRotate=not clickRotate

    -- 另一种
    -- 1.X轴的正方向: Vector3.right等价于(1, 0, 0)
    -- 2.X轴的负方向: Vector3.left等价于(-1, 0, 0)
    -- 3.Y轴的正方向: Vector3.up等价于(0, 1, 0)
    -- 4.Y轴的负方向: Vector3.down等价于(0, -1, 0)
    -- 5.Z轴的正方向: Vector3.forward等价于(0, 0, 1)
    -- 6.Z轴的负方向: Vector3.back等价于(0, 0, -1)
    -- 表示转到这个位置，然后持续duration的时间，转的模式是Fast
    lionRT:DORotate(Vector3.forward * 180, duration, Tweening.RotateMode.Fast) --  :SetEase(Ease.InOutQuint):SetLoops(-1)
end

function ScaleXY()
    print(lionRT)
    print(lion)
    lionRT:DOScaleX(0.5, 1)
    lionRT:DOScaleY(0.5, 1)
end
-- 实现lion的位置重置
function ResetTransform()
    -- transform.localScale.x
    -- transform.localScale.y
    -- transform.localScale.z
    lion.transform.localScale = Vector3(2, 2, 2)
    lion.transform.localEulerAngles = Vector3(0, 180, 0)
    lightCpnt.color = UnityEngine.Color(1, 1, 1, 1)
end

-- hello周边的动态效果
function HelloAni()
    -- 颜色渐变，参数：1、红色，2、时间
    -- HelloTxt:DOColor(UnityEngine.Color.red, 2)
    -- 渐显，控制透明度的，参数1、alpha值，2、时间
    -- HelloTxt:DOFade(1, 3)
    local delay = duration * 0.2
    DOTween:Sequence():Append(HelloTxt:DOColor(UnityEngine.Color.red,
                                               duration / 2):SetEase(
                                  Ease.OutQuart)):AppendInterval(delay / 2)
        :Append(HelloTxt:DOColor(UnityEngine.Color.yellow, duration / 2)
                    :SetEase(Ease.OutQuart)):AppendInterval(delay / 2):Append(
            HelloTxt:DOFade(0, 3):SetEase(Ease.OutQuart)):SetLoops(-1)

    local pos = MoveCube.anchoredPosition -- (29.5,-7,0)
    pos.x = pos.x + 5
    pos.y = pos.y + 2
    -- 需要给MoveCube增加一个rect transform组件，然后把这个组件给MoveCube
    -- 都用冒号

    -- DOAnchorPosX(浮动至，浮动持续时间)
    -- 这里设置了相对于父对象
    DOTween:Sequence():Append(MoveCube:DOAnchorPosX(-pos.x, duration / 4)
                                  :SetEase(Ease.InOutQuart)):Append(
        MoveCube:DOAnchorPosY(-pos.y, duration / 4):SetEase(Ease.InOutQuart))
        :Append(MoveCube:DOAnchorPosX(pos.x, duration / 4)
                    :SetEase(Ease.InOutQuart)):Append(
            MoveCube:DOAnchorPosY(pos.y, duration / 4):SetEase(Ease.InOutQuart))
        :SetLoops(-1)

    -- tip图片变化
    -- sequence.Kill()
    local TipImage = tip:GetComponent(typeof(UI.Image)) -- Image组件在UnityEngine.UI里面
    local sequence = DOTween.Sequence()
    sequence:Append(TipImage:DOFillAmount(1, duration / 2):SetEase(
                        Ease.InOutQuart))
    sequence:AppendCallback(function()
        TipImage.fillClockwise = not TipImage.fillClockwise
    end) -- 每次循环的时候，设置图片填充是顺时针还是逆时针
    sequence:Append(TipImage:DOFillAmount(0, duration / 2):SetEase(
                        Ease.InOutQuart)) -- 加上这个更顺滑
    sequence:AppendCallback(function()
        -- Image.fillOrigin: Controls the origin point of the Fill process. Value means different things with each fill method.
        TipImage.fillOrigin = UI.Image.OriginHorizontal.Left
    end)
    sequence:SetLoops(-1)

end
-- new end

-- UGUI按钮注册
function RegisterButton(btn, func)
    -- body
    local bce = ButtonClickedEvent()
    bce:AddListener(func)
    btn.onClick = bce
end
