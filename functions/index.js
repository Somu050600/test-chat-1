const { onDocumentCreated } = require("firebase-functions/v2/firestore");
const { initializeApp } = require("firebase-admin/app");
const { getFirestore } = require("firebase-admin/firestore");
const { getMessaging } = require("firebase-admin/messaging");

initializeApp();

exports.onNewMessage = onDocumentCreated(
  "conversations/{conversationId}/messages/{messageId}",
  async (event) => {
    const snapshot = event.data;
    if (!snapshot) return;

    const message = snapshot.data();
    const { conversationId } = event.params;

    const db = getFirestore();

    const convoDoc = await db
      .collection("conversations")
      .doc(conversationId)
      .get();
    if (!convoDoc.exists) return;

    const members = convoDoc.data().members || [];
    const recipientId = members.find((m) => m !== message.senderId);
    if (!recipientId) return;

    const tokensSnapshot = await db
      .collection("users")
      .doc(recipientId)
      .collection("tokens")
      .get();

    if (tokensSnapshot.empty) return;

    const senderDoc = await db
      .collection("users")
      .doc(message.senderId)
      .get();
    const senderName = senderDoc.exists
      ? senderDoc.data().name
      : "Someone";

    const tokens = tokensSnapshot.docs.map((doc) => doc.data().token);
    const messaging = getMessaging();

    const payload = {
      notification: {
        title: senderName,
        body: message.text,
      },
      data: {
        conversationId,
        senderId: message.senderId,
        click_action: "FLUTTER_NOTIFICATION_CLICK",
      },
    };

    const sendPromises = tokens.map((token) =>
      messaging
        .send({ ...payload, token })
        .catch((error) => {
          if (
            error.code === "messaging/invalid-registration-token" ||
            error.code === "messaging/registration-token-not-registered"
          ) {
            const tokenDoc = tokensSnapshot.docs.find(
              (doc) => doc.data().token === token
            );
            if (tokenDoc) tokenDoc.ref.delete();
          }
        })
    );

    await Promise.all(sendPromises);
  }
);
