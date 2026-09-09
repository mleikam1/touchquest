'use strict';
const functions = require('firebase-functions/v1');
const {onDocumentCreated} = require('firebase-functions/v2/firestore');
const admin = require('firebase-admin');
const {plausible} = require('./validation');
admin.initializeApp();
const db = admin.firestore();
exports.inspectRun = onDocumentCreated('runs/{runId}', async (event) => {
  const snap = event.data;
  if (!snap) return;
  const run = snap.data();
  // Plausibility is NOT proof of physical input. Do not publish to rankings.
  await snap.ref.update({validationStatus: plausible(run) ? 'plausible_unverified' : 'rejected', inspectedAt: admin.firestore.FieldValue.serverTimestamp()});
});
exports.deletePlayerData = functions.auth.user().onDelete(async (user) => {
  for (const collection of ['runs', 'leaderboards']) {
    let snapshot;
    do {
      snapshot = await db.collection(collection).where('uid', '==', user.uid).limit(400).get();
      const batch = db.batch();
      for (const doc of snapshot.docs) batch.delete(doc.ref);
      if (snapshot.size) await batch.commit();
    } while (snapshot.size === 400);
  }
  await db.collection('users').doc(user.uid).delete();
});
