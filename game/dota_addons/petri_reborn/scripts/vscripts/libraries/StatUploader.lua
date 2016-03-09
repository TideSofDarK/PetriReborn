local statSettings = LoadKeyValues('scripts/kv/StatUploaderSettings.kv')

SU = {}

-- Request function
function SU:SendRequest( requestParams, successCallback )
  -- Adding auth key
  requestParams.AuthKey = statSettings.AuthKey
  -- DeepPrintTable(requestParams)

  -- Create the request
  local request = CreateHTTPRequest('POST', statSettings.Host)
  request:SetHTTPRequestGetOrPostParameter('CommandParams', json.encode(requestParams))

  -- Send the request
  request:Send(function(res)
    if res.StatusCode ~= 200 or not res.Body then
        print("Request error. See info below: ")
        DeepPrintTable(res)
        return
    end

    -- Try to decode the result
    local obj, pos, err = json.decode(res.Body, 1, nil)
    
    -- if not a JSON send full body
    if obj == nil then
      obj = res.Body
    end
    
    -- Feed the result into our callback
    successCallback(obj)
  end)
end

-- Test function
function SU:Test()
  local requestParams = {
    Command = "Testing"
  }
    
  SU:SendRequest( requestParams, function(obj)
      print("Testing response: ", obj)
  end)
end

-- Testing event
CustomGameEventManager:RegisterListener( "su_test_request", Dynamic_Wrap(SU, 'Test'))