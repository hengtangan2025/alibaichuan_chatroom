jQuery(document).ready(function(){
  var sdk = new WSDK();
  var userid = jQuery(".test-user .current-user").attr("id");
  console.log(userid);

  sdk.Base.login({
    uid: userid,
    appkey: '23459018',
    credential: '12545',
    timeout: 4000,
    success: function(data){
      console.log('登录成功', data);
      var chat_room_targetId = "";
      
      // 获取最近联系人
      // sdk.Base.getRecentContact({
      //   count: 10,
      //   success: function(data){
      //     console.log('收到消息' ,data);
      //   },
      //   error: function(error){
      //     console.log('get recent contact fail' ,error);
      //   }
      // });
      
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

      var chat_room_name = "";
      var chat_room_member_id = "";

      //获取创建群聊时邀请的成员
      jQuery(".chat-room .check-box").click(function(){
        chat_room_member_id = jQuery(this).attr("id");
      });

      //创建群聊
      jQuery(".chat-room .create_chatroom").click(function(){
         //获取群聊名称
        chat_room_name = jQuery(".chat-room .discussion-name").val();
        jQuery.ajax({
          url: "/chat_rooms/create_group",
          method: "POST",
          data: {
            "create_user": userid,
            "group_name": chat_room_name,
            "members": chat_room_member_id
          }
        }).success(function(msg){
          console.log(msg);
        }); 
      });

      //退出群聊
      jQuery(".chat-room .quit-chat-room").click(function(){
        jQuery.ajax({
          url: "/chat_rooms/quit_group",
          method: "POST",
          data: {
            "quit_user": userid,
            "tribe_id": chat_room_targetId,
          }
        }).success(function(msg){
          console.log(msg);
        });
      });

      //发送群消息
      jQuery(".chat-room .send-chat-room-message").click(function(){
        sdk.Tribe.sendMsg({
          tid: chat_room_targetId,
          msg: '你好啊',
          success: function(data){
            console.log('群发成功',data);
          },
          error: function(error){
            console.log(error);
          }
        });
      });
      
      // //接收群消息
      // nextkey = '';
 
      // sdk.Tribe.getHistory({
      //   tid: '5363883',
      //   count: 10,
      //   nextkey: nextkey,
      //   success: function(data){
      //     console.log('接收群消息', data);
      //     nextkey = data.data && data.data.next_key;
      //   },
      //   error: function(error){
      //     console.log('get history msg fail', error);
      //   }
      // });

      //获取群列表
      sdk.Tribe.getTribeList({
        tribeTypes: [0,1,2],
        success: function(data){
          var chat_room_list = data.data
          console.log("获取群列表",data.data);
          for(item in chat_room_list){
            var tribe_id = chat_room_list[item].tid;
            var tribe_name = chat_room_list[item].name;
            var html =  "<div>" +
                          "<input class='chat-room-name' name='radiobutton' type='radio' value='"+ tribe_id +"'>" +
                          tribe_name +
                          "</input>" +
                        "</div>"
            jQuery(".chat-room-list").append(html);

            jQuery(".chat-room .chat-room-list .chat-room-name").click(function(){
              chat_room_targetId = jQuery(this).val();
              console.log(chat_room_targetId);
            });
          }
        },
        error: function(error){
          console.log(error);
        }
      });

      //获取群成员
      jQuery(".chat-room .get-user-list").click(function(){
        sdk.Tribe.getTribeMembers({
          tid: chat_room_targetId,
          success: function(data){
            console.log(data.data);
          },
          error: function(error){
            console.log(error);
          }
        });
      });

      //邀请其他用户
      jQuery(".chat-room .invite-others").click(function(){

      });

      // 接收所有消息
      sdk.Base.startListenAllMsg();

      sdk.Event.on('START_RECEIVE_ALL_MSG', function(data){
        console.log("收到消息",data);
      });
    },
    error: function(error){
     // {code: 1002, resultText: 'TIMEOUT'}
     console.log('login fail', error);
    }
  });

  // jQuery(".test-user .login").click(function(){
    
  // });
});