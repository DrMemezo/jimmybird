--[[
    Jimmy Bird, made by Jamal
]]

-- Importing all required libraries
push = require 'libraries/push'
Class = require 'libraries/class'
-- Importing local classes
require 'bird'
require 'pipe'

function love.load()
    
    --[[ gameWidth = 420 * 7
    gameHeight = 420 * 5 ]]
    WINDOW_WIDTH, WINDOW_HEIGHT = love.window.getDesktopDimensions()
    love.graphics.setDefaultFilter('nearest','nearest')
    
    -- Getting background
    background = love.graphics.newImage('assets/backgroud.png')
    gameHeight = background:getHeight()
    gameWidth = background:getWidth() / 2

    push:setupScreen(gameWidth, gameHeight, WINDOW_WIDTH - 100, WINDOW_HEIGHT,{
        resizable = true,
        fullscreen = false,
        vsync = true
    })
    love.window.setTitle('Jimmy Bird')

    -- Setting font
    scoreFont = love.graphics.newFont('assets/font.ttf', 35)
    myFont = love.graphics.newFont('assets/font.ttf', 30)
    love.graphics.setFont(myFont)

    text = love.graphics.newText(myFont,"Press 'w' to start")
    
    -- Initialising bird
    bird = Bird((gameWidth - 420)/2,
     (gameHeight - 420)/2, 20)
    
    background_y = 0
    
    -- Score
    score = 0
    high_score = 0
    
    -- SFX
    sfx = {}
    sfx.death = love.audio.newSource('assets/die.wav', 'static')
    sfx.jump = love.audio.newSource('assets/Jump.wav', 'static')
    sfx.score = love.audio.newSource('assets/score.wav', 'static')

    -- Table which keeps track of pressed keys
    is_pressed = {}

    -- Game state:
    stateIs = {}    
    stateIs.menu = true
    stateIs.play = false
    stateIs.dead = false   

    -- Pipe:
    pipePairs = {}
    table.insert(pipePairs, Pipe())
    pipe_timer = 0
    limit = 3
    approaching_pipe = 1

    -- Timers
    collision_timer = 0
    comprehension_timer = 0
    comprehended = false
    
end

function updateApproachingPipe(pipe_index)    
    -- No pipes
    if #pipePairs == 0 then
        return 1
    end
    
    local appro_pipe = pipePairs[pipe_index]
    -- if passed the approaching pipe, update pipe
    if bird.x > (appro_pipe.x + PIPE_BORDER.width) then
        pipe_index = updateApproachingPipe(pipe_index + 1)
        score = score + 1
        love.audio.play(sfx.score)
    end
    
    return pipe_index
end


function love.keypressed(key)
    if key == 'escape' then
        love.event.quit()
    end

    is_pressed[key] = true
end

function love.keyreleased(key)
    is_pressed[key] = false
end


function love.resize(w, h)
    return push:resize(w, h)
end


function love.update(dt)    
  
  
    if stateIs['menu'] and is_pressed['w'] then
        stateIs['menu'] = false
        stateIs['play'] = true
    end

    if stateIs['play'] and bird.is_dead then
        
        stateIs['play'] = false
        stateIs['dead'] = true
        love.audio.play(sfx.death)
        high_score = math.max(high_score, score)
        score_text = love.graphics.newText(scoreFont, "Score: "..score.."\nHighscore: "..high_score)
        text = love.graphics.newText(myFont,"You died!\n Press 'w' to try again!")
    end
    
    if stateIs['dead'] and is_pressed['w'] and comprehended then
        stateIs['dead'] = false
        stateIs['play'] = true
        
        comprehended = false
        -- Reset Score
        score = 0
        -- Reinitialize bird
        bird = Bird((gameWidth - 420)/2,
        (gameHeight - 420)/2, 20)
        
        -- Reinitialize pipes
        pipePairs = {}
        table.insert(pipePairs, Pipe())
        pipe_timer = 0
        limit = 3
        approaching_pipe = 1
    end
    
    if not stateIs['menu'] then
        bird:update(dt, is_pressed)

    end
    if stateIs['dead'] then
        comprehension_timer = comprehension_timer + dt
        if comprehension_timer > 0.5 then
            comprehension_timer = 0
            comprehended = true
        end
    end
    
    if stateIs['play'] then 
        -- Update bg        
        background_y = (background_y - (dt * (bird.width * 0.6))) % -1019
        
        -- Check for out-of-bounds
        if bird.y > gameHeight then
            bird.is_dead = true
        end 
        
        -- Check for collisions
        if bird:is_colliding(pipePairs[approaching_pipe]) then 
            bird.is_dead = true
        end

        -- Update pipes
        for _, pipe in ipairs(pipePairs) do
            pipe:update(dt, is_pressed)
        end

        -- Timer for adding more pipes
        pipe_timer = pipe_timer + dt
        
        if pipe_timer > limit then 
            pipe_timer = 0
            limit = math.max(limit - 0.1, 1)
            table.insert(pipePairs, Pipe())
        end

        -- Remove out of bound pipes
        if pipePairs[1].out_of_bounds then
            table.remove(pipePairs, 1)
            approaching_pipe = math.max(approaching_pipe - 1, 1)
        end
        approaching_pipe = updateApproachingPipe(approaching_pipe)


    end
end

function draw_pipes()
    for _, pipe in ipairs(pipePairs) do
        pipe:draw()
    end
end

function love.draw()
    push:apply('start')
    -- love.graphics.draw(drawable,x,y,r,sx,sy,ox,oy)
    love.graphics.draw(background, background_y, 0)
    if not stateIs['menu'] then
        bird:draw()
        draw_pipes()
    end

    if stateIs['play'] then 
        love.graphics.printf("Score: "..score,gameWidth -200,10,100,'center')
    end

    if stateIs['dead'] then
        love.graphics.draw(score_text, score_text:getWidth(),
        score_text:getHeight())
    end

    if not stateIs['play'] then 
        love.graphics.draw(text, (gameWidth- text:getWidth())/2, 
        gameHeight/2)
    end

    push:apply('end')
end