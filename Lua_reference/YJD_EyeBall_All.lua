local util = require 'xlua.util'

local UnityEngine = CS.UnityEngine
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

local parts = nil
local allPos = {}
local states = {}
local tips = {}

local titles = {}
local titleList = {}
local sequence = nil

local enableClickPart = false
local partAnimFinish = true

local curPart = nil
local curIndex = 0

local partCount = 7
local BtnState = nil -- 表示所处的子界面是哪个

-- StartPart里的三个按钮
local RecoginizeEyesBtn = nil
local EyeDevelopmentBtn = nil
local RefractiveErrorBtn = nil
-- Auxiliary1里的按钮和音频
local openBtn = nil
local closeBtn = nil
local eyeballStartSound = nil
-- Auxiliary2里的按钮和音频
local Yrs3Btn = nil
local Yrs6Btn = nil
local Yrs12Btn = nil
local DevelopSound = nil
-- Auxiliary3相关
local Btns = nil -- 表示屈光不正那边的二级按钮
local sound = nil -- 表示第二部分和第三部分的按钮点击后出现的声音
local Videos = nil -- 表示屈光不正那边的视频

local balls = {}
local firstCo = nil

function Awake() print("lua Awake...") end

function Start()
    print("lua Start...")
    -- StartPart
    RecoginizeEyesBtn = StartPart:GetChild(0)
    EyeDevelopmentBtn = StartPart:GetChild(1)
    RefractiveErrorBtn = StartPart:GetChild(2)
    -- 一开始为未选中的状态
    RecoginizeEyesBtn:GetChild(1).gameObject:SetActive(false)
    EyeDevelopmentBtn:GetChild(1).gameObject:SetActive(false)
    RefractiveErrorBtn:GetChild(1).gameObject:SetActive(false)
    -- 挂在点击事件
    RegisterButton(RecoginizeEyesBtn:GetComponent('Button'), ClickBtn1)
    RegisterButton(EyeDevelopmentBtn:GetComponent('Button'), ClickBtn2)
    RegisterButton(RefractiveErrorBtn:GetComponent('Button'), ClickBtn3)

    -- Auxiliary1
    openBtn = Auxiliary1:GetComponent('Transform'):GetChild(0) -- transform类型
    closeBtn = Auxiliary1:GetComponent('Transform'):GetChild(1) -- transform类型
    eyeballStartSound = Auxiliary1:GetComponent('Transform'):GetChild(2)
                            :GetComponent('AudioSource')

    RegisterButton(openBtn:GetComponent('Button'), ClickOpenBtn)
    RegisterButton(closeBtn:GetComponent('Button'), ClickCloseBtn)

    -- Auxiliary2
    Yrs3Btn = Auxiliary2:GetComponent('Transform'):GetChild(1) -- transform类型
    Yrs6Btn = Auxiliary2:GetComponent('Transform'):GetChild(2) -- transform类型
    Yrs12Btn = Auxiliary2:GetComponent('Transform'):GetChild(3) -- transform类型
    DevelopSound = Auxiliary2:GetComponent('Transform'):GetChild(4)
                       :GetComponent('AudioSource')
    RegisterButton(Yrs3Btn:GetComponent('Button'), Click3Btn)
    RegisterButton(Yrs6Btn:GetComponent('Button'), Click6Btn)
    RegisterButton(Yrs12Btn:GetComponent('Button'), Click12Btn)

    balls = {ball1, ball2, ball3}
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

                print(hits[j].collider.gameObject.name)

                local hitObj = hits[j].collider.gameObject
                -- 进入了认识眼睛的子界面
                if BtnState == 1 then
                    -- 判断是否点击了物体，
                    for i = 1, partCount do
                        if hitObj == parts[i].gameObject then -- 通过parts进行判断

                            if not partAnimFinish then
                                break
                            end

                            partAnimFinish = false

                            -- 点击部位不是现阶段展示的部位，更新current
                            if curPart ~= nil and curIndex > 0 and curPart ~=
                                parts[i] then
                                local lastTitle = titleList[curIndex]
                                local extraTitle = nil
                                if curIndex == 7 then
                                    extraTitle = titles[2]
                                end

                                print('lastTitle -> ' ..
                                          lastTitle.gameObject.name)

                                print('old part -> ' .. curPart.gameObject.name)

                                curPart:DOLocalMove(allPos[curIndex], .1)
                                    :SetEase(Ease.Linear).onComplete =
                                    function()
                                        lastTitle.transform:DOScale(
                                            Vector3.one * .0006, .3):SetEase(
                                            Ease.Linear)
                                        if extraTitle then
                                            extraTitle.transform:DOScale(
                                                Vector3.one * 0.0006, .3)
                                                :SetEase(Ease.Linear)
                                        end
                                    end
                                -- print('update:' .. parts[7].localPosition.y)
                                states[curIndex] = false -- 更新当前部位的状态
                                tips[curIndex]:SetActive(false) -- 更新当前部位的标签
                            end

                            curPart = parts[i]
                            curIndex = i

                            print('new part -> ' .. curPart.gameObject.name)

                            -- 点击部位现在需要改变状态，下面的实现了点击展开和点击关闭两种情况
                            states[i] = not states[i] -- 更新状态
                            local targetPos = states[i] and
                                                  (allPos[i] +
                                                      Vector3(0, 100, 0)) or
                                                  allPos[i] -- 根据上面修改的状态确定这个部位最后的位置
                            -- print('updatenew:' .. parts[7].localPosition.y)
                            if not states[i] then -- 更新tip的状态
                                tips[i]:SetActive(false)
                            else
                                titleList[curIndex].transform.localScale =
                                    Vector3.zero

                                if curIndex == 7 then
                                    titles[2].transform.localScale =
                                        Vector3.zero
                                end
                            end

                            -- 移动到对应的位置并设置tip的状态
                            -- DOTween完成之后（onComplete）之后，设置标签显示
                            parts[i]:DOLocalMove(targetPos, .5):SetEase(
                                Ease.Linear).onComplete = function()
                                -- body
                                if states[i] then
                                    tips[i]:SetActive(true)
                                    local tipAnim =
                                        tips[i]:GetComponent('Animator')
                                    tipAnim:SetBool('click', true)
                                    local tipSound =
                                        tips[i]:GetComponent('AudioSource')
                                    tipSound:Play()
                                else
                                    titleList[curIndex].transform:DOScale(
                                        Vector3.one * .0006, .3):SetEase(
                                        Ease.Linear)

                                    if curIndex == 7 then
                                        titles[2].transform:DOScale(
                                            Vector3.one * .0006, .3):SetEase(
                                            Ease.Linear)
                                    end
                                end

                                partAnimFinish = true
                            end

                            -- 播放点击音效
                            clickSound:Play()
                            hited = true
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
                            hited = true
                            break -- 一次进入即可退出，因为一次只能点击一个
                        end
                    end

                    if hited then break end
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
    -- 先隐藏掉按钮
    Auxiliary1:SetActive(false)
    Auxiliary2:SetActive(false)
    Auxiliary3:SetActive(false)

    -- 部位、标签、初始位置、状态的初始化，并播放开始的音效
    if parts == nil then
        parts = {p1, p2, p3, p4, p5, p6, p7} -- 存放了对应部位的模型的transform属性
        tips = {
            Tips1:GetComponent('Transform'):GetChild(5).gameObject,
            Tips1:GetComponent('Transform'):GetChild(6).gameObject,
            Tips1:GetComponent('Transform'):GetChild(4).gameObject,
            Tips1:GetComponent('Transform'):GetChild(1).gameObject,
            Tips1:GetComponent('Transform'):GetChild(2).gameObject,
            Tips1:GetComponent('Transform'):GetChild(3).gameObject,
            Tips1:GetComponent('Transform'):GetChild(0).gameObject
        }
        titles = {
            TGroup:GetComponent('Transform'):GetChild(0).gameObject,
            TGroup:GetComponent('Transform'):GetChild(1).gameObject,
            TGroup:GetComponent('Transform'):GetChild(6).gameObject,
            TGroup:GetComponent('Transform'):GetChild(7).gameObject,
            TGroup:GetComponent('Transform'):GetChild(2).gameObject,
            TGroup:GetComponent('Transform'):GetChild(5).gameObject,
            TGroup:GetComponent('Transform'):GetChild(3).gameObject,
            TGroup:GetComponent('Transform'):GetChild(4).gameObject
        }
        titleList = {
            titles[3], titles[4], titles[5], titles[6], titles[7], titles[8],
            titles[1]
        }
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

    for i = 1, 8 do titles[i].transform.localScale = Vector3.zero end
    -- 三个状态记录变量
    enableClickPart = false
    curPart = nil
    curIndex = 0

    -- Auxiliary3
    local labels = nil
    if Btns == nil then
        Btns = {
            Auxiliary3:GetComponent('Transform'):GetChild(1):GetComponent(
                'Button'),
            Auxiliary3:GetComponent('Transform'):GetChild(2)
                :GetComponent('Button'),
            Auxiliary3:GetComponent('Transform'):GetChild(3)
                :GetComponent('Button'),
            Auxiliary3:GetComponent('Transform'):GetChild(4)
                :GetComponent('Button'),
            Auxiliary3:GetComponent('Transform'):GetChild(5)
                :GetComponent('Button'),
            Auxiliary3:GetComponent('Transform'):GetChild(6)
                :GetComponent('Button'),
            Auxiliary3:GetComponent('Transform'):GetChild(7)
                :GetComponent('Button')
        }
        labels = {'AM', 'AH', 'CM', 'CH', 'SanGuang'}

        -- 设置为未选中状态
        for i = 1, #Btns do
            Btns[i].gameObject:GetComponent('Transform'):GetChild(1).gameObject:SetActive(
                false)

            if i <= 5 then
                local bce = ButtonClickedEvent()
                bce:AddListener(function()
                    -- 点击音频和解说音频播放
                    clickSound:Play()
                    if sound then sound:Stop() end
                    sound = Btns[i].gameObject:GetComponent('AudioSource')
                    sound:Play()
                    -- 触发动画
                    -- print(labels[i])
                    a3:SetTrigger(labels[i])
                    -- 设置选中状态
                    for j = 1, 5 do
                        Btns[j].gameObject:GetComponent('Transform'):GetChild(1)
                            .gameObject:SetActive(i == j)
                    end

                    if i == 2 then
                        tree1_3.transform.localScale = Vector3.one
                    end

                    if i == 1 then
                        Btns[6].gameObject:SetActive(true)
                        RegisterButton(Btns[6], ClickComplicationBtn)
                    else
                        Btns[6].gameObject:SetActive(false)
                    end
                    Btns[7].gameObject:SetActive(true)
                    RegisterButton(Btns[7], ClickSolutionBtn)
                end)
                Btns[i].onClick = bce
            end
        end

        Videos = {
            Auxiliary3:GetComponent('Transform'):GetChild(8):GetComponent(
                'VideoPlayer')
        }
    end
end

function OnDisable() print("lua OnDisable...") end

function OnDestroy() print("lua OnDestroy") end

local firstInterval = 1

-- 下面三个函数：对应到了start open close三个animation clip的最后一帧开始执行，主要是设置按钮显隐和状态
function OnStartAnimationFinished()
    -- print(Auxiliary1:GetComponent('Transform'):GetChild(0).gameObject)

    return util.cs_generator(function()
        coroutine.yield(CS.UnityEngine.WaitForSeconds(firstInterval))
        -- openBtn.gameObject:SetActive(true)
        Auxiliary1:GetComponent('Transform'):GetChild(0).gameObject:SetActive(
            true)
    end)
end

function OnOpenAnimationFinished()

    return util.cs_generator(function()
        coroutine.yield(CS.UnityEngine.WaitForSeconds(firstInterval))
        -- closeBtn.gameObject:SetActive(true)
        Auxiliary1:GetComponent('Transform'):GetChild(1).gameObject:SetActive(
            true)
        enableClickPart = true
        partAnimFinish = true
    end)
end

function OnCloseAnimationFinished()

    return util.cs_generator(function()
        coroutine.yield(CS.UnityEngine.WaitForSeconds(firstInterval))

        Auxiliary1:GetComponent('Transform'):GetChild(0).gameObject:SetActive(
            true)
    end)
end

-- 下面两个函数：实现更新 动画、按钮、音乐；状态、位置、标签状态
function ClickOpenBtn()
    a1:SetTrigger('Open')
    openBtn.gameObject:SetActive(false)
    clickSound:Play()

    if sequence ~= nil then sequence:Kill() end
    sequence = DOTween.Sequence()

    for i = 1, 8 do
        sequence:AppendInterval(.2)
        sequence:AppendCallback(function()
            titles[i].transform:DOScale(Vector3.one * .0006, .3):SetEase(
                Ease.Linear)
        end)
    end

    sequence:SetDelay(2)

    if firstCo ~= nil then self:StopCoroutine(firstCo) end

    firstCo = OnOpenAnimationFinished()
    firstInterval = 2.7
    self:StartCoroutine(firstCo)
end

function EndCoroutine() end

function ClickCloseBtn()
    a1:SetTrigger('Close')
    closeBtn.gameObject:SetActive(false)
    --
    enableClickPart = false
    for i = 1, partCount do
        parts[i].localPosition = allPos[i] -- 位置数组初始化
        tips[i]:SetActive(false)
    end
    --
    clickSound:Play()
    for i = 1, 8 do titles[i].transform.localScale = Vector3.zero end

    if firstCo ~= nil then self:StopCoroutine(firstCo) end

    firstCo = OnCloseAnimationFinished()
    firstInterval = 2.3
    self:StartCoroutine(firstCo)
end

-- 认识眼睛
function ClickBtn1()
    SelectMode(1)
    BtnState = 1
    clickSound:Play()
    ball3_UI:SetActive(false)
    Videos[1]:Stop()
    -- StartPart.gameObject:SetActive(false)
    Auxiliary1:SetActive(true)
    Auxiliary2:SetActive(false)
    Auxiliary3:SetActive(false)
    Tips1:SetActive(true)
    TGroup:SetActive(true)

    for i = 1, partCount do tips[i]:SetActive(false) end
    for i = 1, #titles do titles[i].transform.localScale = Vector3.zero end
    if DevelopSound then DevelopSound:Stop() end
    balls[1].transform:DOLocalRotate(UnityEngine.Vector3(0, 90, 0), 1,
                                     CS.DG.Tweening.RotateMode.Fast)
    a1:SetBool('Idle', false)
    a1:SetTrigger('Start')
    RecoginizeEyesBtn:GetChild(1).gameObject:SetActive(true)
    EyeDevelopmentBtn:GetChild(1).gameObject:SetActive(false)
    RefractiveErrorBtn:GetChild(1).gameObject:SetActive(false)
    openBtn.gameObject:SetActive(false)
    closeBtn.gameObject:SetActive(false)
    eyeballStartSound:Play()

    if firstCo ~= nil then self:StopCoroutine(firstCo) end

    firstCo = OnStartAnimationFinished()
    firstInterval = 3
    self:StartCoroutine(firstCo)

end

-- 眼球发育
function ClickBtn2()
    SelectMode(2)
    BtnState = 2
    clickSound:Play()
    RightHalf2:SetActive(false)
    ball3_UI:SetActive(false)
    Videos[1]:Stop()
    -- StartPart.gameObject:SetActive(false)
    Auxiliary1:SetActive(false)
    Auxiliary2:SetActive(true)
    Auxiliary3:SetActive(false)
    Tips1:SetActive(false)
    TGroup:SetActive(false)
    RecoginizeEyesBtn:GetChild(1).gameObject:SetActive(false)
    EyeDevelopmentBtn:GetChild(1).gameObject:SetActive(true)
    RefractiveErrorBtn:GetChild(1).gameObject:SetActive(false)
    balls[2].transform:DOLocalRotate(UnityEngine.Vector3(0, 180, 0), 1,
                                     CS.DG.Tweening.RotateMode.Fast)
    Yrs3Btn.gameObject:SetActive(false)
    Yrs6Btn.gameObject:SetActive(false)
    Yrs12Btn.gameObject:SetActive(false)
    a2:SetBool('Idle', false)
    a2:SetTrigger('DevelopmentAll')
    balls[2].transform:DOLocalRotate(UnityEngine.Vector3(0, 180, 0), 1,
                                     CS.DG.Tweening.RotateMode.Fast)
    if DevelopSound then DevelopSound:Stop() end
    DevelopSound = Auxiliary2:GetComponent('Transform'):GetChild(4)
                       :GetComponent('AudioSource')
    DevelopSound:Play()

    ball2_UI_Anim.gameObject:SetActive(true)
    ball2_UI_Anim:SetTrigger('All')

    if firstCo ~= nil then self:StopCoroutine(firstCo) end

    firstCo = OnEyeDevelopmentAnimationFinished()
    firstInterval = 50 -- 这里是语音播放到过度透支的前面一句
    self:StartCoroutine(firstCo)
end

-- 眼球发育那边先播完眼球发育过程再显示那些UI
function OnEyeDevelopmentAnimationFinished()

    return util.cs_generator(function()
        coroutine.yield(CS.UnityEngine.WaitForSeconds(firstInterval))
        a2:SetTrigger('Over')

        coroutine.yield(CS.UnityEngine.WaitForSeconds(11))

        Yrs3Btn.gameObject:SetActive(true)
        Yrs6Btn.gameObject:SetActive(true)
        Yrs12Btn.gameObject:SetActive(true)

        Yrs3Btn:GetChild(0).gameObject:SetActive(true)
        Yrs6Btn:GetChild(0).gameObject:SetActive(true)
        Yrs12Btn:GetChild(0).gameObject:SetActive(true)
        Yrs3Btn:GetChild(1).gameObject:SetActive(false)
        Yrs6Btn:GetChild(1).gameObject:SetActive(false)
        Yrs12Btn:GetChild(1).gameObject:SetActive(false)
    end)
end

-- 屈光不正那边先播完眼球成像原理再显示那些UI
function OnNormalImagingAnimationFinished()

    return util.cs_generator(function()
        coroutine.yield(CS.UnityEngine.WaitForSeconds(firstInterval))

        for i = 1, #Btns do Btns[i].gameObject:SetActive(true) end
        Btns[6].gameObject:SetActive(false) -- 并发症的按钮只需要在轴性近视那边显示就行
        Btns[7].gameObject:SetActive(false) -- 解决方案的按钮只需要在右边按钮点击后显示就行
    end)
end

-- 屈光不正
function ClickBtn3()
    SelectMode(3)
    BtnState = 3
    clickSound:Play()
    Videos[1]:Stop()
    -- StartPart.gameObject:SetActive(false)
    Auxiliary1:SetActive(false)
    Auxiliary2:SetActive(false)

    Auxiliary3:SetActive(true)
    for i = 1, #Btns do Btns[i].gameObject:SetActive(false) end
    for i = 1, #Videos do Videos[i].gameObject:SetActive(false) end

    Tips1:SetActive(false)
    TGroup:SetActive(false)
    if DevelopSound then DevelopSound:Stop() end
    RecoginizeEyesBtn:GetChild(1).gameObject:SetActive(false)
    EyeDevelopmentBtn:GetChild(1).gameObject:SetActive(false)
    RefractiveErrorBtn:GetChild(1).gameObject:SetActive(true)
    balls[3].transform:DOLocalRotate(UnityEngine.Vector3(0, 180, 0), 1,
                                     CS.DG.Tweening.RotateMode.Fast)
    ball3_UI:SetActive(true)
    a3:SetBool('Idle', false)
    a3:SetTrigger('NormalImaging')
    sound = Auxiliary3:GetComponent('Transform'):GetChild(0):GetComponent(
                'AudioSource')
    sound:Play()

    RightHalf3:SetActive(false)
    jinzhuangti3:SetActive(false)

    if firstCo ~= nil then self:StopCoroutine(firstCo) end

    firstCo = OnNormalImagingAnimationFinished()
    firstInterval = 21.48
    self:StartCoroutine(firstCo)

end

function SelectMode(mode)
    for i = 1, #balls do
        -- print(balls[i].name)
        balls[i]:SetActive(i == mode)
    end
end

function Click3Btn()
    clickSound:Play()
    if DevelopSound then DevelopSound:Stop() end
    DevelopSound = Yrs3Btn:GetComponent('AudioSource')
    DevelopSound:Play()
    a2:SetTrigger('yrs3')
    Yrs3Btn:GetChild(0).gameObject:SetActive(false)
    Yrs6Btn:GetChild(0).gameObject:SetActive(true)
    Yrs12Btn:GetChild(0).gameObject:SetActive(true)
    Yrs3Btn:GetChild(1).gameObject:SetActive(true)
    Yrs6Btn:GetChild(1).gameObject:SetActive(false)
    Yrs12Btn:GetChild(1).gameObject:SetActive(false)

    ball2_UI_Anim.gameObject:SetActive(true)
    ball2_UI_Anim:SetTrigger('3')
    RightHalf2:SetActive(false)
end

function Click6Btn()
    clickSound:Play()
    if DevelopSound then DevelopSound:Stop() end
    DevelopSound = Yrs6Btn:GetComponent('AudioSource')
    DevelopSound:Play()
    a2:SetTrigger('yrs6')
    Yrs3Btn:GetChild(0).gameObject:SetActive(true)
    Yrs6Btn:GetChild(0).gameObject:SetActive(false)
    Yrs12Btn:GetChild(0).gameObject:SetActive(true)
    Yrs3Btn:GetChild(1).gameObject:SetActive(false)
    Yrs6Btn:GetChild(1).gameObject:SetActive(true)
    Yrs12Btn:GetChild(1).gameObject:SetActive(false)

    ball2_UI_Anim.gameObject:SetActive(true)
    ball2_UI_Anim:SetTrigger('6')
    RightHalf2:SetActive(false)
end

function Click12Btn()
    clickSound:Play()
    if DevelopSound then DevelopSound:Stop() end
    DevelopSound = Yrs12Btn:GetComponent('AudioSource')
    DevelopSound:Play()
    a2:SetTrigger('yrs12')
    Yrs3Btn:GetChild(0).gameObject:SetActive(true)
    Yrs6Btn:GetChild(0).gameObject:SetActive(true)
    Yrs12Btn:GetChild(0).gameObject:SetActive(false)
    Yrs3Btn:GetChild(1).gameObject:SetActive(false)
    Yrs6Btn:GetChild(1).gameObject:SetActive(false)
    Yrs12Btn:GetChild(1).gameObject:SetActive(true)

    ball2_UI_Anim.gameObject:SetActive(true)
    ball2_UI_Anim:SetTrigger('12')
    RightHalf2:SetActive(false)
end

function ClickComplicationBtn()
    ball3:SetActive(false)
    for i = 1, 5 do Btns[i].gameObject:SetActive(false) end
    Videos[1].gameObject:SetActive(true)
    Videos[1]:Play()

end

function ClickSolutionBtn()
    ball3:SetActive(false)
    for i = 1, 5 do Btns[i].gameObject:SetActive(false) end
    Videos[1]:Stop()
end

-- UGUI按钮注册
function RegisterButton(button, func)
    -- body
    -- local bce = ButtonClickedEvent()
    -- bce:AddListener(func)
    -- button.onClick = bce
    button.onClick:AddListener(func)
end
