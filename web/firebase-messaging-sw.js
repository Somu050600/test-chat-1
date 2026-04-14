importScripts("https://www.gstatic.com/firebasejs/10.12.0/firebase-app-compat.js");
importScripts("https://www.gstatic.com/firebasejs/10.12.0/firebase-messaging-compat.js");

firebase.initializeApp({
  apiKey: "AIzaSyAnYqf18SvrvKTdQV-5XUTG2T-bDYQp1E4",
  authDomain: "test-chat-1-ef221.firebaseapp.com",
  projectId: "test-chat-1-ef221",
  storageBucket: "test-chat-1-ef221.firebasestorage.app",
  messagingSenderId: "579497868233",
  appId: "1:579497868233:web:1531e99e9e170893844618",
});

const messaging = firebase.messaging();

messaging.onBackgroundMessage((payload) => {
  const { title, body } = payload.notification ?? {};
  if (title) {
    self.registration.showNotification(title, { body });
  }
});
