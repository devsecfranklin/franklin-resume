const winston = require('winston')

const options = {
    file: {
      level: 'info',
      handleExceptions: true,
      json: false,
      colorize: false,
    },
    console: {
      level: 'debug',
      handleExceptions: true,
      json: true,
      colorize: false,
    },
  };

const logger = winston.createLogger({
levels: winston.config.npm.levels,
transports: [
    new winston.transports.Console(options.console)
  ],
  exitOnError: false
})
  
module.exports = logger

const http = require('http');
const os = require('os');
const handler = function(request, response) {
    logger.info("You've hit " + os.hostname() + "\n") // This is printed to logs in GCP
    console.info("this is console log") // This is printed to logs in GCP
    response.writeHead(200);
    // response.end("You've hit " + os.hostname() + "\n");
};

var www = http.createServer(handler);
www.listen(8089);