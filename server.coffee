MainPageTitle = "Hlavná_stránka"

express = require('express')
app = express()

logger = (req, res, next) ->
    console.log('Request: ' + req.method + ' ' + req.url)
    next()

errorLogger = (err, req, res, next) ->
    console.log('Error: ' + req.method + ' ' + req.url + ' ' + err.message)

app.configure(() ->
    app.use(logger)
    app.use(app.router)
)

app.get('/', (req, res) ->
    res.redirect('/wiki/' + MainPageTitle)
)

app.get('/wiki/:contentId', (req, res) ->
    res.send(req.params.contentId)
)

app.get('/search/:searchString', (req, res) ->
    res.send(req.params.searchString)
)

app.listen(8080)