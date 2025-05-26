
exports.getNewsPage = (req, res) => {
  res.render('news/index', { title: 'Quản lý bài viết' });
};