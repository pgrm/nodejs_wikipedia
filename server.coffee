MainPageTitle = "Hlavná stránka"
elasticSearchHost = "localhost"  #"ubuntuserver"
elasticSearchPort = "9200"
indexName = "wikipedia_cached"

elasticSearchOptions = (title) ->
    hostname: elasticSearchHost
    port: elasticSearchPort
    path: "/#{indexName}/page/" + encodeURIComponent(title)
    method: 'GET'
    agent: false

logger = (req, res, next) ->
    console.log('Request: ' + req.method + ' ' + req.url)
    next()

errorLogger = (err, req, res, next) ->
    console.log('Error: ' + req.method + ' ' + req.url + ' ' + err.message)
    next()


cluster = require('cluster')
express = require('express')
http = require('http')
wikijs = require('wiky.js')
hbs = require('hbs')
numCPUs = require('os').cpus().length

http.globalAgent.maxSockets = 1000


if (cluster.isMaster)
    for i in [1..numCPUs]
        cluster.fork()

    cluster.on('exit', (worker, code, signal) ->
        console.log('worker ' + worker.process.pid + ' died')
    )
else
    app = express()

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
        innerReq = http.request(elasticSearchOptions(req.params.contentId), (innerRes) ->
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
        )

        innerReq.on('error', (e) ->
            console.log('Got error: ' + e.message)
        )

        innerReq.end()
    )

    app.get('/search/:searchString', (req, res) ->
        res.send(req.params.searchString)
    )

    app.listen(8080)
