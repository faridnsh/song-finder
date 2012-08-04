This is nodejs module or script that gets songs of a user from last.fm that have been listened more than 3 times and outputs them categorized by album.

## How to get

    git clone git://github.com/alFReD-NSH/song-finder.git
    cd song-finder
    npm install

## How to use

Just execute it with node, or use it from a module.

### In terminal

When first time running it asks for username and api, and saves it to a local config.json file. It pipes each album as a JSON object, each delimited by a new line character.

    node find.js

### or in node

Just give it an object having `username` and `api` and it returns you a full featured readable stream of `album` javascript objects. 

    var songFiner = require('song-finder');

    songFinder({
        username : 'AwesomeGuy',
        api : '123123sdnkfjdnslolz234this343is23my2api'
    })
        .pipe(process.stdout)
        .on('error', function (e) {
               throw e;
        });
    
Each album object contains the following properties.

* name `String`
* artist `String`
* tracks `Array<String>`

## FAQ

### Why streams and all the http abuse?

Becuase I don't wanna run out of memory coz some kid listened to a lot of songs! Streams are cool and fast(somtimes). And I wanted to play with some of @dominictarr awesome modules.
