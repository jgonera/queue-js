require('coffee-script');
var chai = require('chai');
var sinonChai = require('sinon-chai');

global.sinon = require('sinon');
global.should = chai.should();
chai.use(sinonChai);
