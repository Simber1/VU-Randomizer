print('Hello from the shared world!')
Events:Subscribe('Player:Joining', function(name, playerGuid, ipAddress, accountGuid)
    print('Player "' .. name .. '" is joining!')
  end)