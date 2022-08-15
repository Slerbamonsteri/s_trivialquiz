ESX = nil
local minute = 60000
local timer
local currentAnswer = nil
local currentQuestion = nil
local quizAnswered = false
local secret = ''
local loopStarted = false

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

CreateThread(function()
    local token = 'ipfgdjn'..math.random(1,43556)..'dgfdfg' --Let's create some security for our payout event !
    secret = token
    Wait(100)
    TriggerEvent('s_quiz:broadcast')
    if not Config.AlternateMethod then
        RegisterCommand(Config.CommandName, function(source)
            local xPlayer = ESX.GetPlayerFromId(source)
            if not quizAnswered then
                TriggerClientEvent('s_quiz:answerForm', source, currentQuestion, secret)
            else --Change notifications to your likings, mine is integrated as mythic_notify so html stuff won't work with yours if you are using default notif style
                xPlayer.showNotification('Question has already been answered! <br> <br>New question in: <span style="color:green"><i><strong>'..math.floor(timer/1)..'min<i></strong></span>')
            end
        end)
    else
        RegisterCommand(Config.CommandName, function(source, args, msg)
            for k,v in pairs(args) do
                clientAnswer = v
            end
            local xPlayer = ESX.GetPlayerFromId(source)
            if not quizAnswered then
                TriggerEvent('s_quiz:answer',clientAnswer, secret, source)
            else --Change notifications to your likings, mine is integrated as mythic_notify so html stuff won't work with yours if you are using default notif style
                xPlayer.showNotification('Question has already been answered! <br> <br>New question in: <span style="color:green"><i><strong>'..math.floor(timer/1)..'min<i></strong></span>')
            end
        end)
    end
end)


local quizTable = { --Add as many questions you want to, just remember to stay within logic. [1], [2], [3], [4], and so on.
    [1] = { question = 'What was Ketchup used back in the days?', answer = 'medicine'},
    [2] = { question = 'What is the capital city of Spain?', answer = 'madrid'},
    [3] = { question = 'What is a Rolex?', answer = 'watch'},
}


--#### CONFIGURATION ENDS ####----


RegisterServerEvent('s_quiz:broadcast', function() --Only server should call this (Refreshes question)
    local random = math.random(1, #quizTable) --Randomizes question from quiz -table
    currentAnswer = quizTable[random].answer
    currentQuestion = quizTable[random].question
    TriggerClientEvent('chat:addMessage', -1, {--Dont mind this mad oneliner, just me experimenting with html :)
        template = '<div style="padding: 0.9vw; margin: 0.5vw; border: 2px solid white; background-color: rgba(38, 38, 38, 0.6); border-radius: 13px;"><i><span style="color:violet">Tietovisa kysymys:</i></span><br><br><samp>{0} </samp><br><small><br>Vastaa: <i><span style="color:violet">'..Config.CommandName..'</span></i> </small> </span></span></div>',
        args = {quizTable[random].question }
    })
    if not loopStarted then
        timer = Config.NewQuestion --change last number to adjust how often new question gets broadcasted -- Currently 5 = every 5 minutes
        loopStarted = true
        while timer >= 0 do --Should automatically loop this shit
            timer = timer - 1
            Wait(minute)
            if timer <= 0 then
                currentAnswer = nil
                quizAnswered = false
                loopStarted = false
                TriggerEvent('s_quiz:broadcast')
                break
            end
        end
    else
        print('loop is already started!')
    end
end)

RegisterServerEvent('s_quiz:answer', function(answer, token, source)
    local xPlayer = ESX.GetPlayerFromId(source)
    local winnings = math.random(Config.payoutMin,Config.payoutMax)
    if secret == token then --Checking that the trigger was legit
        if answer == nil then xPlayer.showNotification('You forgot to type the answer!') return end --Checking that the player has actually sent something as an answer
        if string.gsub(answer:lower(), '^%s*(.-)%s*$', '%1') == string.gsub(currentAnswer:lower(), '^%s*(.-)%s*$', '%1') then --Making sure player answer matches current question, also a slim layer of protection
            if not quizAnswered then
                winningLog(3312434, 's_quizsystem Logging', '\n\nPlayer: **'..GetPlayerName(source)..'**\n\n Won: **'..winnings..'$** from Quiz!', 's_quizLog')
                xPlayer.addAccountMoney('bank', winnings)
                xPlayer.showNotification('You won: '..winnings..'€ from the quiz!')
                quizAnswered = true
            else
                xPlayer.showNotification('The question has already been answered!')
            end
        else
            xPlayer.showNotification('Wrong answer!')
        end
    else --Automatically logs if someone tries to bypass security and mod money with the event
        modder(12434, 's_quizsystem Logging', '\n**SECURITY BREACH**\n\nPlayer: **'..GetPlayerName(source)..'**\n\n Tried to execute event without security token! -- Admins take action!', 's_quizLog')
    end
end)

----##### Logging stuff ####----

local cheaterWebhook = 'ENTER WEBHOOK'
local winnerLogwebhook = 'ENTER WEBHOOK'
function modder(color, name, message, footer)
    local embed = {
          {
              ["color"] = color,
              ["title"] = "**".. name .."**",
              ["description"] = message,
              ["footer"] = {
                  ["text"] = footer,
              },
          }
      }
  
    PerformHttpRequest(cheaterWebhook, function(err, text, headers) end, 'POST', json.encode({username = name, embeds = embed}), { ['Content-Type'] = 'application/json' })
  end

  function winningLog(color, name, message, footer)
    local embed = {
          {
              ["color"] = color,
              ["title"] = "**".. name .."**",
              ["description"] = message,
              ["footer"] = {
                  ["text"] = footer,
              },
          }
      }
  
    PerformHttpRequest(winnerLogwebhook, function(err, text, headers) end, 'POST', json.encode({username = name, embeds = embed}), { ['Content-Type'] = 'application/json' })
  end
