local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local ROOT_NAME = "RBS_GUI_Studio"

local function DestroyOld(container)
	pcall(function()
		local old = container:FindFirstChild(ROOT_NAME)
		if old then
			old:Destroy()
		end
	end)
end

DestroyOld(CoreGui)

if player then
	local pg = player:FindFirstChildOfClass("PlayerGui")
	if pg then
		DestroyOld(pg)
	end
end

if gethui then
	pcall(function()
		DestroyOld(gethui())
	end)
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = ROOT_NAME
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.DisplayOrder = 999999
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local parented = false

if gethui then
	parented = pcall(function()
		ScreenGui.Parent = gethui()
	end) and ScreenGui.Parent ~= nil
end

if not parented then
	parented = pcall(function()
		ScreenGui.Parent = CoreGui
	end) and ScreenGui.Parent ~= nil
end

if not parented then
	ScreenGui.Parent = player:WaitForChild("PlayerGui")
end

local Conns = {}

local function Track(c)
	Conns[#Conns + 1] = c
	return c
end

ScreenGui.Destroying:Connect(function()
	for _, c in ipairs(Conns) do
		pcall(function()
			c:Disconnect()
		end)
	end
end)

local Theme = {
	Bg = Color3.fromRGB(16, 16, 20),
	Panel = Color3.fromRGB(24, 24, 29),
	Item = Color3.fromRGB(35, 35, 42),
	ItemHover = Color3.fromRGB(48, 48, 58),
	Stroke = Color3.fromRGB(62, 62, 74),
	Accent = Color3.fromRGB(0, 140, 255),
	AccentDark = Color3.fromRGB(0, 100, 185),
	Text = Color3.fromRGB(236, 236, 242),
	Sub = Color3.fromRGB(150, 150, 164),
	Danger = Color3.fromRGB(235, 70, 70),
	DangerDark = Color3.fromRGB(160, 45, 45),
	Success = Color3.fromRGB(60, 200, 120),
}

local function New(class, props, parent)
	local obj = Instance.new(class)

	for k, v in pairs(props or {}) do
		obj[k] = v
	end

	obj.Parent = parent
	return obj
end

local function Corner(obj, radius)
	return New("UICorner", {
		CornerRadius = UDim.new(0, radius)
	}, obj)
end

local function Stroke(obj, color, thickness)
	return New("UIStroke", {
		Color = color,
		Thickness = thickness,
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
	}, obj)
end

local function Pad(obj, l, t, r, b)
	return New("UIPadding", {
		PaddingLeft = UDim.new(0, l),
		PaddingTop = UDim.new(0, t),
		PaddingRight = UDim.new(0, r),
		PaddingBottom = UDim.new(0, b),
	}, obj)
end

local function Tween(obj, props, t)
	TweenService:Create(
		obj,
		TweenInfo.new(t or 0.12, Enum.EasingStyle.Quad),
		props
	):Play()
end

local function IsClick(input)
	return input.UserInputType == Enum.UserInputType.MouseButton1
		or input.UserInputType == Enum.UserInputType.Touch
end

local function IsMove(input)
	return input.UserInputType == Enum.UserInputType.MouseMovement
		or input.UserInputType == Enum.UserInputType.Touch
end

local function Button(props, parent, base, hover)
	base = base or Theme.Item
	hover = hover or Theme.ItemHover

	local b = New("TextButton", {
		BackgroundColor3 = base,
		AutoButtonColor = false,
		Text = "",
		TextColor3 = Theme.Text,
		TextSize = 13,
		Font = Enum.Font.GothamMedium,
		BorderSizePixel = 0,
	}, nil)

	for k, v in pairs(props or {}) do
		b[k] = v
	end

	b:SetAttribute("Base", base)
	b:SetAttribute("Hover", hover)
	b.Parent = parent

	Corner(b, 6)

	b.MouseEnter:Connect(function()
		Tween(b, {
			BackgroundColor3 = b:GetAttribute("Hover")
		})
	end)

	b.MouseLeave:Connect(function()
		Tween(b, {
			BackgroundColor3 = b:GetAttribute("Base")
		})
	end)

	return b
end

local function Dragify(handle, target)
	local dragging = false
	local startMouse
	local startPos

	handle.InputBegan:Connect(function(input)
		if IsClick(input) then
			dragging = true
			startMouse = input.Position
			startPos = target.Position
		end
	end)

	Track(UserInputService.InputChanged:Connect(function(input)
		if dragging and IsMove(input) then
			local d = input.Position - startMouse

			target.Position = UDim2.new(
				startPos.X.Scale,
				math.round(startPos.X.Offset + d.X),
				startPos.Y.Scale,
				math.round(startPos.Y.Offset + d.Y)
			)
		end
	end))

	Track(UserInputService.InputEnded:Connect(function(input)
		if IsClick(input) then
			dragging = false
		end
	end))
end

local function Num(n)
	if n == math.floor(n) then
		return tostring(math.floor(n))
	end

	local s = string.format("%.4f", n)
	s = s:gsub("0+$", "")
	s = s:gsub("%.$", "")

	return s
end

local function ColorStr(c)
	return string.format(
		"%d, %d, %d",
		math.round(c.R * 255),
		math.round(c.G * 255),
		math.round(c.B * 255)
	)
end

local function FormatValue(v)
	local t = typeof(v)

	if t == "Color3" then
		return ColorStr(v)
	elseif t == "UDim2" then
		return string.format(
			"%s, %s, %s, %s",
			Num(v.X.Scale),
			Num(v.X.Offset),
			Num(v.Y.Scale),
			Num(v.Y.Offset)
		)
	elseif t == "UDim" then
		return string.format(
			"%s, %s",
			Num(v.Scale),
			Num(v.Offset)
		)
	elseif t == "Vector2" then
		return string.format(
			"%s, %s",
			Num(v.X),
			Num(v.Y)
		)
	elseif t == "Vector3" then
		return string.format(
			"%s, %s, %s",
			Num(v.X),
			Num(v.Y),
			Num(v.Z)
		)
	elseif t == "NumberRange" then
		return string.format(
			"%s, %s",
			Num(v.Min),
			Num(v.Max)
		)
	elseif t == "Rect" then
		return string.format(
			"%s, %s, %s, %s",
			Num(v.Min.X),
			Num(v.Min.Y),
			Num(v.Max.X),
			Num(v.Max.Y)
		)
	elseif t == "EnumItem" then
		return v.Name
	elseif t == "number" then
		return Num(v)
	elseif t == "ColorSequence" then
		local kp = v.Keypoints
		return ColorStr(kp[1].Value) .. " | " .. ColorStr(kp[#kp].Value)
	elseif t == "NumberSequence" then
		local kp = v.Keypoints
		return Num(kp[1].Value) .. ", " .. Num(kp[#kp].Value)
	end

	return tostring(v)
end

local function Nums(text)
	local r = {}

	for s in tostring(text):gmatch("%-?%d*%.?%d+") do
		local n = tonumber(s)

		if n then
			r[#r + 1] = n
		end
	end

	return r
end

local function ParseColor3(text)
	local hex = text:match("^%s*#(%x%x%x%x%x%x)%s*$")

	if hex then
		return Color3.fromRGB(
			tonumber(hex:sub(1, 2), 16),
			tonumber(hex:sub(3, 4), 16),
			tonumber(hex:sub(5, 6), 16)
		)
	end

	local n = Nums(text)

	if #n == 3 then
		local r, g, b = n[1], n[2], n[3]

		if r > 1 or g > 1 or b > 1 then
			r, g, b = r / 255, g / 255, b / 255
		end

		return Color3.new(
			math.clamp(r, 0, 1),
			math.clamp(g, 0, 1),
			math.clamp(b, 0, 1)
		)
	end

	return nil
end

local function ParseBool(text)
	text = text:lower():gsub("%s+", "")

	if text == "true" or text == "1" or text == "yes" then
		return true
	end

	if text == "false" or text == "0" or text == "no" then
		return false
	end

	return nil
end

local function ParseValue(current, text)
	local t = typeof(current)
	local n = Nums(text)

	if t == "string" then
		return text

	elseif t == "number" then
		return tonumber(text)

	elseif t == "boolean" then
		return ParseBool(text)

	elseif t == "Color3" then
		return ParseColor3(text)

	elseif t == "UDim2" then
		if #n == 4 then
			return UDim2.new(n[1], n[2], n[3], n[4])
		elseif #n == 2 then
			return UDim2.fromOffset(n[1], n[2])
		end

	elseif t == "UDim" then
		if #n == 2 then
			return UDim.new(n[1], n[2])
		end

	elseif t == "Vector2" then
		if #n == 2 then
			return Vector2.new(n[1], n[2])
		end

	elseif t == "Vector3" then
		if #n == 3 then
			return Vector3.new(n[1], n[2], n[3])
		end

	elseif t == "NumberRange" then
		if #n == 2 then
			return NumberRange.new(n[1], n[2])
		end

	elseif t == "Rect" then
		if #n == 4 then
			return Rect.new(n[1], n[2], n[3], n[4])
		end

	elseif t == "NumberSequence" then
		if #n == 1 then
			return NumberSequence.new(n[1])
		elseif #n == 2 then
			return NumberSequence.new(n[1], n[2])
		end

	elseif t == "ColorSequence" then
		local parts = {}

		for part in (text .. "|"):gmatch("([^|]*)|") do
			if part:match("%S") then
				parts[#parts + 1] = part
			end
		end

		local c1 = parts[1] and ParseColor3(parts[1])
		local c2 = parts[2] and ParseColor3(parts[2])

		if c1 and c2 then
			return ColorSequence.new(c1, c2)
		elseif c1 then
			return ColorSequence.new(c1)
		end

	elseif t == "EnumItem" then
		local low = text:lower():gsub("%s+", "")

		for _, item in ipairs(current.EnumType:GetEnumItems()) do
			if item.Name:lower() == low
				or tostring(item):lower() == low
				or tostring(item.Value) == low then
				return item
			end
		end
	end

	return nil
end

local function LuaValue(v)
	local t = typeof(v)

	if t == "string" then
		return string.format("%q", v)

	elseif t == "number" then
		return string.format("%.10g", v)

	elseif t == "boolean" then
		return tostring(v)

	elseif t == "Color3" then
		return string.format(
			"Color3.fromRGB(%d, %d, %d)",
			math.round(v.R * 255),
			math.round(v.G * 255),
			math.round(v.B * 255)
		)

	elseif t == "UDim2" then
		return string.format(
			"UDim2.new(%s, %s, %s, %s)",
			Num(v.X.Scale),
			Num(v.X.Offset),
			Num(v.Y.Scale),
			Num(v.Y.Offset)
		)

	elseif t == "UDim" then
		return string.format(
			"UDim.new(%s, %s)",
			Num(v.Scale),
			Num(v.Offset)
		)

	elseif t == "Vector2" then
		return string.format(
			"Vector2.new(%s, %s)",
			Num(v.X),
			Num(v.Y)
		)

	elseif t == "Vector3" then
		return string.format(
			"Vector3.new(%s, %s, %s)",
			Num(v.X),
			Num(v.Y),
			Num(v.Z)
		)

	elseif t == "NumberRange" then
		return string.format(
			"NumberRange.new(%s, %s)",
			Num(v.Min),
			Num(v.Max)
		)

	elseif t == "Rect" then
		return string.format(
			"Rect.new(%s, %s, %s, %s)",
			Num(v.Min.X),
			Num(v.Min.Y),
			Num(v.Max.X),
			Num(v.Max.Y)
		)

	elseif t == "EnumItem" then
		return tostring(v)

	elseif t == "ColorSequence" then
		local parts = {}

		for _, k in ipairs(v.Keypoints) do
			parts[#parts + 1] = string.format(
				"ColorSequenceKeypoint.new(%s, %s)",
				Num(k.Time),
				string.format(
					"Color3.fromRGB(%d, %d, %d)",
					math.round(k.Value.R * 255),
					math.round(k.Value.G * 255),
					math.round(k.Value.B * 255)
				)
			)
		end

		return "ColorSequence.new({" .. table.concat(parts, ", ") .. "})"

	elseif t == "NumberSequence" then
		local parts = {}

		for _, k in ipairs(v.Keypoints) do
			parts[#parts + 1] = string.format(
				"NumberSequenceKeypoint.new(%s, %s, %s)",
				Num(k.Time),
				Num(k.Value),
				Num(k.Envelope)
			)
		end

		return "NumberSequence.new({" .. table.concat(parts, ", ") .. "})"
	end

	return nil
end

local Schema = {
	{ "Object", { "Instance" }, { "Name" } },

	{ "Layout", { "GuiObject" }, {
		"AnchorPoint",
		"Position",
		"Size",
		"Rotation",
		"SizeConstraint",
		"AutomaticSize",
		"LayoutOrder",
		"ZIndex",
		"Visible",
		"ClipsDescendants",
		"Active",
		"Selectable",
	} },

	{ "Appearance", { "GuiObject" }, {
		"BackgroundColor3",
		"BackgroundTransparency",
		"BorderColor3",
		"BorderMode",
		"BorderSizePixel",
	} },

	{ "Canvas Group", { "CanvasGroup" }, {
		"GroupColor3",
		"GroupTransparency",
	} },

	{ "Button", { "GuiButton" }, {
		"AutoButtonColor",
		"Modal",
		"Style",
	} },

	{ "Text", { "TextLabel", "TextButton", "TextBox" }, {
		"Text",
		"TextColor3",
		"TextTransparency",
		"TextSize",
		"Font",
		"TextScaled",
		"TextWrapped",
		"RichText",
		"TextXAlignment",
		"TextYAlignment",
		"LineHeight",
		"MaxVisibleGraphemes",
		"TextStrokeColor3",
		"TextStrokeTransparency",
		"TextTruncate",
		"TextDirection",
	} },

	{ "TextBox", { "TextBox" }, {
		"PlaceholderText",
		"PlaceholderColor3",
		"ClearTextOnFocus",
		"MultiLine",
		"TextEditable",
		"ShowNativeInput",
	} },

	{ "Image", { "ImageLabel", "ImageButton" }, {
		"Image",
		"ImageColor3",
		"ImageTransparency",
		"ScaleType",
		"ResampleMode",
		"ImageRectOffset",
		"ImageRectSize",
		"SliceCenter",
		"SliceScale",
		"TileSize",
	} },

	{ "Image Button", { "ImageButton" }, {
		"HoverImage",
		"PressedImage",
	} },

	{ "Scrolling", { "ScrollingFrame" }, {
		"CanvasSize",
		"CanvasPosition",
		"AutomaticCanvasSize",
		"ScrollingEnabled",
		"ScrollingDirection",
		"ScrollBarThickness",
		"ScrollBarImageColor3",
		"ScrollBarImageTransparency",
		"ElasticBehavior",
		"HorizontalScrollBarInset",
		"VerticalScrollBarInset",
		"VerticalScrollBarPosition",
	} },

	{ "UICorner", { "UICorner" }, {
		"CornerRadius",
	} },

	{ "UIStroke", { "UIStroke" }, {
		"Enabled",
		"Color",
		"Thickness",
		"Transparency",
		"ApplyStrokeMode",
		"LineJoinMode",
	} },

	{ "UIGradient", { "UIGradient" }, {
		"Enabled",
		"Color",
		"Transparency",
		"Rotation",
		"Offset",
	} },

	{ "UIListLayout", { "UIListLayout" }, {
		"FillDirection",
		"HorizontalAlignment",
		"VerticalAlignment",
		"SortOrder",
		"Padding",
		"Wraps",
		"HorizontalFlex",
		"VerticalFlex",
		"ItemLineAlignment",
	} },

	{ "UIGridLayout", { "UIGridLayout" }, {
		"CellSize",
		"CellPadding",
		"FillDirection",
		"FillDirectionMaxCells",
		"StartCorner",
		"HorizontalAlignment",
		"VerticalAlignment",
		"SortOrder",
	} },

	{ "UIPadding", { "UIPadding" }, {
		"PaddingTop",
		"PaddingBottom",
		"PaddingLeft",
		"PaddingRight",
	} },

	{ "UIScale", { "UIScale" }, {
		"Scale",
	} },

	{ "UIAspectRatioConstraint", { "UIAspectRatioConstraint" }, {
		"AspectRatio",
		"AspectType",
		"DominantAxis",
	} },

	{ "UISizeConstraint", { "UISizeConstraint" }, {
		"MinSize",
		"MaxSize",
	} },
}

local function Matches(obj, classes)
	for _, c in ipairs(classes) do
		if obj:IsA(c) then
			return true
		end
	end

	return false
end

local function IsGuiObject(obj)
	return obj ~= nil and obj:IsA("GuiObject")
end

local function Listed(obj)
	return obj:IsA("GuiObject") or obj:IsA("UIComponent")
end

local BLUE = Color3.fromRGB(0, 120, 215)
local GREEN = Color3.fromRGB(45, 160, 100)
local ORANGE = Color3.fromRGB(220, 130, 40)
local TEAL = Color3.fromRGB(30, 170, 175)
local PURPLE = Color3.fromRGB(140, 80, 220)

local MetaTable = {
	Frame = { "Fr", BLUE },
	CanvasGroup = { "Cg", BLUE },
	ScrollingFrame = { "Sc", TEAL },
	TextLabel = { "Tx", GREEN },
	TextButton = { "Bt", GREEN },
	TextBox = { "Tb", GREEN },
	ImageLabel = { "Im", ORANGE },
	ImageButton = { "Ib", ORANGE },
	UICorner = { "Co", PURPLE },
	UIStroke = { "St", PURPLE },
	UIListLayout = { "Li", PURPLE },
	UIGridLayout = { "Gr", PURPLE },
	UIGradient = { "Gd", PURPLE },
	UIPadding = { "Pd", PURPLE },
	UIScale = { "Sl", PURPLE },
	UIAspectRatioConstraint = { "Ar", PURPLE },
	UISizeConstraint = { "Sz", PURPLE },
}

local function MetaByClass(className)
	local m = MetaTable[className]

	if m then
		return m[1], m[2]
	end

	return "UI", PURPLE
end

local UI = {}
local Selected
local GuiTarget

local SetSelected
local BuildProperties
local RefreshProperties
local RefreshExplorer
local UpdateSelection
local CloseMenus
local OpenPalette
local Notify
local UpdateToolbar

local PropRefreshers = {}
local Drag = {
	mode = nil
}

local function Viewport()
	local s = ScreenGui.AbsoluteSize

	if s.X == 0 or s.Y == 0 then
		local cam = workspace.CurrentCamera

		if cam then
			return cam.ViewportSize
		end

		return Vector2.new(1280, 720)
	end

	return s
end

local Editor = New("Frame", {
	Name = "Editor",
	BackgroundColor3 = Color3.fromRGB(10, 10, 13),
	BackgroundTransparency = 0.3,
	BorderSizePixel = 0,
	Size = UDim2.fromScale(1, 1),
	Active = true,
	ZIndex = 1,
}, ScreenGui)

local Canvas = New("Frame", {
	Name = "Canvas",
	AnchorPoint = Vector2.new(0.5, 0.5),
	Position = UDim2.fromScale(0.5, 0.5),
	Size = UDim2.fromOffset(700, 450),
	BackgroundColor3 = Color3.fromRGB(30, 30, 37),
	BorderSizePixel = 0,
	ClipsDescendants = true,
	ZIndex = 2,
}, Editor)

local CanvasBorder = New("Frame", {
	Name = "CanvasBorder",
	AnchorPoint = Vector2.new(0.5, 0.5),
	Position = UDim2.fromScale(0.5, 0.5),
	Size = UDim2.fromOffset(700, 450),
	BackgroundTransparency = 1,
	BorderSizePixel = 0,
	ZIndex = 3,
}, Editor)

Stroke(CanvasBorder, Theme.Stroke, 1)

local Selection = New("Frame", {
	Name = "Selection",
	BackgroundTransparency = 1,
	BorderSizePixel = 0,
	Visible = false,
	ZIndex = 50,
}, Editor)

Stroke(Selection, Theme.Accent, 2)

local Handle = New("Frame", {
	Name = "ResizeHandle",
	Size = UDim2.fromOffset(16, 16),
	AnchorPoint = Vector2.new(0.5, 0.5),
	BackgroundColor3 = Theme.Accent,
	BorderSizePixel = 0,
	Visible = false,
	Active = true,
	ZIndex = 51,
}, Editor)

Corner(Handle, 8)
Stroke(Handle, Color3.new(1, 1, 1), 2)

function UpdateSelection()
	local g = GuiTarget

	if not g or not g.Parent or not g:IsDescendantOf(Canvas) then
		Selection.Visible = false
		Handle.Visible = false
		return
	end

	local pos = g.AbsolutePosition
	local size = g.AbsoluteSize
	local origin = Editor.AbsolutePosition

	Selection.Position = UDim2.fromOffset(
		pos.X - origin.X,
		pos.Y - origin.Y
	)

	Selection.Size = UDim2.fromOffset(
		size.X,
		size.Y
	)

	Handle.Position = UDim2.fromOffset(
		pos.X - origin.X + size.X,
		pos.Y - origin.Y + size.Y
	)

	Selection.Visible = true
	Handle.Visible = true
end

local Pending

local function Candidate(obj, input)
	local depth = 0

	if obj then
		local p = obj

		while p and p ~= Canvas do
			depth += 1
			p = p.Parent
		end
	end

	if Pending then
		if depth > Pending.depth then
			Pending.obj = obj
			Pending.depth = depth
		end

		return
	end

	local mine = {
		obj = obj,
		depth = depth
	}

	Pending = mine

	task.defer(function()
		if Pending == mine then
			Pending = nil
		end

		CloseMenus()

		if mine.obj and mine.obj.Parent then
			SetSelected(mine.obj)

			Drag.mode = "move"
			Drag.obj = mine.obj
			Drag.start = input.Position
			Drag.origin = mine.obj.Position
			Drag.moved = false
		else
			SetSelected(nil)
		end
	end)
end

local Hooked = setmetatable({}, {
	__mode = "k"
})

local function Hook(obj)
	if Hooked[obj] or not IsGuiObject(obj) then
		return
	end

	Hooked[obj] = true

	obj.InputBegan:Connect(function(input)
		if IsClick(input) then
			Candidate(obj, input)
		end
	end)

	if obj:IsA("TextBox") then
		obj.Focused:Connect(function()
			obj:ReleaseFocus()
		end)
	end

	for _, child in ipairs(obj:GetChildren()) do
		Hook(child)
	end
end

Canvas.InputBegan:Connect(function(input)
	if IsClick(input) then
		Candidate(nil, input)
	end
end)

local BG = Color3.fromRGB(45, 45, 52)

local ObjectDefaults = {
	Frame = {
		Size = UDim2.fromOffset(180, 100),
		BackgroundColor3 = BG
	},

	CanvasGroup = {
		Size = UDim2.fromOffset(180, 100),
		BackgroundColor3 = BG
	},

	TextLabel = {
		Size = UDim2.fromOffset(180, 40),
		BackgroundColor3 = BG,
		Text = "TextLabel",
		TextColor3 = Color3.new(1, 1, 1),
		Font = Enum.Font.GothamMedium,
		TextSize = 14,
	},

	TextButton = {
		Size = UDim2.fromOffset(180, 40),
		BackgroundColor3 = BG,
		Text = "TextButton",
		TextColor3 = Color3.new(1, 1, 1),
		Font = Enum.Font.GothamMedium,
		TextSize = 14,
	},

	TextBox = {
		Size = UDim2.fromOffset(180, 40),
		BackgroundColor3 = BG,
		Text = "TextBox",
		PlaceholderText = "Type here...",
		TextColor3 = Color3.new(1, 1, 1),
		Font = Enum.Font.GothamMedium,
		TextSize = 14,
		ClearTextOnFocus = false,
	},

	ImageLabel = {
		Size = UDim2.fromOffset(100, 100),
		BackgroundColor3 = BG
	},

	ImageButton = {
		Size = UDim2.fromOffset(100, 100),
		BackgroundColor3 = BG
	},

	ScrollingFrame = {
		Size = UDim2.fromOffset(200, 150),
		BackgroundColor3 = BG,
		CanvasSize = UDim2.fromOffset(0, 400),
		ScrollBarThickness = 4,
	},
}

local Addables = {
	"Frame",
	"CanvasGroup",
	"ScrollingFrame",
	"TextLabel",
	"TextButton",
	"TextBox",
	"ImageLabel",
	"ImageButton"
}

local ModifierInit = {
	UICorner = function(o)
		o.CornerRadius = UDim.new(0, 8)
	end,

	UIStroke = function(o)
		o.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		o.Color = Color3.fromRGB(0, 140, 255)
		o.Thickness = 2
	end,

	UIListLayout = function(o)
		o.Padding = UDim.new(0, 6)
		o.SortOrder = Enum.SortOrder.LayoutOrder
	end,

	UIGridLayout = function(o)
		o.CellSize = UDim2.fromOffset(80, 80)
		o.CellPadding = UDim2.fromOffset(6, 6)
		o.SortOrder = Enum.SortOrder.LayoutOrder
	end,

	UIGradient = function(o)
		o.Color = ColorSequence.new(
			Color3.fromRGB(0, 140, 255),
			Color3.fromRGB(150, 80, 235)
		)
		o.Rotation = 45
	end,

	UIPadding = function(o)
		o.PaddingTop = UDim.new(0, 8)
		o.PaddingBottom = UDim.new(0, 8)
		o.PaddingLeft = UDim.new(0, 8)
		o.PaddingRight = UDim.new(0, 8)
	end,

	UIScale = function(o)
		o.Scale = 1
	end,

	UIAspectRatioConstraint = function(o)
		o.AspectRatio = 1
	end,

	UISizeConstraint = function(o)
		o.MinSize = Vector2.new(20, 20)
		o.MaxSize = Vector2.new(1000, 1000)
	end,
}

local ModifierList = {
	"UICorner",
	"UIStroke",
	"UIGradient",
	"UIListLayout",
	"UIGridLayout",
	"UIPadding",
	"UIScale",
	"UIAspectRatioConstraint",
	"UISizeConstraint",
}

local function CreateObject(className, parent)
	local obj = Instance.new(className)

	for k, v in pairs(ObjectDefaults[className] or {}) do
		obj[k] = v
	end

	local n = #Canvas:GetChildren() % 6

	obj.Name = className
	obj.Position = UDim2.fromOffset(
		24 + n * 20,
		24 + n * 20
	)

	obj.BorderSizePixel = 0
	obj.Parent = parent or Canvas

	Hook(obj)

	return obj
end

local function AddModifierTo(target, className)
	local obj = Instance.new(className)
	local init = ModifierInit[className]

	if init then
		init(obj)
	end

	obj.Parent = target

	return obj
end

local function AddModifier(className)
	if not GuiTarget then
		Notify("Select an object first", Theme.Danger)
		return
	end

	local existing = GuiTarget:FindFirstChildOfClass(className)

	if existing then
		SetSelected(existing)
		return
	end

	local m = AddModifierTo(GuiTarget, className)

	SetSelected(m)
end

local function ResolveParent()
	local base = GuiTarget

	if base then
		if base:IsA("Frame")
			or base:IsA("ScrollingFrame")
			or base:IsA("CanvasGroup") then
			return base
		end

		if base.Parent and IsGuiObject(base.Parent) then
			return base.Parent
		end
	end

	return Canvas
end

local function DeleteSelected()
	if not Selected then
		return
	end

	local obj = Selected
	local nextSel = nil

	if not IsGuiObject(obj) then
		nextSel = GuiTarget
	elseif obj.Parent ~= Canvas and IsGuiObject(obj.Parent) then
		nextSel = obj.Parent
	end

	obj:Destroy()

	SetSelected(nextSel)
end

local function DuplicateSelected()
	local src = GuiTarget

	if not src or not src.Parent then
		return
	end

	local clone = src:Clone()
	local p = src.Position

	clone.Position = UDim2.new(
		p.X.Scale,
		p.X.Offset + 14,
		p.Y.Scale,
		p.Y.Offset + 14
	)

	clone.Parent = src.Parent

	Hook(clone)
	SetSelected(clone)
end

local function MakePanel(title, size, position, z)
	local frame = New("Frame", {
		Name = title,
		Size = size,
		Position = position,
		BackgroundColor3 = Theme.Panel,
		BorderSizePixel = 0,
		Active = true,
		Visible = false,
		ZIndex = z,
	}, ScreenGui)

	Corner(frame, 10)
	Stroke(frame, Theme.Stroke, 1)

	local header = New("Frame", {
		Size = UDim2.new(1, 0, 0, 36),
		BackgroundColor3 = Theme.Item,
		BorderSizePixel = 0,
	}, frame)

	Corner(header, 10)

	New("Frame", {
		Position = UDim2.new(0, 0, 1, -10),
		Size = UDim2.new(1, 0, 0, 10),
		BackgroundColor3 = Theme.Item,
		BorderSizePixel = 0,
	}, header)

	local titleLabel = New("TextLabel", {
		Position = UDim2.fromOffset(12, 0),
		Size = UDim2.new(1, -50, 1, 0),
		BackgroundTransparency = 1,
		Text = title,
		TextColor3 = Theme.Text,
		TextSize = 14,
		Font = Enum.Font.GothamBold,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextTruncate = Enum.TextTruncate.AtEnd,
	}, header)

	local close = Button({
		Position = UDim2.new(1, -32, 0, 5),
		Size = UDim2.fromOffset(26, 26),
		Text = "×",
		TextSize = 18,
	}, header, Theme.Item, Theme.DangerDark)

	close.MouseButton1Click:Connect(function()
		frame.Visible = false
	end)

	local body = New("ScrollingFrame", {
		Position = UDim2.fromOffset(6, 42),
		Size = UDim2.new(1, -12, 1, -48),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ScrollBarThickness = 3,
		ScrollBarImageColor3 = Theme.Stroke,
		CanvasSize = UDim2.new(),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
	}, frame)

	New("UIListLayout", {
		Padding = UDim.new(0, 4),
		SortOrder = Enum.SortOrder.LayoutOrder,
	}, body)

	Dragify(header, frame)

	return frame, body, titleLabel
end

UI.Explorer, UI.ExplorerBody = MakePanel(
	"Explorer",
	UDim2.new(0, 240, 0.55, 0),
	UDim2.fromOffset(10, 62),
	11
)

UI.Props, UI.PropBody, UI.PropTitle = MakePanel(
	"Properties",
	UDim2.new(0, 290, 0.8, 0),
	UDim2.new(1, -300, 0, 62),
	11
)

UI.Props.Visible = true

UI.Code, UI.CodeBody = MakePanel(
	"Generated Luau",
	UDim2.fromOffset(480, 380),
	UDim2.new(0.5, -240, 0.5, -190),
	30
)

local ExplorerQueued = false

function RefreshExplorer()
	if ExplorerQueued then
		return
	end

	ExplorerQueued = true

	task.defer(function()
		ExplorerQueued = false

		if not UI.Explorer.Visible then
			return
		end

		for _, c in ipairs(UI.ExplorerBody:GetChildren()) do
			if c:IsA("GuiObject") then
				c:Destroy()
			end
		end

		local order = 0

		local function add(obj, depth)
			order += 1

			local sel = obj == Selected

			local row = Button({
				Size = UDim2.new(1, -6, 0, 28),
				LayoutOrder = order,
			}, UI.ExplorerBody,
				sel and Theme.AccentDark or Theme.Panel,
				sel and Theme.Accent or Theme.ItemHover
			)

			local tag, col = MetaByClass(obj.ClassName)

			local badge = New("TextLabel", {
				Position = UDim2.fromOffset(
					6 + depth * 14,
					5
				),
				Size = UDim2.fromOffset(22, 18),
				BackgroundColor3 = col,
				BorderSizePixel = 0,
				Text = tag,
				TextColor3 = Color3.new(1, 1, 1),
				TextSize = 10,
				Font = Enum.Font.GothamBold,
			}, row)

			Corner(badge, 4)

			New("TextLabel", {
				Position = UDim2.fromOffset(
					34 + depth * 14,
					0
				),
				Size = UDim2.new(
					1,
					-40 - depth * 14,
					1,
					0
				),
				BackgroundTransparency = 1,
				Text = obj.Name,
				TextColor3 = Theme.Text,
				TextSize = 12,
				Font = Enum.Font.Gotham,
				TextXAlignment = Enum.TextXAlignment.Left,
				TextTruncate = Enum.TextTruncate.AtEnd,
			}, row)

			row.MouseButton1Click:Connect(function()
				if obj.Parent then
					SetSelected(obj)
				end
			end)

			for _, child in ipairs(obj:GetChildren()) do
				if Listed(child) then
					add(child, depth + 1)
				end
			end
		end

		for _, child in ipairs(Canvas:GetChildren()) do
			if Listed(child) then
				add(child, 0)
			end
		end

		if order == 0 then
			New("TextLabel", {
				Size = UDim2.new(1, -6, 0, 30),
				BackgroundTransparency = 1,
				Text = "Canvas is empty",
				TextColor3 = Theme.Sub,
				TextSize = 12,
				Font = Enum.Font.Gotham,
			}, UI.ExplorerBody)
		end
	end)
end

Canvas.DescendantAdded:Connect(RefreshExplorer)
Canvas.DescendantRemoving:Connect(RefreshExplorer)

local PaletteCallback

do
	local colors = {}

	local raw = {
		{ 0, 0, 0 },
		{ 40, 40, 45 },
		{ 80, 80, 90 },
		{ 120, 120, 130 },
		{ 160, 160, 170 },
		{ 200, 200, 208 },
		{ 235, 235, 240 },
		{ 255, 255, 255 },
		{ 235, 70, 70 },
		{ 255, 145, 50 },
		{ 255, 210, 60 },
		{ 150, 220, 60 },
		{ 60, 200, 120 },
		{ 30, 200, 200 },
		{ 0, 140, 255 },
		{ 90, 90, 235 },
		{ 150, 80, 235 },
		{ 235, 80, 180 },
		{ 255, 110, 130 },
		{ 140, 90, 55 },
		{ 20, 40, 90 },
		{ 20, 90, 50 },
		{ 100, 25, 35 },
		{ 90, 45, 110 },
		{ 255, 180, 180 },
		{ 255, 215, 170 },
		{ 255, 240, 170 },
		{ 200, 240, 170 },
		{ 170, 235, 200 },
		{ 170, 230, 240 },
		{ 170, 200, 255 },
		{ 210, 185, 255 },
	}

	for _, c in ipairs(raw) do
		colors[#colors + 1] = Color3.fromRGB(
			c[1],
			c[2],
			c[3]
		)
	end

	local frame = New("Frame", {
		Name = "Palette",
		Size = UDim2.fromOffset(236, 164),
		BackgroundColor3 = Theme.Panel,
		BorderSizePixel = 0,
		Active = true,
		Visible = false,
		ZIndex = 25,
	}, ScreenGui)

	Corner(frame, 10)
	Stroke(frame, Theme.Stroke, 1)

	New("TextLabel", {
		Size = UDim2.new(1, 0, 0, 28),
		BackgroundTransparency = 1,
		Text = "Colors",
		TextColor3 = Theme.Text,
		TextSize = 13,
		Font = Enum.Font.GothamBold,
	}, frame)

	local grid = New("Frame", {
		Position = UDim2.fromOffset(8, 32),
		Size = UDim2.new(1, -16, 1, -40),
		BackgroundTransparency = 1,
	}, frame)

	New("UIGridLayout", {
		CellSize = UDim2.fromOffset(24, 24),
		CellPadding = UDim2.fromOffset(4, 4),
		SortOrder = Enum.SortOrder.LayoutOrder,
	}, grid)

	for i, c in ipairs(colors) do
		local b = New("TextButton", {
			BackgroundColor3 = c,
			Text = "",
			AutoButtonColor = false,
			BorderSizePixel = 0,
			LayoutOrder = i,
		}, grid)

		Corner(b, 6)
		Stroke(b, Theme.Stroke, 1)

		b.MouseButton1Click:Connect(function()
			if PaletteCallback then
				PaletteCallback(c)
			end

			frame.Visible = false
		end)
	end

	UI.Palette = frame
end

function OpenPalette(callback, anchor)
	PaletteCallback = callback

	local vp = Viewport()

	local ax = anchor.AbsolutePosition.X
	local ay = anchor.AbsolutePosition.Y

	local x = math.clamp(
		ax - 246,
		6,
		math.max(6, vp.X - 242)
	)

	local y = math.clamp(
		ay - 20,
		58,
		math.max(58, vp.Y - 170)
	)

	UI.Palette.Position = UDim2.fromOffset(x, y)
	UI.Palette.Visible = true
end

local function TextInput(parent, pos, size)
	local box = New("TextBox", {
		Position = pos,
		Size = size,
		BackgroundColor3 = Theme.Item,
		TextColor3 = Theme.Text,
		PlaceholderColor3 = Theme.Sub,
		TextSize = 11,
		Font = Enum.Font.Gotham,
		ClearTextOnFocus = false,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextTruncate = Enum.TextTruncate.AtEnd,
		BorderSizePixel = 0,
		Text = "",
	}, parent)

	Corner(box, 5)

	local st = Stroke(box, Theme.Stroke, 1)

	Pad(box, 6, 0, 4, 0)

	box.Focused:Connect(function()
		Tween(st, {
			Color = Theme.Accent
		})
	end)

	box.FocusLost:Connect(function()
		Tween(st, {
			Color = Theme.Stroke
		})
	end)

	return box
end

local function Swatch(parent, pos)
	local sw = New("TextButton", {
		Position = pos,
		Size = UDim2.fromOffset(24, 22),
		BackgroundColor3 = Color3.new(1, 1, 1),
		Text = "",
		AutoButtonColor = false,
		BorderSizePixel = 0,
	}, parent)

	Corner(sw, 5)
	Stroke(sw, Theme.Stroke, 1)

	return sw
end

local function AddRow(target, name, order)
	local ok, value = pcall(function()
		return target[name]
	end)

	if not ok or value == nil then
		return
	end

	local t = typeof(value)

	local row = New("Frame", {
		Size = UDim2.new(1, -6, 0, 30),
		BackgroundTransparency = 1,
		LayoutOrder = order,
	}, UI.PropBody)

	New("TextLabel", {
		Size = UDim2.new(0.38, -4, 1, 0),
		BackgroundTransparency = 1,
		Text = name,
		TextColor3 = Theme.Sub,
		TextSize = 11,
		Font = Enum.Font.Gotham,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextTruncate = Enum.TextTruncate.AtEnd,
	}, row)

	local holder = New("Frame", {
		Position = UDim2.fromScale(0.38, 0),
		Size = UDim2.fromScale(0.62, 1),
		BackgroundTransparency = 1,
	}, row)

	local function read()
		local ok2, v = pcall(function()
			return target[name]
		end)

		if ok2 then
			return v
		end

		return nil
	end

	local function write(v)
		return pcall(function()
			target[name] = v
		end)
	end

	local function after()
		if name == "Name" then
			RefreshExplorer()
		end

		RefreshProperties()
	end

	if t == "boolean" then
		local btn = Button({
			Position = UDim2.fromOffset(0, 2),
			Size = UDim2.new(1, 0, 1, -4),
			TextSize = 11,
		}, holder)

		btn.MouseButton1Click:Connect(function()
			write(not read())
			after()
		end)

		table.insert(PropRefreshers, function()
			local v = read()
			local base = v and Theme.AccentDark or Theme.Item

			btn.Text = tostring(v)

			btn:SetAttribute("Base", base)
			btn:SetAttribute(
				"Hover",
				v and Theme.Accent or Theme.ItemHover
			)

			btn.BackgroundColor3 = base
		end)

	elseif t == "EnumItem" then
		local items = value.EnumType:GetEnumItems()

		local function step(dir)
			local cur = read()
			local idx = table.find(items, cur) or 1

			idx = ((idx - 1 + dir) % #items) + 1

			write(items[idx])
			after()
		end

		local prev = Button({
			Position = UDim2.fromOffset(0, 2),
			Size = UDim2.fromOffset(22, 26),
			Text = "‹",
			TextSize = 16,
		}, holder)

		local mid = Button({
			Position = UDim2.new(0, 24, 0, 2),
			Size = UDim2.new(1, -48, 1, -4),
			TextSize = 11,
		}, holder)

		local nxt = Button({
			Position = UDim2.new(1, -22, 0, 2),
			Size = UDim2.fromOffset(22, 26),
			Text = "›",
			TextSize = 16,
		}, holder)

		prev.MouseButton1Click:Connect(function()
			step(-1)
		end)

		nxt.MouseButton1Click:Connect(function()
			step(1)
		end)

		mid.MouseButton1Click:Connect(function()
			step(1)
		end)

		table.insert(PropRefreshers, function()
			local v = read()

			if v then
				mid.Text = v.Name
			end
		end)

	elseif t == "Color3" then
		local sw = Swatch(
			holder,
			UDim2.fromOffset(0, 4)
		)

		local box = TextInput(
			holder,
			UDim2.fromOffset(30, 2),
			UDim2.new(1, -30, 1, -4)
		)

		local shown = ""

		sw.MouseButton1Click:Connect(function()
			OpenPalette(function(c)
				write(c)
				after()
			end, sw)
		end)

		box.FocusLost:Connect(function()
			if box.Text == shown then
				return
			end

			local nv = ParseValue(read(), box.Text)

			if nv ~= nil and write(nv) then
				after()
			else
				box.Text = shown
			end
		end)

		table.insert(PropRefreshers, function()
			local v = read()

			sw.BackgroundColor3 = v

			if not box:IsFocused() then
				shown = FormatValue(v)
				box.Text = shown
			end
		end)

	elseif t == "ColorSequence" then
		local sw1 = Swatch(
			holder,
			UDim2.fromOffset(0, 4)
		)

		local sw2 = Swatch(
			holder,
			UDim2.fromOffset(28, 4)
		)

		local box = TextInput(
			holder,
			UDim2.fromOffset(56, 2),
			UDim2.new(1, -56, 1, -4)
		)

		local shown = ""

		local function setStop(index, c)
			local cur = read()
			local kp = cur.Keypoints

			local c1 = kp[1].Value
			local c2 = kp[#kp].Value

			if index == 1 then
				c1 = c
			else
				c2 = c
			end

			write(ColorSequence.new(c1, c2))
			after()
		end

		sw1.MouseButton1Click:Connect(function()
			OpenPalette(function(c)
				setStop(1, c)
			end, sw1)
		end)

		sw2.MouseButton1Click:Connect(function()
			OpenPalette(function(c)
				setStop(2, c)
			end, sw2)
		end)

		box.FocusLost:Connect(function()
			if box.Text == shown then
				return
			end

			local nv = ParseValue(read(), box.Text)

			if nv ~= nil and write(nv) then
				after()
			else
				box.Text = shown
			end
		end)

		table.insert(PropRefreshers, function()
			local v = read()
			local kp = v.Keypoints

			sw1.BackgroundColor3 = kp[1].Value
			sw2.BackgroundColor3 = kp[#kp].Value

			if not box:IsFocused() then
				shown = FormatValue(v)
				box.Text = shown
			end
		end)

	else
		local box = TextInput(
			holder,
			UDim2.fromOffset(0, 2),
			UDim2.new(1, 0, 1, -4)
		)

		local shown = ""

		box.FocusLost:Connect(function()
			if box.Text == shown then
				return
			end

			local nv = ParseValue(read(), box.Text)

			if nv ~= nil and write(nv) then
				after()
			else
				box.Text = shown
			end
		end)

		table.insert(PropRefreshers, function()
			if not box:IsFocused() then
				shown = FormatValue(read())
				box.Text = shown
			end
		end)
	end
end

function RefreshProperties()
	for _, fn in ipairs(PropRefreshers) do
		pcall(fn)
	end
end

function BuildProperties()
	for _, c in ipairs(UI.PropBody:GetChildren()) do
		if c:IsA("GuiObject") then
			c:Destroy()
		end
	end

	table.clear(PropRefreshers)

	if not Selected or not Selected.Parent then
		UI.PropTitle.Text = "Properties"

		New("TextLabel", {
			Size = UDim2.new(1, -6, 0, 40),
			BackgroundTransparency = 1,
			Text = "Nothing selected",
			TextColor3 = Theme.Sub,
			TextSize = 12,
			Font = Enum.Font.Gotham,
		}, UI.PropBody)

		return
	end

	UI.PropTitle.Text = "Properties · " .. Selected.ClassName

	local order = 0

	for _, sec in ipairs(Schema) do
		if Matches(Selected, sec[2]) then
			order += 1

			New("TextLabel", {
				Size = UDim2.new(1, -6, 0, 22),
				BackgroundTransparency = 1,
				Text = string.upper(sec[1]),
				TextColor3 = Theme.Accent,
				TextSize = 10,
				Font = Enum.Font.GothamBold,
				TextXAlignment = Enum.TextXAlignment.Left,
				LayoutOrder = order,
			}, UI.PropBody)

			for _, name in ipairs(sec[3]) do
				order += 1
				AddRow(Selected, name, order)
			end
		end
	end

	RefreshProperties()
end

function UpdateToolbar()
	local has = Selected ~= nil

	for _, b in ipairs({
		UI.BtnStyle,
		UI.BtnDup,
		UI.BtnDel,
		UI.BtnProps
	}) do
		if b then
			b.Visible = has
		end
	end
end

function SetSelected(obj)
	Selected = obj

	if obj and obj:IsA("GuiObject") then
		GuiTarget = obj
	elseif obj and obj.Parent and obj.Parent:IsA("GuiObject") then
		GuiTarget = obj.Parent
	else
		GuiTarget = nil
	end

	BuildProperties()
	RefreshExplorer()
	UpdateSelection()
	UpdateToolbar()
end

local function MakePopup(title, classes, onPick)
	local frame = New("Frame", {
		Name = title,
		Size = UDim2.fromOffset(
			210,
			36 + #classes * 32 + 6
		),
		BackgroundColor3 = Theme.Panel,
		BorderSizePixel = 0,
		Active = true,
		Visible = false,
		ZIndex = 20,
	}, ScreenGui)

	Corner(frame, 10)
	Stroke(frame, Theme.Stroke, 1)

	New("TextLabel", {
		Size = UDim2.new(1, 0, 0, 32),
		BackgroundTransparency = 1,
		Text = title,
		TextColor3 = Theme.Text,
		TextSize = 14,
		Font = Enum.Font.GothamBold,
	}, frame)

	local list = New("Frame", {
		Position = UDim2.fromOffset(6, 34),
		Size = UDim2.new(1, -12, 1, -40),
		BackgroundTransparency = 1,
	}, frame)

	New("UIListLayout", {
		Padding = UDim.new(0, 4),
		SortOrder = Enum.SortOrder.LayoutOrder,
	}, list)

	for i, className in ipairs(classes) do
		local btn = Button({
			Size = UDim2.new(1, 0, 0, 28),
			LayoutOrder = i,
		}, list)

		local tag, col = MetaByClass(className)

		local badge = New("TextLabel", {
			Position = UDim2.fromOffset(6, 5),
			Size = UDim2.fromOffset(22, 18),
			BackgroundColor3 = col,
			BorderSizePixel = 0,
			Text = tag,
			TextColor3 = Color3.new(1, 1, 1),
			TextSize = 10,
			Font = Enum.Font.GothamBold,
		}, btn)

		Corner(badge, 4)

		New("TextLabel", {
			Position = UDim2.fromOffset(36, 0),
			Size = UDim2.new(1, -42, 1, 0),
			BackgroundTransparency = 1,
			Text = className,
			TextColor3 = Theme.Text,
			TextSize = 12,
			Font = Enum.Font.GothamMedium,
			TextXAlignment = Enum.TextXAlignment.Left,
		}, btn)

		btn.MouseButton1Click:Connect(function()
			frame.Visible = false
			onPick(className)
		end)
	end

	return frame
end

UI.AddMenu = MakePopup(
	"Add Object",
	Addables,
	function(className)
		local obj = CreateObject(
			className,
			ResolveParent()
		)

		SetSelected(obj)
	end
)

UI.StyleMenu = MakePopup(
	"Add Style",
	ModifierList,
	AddModifier
)

function CloseMenus()
	UI.AddMenu.Visible = false
	UI.StyleMenu.Visible = false
	UI.Palette.Visible = false
end

local function OpenPopup(popup, anchor)
	local was = popup.Visible

	CloseMenus()

	if was then
		return
	end

	local vp = Viewport()

	local x = math.clamp(
		anchor.AbsolutePosition.X,
		6,
		math.max(
			6,
			vp.X - popup.AbsoluteSize.X - 6
		)
	)

	popup.Position = UDim2.fromOffset(x, 60)
	popup.Visible = true
end

function Notify(text, color)
	local f = New("Frame", {
		AnchorPoint = Vector2.new(0.5, 1),
		Position = UDim2.new(0.5, 0, 1, -24),
		Size = UDim2.fromOffset(0, 38),
		AutomaticSize = Enum.AutomaticSize.X,
		BackgroundColor3 = Theme.Panel,
		BorderSizePixel = 0,
		ZIndex = 40,
	}, ScreenGui)

	Corner(f, 8)
	Stroke(f, color or Theme.Accent, 1)
	Pad(f, 16, 0, 16, 0)

	New("TextLabel", {
		Size = UDim2.fromOffset(0, 38),
		AutomaticSize = Enum.AutomaticSize.X,
		BackgroundTransparency = 1,
		Text = text,
		TextColor3 = Theme.Text,
		TextSize = 13,
		Font = Enum.Font.GothamMedium,
	}, f)

	task.delay(2.2, function()
		if f.Parent then
			f:Destroy()
		end
	end)
end

local DefaultCache = {}

local function GetDefault(className)
	if DefaultCache[className] == nil then
		local ok, inst = pcall(
			Instance.new,
			className
		)

		DefaultCache[className] = ok and inst or false
	end

	return DefaultCache[className]
end

local function SafeName(str)
	local s = tostring(str):gsub(
		"[^%w_]",
		""
	)

	if s == "" then
		s = "Object"
	end

	return s
end

local function Generate(
	obj,
	depth,
	parentVar,
	lines,
	state
)
	state.n += 1

	local var = SafeName(obj.Name) .. "_" .. state.n
	local pad = string.rep("\t", depth)
	local inner = pad .. "\t"
	local default = GetDefault(obj.ClassName)

	table.insert(
		lines,
		pad .. "do"
	)

	table.insert(
		lines,
		inner ..
		"local " ..
		var ..
		" = Instance.new(" ..
		string.format("%q", obj.ClassName) ..
		")"
	)

	for _, sec in ipairs(Schema) do
		if Matches(obj, sec[2]) then
			for _, name in ipairs(sec[3]) do
				local ok, v = pcall(function()
					return obj[name]
				end)

				if ok and v ~= nil then
					local lv = LuaValue(v)

					if lv then
						local dv

						if default then
							local ok2, d = pcall(function()
								return default[name]
							end)

							if ok2 and d ~= nil then
								dv = LuaValue(d)
							end
						end

						if name == "Name" or lv ~= dv then
							table.insert(
								lines,
								inner ..
								var ..
								"." ..
								name ..
								" = " ..
								lv
							)
						end
					end
				end
			end
		end
	end

	for _, child in ipairs(obj:GetChildren()) do
		if Listed(child) then
			Generate(
				child,
				depth + 1,
				var,
				lines,
				state
			)
		end
	end

	table.insert(
		lines,
		inner ..
		var ..
		".Parent = " ..
		parentVar
	)

	table.insert(
		lines,
		pad .. "end"
	)
end

local function ExtractCode()
	local lines = {
		'local ScreenGui = Instance.new("ScreenGui")',
		'ScreenGui.Name = "GeneratedGUI"',
		"ScreenGui.ResetOnSpawn = false",
		'ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling',
		'ScreenGui.Parent = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")',
		"",
		'local Canvas = Instance.new("Frame")',
		'Canvas.Name = "Canvas"',
		"Canvas.AnchorPoint = Vector2.new(0.5, 0.5)",
		"Canvas.Position = UDim2.new(0.5, 0, 0.5, 0)",
		"Canvas.Size = UDim2.new(0, 700, 0, 450)",
		"Canvas.BackgroundTransparency = 1",
		"Canvas.BorderSizePixel = 0",
		"Canvas.Parent = ScreenGui",
		"",
	}

	local state = {
		n = 0
	}

	for _, obj in ipairs(Canvas:GetChildren()) do
		if Listed(obj) then
			Generate(
				obj,
				0,
				"Canvas",
				lines,
				state
			)

			table.insert(lines, "")
		end
	end

	for k, inst in pairs(DefaultCache) do
		if inst then
			inst:Destroy()
		end

		DefaultCache[k] = nil
	end

	local source = table.concat(
		lines,
		"\n"
	)

	UI.CodeBox.Text = source
	UI.Code.Visible = true

	if setclipboard then
		local ok = pcall(
			setclipboard,
			source
		)

		if ok then
			Notify(
				"Luau copied to clipboard!",
				Theme.Success
			)

			return
		end
	end

	Notify(
		"Code generated",
		Theme.Accent
	)
end

do
	local copyBtn = Button({
		Size = UDim2.new(1, -6, 0, 32),
		Text = "Copy to clipboard",
		TextSize = 13,
		LayoutOrder = 1,
	}, UI.CodeBody, Theme.AccentDark, Theme.Accent)

	UI.CodeBox = New("TextBox", {
		Size = UDim2.new(1, -6, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundColor3 = Theme.Bg,
		BorderSizePixel = 0,
		TextColor3 = Theme.Text,
		TextSize = 12,
		Font = Enum.Font.Code,
		MultiLine = true,
		TextWrapped = true,
		ClearTextOnFocus = false,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Top,
		Text = "",
		LayoutOrder = 2,
	}, UI.CodeBody)

	Corner(UI.CodeBox, 6)
	Pad(UI.CodeBox, 8, 8, 8, 8)

	copyBtn.MouseButton1Click:Connect(function()
		if setclipboard then
			local ok = pcall(
				setclipboard,
				UI.CodeBox.Text
			)

			if ok then
				Notify(
					"Copied!",
					Theme.Success
				)

				return
			end
		end

		Notify(
			"Clipboard unavailable - copy manually",
			Theme.Danger
		)
	end)
end

do
	local bar = New("Frame", {
		Name = "Toolbar",
		Size = UDim2.new(1, 0, 0, 52),
		BackgroundColor3 = Theme.Panel,
		BorderSizePixel = 0,
		Active = true,
		ZIndex = 10,
	}, ScreenGui)

	Stroke(bar, Theme.Stroke, 1)

	local scroll = New("ScrollingFrame", {
		Position = UDim2.fromOffset(8, 0),
		Size = UDim2.new(1, -16, 1, 0),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ScrollBarThickness = 0,
		ScrollingDirection = Enum.ScrollingDirection.X,
		CanvasSize = UDim2.new(),
		AutomaticCanvasSize = Enum.AutomaticSize.X,
	}, bar)

	New("UIListLayout", {
		FillDirection = Enum.FillDirection.Horizontal,
		VerticalAlignment = Enum.VerticalAlignment.Center,
		SortOrder = Enum.SortOrder.LayoutOrder,
		Padding = UDim.new(0, 6),
	}, scroll)

	local order = 0

	local function ToolButton(
		text,
		width,
		base,
		hover
	)
		order += 1

		return Button({
			Size = UDim2.fromOffset(width, 34),
			Text = text,
			TextSize = 12,
			LayoutOrder = order,
		}, scroll, base, hover)
	end

	order += 1

	New("TextLabel", {
		Size = UDim2.fromOffset(104, 34),
		BackgroundTransparency = 1,
		Text = "GUI Studio",
		TextColor3 = Theme.Accent,
		TextSize = 15,
		Font = Enum.Font.GothamBold,
		LayoutOrder = order,
	}, scroll)

	local btnExplorer = ToolButton(
		"Explorer",
		78
	)

	local btnAdd = ToolButton(
		"+ Add",
		66,
		Theme.AccentDark,
		Theme.Accent
	)

	UI.BtnStyle = ToolButton(
		"Style",
		62
	)

	UI.BtnDup = ToolButton(
		"Duplicate",
		80
	)

	UI.BtnDel = ToolButton(
		"Delete",
		66,
		Theme.DangerDark,
		Theme.Danger
	)

	UI.BtnProps = ToolButton(
		"Props",
		62
	)

	local btnExtract = ToolButton(
		"Extract",
		74,
		Color3.fromRGB(30, 140, 85),
		Theme.Success
	)

	btnExplorer.MouseButton1Click:Connect(function()
		CloseMenus()

		UI.Explorer.Visible = not UI.Explorer.Visible

		if UI.Explorer.Visible then
			RefreshExplorer()
		end
	end)

	btnAdd.MouseButton1Click:Connect(function()
		OpenPopup(
			UI.AddMenu,
			btnAdd
		)
	end)

	UI.BtnStyle.MouseButton1Click:Connect(function()
		OpenPopup(
			UI.StyleMenu,
			UI.BtnStyle
		)
	end)

	UI.BtnDup.MouseButton1Click:Connect(function()
		CloseMenus()
		DuplicateSelected()
	end)

	UI.BtnDel.MouseButton1Click:Connect(function()
		CloseMenus()
		DeleteSelected()
	end)

	UI.BtnProps.MouseButton1Click:Connect(function()
		CloseMenus()

		UI.Props.Visible = not UI.Props.Visible

		if UI.Props.Visible then
			BuildProperties()
		end
	end)

	btnExtract.MouseButton1Click:Connect(function()
		CloseMenus()
		ExtractCode()
	end)
end

Handle.InputBegan:Connect(function(input)
	if not GuiTarget or not IsClick(input) then
		return
	end

	Drag.mode = "resize"
	Drag.obj = GuiTarget
	Drag.start = input.Position
	Drag.origin = GuiTarget.Size
end)

Track(UserInputService.InputChanged:Connect(function(input)
	if not Drag.mode or not IsMove(input) then
		return
	end

	local obj = Drag.obj

	if not obj or not obj.Parent then
		Drag.mode = nil
		return
	end

	local d = input.Position - Drag.start

	if Drag.mode == "move" then
		if not Drag.moved and d.Magnitude < 3 then
			return
		end

		Drag.moved = true

		local o = Drag.origin

		obj.Position = UDim2.new(
			o.X.Scale,
			math.round(o.X.Offset + d.X),
			o.Y.Scale,
			math.round(o.Y.Offset + d.Y)
		)

	elseif Drag.mode == "resize" then
		local o = Drag.origin

		local nx = math.round(
			o.X.Offset + d.X
		)

		local ny = math.round(
			o.Y.Offset + d.Y
		)

		if o.X.Scale == 0 then
			nx = math.max(8, nx)
		end

		if o.Y.Scale == 0 then
			ny = math.max(8, ny)
		end

		obj.Size = UDim2.new(
			o.X.Scale,
			nx,
			o.Y.Scale,
			ny
		)
	end
end))

Track(UserInputService.InputEnded:Connect(function(input)
	if IsClick(input) and Drag.mode then
		Drag.mode = nil
		RefreshProperties()
	end
end))

Track(UserInputService.InputBegan:Connect(function(input, processed)
	if UserInputService:GetFocusedTextBox() then
		return
	end

	if input.KeyCode == Enum.KeyCode.Delete
		or input.KeyCode == Enum.KeyCode.Backspace then

		DeleteSelected()

	elseif input.KeyCode == Enum.KeyCode.D
		and (
			UserInputService:IsKeyDown(Enum.KeyCode.LeftControl)
			or UserInputService:IsKeyDown(Enum.KeyCode.RightControl)
		) then

		DuplicateSelected()

	elseif input.KeyCode == Enum.KeyCode.Escape then
		CloseMenus()
		SetSelected(nil)
	end
end))

local lastRefresh = 0

Track(RunService.RenderStepped:Connect(function()
	if Selected and not Selected:IsDescendantOf(Canvas) then
		SetSelected(nil)
	end

	UpdateSelection()

	if Drag.mode and os.clock() - lastRefresh > 0.1 then
		lastRefresh = os.clock()
		RefreshProperties()
	end
end))

local first = CreateObject(
	"Frame",
	Canvas
)

AddModifierTo(
	first,
	"UICorner"
)

AddModifierTo(
	first,
	"UIStroke"
)

SetSelected(first)
RefreshExplorer()
