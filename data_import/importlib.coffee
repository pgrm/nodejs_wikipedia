class XmlPath
    currentPath: []

    push: (item) ->
        @currentPath.push(item)

    pop: ->
        @currentPath.pop()

    peek: ->
        @currentPath[@currentPath.length - 1]

    isEmpty: ->
        @currentPath.length == 0

    startsWith: (subPath) ->
        @startsWith(@currentPath, subPath)

    startsWith: (path, subPath) ->
        for i in [0...subPath.length] by 1
            if subPath[i] != path[i]
                return false
        true

    endsWith: (subPath) ->
        @startsWith(path.reverse(), subPath.reverse())

    applyForStatsToObject: (item, attributes) ->
        for part in @currentPath
            if item[part] == undefined
                item[part] =
                    _count: 0

            item = item[part]

        item['_count']++

        for k, v of attributes
            if item[k] == undefined
                item[k] = 0
            else
                item[k]++

    toString: ->
        @currentPath.toString()
#end XmlPath

fs = require('fs')
sax = require('sax')
http = require('http')
wikijs = require('wiky.js')
Throttle = require('throttle')
throttle = new Throttle(768 * 1024)

cacheHtml = true

if cacheHtml
    indexName = 'wikipedia_cached'
else
    indexName = 'wikipedia'

xmlPath = new XmlPath
wikipediaDataPath = '/home/peter/host/Dropbox/Bachelor/Wikipedia_rawData/skwiki-20130923-pages-articles.xml'
pageCount = 0
wikijs.options['link-image'] = false
strict = true
saxStreamOptions = 
    trim: true
    normalize: true
    lowercase: true

#xmlStats = {}
saxStream = sax.createStream(strict, saxStreamOptions)

saxStreamFinished = ->
    #console.log('%j', xmlStats)
    console.log('FINISHED')

storePage = (page) ->
    title = page['title']

    if cacheHtml && page['text'] != undefined
        page['html'] = wikijs.process(page['text'])
    options =
        host: 'localhost'
        port: 9200
        path: "/#{indexName}/page/" + encodeURIComponent(page['title'])
        method: 'PUT'
    req = http.request(options, (res) ->
        shouldLog = false
        if res.statusCode != 201
            shouldLog = true

        if shouldLog
            console.log('PAGE: ' + page['title'])
            console.log('HEADERS: ' + JSON.stringify(res.headers))
        res.on('data', (chunk) ->
            if shouldLog
                console.log('BODY: ' + chunk)
        )
    )
    req.on('error', (e) ->
        console.log("problem with request #{title}: " + e.message)
    )
    req.write(JSON.stringify(page))
    req.end()

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
        currentPage = {}
    else if node.name == 'redirect'
        currentPage['redirect_to'] = node.attributes['title']
    #xmlPath.applyForStatsToObject(xmlStats, node.attributes)

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
        storePage(currentPage)
        pageCount++
        if pageCount % 1000 == 0
            console.log("Finished #{pageCount} pages")
    else if xmlPath.isEmpty()
        saxStreamFinished()

fs.createReadStream(wikipediaDataPath).pipe(throttle).pipe(saxStream)