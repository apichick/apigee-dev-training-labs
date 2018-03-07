'use strict';
var debug = require('debug');
var parser = require('xml2json');

module.exports.init = function(config, logger, stats) {

  return {
    
    onend_response: function(req, res, data, next) {
        var baseUrl = res.proxy.parsedUrl.pathname;
        var proxyBasepath = res.proxy.base_path; 
        var proxyPathsuffix = req.reqUrl.pathname.replace(proxyBasepath, '');
        var result = '';
        if(proxyBasepath === '/book/v1') {
            if(new Regexp("/books(\/.+)*").test(proxyPathsuffix)) {
                result = parser.toJson(data.toString());
            } 
        }
        next(null, result);
    }
  };
}
