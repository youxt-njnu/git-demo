local UnityEngine = CS.UnityEngine
local WidgetsManager = CS.Samuel.Widgets.WidgetsManager
local DOTween = CS.DG.Tweening.DOTween
local Vector3 = CS.UnityEngine.Vector3
local Ease = CS.DG.Tweening.Ease
local PlayerPrefs = CS.UnityEngine.PlayerPrefs
local ButtonClickedEvent = CS.UnityEngine.UI.Button.ButtonClickedEvent

local MessageBox = CS.Samuel.MessageBox
local UIMessageBoxWidgetsUniWebView = CS.Samuel.MessageBox
                                          .UIMessageBoxWidgetsUniWebView
local UIMessageBoxFullScreenMediaPlayer =
    CS.Samuel.MessageBox.UIMessageBoxFullScreenMediaPlayer

local UserMobile = CS.Samuel.User.UserModel.Instance.UserData.mobile
local HasLogin = CS.Samuel.User.UserModel.Instance.HasLogin

local CurrentTime = tostring(os.date("%Y-%m-%d %H:%M:%S"))

local Input = CS.UnityEngine.Input
local Touch = CS.UnityEngine.Touch

local startTime = nil
local intervalTime = .25

local bodyAnim = nil
local eyeAnim = nil

local eyeTrigger = nil
local jmBool = nil
local hmBool = nil
local tkBool = nil

local sequence = nil

local touch1 = nil
local touch2 = nil

local lastDistance = nil
local curDistance = nil

local isTouch1Moved = nil
local isTouch2Moved = nil

local isZoomUp = false

function Awake()
    print("lua Awake...")
    -- 直接获取到对应的动画组件，不用再界面拖进去了
    bodyAnim = body:GetComponent('Animator')
    eyeAnim = eye:GetComponent('Animator')
end

function Start() print("lua Start...") end

function Update()
    if EnableClick() then
        -- if true then
        if Input.touchCount > 0 then
            touch1 = Input.GetTouch(0)
            -- 获取单指移动状态
            if touch1.phase == UnityEngine.TouchPhase.Began then
                isTouch1Moved = false
            elseif touch1.phase == UnityEngine.TouchPhase.Moved then
                isTouch1Moved = true
            end

            -- 双指捏合，获取到第二个手指，判断是否移动，求解两指移动距离
            if Input.touchCount >= 2 then
                touch2 = Input.GetTouch(1)

                if touch2.phase == UnityEngine.TouchPhase.Began then
                    isTouch2Moved = false
                    lastDistance = UnityEngine.Vector2.Distance(touch1.position,
                                                                touch2.position)
                elseif touch2.phase == UnityEngine.TouchPhase.Moved then
                    isTouch2Moved = true
                    curDistance = UnityEngine.Vector2.Distance(touch1.position,
                                                               touch2.position)
                end
            end

            -- 表示点击事件
            if Input.touchCount == 1 and not isTouch1Moved and touch1.phase ==
                UnityEngine.TouchPhase.Ended then
                local ray = UnityEngine.Camera.main:ScreenPointToRay(
                                Input.mousePosition)
                -- 获取到点击到的RaycastHit,
                -- https://docs.unity3d.com/ScriptReference/RaycastHit.html
                local hits = UnityEngine.Physics.RaycastAll(ray)

                if hits.Length > 0 then

                    for i = 0, hits.Length - 1 do

                        print(hits[i].collider.gameObject.name)
                        -- collider是RaycastHit的属性，表示点击到的碰撞体
                        -- 之后，.gameObject才会得到物体
                        local hitObj = hits[i].collider.gameObject

                        -- body 为目标
                        if hitObj == body then
                            -- false and 'Close' or 'Open' -> 'Open'
                            -- true and 'Close' or 'Open' -> 'Close'
                            bodyTrigger =
                                (bodyTrigger == 'Open') and 'Close' or 'Open'
                            bodyAnim:SetTrigger(bodyTrigger)

                            break
                            -- eye为目标
                        elseif hitObj == eye then

                            eyeTrigger =
                                eyeTrigger == 'Open' and 'Close' or 'Open'

                            eyeAnim.speed = 4

                            eyeAnim:SetTrigger(eyeTrigger)
                            -- 播放声音
                            eyeSound:SetActive(false)
                            eyeSound:SetActive(true)

                            if eyeTrigger == 'Close' then
                                jmAnim.gameObject:SetActive(false)
                                tkAnim.gameObject:SetActive(false)
                                hmAnim.gameObject:SetActive(false)
                            else -- 播放三个动画
                                local sequence = DOTween.Sequence()
                                sequence:AppendInterval(.4)
                                sequence:AppendCallback(Anim_HM)
                                sequence:AppendInterval(.3)
                                sequence:AppendCallback(Anim_TK)
                                sequence:AppendInterval(.2)
                                sequence:AppendCallback(Anim_JM)
                            end

                            break
                            -- 三个小动画的设置
                        elseif hitObj.transform.parent.name == 'YJD_HM' then
                            hmBool = not hmBool
                            hmAnim:SetTrigger(hmBool and 'Open' or 'Close') -- hmBool true则播放，false则关闭
                            break
                        elseif hitObj.transform.parent.name == 'YJD_JM' then
                            jmBool = not jmBool
                            jmAnim:SetTrigger(jmBool and 'Open' or 'Close')
                            break
                        elseif hitObj.transform.parent.name == 'YJD_TK' then
                            tkBool = not tkBool
                            tkAnim:SetTrigger(tkBool and 'Open' or 'Close')
                            break
                        end
                    end
                end
            end
            -- 缩放
            if Input.touchCount >= 2 and (isTouch1Moved or isTouch2Moved) and
                (touch1.phase == UnityEngine.TouchPhase.Ended or touch2.phase ==
                    UnityEngine.TouchPhase.Ended) then
                if curDistance - lastDistance > 30 then -- 进行了放大，然后显示眼球相关的逻辑
                    if not isZoomUp then Zoom(true) end
                else
                    if isZoomUp then Zoom(false) end -- 进行了缩小，回归主体的逻辑
                end
            end
        end

        -- 新增
        if Input.GetMouseButtonDown(0) then
            local ray = UnityEngine.Camera.main:ScreenPointToRay(
                            Input.mousePosition)
            -- 获取到点击到的RaycastHit,
            -- https://docs.unity3d.com/ScriptReference/RaycastHit.html
            local hits = UnityEngine.Physics.RaycastAll(ray)

            if hits.Length > 0 then

                for i = 0, hits.Length - 1 do

                    -- print(hits[i].collider.gameObject.name)
                    -- collider是RaycastHit的属性，表示点击到的碰撞体
                    -- 之后，.gameObject才会得到物体
                    local hitObj = hits[i].collider.gameObject

                    -- body 为目标
                    if hitObj == body then
                        -- false and 'Close' or 'Open' -> 'Open'
                        -- true and 'Close' or 'Open' -> 'Close'
                        bodyTrigger = (bodyTrigger == 'Open') and 'Close' or
                                          'Open'
                        bodyAnim:SetTrigger(bodyTrigger)

                        break
                        -- eye为目标
                    elseif hitObj == eye then
                        -- 点击后切换状态，所以当眼球展开的时候，对应的eyeTrigger就是Close，这个时候也就不需要播放那三个动画
                        eyeTrigger = eyeTrigger == 'Open' and 'Close' or 'Open'

                        eyeAnim.speed = 4

                        eyeAnim:SetTrigger(eyeTrigger)
                        -- 播放声音
                        eyeSound:SetActive(false)
                        eyeSound:SetActive(true)

                        if eyeTrigger == 'Close' then
                            jmAnim.gameObject:SetActive(false)
                            tkAnim.gameObject:SetActive(false)
                            hmAnim.gameObject:SetActive(false)
                        else -- 播放三个动画
                            local sequence = DOTween.Sequence()
                            sequence:AppendInterval(.4)
                            sequence:AppendCallback(Anim_HM)
                            sequence:AppendInterval(.3)
                            sequence:AppendCallback(Anim_TK)
                            sequence:AppendInterval(.2)
                            sequence:AppendCallback(Anim_JM)
                        end

                        break
                        -- 三个小动画的设置
                    elseif hitObj.transform.parent.name == 'YJD_HM' then
                        -- print(hitObj.parent.name) -- 没有对着物体直接的parent,所以可能还是需要通过transform找父物体
                        hmBool = not hmBool
                        hmAnim:SetTrigger(hmBool and 'Open' or 'Close') -- hmBool true则播放，false则关闭
                        break
                    elseif hitObj.transform.parent.name == 'YJD_JM' then
                        jmBool = not jmBool
                        jmAnim:SetTrigger(jmBool and 'Open' or 'Close')
                        break
                    elseif hitObj.transform.parent.name == 'YJD_TK' then
                        tkBool = not tkBool
                        tkAnim:SetTrigger(tkBool and 'Open' or 'Close')
                        break
                    end
                end
            end
        end
    end

end

function Zoom(isUp)
    -- body

    isZoomUp = isUp

    if isUp then
        -- 缩放的时候显示眼球
        eye:SetActive(true)
        eye:GetComponent("BoxCollider").enabled = false
        eye.transform.localScale = Vector3.zero
        eyeAnim:SetTrigger('Closed')

        body.transform:DOScale(Vector3(.4, .4, .4), .3):SetEase(Ease.Linear)
            .onComplete = function()
            -- 主体放大了之后消失，显示眼球以及其逻辑
            body:SetActive(false)

            eyeSound:SetActive(false)
            eyeSound:SetActive(true)

            eye.transform:DOScale(Vector3(.05, .05, .05), .2):SetEase(
                Ease.Linear):SetDelay(.2).onComplete = function()
                eye:GetComponent("BoxCollider").enabled = true
                eyeTrigger = 'Open'
                eyeAnim.speed = 4
                eyeAnim:SetTrigger(eyeTrigger)

                local sequence = DOTween.Sequence()
                sequence:AppendInterval(.4)
                sequence:AppendCallback(Anim_HM)
                sequence:AppendInterval(.3)
                sequence:AppendCallback(Anim_TK)
                sequence:AppendInterval(.2)
                sequence:AppendCallback(Anim_JM)
            end
        end
    else
        jmAnim.gameObject:SetActive(false)
        tkAnim.gameObject:SetActive(false)
        hmAnim.gameObject:SetActive(false)
        eye.transform:DOScale(Vector3.zero, .2):SetEase(Ease.Linear).onComplete =
            function()

                eyeAnim:SetTrigger('Closed')

                body:SetActive(true)
                body:GetComponent("BoxCollider").enabled = false
                body.transform.localScale = Vector3(.4, .4, .4)

                body.transform:DOScale(Vector3(.2, .2, .2), .3)
                    :SetEase(Ease.Linear).onComplete = function()
                    -- body
                    eye:SetActive(false)
                    body:GetComponent("BoxCollider").enabled = true
                end
            end
    end
end

-- 三个眼球介绍相关的动画，设置物体完全激活后，开始播放
function Anim_HM()
    hmAnim.gameObject:SetActive(false)
    hmAnim.gameObject:SetActive(true)
    hmBool = false
    hmAnim:SetTrigger('Start')
end

function Anim_TK()
    -- body
    tkAnim.gameObject:SetActive(false)
    tkAnim.gameObject:SetActive(true)
    tkBool = false
    tkAnim:SetTrigger('Start')
end

function Anim_JM()
    jmAnim.gameObject:SetActive(false)
    jmAnim.gameObject:SetActive(true)
    jmBool = false
    jmAnim:SetTrigger('Start')
end

-- UniWebview打开链接
function OpenUrl(url)
    -- body
    UIMessageBoxWidgetsUniWebView.Show("", url, nil)
end

-- 编辑模式不触发按钮
function EnableClick()
    if WidgetsManager.Instance and WidgetsManager.Instance.IsEditMode then
        return false
    end

    return true
end

function OnEnable()
    print("lua OnEnable...")

    Reset()
    -- Reset2()
end

function Reset() --
    -- body

    --  显示身体，不显示眼睛
    body:SetActive(true)
    eye:SetActive(false)

    -- 播放身体展开动画
    bodyTrigger = 'Open'

    bodyAnim:SetTrigger(bodyTrigger)

    -- 无缩放、三个动画和音效
    isZoomUp = false

    jmAnim.gameObject:SetActive(false)
    tkAnim.gameObject:SetActive(false)
    hmAnim.gameObject:SetActive(false)

    eyeSound:SetActive(false)
end

function Reset2()
    body:SetActive(false)
    eye:SetActive(true)

    eyeTrigger = 'Open'
    eyeAnim.speed = 4
    eyeAnim:SetTrigger(eyeTrigger)

    -- 无缩放、三个动画和音效
    isZoomUp = false

    -- 慢慢播放出三个标签的动画
    local sequence = DOTween.Sequence()
    sequence:AppendInterval(.4)
    sequence:AppendCallback(Anim_HM)
    sequence:AppendInterval(.3)
    sequence:AppendCallback(Anim_TK)
    sequence:AppendInterval(.2)
    sequence:AppendCallback(Anim_JM)

    eyeSound:SetActive(true)
end
-- 加载数据
function LoadData()
    -- body
    local record_string = PlayerPrefs.GetString(RECORD_KEY)

    print(record_string)

    if #record_string <= 0 then
        record = {0, 0, 0, 0, 0, 0}
        print("没有记录")
    else
        print("读取到记录")
        record = Split(record_string, ",")
    end
end

-- 保存记录
function SaveRecord()
    PlayerPrefs.SetString(RECORD_KEY, table.concat(record, ","))
end

-- 全屏播放视频
function FullScreenPlayMedia(media, cover)
    UIMessageBoxFullScreenMediaPlayer.Show(media, cover, true, nil,
                                           MessageBox.BoxButtonType.None)
end

-- 停止扫描
function StopScaning() CS.ScanLoadingController.Instance:PauseScan() end

-- 字符串分割
function Split(str, delim, maxNb)
    -- Eliminate bad cases...
    if string.find(str, delim) == nil then return {str} end
    if maxNb == nil or maxNb < 1 then
        maxNb = 0 -- No limit
    end
    local result = {}
    local pat = "(.-)" .. delim .. "()"
    local nb = 0
    local lastPos
    for part, pos in string.gmatch(str, pat) do
        nb = nb + 1
        result[nb] = tonumber(part)
        lastPos = pos
        if nb == maxNb then break end
    end
    -- Handle the last field
    if nb ~= maxNb then result[nb + 1] = tonumber(string.sub(str, lastPos)) end
    return result
end

function Login()
    -- body
    if not HasLogin then CS.Samuel.MessageBox.UIMessageBoxLogin.Show() end
end

function RegisterButton(button, func)
    -- body
    local bce = ButtonClickedEvent()
    bce:AddListener(func)
    button.onClick = bce
end

function OnDisable() print("lua OnDisable...") end

function OnDestroy()
    -- print("lua OnDestroy")
end

