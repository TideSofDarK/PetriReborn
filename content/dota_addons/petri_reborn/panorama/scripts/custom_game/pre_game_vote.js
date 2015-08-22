//CustomNetTables.SubscribeNetTableListener( "PreGame_vote", OnNettableChanged );
var parentPanel = $.GetContextPanel();
var VotesList=[];
for(var i=0; i<$('#VotesList').GetChildCount(); i++){
	VotesList.push( $('#VotesList').GetChild(i).id );
	var a="#"+$('#VotesList').GetChild(i).id+"_RadioButtons"
	$.Msg(a)
	SetActiveRadio($(a), 0)
	$.Msg('Adding to votes list:'+$('#VotesList').GetChild(i).id);
}

//parentPanel.visible=false;
function Submit(){
	$.Msg('Submitting vote...');
	$('#SubmitButton').enabled=false;
	
	var a = GetActiveRadio($("#ExitDelay_RadioButtons"));
	var b = GetActiveRadio($("#GameDuration_RadioButtons"));
	$.Msg('a='+a);
	$.Msg('b='+b);
	var data={};
	$.Msg('VoteLIst length = '+VotesList.length);
	for( var i=0; i<VotesList.length; i++ ){
		var item=VotesList[i]
		var item_id="#"+item+"_RadioButtons";
		DisableRadio( $(item_id) )
		$.Msg('item_id= '+item_id);
		data[item]=GetActiveRadio( $( item_id ) );
	}
	$.Msg('Sending event with data:');
	$.Msg(data);
	//GameEvents.SendCustomGameEventToServer( "event_pregame_vote", { "ExitDelay" : a , "GameDuration" : b } );
	GameEvents.SendCustomGameEventToServer( "event_pregame_vote", data );
	$.Msg('Vote submitted.');
}

GameEvents.Subscribe( "PreGameVote_end_event", PreGameVote_end_event);
GameEvents.Subscribe( "PreGameVote_start_event", PreGameVote_event);
function vote_end_foreach(element, index, array){
	$.Msg( "Foreach: "+ element +":"+index);
}
function PreGameVote_event( event_data ){
	//parentPanel.visible=event_data['visible'];
	parentPanel.visible=true;
}
function PreGameVote_end_event( event_data )
{
	$.Msg( "On Vote End" );
	$.Msg( event_data );
	//$.Msg( "OnMyEvent: "+ event_data );
	//event_data.forEach(vote_end_foreach);
	//setTimeout(HideSelf, 3000);
	$.Schedule( 5, HideSelf );

	for( var property in event_data )
	{
		$.Msg("	Event data "+property+" = "+ event_data[property] );
		var a="#"+property+"_RadioButtons";
		$(a).GetChild(event_data[property]).AddClass( "winner" );
	}
	//parentPanel.visible=event_data['visible'];
	//var PanelName=+_RadioButtons
	//var a=
	//parentPanel.AddClass( "winner" );
}
function HideSelf(){
	parentPanel.visible=false;
}
function GetActiveRadio(container){
	$.Msg('child count:'+container.GetChildCount());
	var ExitChildCount=container.GetChildCount();
	for(var i=0; i<ExitChildCount; i++){
		$.Msg('Child '+i+'.id='+container.GetChild(i).id);
		$.Msg('	'+container.GetChild(i).checked);
		if(container.GetChild(i).checked)
			return(i);

	}
}
function DisableRadio(container){
	var ExitChildCount=container.GetChildCount();
	for(var i=0; i<ExitChildCount; i++){
		container.GetChild(i).enabled=false;
	}
}
function SetActiveRadio(container, id){
	var ChildCount=container.GetChildCount();
	if( ChildCount>=id )
		container.GetChild(id).checked=true
	else
		container.GetChild(0).checked=true
}
function init(){
	$( "#vote_timeleft_timer" ).text=data.timeleft;
}