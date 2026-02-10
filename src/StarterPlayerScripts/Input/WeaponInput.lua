local UIS = game:GetService("UserInputService")
local SKILL_E = "SkillE"
local SKILL_R = "SkillR"


local WeaponInput = {}
WeaponInput._bound = false

function WeaponInput.Bind(onSkill)
	if WeaponInput._bound then return end
	WeaponInput._bound = true

	UIS.InputBegan:Connect(function(input, gp)
		if gp then return end

		if input.KeyCode == Enum.KeyCode.E then
			onSkill(SKILL_E)
		elseif input.KeyCode == Enum.KeyCode.R then
			onSkill(SKILL_R)
		end
	end)
end

return WeaponInput
