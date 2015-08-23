package org.bigbluebutton.modules.polling.service
{
  import com.asfusion.mate.events.Dispatcher;
  
  import flash.accessibility.Accessibility;
  
  import org.as3commons.logging.api.ILogger;
  import org.as3commons.logging.api.getClassLogger;
  import org.bigbluebutton.modules.chat.ChatConstants;
  import org.bigbluebutton.modules.chat.events.PublicChatMessageEvent;
  import org.bigbluebutton.modules.chat.vo.ChatMessageVO;
  import org.bigbluebutton.modules.polling.events.PollShowResultEvent;
  import org.bigbluebutton.modules.polling.events.PollStartedEvent;
  import org.bigbluebutton.modules.polling.events.PollStoppedEvent;
  import org.bigbluebutton.modules.polling.events.PollVotedEvent;
  import org.bigbluebutton.modules.polling.model.PollingModel;
  import org.bigbluebutton.modules.polling.model.SimpleAnswer;
  import org.bigbluebutton.modules.polling.model.SimpleAnswerResult;
  import org.bigbluebutton.modules.polling.model.SimplePoll;
  import org.bigbluebutton.modules.polling.model.SimplePollResult;
  import org.bigbluebutton.util.i18n.ResourceUtil;

  public class PollDataProcessor
  {
	private static const LOGGER:ILogger = getClassLogger(PollDataProcessor);      
    
	private var model:PollingModel;
	private var dispatcher:Dispatcher;
    
	public function PollDataProcessor(model: PollingModel) {
		this.model = model;
		this.dispatcher = new Dispatcher();
	}
	
    public function handlePollStartedMesage(msg:Object):void {
      LOGGER.debug("*** Poll started {0} **** \n", [msg.msg]);
      
      var map:Object = JSON.parse(msg.msg);
      if (map.hasOwnProperty("poll")) {
        var poll:Object = map.poll;
        if (poll.hasOwnProperty("id") && poll.hasOwnProperty("answers")) {
          var pollId:String = poll.id;
          
          var answers:Array = poll.answers as Array;
          
          var ans:Array = new Array();
          
          for (var j:int = 0; j < answers.length; j++) {
            var a:Object = answers[j];
            ans.push(new SimpleAnswer(Number(String(a.id)), a.key));
          }
          
          model.setCurrentPoll(new SimplePoll(pollId, ans));
          dispatcher.dispatchEvent(new PollStartedEvent(new SimplePoll(pollId, ans)));            
        }      
      }
    }
    
    public function handlePollStoppedMesage(msg:Object):void {
      LOGGER.debug("*** Poll stopped {0} **** \n", [msg.msg]);
      var map:Object = JSON.parse(msg.msg);
      dispatcher.dispatchEvent(new PollStoppedEvent());
    }
    
    public function handlePollShowResultMessage(msg:Object):void {
      LOGGER.debug("*** Poll show result {0} **** \n", [msg.msg]);
      var map:Object = JSON.parse(msg.msg);
      if (map.hasOwnProperty("poll")) {
        var poll:Object = map.poll;
        if (poll.hasOwnProperty("id") && poll.hasOwnProperty("answers")
			&& poll.hasOwnProperty("num_responders") && poll.hasOwnProperty("num_respondents")) {
          var pollId:String = poll.id;
          
          var answers:Array = poll.answers as Array;
          var accessibleAnswers:String = ResourceUtil.getInstance().getString("bbb.polling.results.accessible.header") + "<br />";
          
          var ans:Array = new Array();
          
          for (var j:int = 0; j < answers.length; j++) {
            var a:Object = answers[j];
            ans.push(new SimpleAnswerResult(a.id as Number, a.key, a.num_votes as Number));
            accessibleAnswers += ResourceUtil.getInstance().getString("bbb.polling.results.accessible.answer", [ResourceUtil.getInstance().getString("bbb.polling.answer."+a.key), a.num_votes]) + "<br />";
          }
          
		  var numRespondents:Number = poll.num_respondents;
		  var numResponders:Number = poll.num_responders;
		  
          dispatcher.dispatchEvent(new PollShowResultEvent(new SimplePollResult(pollId, ans, numRespondents, numResponders)));
          
          if (Accessibility.active) {
            var pollResultMessage:ChatMessageVO = new ChatMessageVO();
            pollResultMessage.chatType = ChatConstants.PUBLIC_CHAT;
            pollResultMessage.fromUserID = ResourceUtil.getInstance().getString("bbb.chat.chatMessage.systemMessage");
            pollResultMessage.fromUsername = ResourceUtil.getInstance().getString("bbb.chat.chatMessage.systemMessage");
            pollResultMessage.fromColor = "86187";
            pollResultMessage.fromTime = new Date().getTime();
            pollResultMessage.fromTimezoneOffset = new Date().getTimezoneOffset();
            pollResultMessage.toUserID = ResourceUtil.getInstance().getString("bbb.chat.chatMessage.systemMessage");
            pollResultMessage.toUsername = ResourceUtil.getInstance().getString("bbb.chat.chatMessage.systemMessage");
            pollResultMessage.message = accessibleAnswers;
            
            var pollResultMessageEvent:PublicChatMessageEvent = new PublicChatMessageEvent(PublicChatMessageEvent.PUBLIC_CHAT_MESSAGE_EVENT);
            pollResultMessageEvent.message = pollResultMessage;
            pollResultMessageEvent.history = false;
            dispatcher.dispatchEvent(pollResultMessageEvent);
          }
        }      
      }    
    }
    
    public function handlePollUserVotedMessage(msg:Object):void {
      LOGGER.debug("*** Poll user voted {0} **** \n", [msg.msg]);
      var map:Object = JSON.parse(msg.msg);
      if (map.hasOwnProperty("poll")) {
        var poll:Object = map.poll;
        if (poll.hasOwnProperty("id") && poll.hasOwnProperty("answers")
			&& poll.hasOwnProperty("num_responders") && poll.hasOwnProperty("num_respondents")) {
          var pollId:String = poll.id;
          
          var answers:Array = poll.answers as Array;
          
          var ans:Array = new Array();
          
          for (var j:int = 0; j < answers.length; j++) {
            var a:Object = answers[j];
            ans.push(new SimpleAnswerResult(a.id as Number, a.key, a.num_votes as Number));
          }
          
		  var numRespondents:Number = poll.num_respondents;
		  var numResponders:Number = poll.num_responders;
		  
          dispatcher.dispatchEvent(new PollVotedEvent(new SimplePollResult(pollId, ans, numRespondents, numResponders)));            
        }      
      }
      
    }
  }
}