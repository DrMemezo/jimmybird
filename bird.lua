
Bird = Class{}

local GRAVITY = 1.0
local ANTI_GRAV = -13.5
local SCALE = 1/4

function Bird:init(x, y, dy)
    self.x = x 
    self.y = y 
    self.dy = dy
    self.ori = 0 -- Orientation of the bird

    self.images = {} -- Possible faces of the bird
    self.images['up'] = love.graphics.newImage('assets/bird1.png')
    self.images['down'] = love.graphics.newImage('assets/bird2.png')

    self.width = self.images['up']:getWidth()
    self.height = self.images['up']:getHeight()
    
    self.border_width = (self.width - 200) * SCALE
    self.border_height = (self.height - 300) * SCALE

    self.face = self.images['up'] -- Current face of the bird
    timer = 0

    -- TODO: remove this after completing collisions
    self.is_dead = false

end

function Bird:update(dt, keys)     
    -- Jumping when w is pressed
    local oob_timer = 0
    

    if (keys['w'] or keys['up']) and not self.is_dead then
        self.face = self.images['down']
        timer = 0
        self.ori = -1
        keys['w']= false
        keys['up'] = false
        self.dy = ANTI_GRAV

        love.audio.play(sfx.jump)
    end
   
    -- Reseting the bird's face after a jump  
    if timer > 0.25 then 
        self.face = self.images['up']  
    end
    timer = timer + dt
    
    -- Falling
    self.dy = self.dy + GRAVITY 
    self.y = math.max(self.y + self.dy, 30)

    -- Changing the angle of the bird every second
    local dOri = GRAVITY / -ANTI_GRAV
    self.ori = math.min(self.ori + dOri, 1.2)

end


function Bird:draw_border(color)
    if color == "green" then
        love.graphics.setColor(0,1,0)
    else
        love.graphics.setColor(1,0,0)
    end

    love.graphics.rectangle("line",self.x-self.border_width/2, self.y-self.border_height/2,
        self.border_width, self.border_height)
    love.graphics.setColor(1,1,1)
end

function Bird:draw()
    -- Function call and parameters for reference:
    -- love.graphics.draw(drawable,x,y,r,sx,sy,ox,oy)
    -- self:draw_border(self.is_dead and "green" or "red")
    love.graphics.draw(self.face, self.x, self.y, self.ori,SCALE,SCALE,
        self.width/2, self.height/2)

end


function Bird:is_colliding(pipe)
    -- Checks if the bird is approaching, leaving, above or inbetween the gap
    -- if not, the bird is colliding

    -- if bird is approaching pipes, return false
    if (self.x + self.border_width) < pipe.x then
        return false
    end 
    -- if bird has passed pipes, return false
    if self.x > (pipe.x + PIPE_BORDER.width) then
        return false
    end
-- Check if inbetween pipes
    if self.y > (pipe.upper_y + PIPE_BORDER.height) and 
        (self.y + self.border_height) < pipe.lower_y then
            return false
    end

    return true
end