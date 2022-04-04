local Parent=script.Parent
local function attributeChanged()
	Parent.BrickColor=Parent:GetAttribute("Team")
	Parent.BillboardGui.TextLabel.Text=Parent:GetAttribute("Value")
end

Parent.AttributeChanged:Connect(attributeChanged)