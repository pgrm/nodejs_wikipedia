MainPageTitle = "Hlavná stránka"
elasticSearchHost = "localhost"  #"ubuntuserver"
elasticSearchPort = "9200"
indexName = "wikipedia_cached"

express = require('express')
http = require('http')
wikijs = require('wiky.js')
app = express()

hbs = require('hbs')
http.globalAgent.maxSockets = 1000

elasticSearchUrl = (title) ->
    "http://#{elasticSearchHost}:#{elasticSearchPort}/#{indexName}/page/" + encodeURIComponent(title)

logger = (req, res, next) ->
    console.log('Request: ' + req.method + ' ' + req.url)
    next()

errorLogger = (err, req, res, next) ->
    console.log('Error: ' + req.method + ' ' + req.url + ' ' + err.message)
    next()

app.configure(() ->
    app.set('view engine', 'hbs')
    app.engine('hbs', hbs.__express)

    app.use(logger)
    app.use(app.router)
    app.use(express.static('public'))
)

app.get('/', (req, res) ->
    res.redirect('/wiki/' + MainPageTitle)
)

app.get('/wiki', (req, res) ->
    res.redirect('/wiki/' + MainPageTitle)
)

app.get('/wiki/:contentId', (req, res) ->
    http.get(elasticSearchUrl(req.params.contentId), (innerRes) ->
        if (innerRes.statusCode != 200)
            res.send(innerRes.statusCode)
            innerRes.resume()
        else
            body = ''
            innerRes.on('data', (bodyChunk) ->
                body += bodyChunk
            )
            innerRes.on('end', () ->
                res.render('page', {'title': req.params.contentId, 'content': JSON.parse(body)._source.html})
            )
    ).on('error', (e) ->
        console.log('Got error: ' + e.message)
    )
)

app.get('/search/:searchString', (req, res) ->
    res.send(req.params.searchString)
)

app.listen(8080)