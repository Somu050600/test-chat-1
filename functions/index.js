const { onDocumentCreated } = require('firebase-functions/v2/firestore');
const { logger } = require('firebase-functions');
const admin = require('firebase-admin');

admin.initializeApp();

exports.onChatMessageCreated = onDocumentCreated(
  'conversations/{conversationId}/messages/{messageId}',
  async (event) => {
    const snap = event.data;
    if (!snap) return;

    const conversationId = event.params.conversationId;
    const msg = snap.data();
    const senderId = msg.senderId;
    const text = (msg.text || '').toString();

    const convRef = admin.firestore().doc(`conversations/${conversationId}`);
    const convDoc = await convRef.get();
    const members = convDoc.get('members') || [];
    if (!Array.isArray(members) || members.length !== 2) {
      logger.warn('Invalid conversation members', { conversationId });
      return;
    }

    const recipientId = members.find((uid) => uid !== senderId);
    if (!recipientId) return;

    const senderDoc = await admin.firestore().doc(`users/${senderId}`).get();
    const senderName =
      senderDoc.get('name') || senderDoc.get('email') || 'New message';

    const tokensSnap = await admin
      .firestore()
      .collection('users')
      .doc(recipientId)
      .collection('tokens')
      .get();

    const tokens = tokensSnap.docs
      .map((d) => d.get('token'))
      .filter((t) => typeof t === 'string' && t.length > 0);

    if (tokens.length === 0) {
      logger.info('No FCM tokens for recipient', { recipientId });
      return;
    }

    const preview =
      text.length > 160 ? `${text.slice(0, 157)}...` : text;

    const message = {
      tokens,
      notification: {
        title: senderName,
        body: preview || 'You have a new message',
      },
      data: {
        conversationId,
        senderId: senderId || '',
        text: preview,
      },
    };

    try {
      const resp = await admin.messaging().sendEachForMulticast(message);
      logger.info('FCM batch', {
        success: resp.successCount,
        failure: resp.failureCount,
      });
    } catch (e) {
      logger.error('FCM send failed', e);
    }
  },
);
