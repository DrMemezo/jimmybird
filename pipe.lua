--[[ PIPE class for jimmy bird
    Pipes will spawn in pairs, one on the top side 
    and one on the bottom side
]]

Pipe = Class{}
math.randomseed(os.time())

local PIPE = {}
PIPE.image = love.graphics.newImage('assets/pipe_new.png')
PIPE.image_data = love.image.newImageData('assets/pipe_new.png')
PIPE.width = PIPE.image:getWidth()
PIPE.scale = 1.15
PIPE.speed = 225
PIPE.height = PIPE.image:getHeight()

PIPE_BORDER = {}
PIPE_BORDER.width = PIPE.width * PIPE.scale
PIPE_BORDER.height = PIPE.height * PIPE.scale

function Pipe:init()
    self.x = gameWidth
    self.size_of_gap = 175
    self.upper_y = math.random(-PIPE_BORDER.height + self.size_of_gap, 0)
    self.lower_y = self.upper_y + self.size_of_gap + PIPE_BORDER.height    
    self.out_of_bounds = false
    
end

function Pipe:draw_border(y)
    --[[
        Since both pipes have the same width, size and x co-ord, ill just
        take the y co-ord as the parameter
    ]]

    local r,g,b,a = love.graphics.getColor()
    love.graphics.setColor(1,0,0)
    love.graphics.rectangle("line", self.x,
    y, PIPE_BORDER.width, PIPE_BORDER.height)
    love.graphics.setColor(r,g,b,a)
end

function Pipe:draw()
    -- Upper pipe
    -- self:draw_border(self.upper_y)
    love.graphics.draw(PIPE.image, self.x , self.upper_y,
    0, PIPE.scale, PIPE.scale)
    
    -- Lower pipe 
    -- self:draw_border(self.lower_y)
    love.graphics.draw(PIPE.image, self.x, self.lower_y,
    3.14, PIPE.scale, PIPE.scale,
    PIPE.width, PIPE.height)
    
end

function Pipe:update(dt, keys)
    if self.x < -PIPE_BORDER.width then
        self.out_of_bounds = true
    end
    self.x = self.x - (PIPE.speed * dt) 
end



