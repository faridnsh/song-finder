This is node module or script that gets songs.

If you didn't understand how does it work from description and wanna know more just do the following.

## How to get

    git clone git://github.com/alFReD-NSH/song-finder.git
    cd song-finder
    npm install

## How to use

Just execute it with node, or use it from a module.

### In terminal

When first time running it asks for username and api, and saves it to a local config.json file.

    node find.js

### or in node

Just give it an object having `username` and `api` and it returns you a full featured readable stream.

    var songFiner = require('song-finder');

    songFinder({
        username : 'AwesomeGuy',
        api : '123123sdnkfjdnslolz234this343is23my2api'
    })
        .pipe(process.stdout)
        .on('error', function (e) {
               throw e;
        });
## FAQ

### Why streams and all the http abuse?

Becuase I don't wanna run out of memory coz some kid listened to a lot of songs! Streams are cool and fast(somtimes). And I wanted to play with some of @dominictarr awesome modules.
