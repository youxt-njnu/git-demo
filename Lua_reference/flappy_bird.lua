local util = require 'xlua.util'

local UnityEngine = CS.UnityEngine
local Vector3 = CS.UnityEngine.Vector3
local Vector2 = CS.UnityEngine.Vector2
local UI = CS.UnityEngine.UI
local Time = CS.UnityEngine.Time
local DOTween = CS.DG.Tweening.DOTween
local Instantiate = CS.UnityEngine.GameObject.Instantiate
local ButtonClickedEvent = CS.UnityEngine.UI.Button.ButtonClickedEvent
local GameObject = CS.UnityEngine.GameObject

local direction = nil -- 构造一个方向，传递给鸟的位置并进行更新
local gravity = -9.8
local strength = 5
local spriteRenderer = nil -- 表示当前物体对应的精灵图
local sprites = nil -- 存储所有精灵图的table
local spriteIndex = 0 -- 记录当前精灵图对应的索引
local sequence = nil -- 用于player上鸟切换图片
local meshRenderer_background = nil -- 为了获取背景的材质，以实现背景移动
local meshRenderer_ground = nil -- 为了获取背景的材质，以实现背景移动
local animationSpeed_background = 0.05 -- 设置背景移动的速度
local animationSpeed_ground = 1 -- 设置地面移动的速度
local spawnRate = 1 -- 障碍物出现频率
local minHeight = -1 -- 障碍物出现的高度的限额
local maxHeight = 2
local seuence_spawn = nil -- 用于spawn上切换状态
local speed_pipes = 5 -- 管子移动的速度
local leftEdge = nil -- 用于判断屏幕左边缘
local score = 0 -- 表示得分
local clicked = false -- 表示游戏未开始
local collider_bird = false
local gb_hit = nil -- 表示碰撞到的pip的部位，所对应的物体
local scoreSpaceUp = nil -- 表示可以得分的范围
local scoreSpaceDown = nil -- 表示可以得分的范围
local stage = nil -- 表示碰撞的状态

math.randomseed(tostring(os.time()):reverse():sub(1, 6))

local cachedPipes = {} -- 存放所有生成的pipes的对象池

local isGameOver = false

function CachePipes(clone)
    -- 构建对象池
    local pipe = clone.transform

    local item = {}
    item.gameObject = clone
    item.top = pipe:Find('Top Pipe')
    item.bottom = pipe:Find('Bottom Pipe')
    item.scorezone = pipe:Find('Scoring Zone')

    return item
end

function Awake()
    print("lua Awake...")
    -- UnityEngine.Application.targetFrameRate = 60 --不需要设置，因为我们的应用里面已经是60了
    Pause()
end

function Start()
    print("lua Start...")
    leftEdge = UnityEngine.Camera.main:ScreenToWorldPoint(Vector3.zero).x - 1 -- 将屏幕点转换为世界坐标，并向左偏移1个单位（一般情况下1个单位就好）
end

-- 就是物体前面勾选了对应的脚本组件
function OnEnable()
    print("lua OnEnable...")
    -- 获取到对应的组件
    if spriteRenderer == nil then
        spriteRenderer = Bird:GetComponent('SpriteRenderer')
    end
    if meshRenderer_background == nil then
        meshRenderer_background = Background:GetComponent('MeshRenderer')
    end
    if meshRenderer_ground == nil then
        meshRenderer_ground = Ground:GetComponent('MeshRenderer')
    end

    if sprites == nil then sprites = {Sprites1, Sprites2, Sprites3} end
    RegisterButton(playBtn, PlayGame)
    collider_bird = Bird:GetComponent('CircleCollider2D')
    clicked = true
end

function Update()
    -- Input, KeyCode都是UnityEngine里的
    -- 空格和左键控制移动方向
    -- print(clicked)
    if clicked then
        if UnityEngine.Input.GetKeyDown(UnityEngine.KeyCode.Space) or
            UnityEngine.Input.GetMouseButtonDown(0) then
            direction = Vector3.up * strength
        end

        -- 移动端控制方向
        if UnityEngine.Input.touchCount > 0 then
            local touch = UnityEngine.Input.GetTouch(0)

            if touch.phase == UnityEngine.TouchPhase.Began then
                direction = Vector3.up * strength
            end
        end

        -- 根据direction来更新鸟的位置
        -- lua里面没有+=
        if (direction ~= nil) then
            direction.y = direction.y + gravity * Time.deltaTime -- 为鸟的重力gravity设置做准备
            Bird.transform.position = Bird.transform.position + direction *
                                          Time.deltaTime -- transform是鸟的，*Time.deltaTime can make frame rate independent no matter what the frame rate of your game, can be consistent
            -- gravity is an acceleration it's meters per second squared and so we specifically for gravity we actually want to multiply it both time 重力是一个加速度，它是米每二次方秒的，所以我们特别针对重力，我们实际上想要两次乘以时间，得到长度m
        end

        -- 更新背景图片的位置
        -- Vector2 type, The offset of the main texture.
        if meshRenderer_background ~= nil then
            meshRenderer_background.material.mainTextureOffset =
                meshRenderer_background.material.mainTextureOffset +
                    Vector2(animationSpeed_background * Time.deltaTime, 0)
        end
        if meshRenderer_ground ~= nil then
            meshRenderer_ground.material.mainTextureOffset =
                meshRenderer_ground.material.mainTextureOffset +
                    Vector2(animationSpeed_ground * Time.deltaTime, 0)
        end

        -- 如果超出了屏幕，设置为非激活状态
        if cachedPipes ~= nil then
            for i = 1, #cachedPipes do
                if cachedPipes[i].gameObject.activeSelf then -- activeSelf是gameObject的属性，而cachedPipes[i]是你自己定义的类
                    cachedPipes[i].gameObject.transform.position =
                        cachedPipes[i].gameObject.transform.position +
                            Vector3.left * speed_pipes * Time.deltaTime

                    -- 判断相撞
                    if cachedPipes[i].gameObject.transform.position.x > -0.1 and
                        cachedPipes[i].gameObject.transform.position.x < 0.1 then --
                        -- TODO: 遍历每一个pipes，获取到屏幕上距离鸟最近的那个pipes的部位,作为gb_hit
                        -- 根据中间得分区的位置来看
                        scoreSpaceUp = cachedPipes[i].scorezone.position.y + 1
                        scoreSpaceDown = cachedPipes[i].scorezone.position.y - 1
                        -- if Bird.transform.position.y < -3.2 then GameOver()
                        -- else
                        if Bird.transform.position.y > scoreSpaceDown and
                            Bird.transform.position.y < scoreSpaceUp then
                            -- gb_hit = cachedPipes[i].scorezone.gameObject
                            IncreaseScore()
                            -- elseif Bird.transform.position.y < scoreSpaceDown then
                            --     gb_hit = cachedPipes[i].bottom.gameObject
                            -- else gb_hit = cachedPipes[i].top.gameObject
                        elseif not isGameOver then
                            -- todo
                            isGameOver = true
                            if (sequence_spawn ~= nil) then
                                sequence_spawn:Kill()
                            end
                            GameOver()
                        end
                        -- stage = gb_hit.gameObject.name
                        -- -- OnTriggerEnter2DCollider(TriggerEnterFunc)
                        -- if(stage == 'Scoring Zone') then
                        --     IncreaseScore()
                        -- else GameOver()
                        -- end
                    end

                    -- 超出屏幕
                    if cachedPipes[i].gameObject.transform.position.x < leftEdge then
                        cachedPipes[i].gameObject:SetActive(false)
                    end

                end
            end

        end
    end

end

-- 也是物体前面没有勾选对应的脚本组件
function OnDisable()
    clicked = false
    sequence_spawn:Kill() -- 原来是CancelInvoke(nameof(Spawn))
end

function AnimateSprite()
    spriteIndex = spriteIndex + 1
    if (spriteIndex > #sprites) then spriteIndex = 1 end -- 从1开始
    spriteRenderer.sprite = sprites[spriteIndex]
    -- print(spriteIndex)
end

function Spawn()
    -- UnityEngine.GameObject.Find可以找到对应的预制体吗
    -- C#: Instantiate, 也就是object类里面的
    -- Lua: UnityEngine.GameObject.Instantiate
    if GetPipes() == nil then -- 都没有超出，生成新的
        local pipes = Instantiate(prefab, Spawner.transform.position,
                                  UnityEngine.Quaternion.identity) -- 初始化一个预制体
        pipes.transform.position = pipes.transform.position + Vector3.up *
                                       math.random(minHeight, maxHeight)
        -- print("height"..Vector3.up * Random.Range(minHeight, maxHeight))

        table.insert(cachedPipes, CachePipes(pipes))
    else -- 有超出的

        local pipes = GetPipes() -- 使用旧的
        -- 位置初始化
        pipes.gameObject.transform.position = Spawner.transform.position
        pipes.gameObject.transform.position =
            pipes.gameObject.transform.position + Vector3.up *
                math.random(minHeight, maxHeight)
        pipes.gameObject:SetActive(true)
    end

end

function GetPipes()
    -- 返回所有超出的pipes, 这些都是false
    if cachedPipes ~= nil and #cachedPipes > 0 then
        for i = 1, #cachedPipes do
            if not cachedPipes[i].gameObject.activeSelf then
                return cachedPipes[i]
            end
        end
    end
    return nil
end

function PlayGame()
    isGameOver = false
    clicked = true
    -- 得分
    score = 0
    scoreText.text = tostring(score)
    -- 隐藏
    playBtn.gameObject:SetActive(false)
    gameOver:SetActive(false)

    Time.timeScale = 1
    -- Player.enabled = true -- 表示脚本Player激活，这里不需要
    -- local pipes = GameObject.FindObjectsOfType('PipesNew') -- 不建议用这个

    -- for i = 0, pipes.Length - 1 do
    --     GameObject.Destory(pipes[i].gameObject)
    -- end

    if cachedPipes ~= nil and #cachedPipes > 0 then

        for i = #cachedPipes, 1, -1 do
            GameObject.DestroyImmediate(cachedPipes[i].gameObject)
        end
        cachedPipes = {}
    end

    -- 设置鸟的初始位置
    local position = Bird.transform.position
    position.y = 0
    Bird.transform.position = position
    direction = Vector3.zero

    -- Invokes the method methodName in time seconds, then repeatedly every repeatRate seconds. To cancel InvokeRepeating use MonoBehaviour.CancelInvoke.
    -- self:InvokeRepeating('AnimateSprite', 0.15, 0.15)
    -- sequence = DOTween.Sequence()
    -- sequence:SetDelay(5)
    if (sequence ~= nil) then sequence:Kill() end
    sequence = DOTween.Sequence()
    sequence:AppendCallback(AnimateSprite)
    sequence:AppendInterval(0.15)
    sequence:SetLoops(-1)

    -- 对应了spawn
    if (sequence_spawn ~= nil) then sequence_spawn:Kill() end
    sequence_spawn = DOTween.Sequence()
    sequence_spawn:AppendCallback(Spawn)
    sequence_spawn:AppendInterval(spawnRate)
    sequence_spawn:SetLoops(-1)

end

function GameOver()
    playBtn.gameObject:SetActive(true)
    gameOver:SetActive(true)
    Pause()
    clicked = false
end

function Pause()
    Time.timeScale = 0
    clicked = false
    -- Player.enabled = false
end

function IncreaseScore()
    score = score + 1
    scoreText.text = tostring(score)
end

function RegisterButton(btn, func)
    -- local bce = ButtonClickedEvent(func)
    btn.onClick:AddListener(func)
end

function TriggerEnterFunc()
    if gb_hit.CompareTag("Obstacle") then
        GameOver()
    elseif gb_hit.ComapreTag("Scoring") then
        IncreaseScore()
    end

end

-- 在Update里面，调用这个函数
function OnTriggerEnter2DCollider(func)
    -- 看是哪个部位碰到了bird,然后获取到这个部位的tag，根据tag判断游戏结束还是加分数
    local gb_hit_collider2D = gb_hit:GetComponent('BoxCollider2D')
    gb_hit_collider2D.OnTriggerEnter2D(collider_bird):AddListener(func)
end
