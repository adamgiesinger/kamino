'use strict';

/* global LiquidCore */

// Environment variables set by webpack:
// process.env.CLAWS_ENV = 'client';

const EventEmitter = require('events');
// Load providers from the Claws repository (https://github.com/ApolloTVofficial/claws)
const providers = require(`${process.env.CLAWS_DIR}/src/scrapers/providers`);

/*let LiquidCore = global['LiquidCore'];
if (typeof LiquidCore === 'undefined') {
  console.error("LiquidCore does not exist. Creating empty shim...");
  class LiquidCore_ extends EventEmitter {}
  LiquidCore = new LiquidCore_();
}*/

/**
 * Shim for express-sse which emits data over to LiquidCore.
 */
class SseShim extends EventEmitter {
  /**
   * Send data to LiquidCore
   * @param data {(object|string)} Data to send into the stream
   * @param event [string] Event name
   * @param id [(string|number)] Custom event ID
   */
  send(data, event, id = null) {
    LiquidCore.emit(event, data);
  }
}

const sses = [];

/**
 *
 * @param {string} mediaType
 * @param {object} query
 * @return {SseShim|EventEmitter}
 */
function resolveLinks(mediaType, query = {}) {
  const promises = [];

  // Create a shim recreation of the express request object.
  const req = new EventEmitter();
  req.client = {
    remoteAddress: '127.0.0.1',
  };
  req.query = query;

  const sse = new SseShim();
  sse.send({data: [`${new Date().getTime()}`], event: 'status'}, 'result');

  sses.push(sse);

  switch (mediaType) {
    case 'movies':
      [...providers.movies, ...providers.universal].forEach((provider) => {
        promises.push(provider(req, sse));
      });
      break;
    case 'tv':
      [...providers.tv, ...providers.universal].forEach((provider) => {
        promises.push(provider(req, sse));
      });
      break;
    default:
      throw `Unknown media type: ${mediaType}.`;
  }

  Promise.all(promises).then(function onFulfilled(values) {
    sse.send({event: 'success'}, 'done');
  }, function onRejected(reason) {
    console.error(reason);
    sse.send({event: 'error', error: reason + ''}, 'done');
  }).then(() => {
    // Remove it from the list.
    sses.splice( sses.indexOf(sse), 1 );
  });

  return sse;
}

// Listen for disconnections as soon as possible.
LiquidCore.on('disconnected', () => {
  for (let i=0; i<sses.length; i++) {
    sses[i].stopExecution = true;
  }
  // Exit the server. This will be called by the app.
  process.exit(0);
});

// Request links.
LiquidCore.on('request_links', (data) => {
  return resolveLinks(data.type, data.query);
});

// Ok, we are all set up.  Let the host know we are ready to talk
LiquidCore.emit('ready');

// Release the service after a maximum of 2 minutes.
// This shouldn't ever happen. 
setTimeout(function () {
  console.log("Server timeout reached, Exiting...");
  process.exit(1);
}, 120 * 1000);

// The micro service will exit when it has nothing left to do.  So to
// avoid a premature exit, we'll set an indefinite timer here until process.exit() is called.
//setInterval(function () {}, 1000);
