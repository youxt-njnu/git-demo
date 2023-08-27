local util = require 'xlua.util'

local UnityEngine = CS.UnityEngine
local WidgetsManager = CS.Samuel.Widgets.WidgetsManager
local Vector3 = CS.UnityEngine.Vector3
local Ease = CS.DG.Tweening.Ease
local ButtonClickedEvent = CS.UnityEngine.UI.Button.ButtonClickedEvent
local DOTween = CS.DG.Tweening.DOTween
local Time = CS.UnityEngine.Time

-- 编辑模式(通常用来限制交互触发)
local IsEditMode = (WidgetsManager ~= nil and WidgetsManager.Instance ~= nil and
                       WidgetsManager.Instance.IsEditMode ~= nil and
                       WidgetsManager.Instance.IsEditMode == true) and true or
                       false

local Audios_Model2 = {}
local tips = nil
local labels = {
    'ZuiYouShiJue', 'Qingbian', 'WenGuTieHe1', 'WenGuTieHe2', 'Start2',
    'Start3', 'Start4'
} -- 第二个动画里面的触发条件
local firstCo = nil
local firstIntervals = {}
local sequence = nil

function Awake() print("lua Awake...") end

function Start()
    print("lua Start...")
    Audios_Model2 = {Audio1_2, Audio2_2, Audio3_2}
end

function Update()
    if not IsEditMode and
        UnityEngine.Input.GetKeyDown(UnityEngine.KeyCode.Mouse0) and
        enableClickPart then -- enableClickPart表示：true表示，接下来可以点击眼睛的部位了
        -- 点击触发
        local ray = UnityEngine.Camera.main:ScreenPointToRay(UnityEngine.Input
                                                                 .mousePosition)
        local hits = UnityEngine.Physics.RaycastAll(ray)
        if hits.Length > 0 then
            local hited = false
            for j = 0, hits.Length - 1 do

                -- print(hits[j].collider.gameObject.name)

                local hitObj = hits[j].collider.gameObject
                -- 判断是否点击了tip，
                for i = 1, #tips do
                    if hitObj ==
                        tips[i]:GetComponent('Transform'):GetChild(0).gameObject then
                        -- 融合了展开和关闭两种情况
                        -- 获取动画组件，修改转换状态，设置音乐
                        local tipAnim = tips[i]:GetComponent('Animator')
                        local tipState = not tipAnim:GetBool('Open')
                        tipAnim:SetBool('Open', tipState)

                        local tipSound = tips[i]:GetComponent('AudioSource')

                        -- Model2_Ani:SetBool(labels[i], tipState)

                        if tipState then
                            tipSound:Play()
                            Model2_Ani:SetTrigger(labels[i])
                        else
                            tipSound:Stop()
                        end
                        hited = true
                        break -- 一次进入即可退出，因为一次只能点击一个
                    end
                end

                if hited then break end
            end
        end
    end
end

-- 一个游戏物体挂载的脚本中Awake、Start只会执行一次，当这个游戏物体被取消激活 再重新激活的时候，脚本中的Awake、Start都不会再重新执行，而OnEnable会重新在第一帧执行一次！
-- 执行顺序：Awake -> Start -> OnEnable
-- 针对的是脚本所挂的物体，实现重置
function OnEnable()
    print("lua OnEnable...")
    Model1:SetActive(true)
    Model2:SetActive(false)

    if tips == nil then
        tips = {
            Tips_2:GetComponent('Transform'):GetChild(0).gameObject,
            Tips_2:GetComponent('Transform'):GetChild(1).gameObject,
            Tips_2:GetComponent('Transform'):GetChild(2).gameObject
        }
    end
    if firstCo ~= nil then self:StopCoroutine(firstCo) end
    firstCo = OnModel1AnimationStarted()
    firstIntervals = {3, 3, 1, 13, 15} -- 前三个对应了场景1第一部分的三个特殊状态；第四个对应了场景1第一部分动画播完的时候；第五个对应了场景1第二部分动画播完的时候；
    firstTriggers = {'2Slip', '4Skew', '6Shrink'}
    self:StartCoroutine(firstCo)
end

function OnDisable() print("lua OnDisable...") end

function OnDestroy() print("lua OnDestroy") end

-- 控制语音1播放的时间
function OnModel1AnimationStarted()
    -- print(Auxiliary1:GetComponent('Transform'):GetChild(0).gameObject)
    return util.cs_generator(function()
        for i = 1, #firstIntervals do
            coroutine.yield(CS.UnityEngine.WaitForSeconds(firstIntervals[i]))

            -- 写逻辑的代码
            if i == 1 then
                Audio_1:SetActive(true) -- 语音在特定的时间播放
            elseif i <= 3 then
                Model1_Ani:SetTrigger(firstTriggers[i])
            elseif i == 4 then -- OnModel1AnimationFinished
                local sound = Audio_2:GetComponent('AudioSource')
                local soundIntervals = {2, 3, 15, 15}
                Model1:SetActive(false)
                Model2:SetActive(true)
                Tips_2:SetActive(false)
                for j = 1, 4 do
                    coroutine.yield(CS.UnityEngine.WaitForSeconds(
                                        soundIntervals[j]))
                    if j == 1 then -- j是1的时候不需要触发动画，其他需要触发动画
                        sound.clip = Audios_Model2[j]
                        sound:Play()
                    elseif j == 2 then -- j=2的时候不需要触发语音，其他需要
                        Model2_Ani:SetTrigger(labels[j + 3])
                    else
                        Model2_Ani:SetTrigger(labels[j + 3])
                        sound.clip = Audios_Model2[j - 1]
                        sound:Play()
                    end
                    -- 没有触发Start2
                end
            elseif i == 5 then -- OnModel2AnimationFinished

                for i = 0, 2 do
                    Tips_2:GetComponent('Transform'):GetChild(i).localScale =
                        Vector3.zero
                end
                Tips_2:SetActive(true)
                if sequence ~= nil then sequence:Kill() end
                sequence = DOTween.Sequence()

                for i = 0, 2 do
                    sequence:AppendInterval(.2)
                    sequence:AppendCallback(function()
                        Tips_2:GetComponent('Transform'):GetChild(i):DOScale(
                            Vector3.one * .1, .3):SetEase(Ease.Linear)
                    end)
                end

                enableClickPart = true
            end
        end
    end)
end

function EndCoroutine() end
