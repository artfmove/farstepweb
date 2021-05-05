const functions = require("firebase-functions");

const admin = require("firebase-admin");
const { CloudTasksClient } = require('@google-cloud/tasks');
admin.initializeApp();
const project = JSON.parse(process.env.FIREBASE_CONFIG).projectId;
const location = 'europe-west1';
const couponQueue = 'couponQueue';
const feedQueue = 'feedQueue';
const barcodeQueue = 'barcodeQueue';
const serviceAccountEmail = "farstep-art@appspot.gserviceaccount.com";

const { v4: uuidv4 } = require('uuid');

exports.onCouponScheduledCreate = functions.region('europe-west1')
    .firestore.document('/scheduledcoupons/{id}').onCreate(async (snapshot) => {
        const data = snapshot.data();
        const { couponId, startDate, expirationDate } = data;
        let startAtSeconds;
        if (startDate) {
            startAtSeconds = startDate.seconds;
        }
        const tasksClient = new CloudTasksClient();
        const queuePath = tasksClient.queuePath(project, location, couponQueue);
        const url = `https://${location}-${project}.cloudfunctions.net/CouponCreateCallback`;
        const startDateInt = startDate.seconds;
        const expirationDateInt = expirationDate.seconds;

        const task = {
            httpRequest: {
                httpMethod: 'POST',
                url,
                body: Buffer.from(JSON.stringify({ couponId, startDateInt, expirationDateInt })).toString('base64'),
                headers: {
                    'Content-Type': 'application/json',
                },
                oidcToken: {
                    serviceAccountEmail
                }
            },
            scheduleTime: {
                seconds: startAtSeconds
            },

        };
        const [response] = await tasksClient.createTask({ parent: queuePath, task });
        const startTask = response.name;
        await snapshot.ref.update({ 'startTask': startTask });
    });
exports.CouponCreateCallback = functions.region('europe-west1').https.onRequest(async (req, res) => {
    const payload = req.body;
    try {
        var schCoupon;
        await admin.firestore().collection('scheduledcoupons').doc(payload.couponId).get().then(doc => {

            schCoupon = doc.data();
        });
        const couponPath = `coupons/${payload.couponId}`;
        await admin.firestore().doc(couponPath).set(schCoupon);
        await admin.firestore().collection('scheduledcoupons').doc(payload.couponId).delete();
        const tasksClient = new CloudTasksClient();
        const queuePath = tasksClient.queuePath(project, location, couponQueue);
        const url = `https://${location}-${project}.cloudfunctions.net/CouponFinishCallback`;
        const task = {
            httpRequest: {
                httpMethod: 'POST',
                url,
                body: Buffer.from(JSON.stringify({ 'couponPath': couponPath })).toString('base64'),
                headers: {
                    'Content-Type': 'application/json',
                },
                oidcToken: {
                    serviceAccountEmail
                }
            },
            scheduleTime: {
                seconds: payload.expirationDateInt
            }
        };
        const [response] = await tasksClient.createTask({ parent: queuePath, task });
        res.send(200);
        const expirationTask = response.name;
        await admin.firestore().doc(couponPath).update({ 'expirationTask': expirationTask });
    }
    catch (error) {
        console.error(error);
        res.status(500).send(error);
    }
});
exports.CouponFinishCallback = functions.region('europe-west1').https.onRequest(async (req, res) => {
    const payload = req.body['couponPath'];
    try {
        await admin.firestore().doc(payload).delete();
        res.send(200);
    }
    catch (e) {
        res.status(500).send(e);
    }
});


exports.onCouponScheduledDelete = functions.region('europe-west1').firestore.document('/scheduledcoupons/{id}').onDelete(async (snapshot) => {
    const startTask = snapshot.data().startTask;
    try {
        const tasksClient = new CloudTasksClient();
        await tasksClient.deleteTask({ name: startTask });
    }
    catch (e) {
        return { response: 'fail' }
    }
});

exports.onCouponCurrentDelete = functions.region('europe-west1').firestore.document('/coupons/{couponId}').onDelete(async (snapshot) => {
    const data = snapshot.data();
    const expirationTask = data.expirationTask;
    try {
        const tasksClient = new CloudTasksClient();
        await tasksClient.deleteTask({ name: expirationTask });
    }
    catch (e) {
        //  return {response:'fail'}
    }
});


exports.onFeedScheduledCreate = functions.region('europe-west1').firestore.document('/scheduledfeeds/{id}').onCreate(async (snapshot) => {
    const data = snapshot.data();
    const { feedId, startDate } = data;
    let startAtSeconds;
    if (startDate) {
        startAtSeconds = startDate.seconds;
    }
    const tasksClient = new CloudTasksClient();
    const queuePath = tasksClient.queuePath(project, location, feedQueue);
    const url = `https://${location}-${project}.cloudfunctions.net/CreateFeedCallback`;
    const expirationDateInt = startDate.seconds + 60 * 60 * 24 * 30;


    const task = {
        httpRequest: {
            httpMethod: 'POST',
            url,
            body: Buffer.from(JSON.stringify({ feedId, expirationDateInt })).toString('base64'),
            headers: {
                'Content-Type': 'application/json',
            },
            oidcToken: {
                serviceAccountEmail
            }
        },
        scheduleTime: {
            seconds: startAtSeconds
        }
    };
    const [response] = await tasksClient.createTask({ parent: queuePath, task });
    const startTask = response.name;
    await snapshot.ref.update({ 'startTask': startTask });
});

exports.CreateFeedCallback = functions.region('europe-west1').https.onRequest(async (req, res) => {

    const data = req.body;
    var schFeed;
    try {
        await admin.firestore().collection('scheduledfeeds').doc(data.feedId).get().then(doc => {
            schFeed = doc.data();
        });
        const feedPath = `feeds/${data.feedId}`;
        await admin.firestore().doc(feedPath).set(schFeed);
        await admin.firestore().collection('scheduledfeeds').doc(data.feedId).delete();
        


        var messageRu = {
            
            notification: { title: schFeed['title'][0], body: schFeed['description'][0] },

            topic: `allUsersru`
        };
        var messageUk = {
            
            notification: { title: schFeed['title'][1], body: schFeed['description'][1] },

            topic: `allUsersuk`
        };
        await admin.messaging().send(messageRu);
        await admin.messaging().send(messageUk);
        res.send(200);
    }
    catch (error) {
        console.error(error);
        res.status(500).send(error);
    }
});


exports.onScheduledFeedDelete = functions.region('europe-west1').firestore.document('/scheduledfeeds/{feedId}').onDelete(async (snapshot) => {
    const startTask = snapshot.data().startTask;
    const tasksClient = new CloudTasksClient();
    await tasksClient.deleteTask({ name: startTask });
});


exports.currentTime = functions.region('europe-west1').https.onCall((data, context) => {
    return { response: new Date().getTime() }

})



exports.GenerateBarcode = functions.region('europe-west1').https.onCall(async (data, context) => {



    if (context.auth == null || !context.auth.token.email_verified) {
        return { 'isSuccess': false }
    }
    var couponId;
    const userId = context.auth.uid;


    try {
        couponId = data.couponId;

        var restartHours = 8;
        var expirationMinutes = 15;

        await admin.firestore().collection('coupons').doc(couponId).get().then((snapshot) => {
            restartHours = parseInt(snapshot.data()['restartHours']);
            expirationMinutes = parseInt(snapshot.data()['expirationMinutes']);
        });
    } catch (e) {
        return { 'isSuccess': false }
    }


    const now = new Date();
    var isSuccess = false;
    const randomId = uuidv4().substring(0, 5).toUpperCase();
    var restartAt = new Date();
    var expirationDate = new Date();

    restartAt.setHours(restartAt.getHours() + restartHours);


    expirationDate.setMinutes(expirationDate.getMinutes() + expirationMinutes);

    try {
        await admin.firestore()
            .collection('barcodes')
            .doc(randomId)
            .set({
                'barcodeId': randomId,
                'couponId': couponId,

                'expirationDate': expirationDate,
                'userId': userId,
                'restartAt': restartAt,
            })
            .then((value) => isSuccess = true)


    } catch (e) {
        isSuccess = false;
    }

    if (isSuccess == false) return { 'isSuccess': isSuccess }


    try {
        await admin.firestore()
            .collection('users')
            .doc(userId)
            .collection('coupons')
            .doc(couponId)
            .set({
                'couponId': couponId,
                'barcodeId': randomId,
                'expirationDate': expirationDate,
                'restartAt': restartAt,
                'used': false,
            }).then((e) => isSuccess = true)

    } catch (e) { isSuccess = false; }

    if (isSuccess == false) {
        await admin.firestore()
            .collection('barcodes')
            .doc(randomId).delete();

        return { 'isSuccess': isSuccess }
    }

    else
        return { 'barcodeId': randomId, 'isSuccess': isSuccess, 'expirationSeconds': (expirationDate.getTime() - now.getTime()) }


})

exports.ScanBarcode = functions.region('europe-west1').https.onCall(async (data, context) => {
    var barcodeId;
    try {
        const employers = [];
        await admin.firestore().collection('app').doc('employers').get().then(async (snapshot) => {
            
        
            for(var doc in snapshot.data()['employers']){
                
                employers.push(doc.toString());
            }
        });
            
        if (!employers.includes(context.auth.token.email)) {
            return { 'message': 'no-access' };
        }

        barcodeId = data.barcodeId;
    } catch (e) {
        return { 'message': 'error' };
    }

    const now = new Date();
    var message = '';
    var currentBarcode = {};
    var currentCoupon = {};

    try {
        await admin.firestore()
            .collection('barcodes')
            .doc(barcodeId)
            .get()
            .then(async (snapshot) => {
                const doc = snapshot.data();
                if (doc != null) {
                    if (doc['expirationDate'].toDate() > now) {
                        message = 'success';
                        currentBarcode = {
                            'barcodeId': doc['barcodeId'],
                            'couponId': doc['couponId'],

                            'expirationDate': doc['expirationDate'].toDate(),
                            'userId': doc['userId']
                        };
                    } else {
                        message = 'expired';
                    }

                } else {
                    message = 'notfound';
                }
            });
    } catch (e) {
        message = 'notfound';
        return { 'message': message };
    }

    if (message == 'notfound' || message == 'expired' || message == 'error' || message == 'used') return { 'message': message };

    try {
        await admin.firestore()
            .collection('coupons')
            .doc(currentBarcode['couponId'])
            .get()
            .then((snapshot) => {
                if (snapshot.data() == null) message = 'error';
                else {
                    currentCoupon = {
                        'couponId': snapshot.data()['couponId'],
                        'images': snapshot.data()['images'],

                        'price': snapshot.data()['price'],
                        
                        'title': snapshot.data()['title']
                    };
                    message = 'success';
                }
            });
    } catch (e) { message = 'error'; return { 'message': message }; }

    if (message == 'error') return { 'message': message };

    try {
        await admin.firestore()
            .collection('users')
            .doc(currentBarcode['userId'])
            .collection('coupons')
            .doc(currentBarcode['couponId'])
            .update({ 'used': true })
        await admin.firestore().collection('barcodes').doc(barcodeId).delete();
    } catch (e) { }


    return { 'message': message, 'coupon': currentCoupon };





})







exports.onBarcodeCreate = functions.region('europe-west1').firestore.document('/barcodes/{id}').onCreate(async (snapshot) => {
    const data = snapshot.data();
    const { couponId, barcodeId, restartAt, userId } = data;
    let restartAtSeconds;
    if (restartAt) {
        restartAtSeconds = restartAt.seconds;
    }
    const tasksClient = new CloudTasksClient();
    const queuePath = tasksClient.queuePath(project, location, barcodeQueue);
    const url = `https://${location}-${project}.cloudfunctions.net/BarcodeCreateCallback`;
    const task = {
        httpRequest: {
            httpMethod: 'POST',
            url,
            body: Buffer.from(JSON.stringify({ couponId, barcodeId, userId })).toString('base64'),
            headers: {
                'Content-Type': 'application/json',
            },
            oidcToken: {
                serviceAccountEmail
            }
        },
        scheduleTime: {
            seconds: restartAtSeconds
        }
    };
    await tasksClient.createTask({ parent: queuePath, task });
});
exports.BarcodeCreateCallback = functions.region('europe-west1').https.onRequest(async (req, res) => {
    const data = req.body;
    try {

        await admin.firestore().collection('users').doc(data.userId).collection('coupons').doc(data.couponId).delete();
        await admin.firestore().collection('barcodes').doc(data.barcodeId).delete();

    }
    catch (error) {
        console.error(error);
        res.status(500).send(error);
    }
});
