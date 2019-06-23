const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp(functions.config().firebase);
const db = admin.firestore();

exports.txNotification = functions.firestore.document('users/{email}/transactions/{transactionId}')
 .onCreate( async (snap, context) => {
    const newValue = snap.data();

    const querySnap = await db.collection('users').doc(newValue.receiver).get();

    const token = querySnap.data().tokenId;

    const amount = newValue.amount;
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
    if(token && senderName) { return admin.messaging().sendToDevice(token, notificationContent);}
 });

 exports.newContactNotification = functions.firestore.document('users/{email}/contacts/{contactEmail}')
  .onCreate( async (snap, context) => {


     const newValue = snap.data();

     const querySnap = await db.collection('users').doc(newValue.requestedTo).get();

     const token = querySnap.data().tokenId;

     const userId = newValue.requestedBy;
     const firstName = newValue.contactFirstName;
     const lastName = newValue.contactLastName;
 	const notificationContent = {
            notification: {
               title: 'New Contact Request',           //we use the sender name to show in notification
               body: firstName + ' ' + lastName + ' wants to connect with you',                      //we use the receiver's name and message to show in notifcation
               icon: "default",                                   //you can change the icon on the app side too
               sound : "default"                                  //also you can change the sound in app side
             },
             data : {
                 click_action: 'FLUTTER_NOTIFICATION_CLICK',
                 message: 'contactRequest'
             }
             };
     if(token && firstName && lastName) {return admin.messaging().sendToDevice(token, notificationContent);}
  });