MainPageTitle = "Hlavná stránka"
elasticSearchHost = "ubuntuserver"
elasticSearchPort = "9200"
indexName = "wikipedia_cached"

express = require('express')
http = require('http')
app = express()

elasticSearchUrl = (title) ->
    "http://#{elasticSearchHost}:#{elasticSearchPort}/#{indexName}/page/" + encodeURIComponent(title)

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
    console.log(elasticSearchUrl(req.params.contentId))
    http.get(elasticSearchUrl(req.params.contentId), (innerRes) ->
        if (innerRes.statusCode != 200)
            res.send(innerRes.statusCode)
        else
            body = ''
            innerRes.on('data', (bodyChunk) ->
                body += bodyChunk
            )
            innerRes.on('end', () ->
                res.send(JSON.parse(body)._source.text)
            )
    )
    #res.send(req.params.contentId)
)

app.get('/search/:searchString', (req, res) ->
    res.send(req.params.searchString)
)

app.listen(8080)