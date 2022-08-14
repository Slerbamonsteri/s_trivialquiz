ESX = nil
local minute = 60000
local timer
local currentAnswer = nil
local fetchStatus = false
local quizAnswered = false
local secret = ''


----#### CONFIGURATION ####----
local CommandName = 'entercommandhere' --Add your wanted command here which should be used to answer in quiz
local NewQuestion = 10 --How often should new quiz be broadcast to players (in minutes)
--Payout
local payoutMin = 2500 --Set how much should player win from trivia (min)
local payoutMax = 10000 --Set how much should player win from trivia (max)
--Payout is something between what you set in those
local quizTable = { --Add as many questions you want to, just remember to stay within logic. [1], [2], [3], [4], and so on.
    [1] = { question = 'What was Ketchup used back in the days?', answer = 'medicine'},
    [2] = { question = 'What is the capital city of Spain?', answer = 'madrid'},
    [3] = { question = 'What is a Rolex?', answer = 'watch'},
}

RegisterCommand(CommandName, function(source)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not quizAnswered then
        TriggerClientEvent('s_quiz:answerForm', source, questionData.question, secret)
    else --Change notifications to your likings, mine is integrated as mythic_notify so html stuff won't work with yours if you are using default notif style
        xPlayer.showNotification('Question has already been answered! <br> <br>New question in: <span style="color:green"><i><strong>'..math.floor(timer/1)..'min<i></strong></span>')
    end
end)


--#### CONFIGURATION ENDS ####----

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

CreateThread(function()
    local token = 'ipfgdjn'..math.random(1,43556)..'dgfdfg' --Let's create some security for our payout event !
    secret = token
    Wait(1000) --Lets give some time just incase.
    TriggerEvent('s_quiz:broadcast')
end)


RegisterServerEvent('s_quiz:broadcast', function() --Only server should call this (Refreshes question)
    timer = NewQuestion --change last number to adjust how often new question gets broadcasted -- Currently 5 = every 5 minutes
    local random = math.random(1, #quizTable) --Randomizes question from quiz -table
    for k,v in pairs(quizTable) do
        if v.question == quizTable[random].question and v.answer == quizTable[random].answer then --Not sure if needed to do like this but it seems to work so let's do it anyway
            currentAnswer = v.answer
            questionData = {
                question = v.question,
                answer = v.answer,
            }
            TriggerClientEvent('chat:addMessage', -1, {--Dont mind this mad oneliner, just me experimenting with html :)
                template = '<div style="padding: 0.9vw; margin: 0.5vw; border: 2px solid white; background-color: rgba(38, 38, 38, 0.6); border-radius: 13px;"><i><span style="color:violet">Trivia Questions:</i></span><br><br><samp>{0} </samp><br><small><br>To answer do: <i><span style="color:violet">/'..CommandName..'</span></i> </small> </span></span></div>',
                args = {questionData.question }
            })
        end
    end
    while tonumber(timer) >= tonumber(NewQuestion) do --Should automatically loop this shit
        timer = timer - (minute / 60000)
        Wait(minute)
        if timer == 0 then
            currentAnswer = nil
            quizAnswered = false
            TriggerEvent('s_quiz:broadcast')
        end
    end
end)

RegisterServerEvent('s_quiz:answer', function(answer, token)
    local xPlayer = ESX.GetPlayerFromId(source)
    local winnings = math.random(payoutMin, payoutMax)
    if secret == token then
        if string.gsub(answer:lower(), '^%s*(.-)%s*$', '%1') == string.gsub(currentAnswer:lower(), '^%s*(.-)%s*$', '%1') then --Making sure player answer matches current question, also a slim layer of protection
            if not quizAnswered then
                modder(3312434, 's_quizsystem Logging', '\n\nPlayer: **'..GetPlayerName(source)..'**\n\n Won: **'..winnings..'$** from quiz!', 's_quizLog')
                xPlayer.addAccountMoney('bank', winnings)
                xPlayer.showNotification('You have won: '..winnings..'€ from trivia!')
                quizAnswered = true
            else
                xPlayer.showNotification('Trivia has already been answered correctly!')
            end
        else
            xPlayer.showNotification('Wrong answer!')
        end
    else --Automatically logs if someone tries to bypass security and mod money with the event
        modder(12434, 's_quizsystem Logging', '\n**SECURITY BREACH**\n\nPlayer: **'..GetPlayerName(source)..'**\n\n Tried to execute event without security token! -- Admins take action!', 's_quizLog')
    end
end)

----##### Logging stuff ####----

local cheaterWebhook = 'ENTER WEBHOOK HERE'
local winnerLogwebhook = 'ENTER WEBHOOK HERE'
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
