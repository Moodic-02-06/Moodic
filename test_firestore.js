const admin = require('firebase-admin');
const serviceAccount = require('./functions/serviceAccountKey.json'); // Assumes we have one or can initialize default

admin.initializeApp();
const db = admin.firestore();

async function checkData() {
  const usersRef = await db.collection('users').limit(5).get();
  console.log("--- Users ---");
  usersRef.forEach(doc => {
    const data = doc.data();
    console.log(`User ${doc.id}: fcmToken exists = ${!!data.fcmToken}, isNotificationEnabled = ${data.isNotificationEnabled}`);
  });
  
  const notifsRef = await db.collection('notifications').orderBy('createdAt', 'desc').limit(5).get();
  console.log("\n--- Recent Notifications ---");
  notifsRef.forEach(doc => {
    console.log(`Notification ${doc.id}:`, doc.data());
  });
}
checkData().then(() => process.exit(0)).catch(e => { console.error(e); process.exit(1); });
