TextField = {}

function TextField.create(properties)
	if type(properties) ~= "table" then
		properties = {}
	end
	
	local widget = Widget.create(properties)
	widget.text = properties.text or ""
	widget.font = properties.font or "default"
	widget.alignX = properties.alignX
	widget.alignY = properties.alignY
	widget.clip = not not properties.clip
	widget.wordBreak = not not properties.wordBreak
	widget.colorCoded = not not properties.colorCoded

	function widget:draw()
		Drawing.setFont(self.font)
		Drawing.text(
			self.x, 
			self.y, 
			self.width, 
			self.height, 
			self.text, 
			self.alignX, 
			self.alignY, 
			self.clip, 
			self.wordBreak, 
			self.colorCoded
		)
	end
	return widget
end