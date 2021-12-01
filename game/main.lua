local str, font = "Hello World", nil

local background = love.graphics.newImage("images/upper_background.png")
local bottom_game_bg = love.graphics.newImage("images/bottom_game_bg.png")
local bomb = love.graphics.newImage("images/Bomb_fited.png")
local cursor = love.graphics.newImage("images/cursor.png")
local refresh_icon = love.graphics.newImage("images/transparent-refresh-icon.png")


local cake = love.graphics.newImage("images/cake.png")
local cupcake = love.graphics.newImage("images/cupcake.png")
local jelly = love.graphics.newImage("images/jelly.png")
local macaron = love.graphics.newImage("images/macaron.png")
local lollipop = love.graphics.newImage("images/lollipop.png")
local gummy = love.graphics.newImage("images/gummy-bear.png")
local donnut = love.graphics.newImage("images/donnut.png")
local eclair = love.graphics.newImage("images/eclair.png")



local index = 1

function reverse(t)
    local n = #t
    local i = 1
    while i < n do
        t[i],t[n] = t[n],t[i]
        i = i + 1
        n = n - 1
    end
end



function drawCandy(candy, i, j)
    local xs = {77, 98, 119, 140, 161, 182}
    local ys = {14, 38, 62, 86, 110, 134, 158, 182, 206}
    reverse(ys)
    love.graphics.draw(candy, xs[i], ys[j], 0, 20/candy:getWidth(), 20/candy:getHeight())
end

function drawStack(stack)
    local x = 225
    local ys = {14, 38, 62, 86, 110, 134, 158, 182, 206}
    reverse(ys)
    for i = 1, #stack do
        if i == 10 then
            break
        end
        local candy = stack[i]
        if candy == nil then
            break
        end
        love.graphics.draw(candy, x, ys[i], 0, 20/candy:getWidth(), 20/candy:getHeight())
    end
end

function initCandys(candys, n, m)
    local candyMatrix = {}
    for i = 1, n do
        candyMatrix[i] = {length = m}
        for j = 1, m do
            candyMatrix[i][j] = candys[math.random(1, #candys)]
        end
    end
    return candyMatrix
end

function popCandy(candyMatrix, index)
    local element = candyMatrix[index][candyMatrix[index].length]
    candyMatrix[index].length = candyMatrix[index].length - 1
    return element
end

local stack = {}

function push(stack, element)
    stack[#stack + 1] = element
end
local candyKinds = {cake, cupcake, jelly, macaron}
local candyMatrix = initCandys(candyKinds, 6, 9)


function love.load()
    font = love.graphics.getFont()
end

function menu(screen)
    -- TODO: 난이도 선택 화면.
end

function refresh()
    candyMatrix = initCandys(candyKinds, 6, 9)
    stack = {}
end

refresh_icon_location = {x = 16, y = 16, w = 30, h = 30}

function game(screen)
    if screen == "bottom" then
        love.graphics.draw(bottom_game_bg, 0, 0)
        love.graphics.draw(bomb, 265, 180)
        love.graphics.draw(refresh_icon, 
                           refresh_icon_location.x,
                           refresh_icon_location.y,
                           0,
                           refresh_icon_location.w/refresh_icon:getWidth(), 
                           refresh_icon_location.h/refresh_icon:getHeight())
        for i = 1, #candyMatrix do
            for j = 1, candyMatrix[i].length do
                drawCandy(candyMatrix[i][j], i, j)
            end
        end
        drawStack(stack)
        draw_cursor(index)
    else
        local sysDepth = -love.graphics.get3DDepth()
        if screen == "right" then
            sysDepth = -sysDepth
        end

        love.graphics.draw(background, sysDepth * 3, 0)

        local left = math.floor(0.5 * (400 - font:getWidth(str)))
        love.graphics.print("Candy Crain", left - sysDepth * 2, 120)
    end
end

function love.draw(screen)
    game(screen)
end

function love.gamepadpressed(joystick, button)
    if button == "dpright" then
        index = index + 1
    elseif button == "dpleft" then
        index = index - 1
    end
    if button == "start" or button == "back" then
        refresh()
    end
    if index == 7 then
        index = 1
    elseif index == 0 then
        index = 6
    end
    if button == "a" then
        push(stack, popCandy(candyMatrix, index))
    end
end

function explodeBomb()
    if #stack >=3 and stack[#stack] == stack[#stack-1] and stack[#stack-1] ==stack[#stack-2] then
        local node = stack[#stack]
        local size = 1
        for i = #stack - 1, 1, -1 do
            if stack[i] == node then
                size = size + 1
            else
                break
            end
        end
        for i = 1, size do
            table.remove(stack)
        end
    end
end

function love.touchreleased(id, x, y, dx, dy, pressure)
    if 256<x and x<265+bomb:getWidth() and 180 < y and y < 180+bomb:getHeight() then
        explodeBomb()
    end
    if refresh_icon_location.x < x and x < refresh_icon_location.x + refresh_icon_location.w and
       refresh_icon_location.y < y and y < refresh_icon_location.y + refresh_icon_location.h then
        refresh()
    end
end

function draw_cursor(index)
    love.graphics.draw(cursor, 76+(21*(index - 1)) - 5, 13 - 6)
    love.graphics.draw(cursor, 76+(21*(index - 1)) - 5, 13 - 6+228, 0, 1, -1)
end