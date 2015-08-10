'use strict';

var exec_result = null;
var received = false;

function GetFunctResult( res )
{
    $.Msg( "result = ", res);
    exec_result = res;
}

LuaScriptExecutor.prototype.GetExecResult = function()
{
  return exec_result;
}

LuaScriptExecutor.prototype.Exec = function( funct, args)
{
    if (args == null)
        GameEvents.SendCustomGameEventToServer( "exec_lua_function", { "FunctionName" : funct } );
    else
        GameEvents.SendCustomGameEventToServer( "exec_lua_function", { "FunctionName" : funct, "Args" : args } );
}

function LuaScriptExecutor()
{
    GameEvents.Subscribe( "return_funct_result", GetFunctResult ); 
}