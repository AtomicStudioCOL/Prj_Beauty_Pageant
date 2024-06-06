--!Header("Zoom Settings")
--!SerializeField
local zoom : number = 15
--!SerializeField
local zoomMin : number = 10
--!SerializeField
local zoomMax : number = 50
--!SerializeField
local fov : number = 30
--!Header("Defaults")
--!SerializeField
local pitch : number = 30
--!SerializeField
local yaw : number = 45
--!SerializeField
local centerOnCharacterWhenSpawned : boolean = true

local camera = self.gameObject:GetComponent(Camera)
if camera == nil then return end
local cameraRig : Transform = camera.transform   -- quick reference to the camera's transform

local inertiaVelocity : Vector3 = Vector3.zero;  -- the current velocity of the camera fom inertia
local inertiaMagnitude : number = 0;             -- the magnitude of the current InertiaVelocity (this is an optimization to avoid calculating it every frame)
local inertiaMultiplier : number = 2             -- A multiplier to the inertia force to make it feel more or less initially intense.
local closeMaxInitialInertia : number = 35       -- The maximum amount of force when applying inertia to the panning of the camera at closest zoom
local farMaxInitialIntertia : number = 150       -- The maximum amount of force when applying inertia to the panning of the camera at farthest zoom
local inertiaDampeningFactor : number = 0.93     -- The multiplier used to scale the inertia force back over time.

local initialZoomOfPinch : number = zoom         -- the zoom level at the start of the pinch gesture
local lastZoomScale : number = 1                 -- the scale that the pinch applied to InitialZoomOfPinch on the last frame, 1 being no change
local wasPinching : boolean = false                 -- whether the last frame was pinching (two fingers) or not

local rotation : Vector3 = Vector3.zero          -- the rotation of the camera (.y can be thought of it as the "swivel" of the camera around the Target)
local lastDirection : Vector2 = Vector2.zero     -- the direction of the last frame of the pinch gesture (for rotating the camera with touch controls)

local target = Vector3.zero                      -- the point the camera is looking at
local offset = Vector3.zero                      -- the offset from the Target

charPlayer = nil
local InertiaMinVelocity = 0.5; -- prevents the infinite slow drag at the end of inertia
local InertiaStepDuration = 1 / 60; -- each "inertia step" is normalized to 60fps
local MaxSwipeVelocity = 400 -- the maximum velocity of a swipe to apply inertia with
local worldUpPlane = Plane.new(Vector3.up, Vector3.new(0,0,0)) -- cached to avoid re-generating every call
local localCharacterInstantiatedEvent = nil

function CenterOn(newTarget, newZoom)
    zoom = newZoom or zoom

    target = newTarget
    zoom = Mathf.Clamp(zoom, zoomMin, zoomMax)
    offset = Vector3.new(0, 0, offset.z)
end

if centerOnCharacterWhenSpawned then
    function OnLocalCharacter(player, character)
        localCharacterInstantiatedEvent:Disconnect()
        localCharacterInstantiatedEvent = nil

       local position = character.gameObject.transform.position
       CenterOn(position)
    end

    localCharacterInstantiatedEvent = client.localPlayer.CharacterChanged:Connect(function(player, character)
        if character then
            charPlayer = character
            OnLocalCharacter(player, character)
        end
    end)
end

--Verified if the camera is activated
function IsActive()
    return camera ~= nil and camera.isActiveAndEnabled
end

-- Functionality zoom camera player
function ZoomIn()
    zoom = Mathf.Clamp(zoom - 1, zoomMin, zoomMax)
end

function ZoomOut()
    zoom = Mathf.Clamp(zoom + 1, zoomMin, zoomMax)
end

function ZoomScaled(baseZoom, scaleFactor)
    local newZoom = baseZoom + (baseZoom / scaleFactor - baseZoom)
    zoom = Mathf.Clamp(newZoom, zoomMin, zoomMax)
end

-- to make the zoom behave correctly focusPoint needs to stay in the same spot on the screen
-- to do that the screen distance between focusPoint and the target needs to stay the same
-- therefore the world distance between these points needs to be scaled by deltaScalefunction ZoomCamera(evt)
function ZoomCamera(evt)
    -- New zoom attempt
    if not wasPinching then
        ResetZoomScale()
    end

    ZoomScaled(initialZoomOfPinch, evt.scale)

    local scale = zoom / initialZoomOfPinch
    local deltaScale = scale / lastZoomScale
    local focusPoint = ScreenPositionToWorldPoint(camera, evt.position)
    local zoomAdjustment = (target - focusPoint) * (1 / deltaScale - 1)

    target = target - zoomAdjustment
    lastZoomScale = scale
end

Input.MouseWheel:Connect(function(evt)
    if not IsActive() then
        return
    end
    if evt.delta.y < 0.0 then
        ZoomIn()
    else
        ZoomOut()
    end
end)

-- Functionality pan camera
function ScreenPositionToWorldPoint(camera, screenPosition)
    local ray = camera:ScreenPointToRay(screenPosition)

    local success, distance = worldUpPlane:Raycast(ray)
    if not success then
        print("HighriseCameraController Failed to cast ray down into the world. Is the camera not looking down?")
        return Vector3.zero
    end

    return ray:GetPoint(distance)
end

function ResetZoomScale(self)
    initialZoomOfPinch = zoom
    lastZoomScale = 1
end

function ResetInertia()
    inertiaVelocity = Vector3.zero
    inertiaMagnitude = 0
end

function PanCamera(evt)
    local lastPosition = evt.position - evt.deltaPosition
    local startPoint = ScreenPositionToWorldPoint(camera, lastPosition)
    local endPoint = ScreenPositionToWorldPoint(camera, evt.position)
    local dragAdjustment = -(endPoint - startPoint)
    dragAdjustment.y = 0

    target = target + dragAdjustment
end

function CalculateWorldVelocity(evt)
    local velocity = evt.velocity
    velocity.x = Mathf.Clamp(velocity.x, -MaxSwipeVelocity, MaxSwipeVelocity)
    velocity.y = Mathf.Clamp(velocity.y, -MaxSwipeVelocity, MaxSwipeVelocity)

    local screenStart = evt.position
    local screenEnd = evt.position + velocity

    local worldStart = ScreenPositionToWorldPoint(camera, screenStart)
    local worldEnd = ScreenPositionToWorldPoint(camera, screenEnd)

    local result = -(worldEnd - worldStart) -- swiping right means moving the camera left
    return result
end

function ApplyInertia(worldVelocity)
    local t = Easing.Quadratic((zoom - zoomMin) / (zoomMax - zoomMin)) -- closer camera means slower inertia
    local currentMaxVelocity = Mathf.Lerp(closeMaxInitialInertia, farMaxInitialIntertia, t)

    inertiaVelocity = Vector3.ClampMagnitude(worldVelocity * inertiaMultiplier, currentMaxVelocity)
    inertiaMagnitude = inertiaVelocity.magnitude
end

Input.PinchOrDragBegan:Connect(function(evt)
    if not IsActive() then return end

    lastDirection = Vector2.zero
    ResetZoomScale()
    ResetInertia()
end)

Input.PinchOrDragChanged:Connect(function(evt)
    if not IsActive() then return end

    PanCamera(evt)

    if evt.isPinching then
        ZoomCamera(evt)
    end

    wasPinching = evt.isPinching
end)

Input.PinchOrDragEnded:Connect(function(evt)
    if not IsActive() then return end
    
    if not Input.isMouseInput then
        ApplyInertia(CalculateWorldVelocity(evt))
    end
end)

-- Update Inertia Player translation
function UpdateInertia()
    if not Input.isMouseInput and inertiaMagnitude > InertiaMinVelocity then
        local stepReduction = (1.0 - inertiaDampeningFactor) / (InertiaStepDuration / Time.deltaTime)
        local velocityDampener = 1.0 - math.min(math.max(stepReduction, 0), 1)
        inertiaVelocity = inertiaVelocity * velocityDampener
        inertiaMagnitude = inertiaMagnitude * velocityDampener
        target = target + (inertiaVelocity * Time.deltaTime)
    end
end

function UpdatePosition()
    local rotation = Quaternion.Euler(
        pitch + rotation.x,
        yaw + rotation.y,
        0
    )

    local frustumHeight = zoom
    local distance = (frustumHeight * 0.5) / math.tan(fov * 0.5 * Mathf.Deg2Rad)
    camera.fieldOfView = fov

    local cameraPos = Vector3.back * distance
    cameraPos = rotation * cameraPos
    cameraPos = cameraPos + target
    local cameraOffset = cameraRig.rotation * offset

    cameraRig.position = cameraPos
    cameraRig:LookAt(target)
    --cameraRig.position = cameraRig.position + (charPlayer.gameObject.transform.position + cameraOffset)
    cameraRig.position = cameraRig.position + cameraOffset
end

function self:Update()
    if not IsActive() then
        return
    end

    UpdateInertia()
    UpdatePosition()
end