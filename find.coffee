async = require 'async'
request = require 'request'
JSONStream = require 'JSONStream'
es = require 'event-stream'

# I don't wanna have coffee without sugar
require 'sugar'
Object.extend()

config = {}

# This is a helper function to get a stream of last.fm call.
libGet = (type, options={}) ->
    method = 'library.get' + type.capitalize() + 's'
    options.merge {
        user : config.username
        method
        api_key : config.api
        format : 'JSON'
        limit : 10
    }
       
    req = request
        uri : 'http://ws.audioscrobbler.com/2.0'
        qs : options

    jstream = JSONStream.parse([type + 's', type, true])

    es.connect(
        req,
        jstream,
        es.mapSync (data) ->
            return if data.playcount > 3 then data.name # else null
    )

start = () ->
    artistS = libGet 'artist'

    addAlbumWrite = (artist) ->
        this.pause()
        albumS = libGet 'album', { artist }
        albumS.pipe es.map (album, cb) =>
            trackS = libGet 'track', { artist, album }
            trackS.pipe es.writeArray (err, tracks) =>
                if (tracks.length)
                    album =
                        name : album
                        artist : artist
                        tracks : tracks
                    this.emit 'data', album
                cb(null)
        albumS.on 'end', =>
            this.resume()

    addAlbumEnd = ->
        if this.paused
            this.on 'resume', =>
                this.emit 'end'
        else
            this.emit 'end'

    addAlbum = es.through addAlbumWrite, addAlbumEnd
    es.connect(artistS, addAlbum)

ask = (cb = ->) ->
    console.log "Seems you don't have a config.json file let's make one!"
    rl = require('readline').createInterface process.stdin, process.stdout, null
    fs = require 'fs'
    console.log "Just go to this page: http://www.last.fm/api/account and get 
your credentials"
    
    questions =
        api : 'Paste your API KEY here'
        username : 'Now tell us your username'

    questions.each (key, question) ->
        if Object.has config, key
           question += ' (' + config[key] + ') :'
        questions[key] = (cb) ->
            rl.question question, (a) -> cb null, a

    async.series questions, (err, res) ->
        config = res.each (key, value = '') ->
            value = value.trim()
            if value.lengh
                config[key] = value
        fs.writeFileSync './config.json', JSON.stringify(config), 'utf8'
        cb()

if not module.parent
    oldStart = start
    start = (config) ->
        es.connect(oldStart(config), JSONStream.stringify(false),
            process.stdout)
        .on 'err', (e) -> throw e

    # First we get the config and then run the start function
    try
        config = require './config.json'
    catch e
        if not e.message.has 'config.json' then throw e
        config = {}

    start = start.bind null, config

    if config.api and config.username
        start(config)
    else
        ask start
else
    module.exports = start
