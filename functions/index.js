const functions = require("firebase-functions");
const admin = require("firebase-admin");
admin.initializeApp(functions.config().firebase);

const fcm = admin.messaging();
const db = admin.firestore();
exports.send = functions.firestore
    .document("Chats/{projectId}")
    .onUpdate((change, context) => {
      const listMessage = change.after.get("messages");
      const theMessage = listMessage[(listMessage.length) - 1];
      // const listmembers = change.after.get("members");
      const nameChat = change.after.get("name");
      const imageChat = change.after.get("image");
      const senderId = theMessage["senderID"];
      let message = theMessage["message"];
      // const token = change.after.get("token");
      const type = theMessage["type"];
      if (type != "text") {
        message = type;
      }
      let username = "";
      const data = db.collection("Users").doc(senderId);
      data.get().then((doc)=>{
        username = doc.data().name;
        const getTokens = db.collection("Chats").doc(context.params.projectId)
            .collection("tokens").doc("main");
        getTokens.get().then((dToken)=>{
          const token = dToken.data().tokens;
          const payload = {
            notification: {
              title: nameChat,
              body: username + " : " + message,
              click_action: "FLUTTER_NOTIFICATION_CLICK",
              sound: "default",
            },
            data: {
              "image": imageChat,
              "id": context.params.projectId,
              "senderId": senderId,
              "name": nameChat,
              "click_action": "FLUTTER_NOTIFICATION_CLICK",
            },
          };
          return fcm.sendToDevice(token, payload);
        });
      });
    });
