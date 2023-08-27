local UnityEngine = CS.UnityEngine
local Tilemaps = CS.UnityEngine.Tilemaps
local Vector2Int = UnityEngine.Vector2Int

-- 枚举类型的实现
local Tetromino = {'I', 'O', 'T', 'J', 'L', 'S', 'Z'}

function CreateEnum(tal, index)
    local eTable = {}
    local enumIndex = index or 0
    for i, v in ipairs(tal) do eTable[v] = enumIndex + i end
    return eTable
end
Tetromino = CreateEnum(Tetromino)

-- Tetrominoes类的实现
local Tetrominoes = {}
local m_Tetrominoes = {
    __index = {
        tile = nil,
        tetromino = nil,
        cells = {},
        wallKicks = {},
        Initialize = function()
            cells = Data.Cells[tetromino]
            wallKicks = Data.WallKicks[tetromino]
        end
    }
}

setmetatable(Tetrominoes, m_Tetrominoes)

Tetrominoes[Tetromino.I] = Cyan
Tetrominoes[Tetromino.O] = Yellow
Tetrominoes[Tetromino.T] = Puple
Tetrominoes[Tetromino.J] = Blue
Tetrominoes[Tetromino.L] = Orange
Tetrominoes[Tetromino.S] = Green
Tetrominoes[Tetromino.Z] = Red

-- Data类的实现
local Data = {}
local m_Data = {
    __index = {
        cos = math.cos(math.pi / 2.0),
        sin = math.sin(math.pi / 2.0),
        RotationMatrix = {cos, sin, sin, cos},
        Cells = {
            [Tetromino.I] = {
                Vector2Int(-1, 1), Vector2Int(0, 1), Vector2Int(1, 1),
                Vector2Int(2, 1)
            },
            [Tetromino.J] = {
                Vector2Int(-1, 1), Vector2Int(-1, 0), Vector2Int(0, 0),
                Vector2Int(1, 0)
            },
            [Tetromino.L] = {
                Vector2Int(1, 1), Vector2Int(-1, 0), Vector2Int(0, 0),
                Vector2Int(1, 0)
            },
            [Tetromino.O] = {
                Vector2Int(0, 1), Vector2Int(1, 1), Vector2Int(0, 0),
                Vector2Int(1, 0)
            },
            [Tetromino.S] = {
                Vector2Int(0, 1), Vector2Int(1, 1), Vector2Int(-1, 0),
                Vector2Int(0, 0)
            },
            [Tetromino.T] = {
                Vector2Int(0, 1), Vector2Int(-1, 0), Vector2Int(0, 0),
                Vector2Int(1, 0)
            },
            [Tetromino.Z] = {
                Vector2Int(-1, 1), Vector2Int(0, 1), Vector2Int(0, 0),
                Vector2Int(1, 0)
            }
        },
        WallKicksI = {
            {
                Vector2Int(0, 0), Vector2Int(-2, 0), Vector2Int(1, 0),
                Vector2Int(-2, -1), Vector2Int(1, 2)
            }, {
                Vector2Int(0, 0), Vector2Int(2, 0), Vector2Int(-1, 0),
                Vector2Int(2, 1), Vector2Int(-1, -2)
            }, {
                Vector2Int(0, 0), Vector2Int(-1, 0), Vector2Int(2, 0),
                Vector2Int(-1, 2), Vector2Int(2, -1)
            }, {
                Vector2Int(0, 0), Vector2Int(1, 0), Vector2Int(-2, 0),
                Vector2Int(1, -2), Vector2Int(-2, 1)
            }, {
                Vector2Int(0, 0), Vector2Int(2, 0), Vector2Int(-1, 0),
                Vector2Int(2, 1), Vector2Int(-1, -2)
            }, {
                Vector2Int(0, 0), Vector2Int(-2, 0), Vector2Int(1, 0),
                Vector2Int(-2, -1), Vector2Int(1, 2)
            }, {
                Vector2Int(0, 0), Vector2Int(1, 0), Vector2Int(-2, 0),
                Vector2Int(1, -2), Vector2Int(-2, 1)
            }, {
                Vector2Int(0, 0), Vector2Int(-1, 0), Vector2Int(2, 0),
                Vector2Int(-1, 2), Vector2Int(2, -1)
            }
        },
        WallKicksJLOSTZ = {
            {
                Vector2Int(0, 0), Vector2Int(-1, 0), Vector2Int(-1, 1),
                Vector2Int(0, -2), Vector2Int(-1, -2)
            }, {
                Vector2Int(0, 0), Vector2Int(1, 0), Vector2Int(1, -1),
                Vector2Int(0, 2), Vector2Int(1, 2)
            }, {
                Vector2Int(0, 0), Vector2Int(1, 0), Vector2Int(1, -1),
                Vector2Int(0, 2), Vector2Int(1, 2)
            }, {
                Vector2Int(0, 0), Vector2Int(-1, 0), Vector2Int(-1, 1),
                Vector2Int(0, -2), Vector2Int(-1, -2)
            }, {
                Vector2Int(0, 0), Vector2Int(1, 0), Vector2Int(1, 1),
                Vector2Int(0, -2), Vector2Int(1, -2)
            }, {
                Vector2Int(0, 0), Vector2Int(-1, 0), Vector2Int(-1, -1),
                Vector2Int(0, 2), Vector2Int(-1, 2)
            }, {
                Vector2Int(0, 0), Vector2Int(-1, 0), Vector2Int(-1, -1),
                Vector2Int(0, 2), Vector2Int(-1, 2)
            }, {
                Vector2Int(0, 0), Vector2Int(1, 0), Vector2Int(1, 1),
                Vector2Int(0, -2), Vector2Int(1, -2)
            }
        },
        WallKicks = {
            [Tetromino.I] = WallKicksI,
            [Tetromino.J] = WallKicksJLOSTZ,
            [Tetromino.L] = WallKicksJLOSTZ,
            [Tetromino.O] = WallKicksJLOSTZ,
            [Tetromino.S] = WallKicksJLOSTZ,
            [Tetromino.T] = WallKicksJLOSTZ,
            [Tetromino.Z] = WallKicksJLOSTZ
        }
    }
}
setmetatable(Data, m_Data)
print(Data.Cells[Tetromino.I])
print(Data.RotationMatrix[1])

