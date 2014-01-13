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

module.exports = XmlPath