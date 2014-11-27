package org.bigbluebutton.modules.whiteboard.commands
{
  import flash.events.Event;
  
  public class GetWhiteboardSimwriteStateCommand extends Event
  {
    public static const GET_SIMWRITE_STATE:String = "whiteboard get simwrite state command";
    
    public var whiteboardId:String;
    
    public function GetWhiteboardSimwriteStateCommand(wbId:String)
    {
      super(GET_SIMWRITE_STATE, true, false);
      whiteboardId = wbId;
    }
  }
}