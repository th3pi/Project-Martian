const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp(functions.config().firebase);
const db = admin.firestore();

exports.pushNotification = functions.firestore.document('users/{email}/transactions/{transactionId}')
 .onCreate( async snap => {
    const newValue = snap.data();

    const querySnap = await db.collection('users').doc(newValue.userId).collection('tokens').get();

    const tokens = querySnap.docs.map(snap => snap.id);

    const amount = newValue.amount;
	const token = newValue.tokenId;
	const senderName = newValue.senderName;
	const notificationContent = {
           notification: {
              title: 'Received Money',           //we use the sender name to show in notification
              body: senderName + ' just sent you $' + amount,                      //we use the receiver's name and message to show in notifcation
              icon: "default",                                   //you can change the icon on the app side too
              sound : "default"                                  //also you can change the sound in app side
            },
            data : {
                click_action: 'FLUTTER_NOTIFICATION_CLICK',
                message: 'receive'
            }
            };
    if(token) {return admin.messaging().sendToDevice(tokens, notificationContent);}
 });