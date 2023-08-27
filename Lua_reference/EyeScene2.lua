local util = require 'xlua.util'

local UnityEngine = CS.UnityEngine
local Quaternion = UnityEngine.Quaternion
local WidgetsManager = CS.Samuel.Widgets.WidgetsManager
local Vector3 = CS.UnityEngine.Vector3
local Ease = CS.DG.Tweening.Ease
local ButtonClickedEvent = CS.UnityEngine.UI.Button.ButtonClickedEvent
local DOTween = CS.DG.Tweening.DOTween

-- 编辑模式(通常用来限制交互触发)
local IsEditMode = (WidgetsManager ~= nil and WidgetsManager.Instance ~= nil and
    WidgetsManager.Instance.IsEditMode ~= nil and
WidgetsManager.Instance.IsEditMode == true) and true or
false

local firstCo = nil
local firstIntervals = nil
local sounds = nil
local eyeglassT = nil -- 眼镜的transform组件

function Awake()
    print("lua Awake...")

end

function Start()
    print("lua Start...")
    sounds = {s1, s2, s3, s4, s5}
    eyeglassT = Model3.transform:GetChild(0)
end

-- 一个游戏物体挂载的脚本中Awake、Start只会执行一次，当这个游戏物体被取消激活 再重新激活的时候，脚本中的Awake、Start都不会再重新执行，而OnEnable会重新在第一帧执行一次！
-- 执行顺序：Awake -> Start -> OnEnable
-- 针对的是脚本所挂的物体，实现重置
function OnEnable()
    print("lua OnEnable...")

    Model3.transform.localScale = Vector3.zero
    Model3.transform:DOScale(Vector3.one * 0.8, 1):SetEase(Ease.InOutQuint)
    :SetDelay(1)

    if firstCo ~= nil then
        self:StopCoroutine(firstCo)
    end
    firstCo = OnModel3AnimationStarted()
    firstIntervals = {3, 11, 14, 16, 18} -- 对应了什么时候触发什么阶段的动画
    firstTriggers = {'1JingKuang', '2JingMianJiao', '3JingTuiGaoDu', '4JingTuiJiaJiao', '5BiLiang'}
    self:StartCoroutine(firstCo)

end

function OnDisable() print("lua OnDisable...") end

function OnDestroy() print("lua OnDestroy") end

-- 控制语音1播放的时间
function OnModel3AnimationStarted()
    -- print(Auxiliary1:GetComponent('Transform'):GetChild(0).gameObject)
    local audio = Model3:GetComponent('Transform'):GetChild(1):GetComponent('AudioSource')

    return util.cs_generator(function()
        for i = 1, #firstIntervals do

            -- -- 写逻辑的代码
            if i == 2 then
                coroutine.yield(CS.UnityEngine.WaitForSeconds(firstIntervals[i]))
                audio.clip = sounds[i]
                audio:Play()
                -- eyeglassT:DOLocalRotate(UnityEngine.Vector3(-90, 0, 0), 2, CS.DG.Tweening.RotateMode.FastBeyond360)
                eyeglassT:DORotateQuaternion(Quaternion.Euler(Vector3(-90, 0, 0)), 2)

            elseif i == 3 then
                coroutine.yield(CS.UnityEngine.WaitForSeconds(firstIntervals[i]))
                audio.clip = sounds[i]
                audio:Play()
                -- eyeglassT:DOLocalRotate(UnityEngine.Vector3(0, 90, 0), 2, CS.DG.Tweening.RotateMode.FastBeyond360)
                eyeglassT:DORotateQuaternion(Quaternion.Euler(Vector3(0, 90, 0)), 2)

                coroutine.yield(CS.UnityEngine.WaitForSeconds(3))
            elseif i == 4 then
                coroutine.yield(CS.UnityEngine.WaitForSeconds(firstIntervals[i] - 3))
                audio.clip = sounds[i]
                audio:Play()
                -- eyeglassT:DOLocalRotate(UnityEngine.Vector3(-90, 0, 0), 2, CS.DG.Tweening.RotateMode.FastBeyond360)
                eyeglassT:DORotateQuaternion(Quaternion.Euler(Vector3(-90, 0, 0)), 2)

                coroutine.yield(CS.UnityEngine.WaitForSeconds(1))
            elseif i == 5 then
                coroutine.yield(CS.UnityEngine.WaitForSeconds(firstIntervals[i] - 1))
                audio.clip = sounds[i]
                audio:Play()
                -- eyeglassT:DOLocalRotate(UnityEngine.Vector3(0, 180, 0), 2, CS.DG.Tweening.RotateMode.FastBeyond360)
                eyeglassT:DORotateQuaternion(Quaternion.Euler(Vector3(0, 180, 0)), 2)

                coroutine.yield(CS.UnityEngine.WaitForSeconds(3))
            else
                coroutine.yield(CS.UnityEngine.WaitForSeconds(firstIntervals[i]))
                audio.clip = sounds[i]
                audio:Play()
            end

            Model3_Ani:SetTrigger(firstTriggers[i])

        end
        coroutine.yield(CS.UnityEngine.WaitForSeconds(10))
        -- eyeglassT:DOLocalRotate(UnityEngine.Vector3(0, 0, 0), 2, CS.DG.Tweening.RotateMode.FastBeyond360)
        eyeglassT:DORotateQuaternion(Quaternion.Euler(Vector3(0, 0, 0)), 2)
    end)
end

function EndCoroutine()

end
