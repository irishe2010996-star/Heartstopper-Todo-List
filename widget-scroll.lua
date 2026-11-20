local offset, target, maximum, direction = 0, 0, 0, 0
local bounce, velocity = 0, 0

function Initialize()
    local n = tonumber(SKIN:GetVariable('LiveTaskCount', '0')) or 0
    local v = tonumber(SKIN:GetVariable('LiveVisibleRows', '6')) or 6
    maximum = math.max(0, n - v)
    offset, target, direction, bounce, velocity = 0, 0, 0, 0, 0
end

local function clamp(n, lo, hi)
    return math.max(lo, math.min(hi, n))
end

local function draw()
    SKIN:Bang('!SetVariable', 'ListOffset', tostring(offset + bounce))
    local track = SKIN:GetMeter('SbTrack')
    local thumb = SKIN:GetMeter('SbThumb')
    if track and thumb then
        local fraction = maximum > 0 and clamp(offset / maximum, 0, 1) or 0
        local y = track:GetY() + math.max(0, track:GetH() - thumb:GetH()) * fraction
        SKIN:Bang('!SetOption', 'SbThumb', 'Y', tostring(y))
    end
    SKIN:Bang('!UpdateMeterGroup', 'LiveTaskRows')
    SKIN:Bang('!UpdateMeterGroup', 'LiveScrollbar')
    SKIN:Bang('!Redraw')
end

function Update()
    if offset ~= target or bounce ~= 0 or velocity ~= 0 then
        offset = offset + (target - offset) * 0.55
        if math.abs(target - offset) < 0.002 then offset = target end
        velocity = (velocity - bounce * 0.20) * 0.64
        bounce = bounce + velocity
        if math.abs(bounce) < 0.001 and math.abs(velocity) < 0.001 then
            bounce, velocity = 0, 0
        end
        draw()
    end
    return offset
end

function Scroll(delta)
    delta = tonumber(delta) or 0
    if delta == 0 or maximum <= 0 then return end
    local sign = delta > 0 and 1 or -1
    if sign ~= direction then
        target, bounce, velocity = offset, 0, 0
    end
    direction = sign
    local wanted = target + delta
    target = clamp(wanted, 0, maximum)
    if wanted < 0 or wanted > maximum then
        bounce = clamp(bounce + delta * 0.26, -0.45, 0.45)
        velocity = 0
    end
    Update()
end

function Jump(y)
    local track = SKIN:GetMeter('SbTrack')
    local thumb = SKIN:GetMeter('SbThumb')
    if not track or not thumb then return end
    local travel = track:GetH() - thumb:GetH()
    if travel <= 0 or maximum <= 0 then return end
    target = clamp(((tonumber(y) or 0) - thumb:GetH() / 2) / travel * maximum, 0, maximum)
    direction, bounce, velocity = 0, 0, 0
    Update()
end

-- Draggable scrollbar v1
local dragOrigin = nil

function BeginDrag()
    target = offset
    bounce, velocity, direction = 0, 0, 0
    dragOrigin = offset
    draw()
end

function DragTo(delta)
    if dragOrigin == nil or maximum <= 0 then return end
    local track = SKIN:GetMeter('SbTrack')
    local thumb = SKIN:GetMeter('SbThumb')
    if not track or not thumb then return end
    local travel = track:GetH() - thumb:GetH()
    if travel <= 0 then return end
    offset = math.max(0, math.min(maximum,
        dragOrigin + (tonumber(delta) or 0) / travel * maximum))
    target = offset
    bounce, velocity = 0, 0
    draw()
end

function EndDrag()
    dragOrigin = nil
end


-- Single edge bounce v1
local edgeBounceDirection = 0

function Scroll(delta)
    delta = tonumber(delta) or 0
    if delta == 0 or maximum <= 0 then return end
    local sign = delta > 0 and 1 or -1
    if sign ~= direction then
        target, bounce, velocity = offset, 0, 0
        edgeBounceDirection = 0
    end
    direction = sign

    local wanted = target + delta
    target = math.max(0, math.min(maximum, wanted))
    local edge = 0
    if wanted < 0 then edge = -1 end
    if wanted > maximum then edge = 1 end

    if edge == 0 then
        edgeBounceDirection = 0
    elseif edge ~= edgeBounceDirection then
        bounce = math.max(-0.45, math.min(0.45, delta * 0.26))
        velocity = 0
        edgeBounceDirection = edge
    end
    Update()
end