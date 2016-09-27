jQuery(document).ready(function(){
  var sdk = new WSDK();
  console.log(sdk.Tribe.sendMsg);
  jQuery(".test-user .user-name").click(function(){
    var userid = jQuery(this).attr("id");

    console.log(userid); 
 
    sdk.Base.login({
      uid: userid,
      appkey: '23459018',
      credential: '12545',
      timeout: 4000,
      success: function(data){
        // {code: 1000, resultText: 'SUCCESS'}
        console.log('login success', data);
        
        //获取未读消息
        sdk.Base.getUnreadMsgCount({
          count: 10,
          success: function(data){
            console.log('get unread msg count success' ,data.data);
          },
          error: function(error){
            console.log('get unread msg count fail' ,error);
          }
        });
        
        //获取最近联系人
        sdk.Base.getRecentContact({
          count: 10,
          success: function(data){
            console.log('get recent contact success' ,data);
          },
          error: function(error){
            console.log('get recent contact fail' ,error);
          }
        });
        
        //接收所有消息
        sdk.Event.on('MSG_RECEIVED', function(data){
          console.log(data);
        });
   
        sdk.Base.startListenAllMsg();
        
        //发送单聊消息
        var private_userid = "";
        jQuery(".private .user-name").click(function(){
          private_userid = jQuery(this).attr("id");
          console.log(private_userid);
        });
        jQuery(".private .send-private-message").click(function(){
          var message_content = jQuery(".private .message-content").val();
          sdk.Chat.sendMsg({
            touid: private_userid,
            msg: message_content,
            success: function(data){
              console.log('send success', data);
            },
            error: function(error){
              console.log('send fail', error);
            }
          });
        });

        //发送群消息
        sdk.Tribe.sendMsg({
          tid: '5363883',
          msg: '你好啊',
          success: function(data){
            console.log('群发成功',data);
          },
          error: function(error){
            console.log(error);
          }
        });

        //接收群消息
        nextkey = '';
   
        sdk.Tribe.getHistory({
          tid: '5363883',
          count: 10,
          nextkey: nextkey,
          success: function(data){
            console.log('接收群消息', data);
            nextkey = data.data && data.data.next_key;
          },
          error: function(error){
            console.log('get history msg fail', error);
          }
        });
      },
      error: function(error){
       // {code: 1002, resultText: 'TIMEOUT'}
       console.log('login fail', error);
      }
    });
  });
});