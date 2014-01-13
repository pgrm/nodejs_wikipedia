// Generated by CoffeeScript 1.6.3
(function() {
  var MainPageTitle, app, errorLogger, express, logger;

  MainPageTitle = "Hlavná_stránka";

  express = require('express');

  app = express();

  logger = function(req, res, next) {
    console.log('Request: ' + req.method + ' ' + req.url);
    return next();
  };

  errorLogger = function(err, req, res, next) {
    return console.log('Error: ' + req.method + ' ' + req.url + ' ' + err.message);
  };

  app.configure(function() {
    app.use(logger);
    return app.use(app.router);
  });

  app.get('/', function(req, res) {
    return res.redirect('/wiki/' + MainPageTitle);
  });

  app.get('/wiki/:contentId', function(req, res) {
    return res.send(req.params.contentId);
  });

  app.get('/search/:searchString', function(req, res) {
    return res.send(req.params.searchString);
  });

  app.listen(8080);

}).call(this);