RegisterNetEvent('s_quiz:answerForm', function(question, secret)
	AddTextEntry('FMMC_KEY_TIP8', question)
	DisplayOnscreenKeyboard(1, "FMMC_KEY_TIP8", "", "", "", "", "", 99)

	while UpdateOnscreenKeyboard() ~= 1 and UpdateOnscreenKeyboard() ~= 2 do
		Citizen.Wait( 0 )
	end

	local clientAnswer = GetOnscreenKeyboardResult()
	TriggerServerEvent('s_quiz:answer', clientAnswer, secret)
end)

CreateThread(function()
	if Config.AlternateMethod then
		TriggerEvent('chat:addSuggestion','/'..Config.CommandName, 'Type your answer')
	end
end)
