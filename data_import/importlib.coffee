saxStreamFinished = ->
    #console.log('%j', xmlStats)
    console.log('FINISHED')

#parseWikiText = (page) ->
#    page['html'] = ''
#    parsoid = spawn('nodejs', ['../parsoid/tests/parse', '--wt2html'])
#    parsoid.stdout.on('data', (data) ->
#        page['html'] += data
#    )
#    parsoid.stderr.on('data', (data) ->
#        console.log("Error: " + data)
#    )
#    parsoid.on('close', () ->
#        runningConcurrentTransformations--
#        storePageToES(page)
#
#        while (runningConcurrentTransformations < maxConcurrentTransformations)
#            nextPage = pageQueue.shift()
#            if (nextPage != undefined )
#                storePage(nextPage)
#            else
#                break
#    )
#    parsoid.stdin.end(page['text'])
#
#storePage = (page) ->
#    if cacheHtml && page['text'] != undefined
#        page['html'] = wikijs.process(page['text'])
#
#        if (runningConcurrentTransformations > maxConcurrentTransformations)
#            pageQueue.push(page)
#        else
#            runningConcurrentTransformations++
#            parseWikiText(page)
#    else
#        storePageToES(page)

storePageToES = (page) ->
    if cacheHtml && page['text'] != undefined
        page['html'] = wikijs.process(page['text'])

    title = page['title']
    options =
        host: 'localhost'
        port: 9200
        path: "/#{indexName}/page/" + encodeURIComponent(title)
        method: 'PUT'

    req = http.request(options, (res) ->
        shouldLog = false
        if res.statusCode != 201
            shouldLog = true

        if shouldLog
            console.log("PAGE: #{title}")
            console.log('HEADERS: ' + JSON.stringify(res.headers))
        res.on('data', (chunk) ->
            if shouldLog
                console.log('BODY: ' + chunk)
        )
        res.on('error', (e) ->
            console.log("problem with the response #{title}: " + e.message)
        )
    )
    req.on('error', (e) ->
        console.log("problem with request #{title}: " + e.message)
    )
    req.write(JSON.stringify(page))
    req.end()

fs = require('fs')
sax = require('sax')
http = require('http')
wikijs = require('wiky.js')
Throttle = require('throttle')
XmlPath = require ('./XmlPath')
#spawn = require('child_process').spawn

maxConcurrentTransformations = 48
runningConcurrentTransformations = 0
pageQueue = []
throttle = new Throttle(128 * 1024)
cacheHtml = false

if cacheHtml
    indexName = 'wikipedia_cached'
else
    indexName = 'wikipedia'

xmlPath = new XmlPath
#wikipediaDataPath = '/home/peter/host/Dropbox/Bachelor/Wikipedia_rawData/skwiki-20130923-pages-articles.xml'
wikipediaDataPath = process.argv[2]
pageCount = 0
wikijs.options['link-image'] = false
strict = true
saxStreamOptions = 
    trim: true
    normalize: true
    lowercase: true

saxStream = sax.createStream(strict, saxStreamOptions)

inInitMode = true
currentNamespaceId = undefined
currentPage = undefined
namespaces = {}

saxStream.onopentag = (node) ->
    xmlPath.push(node.name)

    if inInitMode
        if node.name == 'namespace'
            currentNamespaceId = node.attributes['key']
    else if node.name == 'page'
        currentPage = {'view_count': 0}
    else if node.name == 'redirect'
        currentPage['redirect_to'] = node.attributes['title']

saxStream.ontext = (text) ->
    if currentNamespaceId != undefined
        namespaces[currentNamespaceId] = text
    else 
        switch xmlPath.peek()
            when 'title' then currentPage['title'] = text
            when 'text' then currentPage['text'] = text
            when 'ns' then currentPage['type'] = namespaces[text]
            when 'timestamp' then currentPage['timestamp'] = text
            when 'comment' then currentPage['comment'] = text
            when 'username' then currentPage['contributor_name'] = text
            when 'ip' then currentPage['contributor_ip'] = text

saxStream.onclosetag = (nodeName) ->
    xmlPath.pop()
    if inInitMode
        if nodeName == 'namespaces'
            inInitMode = false
            currentNamespaceId = undefined
    else if nodeName == 'page'
        storePageToES(currentPage)
        pageCount++
        if pageCount % 1000 == 0
            console.log("Finished #{pageCount} pages")
    else if xmlPath.isEmpty()
        saxStreamFinished()

fs.createReadStream(wikipediaDataPath).pipe(throttle).pipe(saxStream)