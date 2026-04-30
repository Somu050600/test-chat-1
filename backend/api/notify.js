const { initializeApp, cert, getApps } = require("firebase-admin/app");
const { getFirestore } = require("firebase-admin/firestore");
const { getMessaging } = require("firebase-admin/messaging");

function ensureFirebaseApp() {
  if (getApps().length === 0) {
    const serviceAccount = JSON.parse(process.env.FIREBASE_SERVICE_ACCOUNT);
    initializeApp({ credential: cert(serviceAccount) });
  }
}

function setCorsHeaders(res) {
  res.setHeader("Access-Control-Allow-Origin", "*");
  res.setHeader("Access-Control-Allow-Methods", "POST, OPTIONS");
  res.setHeader(
    "Access-Control-Allow-Headers",
    "Content-Type, x-api-key"
  );
  res.setHeader("Access-Control-Max-Age", "86400");
}

module.exports = async function handler(req, res) {
  setCorsHeaders(res);

  if (req.method === "OPTIONS") {
    return res.status(204).end();
  }

  if (req.method !== "POST") {
    return res.status(405).json({ error: "Method not allowed" });
  }

  ensureFirebaseApp();

  const authHeader = req.headers["x-api-key"];
  if (authHeader !== process.env.API_SECRET_KEY) {
    return res.status(401).json({ error: "Unauthorized" });
  }

  const { conversationId, senderId, text } = req.body;
  if (!conversationId || !senderId || !text) {
    return res.status(400).json({ error: "Missing required fields" });
  }

  try {
    const db = getFirestore();

    const convoDoc = await db
      .collection("conversations")
      .doc(conversationId)
      .get();
    if (!convoDoc.exists) {
      return res.status(404).json({ error: "Conversation not found" });
    }

    const members = convoDoc.data().members || [];
    const recipientId = members.find((m) => m !== senderId);
    if (!recipientId) {
      return res.status(200).json({ message: "No recipient found" });
    }

    // Skip notification if recipient is in the same conversation
    const recipientDoc = await db.collection("users").doc(recipientId).get();
    if (
      recipientDoc.exists &&
      recipientDoc.data().activeConversationId === conversationId
    ) {
      return res.status(200).json({ message: "Recipient is in chat, skipped" });
    }

    const tokensSnapshot = await db
      .collection("users")
      .doc(recipientId)
      .collection("tokens")
      .get();

    if (tokensSnapshot.empty) {
      return res.status(200).json({ message: "No tokens found" });
    }

    const senderDoc = await db.collection("users").doc(senderId).get();
    const senderName = senderDoc.exists ? senderDoc.data().name : "Someone";

    const tokens = tokensSnapshot.docs.map((doc) => doc.data().token);
    const messaging = getMessaging();

    const payload = {
      notification: {
        title: senderName,
        body: text.length > 100 ? text.substring(0, 100) + "..." : text,
      },
      data: {
        conversationId,
        senderId,
        click_action: "FLUTTER_NOTIFICATION_CLICK",
      },
    };

    const results = await Promise.allSettled(
      tokens.map((token) => messaging.send({ ...payload, token }))
    );

    // Clean up invalid tokens
    const invalidIndices = results
      .map((r, i) => (r.status === "rejected" ? i : -1))
      .filter((i) => i !== -1);

    for (const i of invalidIndices) {
      const reason = results[i].reason;
      if (
        reason?.code === "messaging/invalid-registration-token" ||
        reason?.code === "messaging/registration-token-not-registered"
      ) {
        const tokenDoc = tokensSnapshot.docs[i];
        if (tokenDoc) await tokenDoc.ref.delete();
      }
    }

    const sent = results.filter((r) => r.status === "fulfilled").length;
    return res.status(200).json({ message: `Sent to ${sent} device(s)` });
  } catch (error) {
    console.error("Notification error:", error);
    return res.status(500).json({ error: "Internal server error" });
  }
};
