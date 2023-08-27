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

local parts = nil
local allPos = {}
local states = {}
local tips = {}

local enableClickPart = false

local curPart = nil
local curIndex = 0

local partCount = 7

function Awake() print("lua Awake...") end

function Start()
    print("lua Start...")
    -- 为按钮注册事件
    RegisterButton(openBtn, ClickOpenBtn)
    RegisterButton(closeBtn, ClickCloseBtn)
end

function Update()

    if not IsEditMode and
        UnityEngine.Input.GetKeyDown(UnityEngine.KeyCode.Mouse0) and
        enableClickPart then -- enableClickPart表示：true表示，接下来可以点击眼睛的部位了
        -- 获取点击的物体
        local ray = UnityEngine.Camera.main:ScreenPointToRay(UnityEngine.Input
                                                                 .mousePosition)

        local hits = UnityEngine.Physics.RaycastAll(ray)

        if hits.Length > 0 then

            for j = 0, hits.Length - 1 do

                -- print(hits[i].collider.gameObject.name)

                local hitObj = hits[j].collider.gameObject
                -- 判断是否点击了物体，
                for i = 1, partCount do
                    if hitObj == parts[i].gameObject then -- 通过parts进行判断
                        -- 点击部位不是现阶段展示的部位，更新current
                        if curPart ~= nil and curIndex > 0 and curPart ~=
                            parts[i] then
                            curPart:DOLocalMove(allPos[curIndex], .1):SetEase(
                                Ease.Linear) -- 移动到allPos存储的原始的位置
                            print('update:' .. parts[7].localPosition.y)
                            states[curIndex] = false -- 更新当前部位的状态
                            tips[curIndex]:SetActive(false) -- 更新当前部位的标签
                        end

                        -- 点击部位现在需要改变状态，下面的实现了点击展开和点击关闭两种情况 
                        states[i] = not states[i] -- 更新状态
                        local targetPos = states[i] and
                                              (allPos[i] + Vector3(0, 100, 0)) or
                                              allPos[i] -- 根据上面修改的状态确定这个部位最后的位置
                        print('updatenew:' .. parts[7].localPosition.y)
                        if not states[i] then -- 更新tip的状态
                            tips[i]:SetActive(false)
                        end

                        -- 移动到对应的位置并设置tip的状态
                        -- DOTween完成之后（onComplete）之后，设置标签显示
                        parts[i]:DOLocalMove(targetPos, .2):SetEase(
                            Ease.OutBounce).onComplete = function()
                            -- body
                            if states[i] then
                                tips[i]:SetActive(true)
                            end
                        end

                        -- 更新现在的部位
                        curPart = parts[i]
                        curIndex = i
                        -- 播放点击音效
                        clickSound:Play()
                        break -- 一次进入即可退出，因为一次只能点击一个
                    end
                end
                -- 判断是否点击了tip，
                for i = 1, partCount do
                    if hitObj == tips[i] then
                        -- 融合了展开和关闭两种情况
                        -- 获取动画组件，修改转换状态，设置音乐
                        local tipAnim = tips[i]:GetComponent('Animator')
                        local tipState = not tipAnim:GetBool('click')
                        tipAnim:SetBool('click', tipState)

                        clickSound:Play()

                        local tipSound = tips[i]:GetComponent('AudioSource')
                        if tipState then
                            tipSound:Play()
                        else
                            tipSound:Stop()
                        end
                        break -- 一次进入即可退出，因为一次只能点击一个
                    end
                end
            end
        end
    end
end

-- 一个游戏物体挂载的脚本中Awake、Start只会执行一次，当这个游戏物体被取消激活 再重新激活的时候，脚本中的Awake、Start都不会再重新执行，而OnEnable会重新在第一帧执行一次！
-- 执行顺序：Awake -> Start -> OnEnable
-- 针对的是脚本所挂的物体，实现重置
function OnEnable()
    print("lua OnEnable...")
    -- 先隐藏掉所有按钮
    openBtn.gameObject:SetActive(false)
    closeBtn.gameObject:SetActive(false)

    -- 部位、标签、初始位置、状态的初始化，并播放开始的音效
    if parts == nil then
        parts = {p1, p2, p3, p4, p5, p6, p7} -- 存放了对应部位的模型的transform属性
        tips = {tip1, tip2, tip3, tip4, tip5, tip6, tip7}
        -- 构建了allPos的表格来存储每个部位的原始位置
        for i = 1, partCount do
            table.insert(allPos, parts[i].localPosition)
        end
    end

    states = {false, false, false, false, false, false, false}

    for i = 1, partCount do
        parts[i].localPosition = allPos[i] -- 存在物体再次被激活的情况，所以要把部位本来的位置更新给物体，确保无误
        tips[i]:SetActive(false)
    end
    print('onEnable:' .. allPos[7])

    -- 三个状态记录变量
    enableClickPart = false
    curPart = nil
    curIndex = 0

    eyeballStartSound:Play()
end

function OnDisable() print("lua OnDisable...") end

function OnDestroy() print("lua OnDestroy") end

-- 下面三个函数：对应到了start open close三个animation clip的最后一帧开始执行，主要是设置按钮显隐和状态
function OnStartAnimationFinished() openBtn.gameObject:SetActive(true) end

function OnOpenAnimationFinished()
    -- body
    closeBtn.gameObject:SetActive(true)
    enableClickPart = true
end

function OnCloseAnimationFinished()
    -- body
    openBtn.gameObject:SetActive(true)
end

-- 下面两个函数：实现更新 动画、按钮、音乐；状态、位置、标签状态
function ClickOpenBtn()
    -- body
    animator:SetTrigger('Open')
    openBtn.gameObject:SetActive(false)
    clickSound:Play()
end

function ClickCloseBtn()
    -- body
    animator:SetTrigger('Close')
    closeBtn.gameObject:SetActive(false)
    -- 
    print('start' .. parts[7].localPosition.y)
    enableClickPart = false
    for i = 1, partCount do
        parts[i].localPosition = allPos[i] -- 位置数组初始化
        tips[i]:SetActive(false)
    end
    print('end' .. parts[7].localPosition.y)
    -- 
    clickSound:Play()
end

-- UGUI按钮注册
function RegisterButton(button, func)
    -- body
    local bce = ButtonClickedEvent()
    bce:AddListener(func)
    button.onClick = bce
end
