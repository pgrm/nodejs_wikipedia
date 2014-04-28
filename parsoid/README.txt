A combined Mediawiki and html parser in JavaScript running on node.js. Please
see (https://www.mediawiki.org/wiki/Future/Parser_development) for an overview
of the current implementation, and instructions on running the tests.

You might need to set the NODE_PATH environment variable,
  export NODE_PATH="node_modules"

Download the dependencies:
  npm install

Run tests:
  npm test

Configure your Parsoid web service:

 cd api
 cp localsettings.js.example localsettings.js
 // Tweak localsettings.js

Run the webservice:

 npm start

More details are available at https://www.mediawiki.org/wiki/Parsoid/Setup
