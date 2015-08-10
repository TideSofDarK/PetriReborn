ExecFunct = {}

function FindFunction( x )
  assert( type(x) == "string" )
  local f = _G
  for v in x:gmatch("[^%.]+") do
    if type(f) ~= "table" then
       return nil, "looking for '"..v.."' expected table, not "..type(f)
    end
    f = f[v]
  end
  if type(f) == "function" then
    return f
  else
    return nil, "expected function, not "..type(f)
  end
end

function ExecFunct:ExecFunctByName( args )
  local x = args["FunctionName"];
  local arg = args["Args"];
  local result;
  if arg == nil then
    result = assert(FindFunction(x))();
  else
    result = assert(FindFunction(x))(arg);
  end

  CustomGameEventManager:Send_ServerToPlayer( PlayerResource:GetPlayer(args['PlayerID']), "return_funct_result", { res = result } )
end