const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp(functions.config().firebase);
const db = admin.firestore();

exports.txNotificationOne = functions.firestore.document('users/{email}/transactions/{transactionId}')
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

 exports.newContactNotificationOne = functions.firestore.document('users/{email}/contacts/{contactEmail}')
  .onCreate( async (snap, context) => {


     const newValue = snap.data();

     const querySnap = await db.collection('users').doc(newValue.requestedTo).get();

     const token = querySnap.data().tokenId;

     const requestedToFirstName = querySnap.data().firstName;
     const requestedToLastName = querySnap.data().lastName;

     const userId = newValue.requestedBy;
     const firstName = newValue.firstName;
     const lastName = newValue.lastName;
 	const notificationContent = {
            notification: {
               title: 'New Contact Request',           //we use the sender name to show in notification
               body: firstName + ' ' + lastName + ' wants to establish comms with you',                      //we use the receiver's name and message to show in notifcation
               icon: "default",                                   //you can change the icon on the app side too
               sound : "default"                                  //also you can change the sound in app side
             },
             data : {
                 click_action: 'FLUTTER_NOTIFICATION_CLICK',
                 message: 'contactRequest'
             }
             };
     if(token && firstName && lastName && (firstName !== requestedToFirstName) && (lastName !== requestedToLastName)) {return admin.messaging().sendToDevice(token, notificationContent);}
  });

  exports.acceptedRequestOne = functions.firestore.document('users/{email}/contacts/{contactEmail}')
    .onUpdate( async (change, context) => {


       const newValue = change.after.data();

       const status = newValue.status;

       const querySnap = await db.collection('users').doc(newValue.requestedBy).get();

       const token = querySnap.data().tokenId;

       const requestedByFirstName = querySnap.data().firstName;
       const requestedByLastName = querySnap.data().lastName;

       const userId = newValue.requestedBy;
       const firstName = newValue.firstName;
       const lastName = newValue.lastName;
   	const notificationContent = {
              notification: {
                 title: 'Contact Request Update',           //we use the sender name to show in notification
                 body: firstName + ' ' + lastName + ' ' + status + ' your comms request',                      //we use the receiver's name and message to show in notifcation
                 icon: "default",                                   //you can change the icon on the app side too
                 sound : "default"                                  //also you can change the sound in app side
               },
               data : {
                   click_action: 'FLUTTER_NOTIFICATION_CLICK',
                   message: 'contactRequest'
               }
               };
       if(token && firstName && lastName && (firstName !== requestedByFirstName) && (lastName !== requestedByLastName)) {return admin.messaging().sendToDevice(token, notificationContent);}
    });