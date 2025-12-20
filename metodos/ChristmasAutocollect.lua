local Players = game:GetService("Players")
	local RunService = game:GetService("RunService")

	local player = Players.LocalPlayer
	local character = player.Character or player.CharacterAdded:Wait()
	local humanoid = character:WaitForChild("Humanoid")
	local root = character:WaitForChild("HumanoidRootPart")

	local folder = workspace.EventSpace.Components.Snowflakes

	local tempomaximo = 2
	local delaypracongelar = 0.2
	local tiltseilaoq = math.rad(15)
	local velocidadedaoscilacao = 3
	local quantidadedaoscilacao = math.rad(3)

	local running = false
	local index = 1
	local processed = 0
	local total = 0

	local currentModel
	local startTime
	local basePosition

	local originalCFrame
	local originalWalkSpeed

	local rotateConn

	local function stopAutoCollect()
		if not running then return end
		running = false

		if rotateConn then
			rotateConn:Disconnect()
			rotateConn = nil
		end

		humanoid.WalkSpeed = originalWalkSpeed
		root.CFrame = originalCFrame

		index = 1
		processed = 0
		currentModel = nil
	end

	local function startAutoCollect()
		if running then return end

		local models = folder:GetChildren()
		if #models == 0 then return end

		running = true

		originalCFrame = root.CFrame
		originalWalkSpeed = humanoid.WalkSpeed

		total = #models
		index = 1
		processed = 0

		currentModel = models[index]

		root.CFrame = CFrame.new(currentModel:GetPivot().Position)
		basePosition = root.Position

		task.delay(delaypracongelar, function()
			if not running then return end

			humanoid.WalkSpeed = 0
			startTime = tick()

			rotateConn = RunService.RenderStepped:Connect(function()
				if not running then return end

				if tick() - startTime >= tempomaximo then
					processed += 1

					if processed >= total then
						stopAutoCollect()
						return
					end

					index += 1
					currentModel = folder:GetChildren()[index]
					startTime = tick()

					root.CFrame = CFrame.new(currentModel:GetPivot().Position)
					basePosition = root.Position
					return
				end

				local osc = math.sin(tick() * velocidadedaoscilacao) * quantidadedaoscilacao

				root.CFrame =
					CFrame.new(basePosition) *
					CFrame.Angles(tiltseilaoq, 0, osc)
			end)
		end)
	end
startAutoCollect()
