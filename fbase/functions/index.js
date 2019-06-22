//const functions = require('firebase-functions');

// The Firebase Admin SDK to access the Firebase Realtime Database.
// const admin = require('firebase-admin');
// admin.initializeApp();

// // Create and Deploy Your First Cloud Functions
// // https://firebase.google.com/docs/functions/write-firebase-functions
//
// exports.helloWorld = functions.https.onRequest((request, response) => {
//  response.send("Hello from Firebase!");
// });'users/{email}/transactions/{transactionId}'

const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp(functions.config().firebase);

exports.pushNotification = functions.firestore.document('users/{email}/transactions/{transactionId}')
 .onCreate(( snap,context) => {
    const newValue = snap.data();
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
                message: 'hello'
            }
            };
    if(token) {return admin.messaging().sendToDevice(token, notificationContent);}
 });