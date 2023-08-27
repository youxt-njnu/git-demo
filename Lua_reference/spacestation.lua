local UnityEngine = CS.UnityEngine;
local Color = UnityEngine.Color;
local isEnd = false
local MainObjIsEnd = false -- 主要物体——此处为space station，表示播放完了

function Awake()
    -- print("lua Awake...")

end

function Start()
    -- print("lua Start...")
end

function Update()
    if UnityEngine.Input.GetKeyDown(UnityEngine.KeyCode.Mouse0) then
        local ray = UnityEngine.Camera.main:ScreenPointToRay(UnityEngine.Input
                                                                 .mousePosition)
        local hits = UnityEngine.Physics.RaycastAll(ray)
        if hits.Length > 0 then
            for i = 0, hits.Length - 1 do
                local hitObj = hits[i].collider.gameObject
                if hitObj ~= nil and hitObj == Tip1_bg.gameObject then
                    ClickBg(Tip1_ani, Tip1_as, -38) -- 后期改这个表示了飞机旋转的角度
                    break
                end
                if hitObj ~= nil and hitObj == Tip2_bg.gameObject then
                    ClickBg(Tip2_ani, Tip2_as, -160)
                    break
                end
                if hitObj ~= nil and hitObj == Tip3_bg.gameObject then
                    ClickBg(Tip3_ani, Tip3_as, 90)
                    break
                end
                if hitObj ~= nil and hitObj == Tip4_bg.gameObject then
                    ClickBg(Tip4_ani, Tip4_as, 10)
                    break
                end
                if hitObj ~= nil and hitObj == Tip5_bg.gameObject then
                    ClickBg(Tip5_ani, Tip5_as, 0)
                    break
                end

            end
        end
    end
end

function ClickBg(ani, clip, rotateY)
    local flag = false -- 记录鼠标点击状态
    if ani == Tip1_ani then
        Tip1_ani:SetBool("click", Tip1_ani:GetBool("click") == false) -- 根据当前状态反向激活
        Tip2_ani:SetBool("click", false)
        Tip3_ani:SetBool("click", false)
        Tip4_ani:SetBool("click", false)
        Tip5_ani:SetBool("click", false)
        flag = Tip1_ani:GetBool("click")
    elseif ani == Tip2_ani then
        Tip1_ani:SetBool("click", false)
        Tip2_ani:SetBool("click", Tip2_ani:GetBool("click") == false)
        Tip3_ani:SetBool("click", false)
        Tip4_ani:SetBool("click", false)
        Tip5_ani:SetBool("click", false)
        flag = Tip2_ani:GetBool("click")
    elseif ani == Tip3_ani then
        Tip1_ani:SetBool("click", false)
        Tip2_ani:SetBool("click", false)
        Tip3_ani:SetBool("click", Tip3_ani:GetBool("click") == false)
        Tip4_ani:SetBool("click", false)
        Tip5_ani:SetBool("click", false)
        flag = Tip3_ani:GetBool("click")
    elseif ani == Tip4_ani then
        Tip1_ani:SetBool("click", false)
        Tip2_ani:SetBool("click", false)
        Tip3_ani:SetBool("click", false)
        Tip4_ani:SetBool("click", Tip4_ani:GetBool("click") == false)
        Tip5_ani:SetBool("click", false)
        flag = Tip4_ani:GetBool("click")
    elseif ani == Tip5_ani then
        Tip1_ani:SetBool("click", false)
        Tip2_ani:SetBool("click", false)
        Tip3_ani:SetBool("click", false)
        Tip4_ani:SetBool("click", false)
        Tip5_ani:SetBool("click", Tip5_ani:GetBool("click") == false)
        flag = Tip5_ani:GetBool("click")
    else
        Tip1_ani:SetBool("click", false)
        Tip2_ani:SetBool("click", false)
        Tip3_ani:SetBool("click", false)
        Tip4_ani:SetBool("click", false)
        Tip5_ani:SetBool("click", false)
    end

    bg_as:Stop() -- 停止背景音乐

    if flag then
        bg_as:PlayOneShot(clip) -- 播放特定段的音乐

        MainObj.transform:DOKill(); -- 一个移动动画序列
        MainObj.transform:DOLocalRotate(UnityEngine.Vector3(0, rotateY, 0), 1,
                                        CS.DG.Tweening.RotateMode.Fast)
    else
        MainObj.transform:DOLocalMoveY(0, 3):OnComplete(MainObjRotate)
    end

end

function MainObjRotate()
    MainObj.transform:DOKill();
    MainObj.transform:DOLocalRotate(UnityEngine.Vector3(0, 360, 0), 60,
                                    CS.DG.Tweening.RotateMode.FastBeyond360)
        :SetLoops(-1, CS.DG.Tweening.LoopType.Restart):SetEase(CS.DG.Tweening
                                                                   .Ease.Linear)
end

function OnEnable()
    MainObj.transform.localScale = UnityEngine.Vector3.zero
    MainObj.transform:DOScale(1, 2):SetEase(CS.DG.Tweening.Ease.OutBack)
        :SetAutoKill():OnComplete(MainObjRotate)
    -- 北斗挂着的音乐和动画开始播放
    if MainObjIsEnd == false then
        bg_as:Play()
        bg_ani:Play()
    end
end

function OnDisable() end

function OnDestroy()
    -- print("lua OnDestroy")
end
