
const { getFirestore } = require('firebase-admin/firestore');
const db = getFirestore();

exports.index = async (req, res) => {
  const snapshot = await db.collection('news').orderBy('createAt', 'desc').get();
  const news = snapshot.docs.map(doc => ({ id: doc.id, ...doc.data() }));
  res.render('news/index', { news });
};

exports.create = (req, res) => {
  res.render('news/create');
};

exports.store = async (req, res) => {
  const { titles, contents } = req.body;
  const Img = req.file?.path || '';
  await db.collection('news').add({ titles, contents, Img, createAt: new Date() });
  res.redirect('/news');
};