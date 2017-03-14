'use strict';

function makeJwt(stravaData) {
  const jwt = require("jsonwebtoken");
  const secret = process.env.JWT_SECRET;

  const jwtData = {
    accessToken: stravaData.access_token,
    athleteName: stravaData.athlete.firstname + " " + stravaData.athlete.lastname
  };

  return jwt.sign(jwtData, secret);
}

module.exports.authCallback = (event, context, callback) => {
  const https = require("https")
  const querystring = require("querystring");

  const applicationURL = process.env.APPLICATION_URL;
  const stravaCode = event.queryStringParameters.code;

  const postData = querystring.stringify({
    "client_id": process.env.STRAVA_CLIENT_ID,
    "client_secret": process.env.STRAVA_CLIENT_SECRET,
    "code": stravaCode
  });
  const options = {
    hostname: "www.strava.com",
    path: "/oauth/token",
    method: "POST",
    headers: {
      "Content-Type": "application/x-www-form-urlencoded",
      "Content-Length": Buffer.byteLength(postData)
    }
  };

  var req = https.request(options, (res) => {
    var stravaData = "";

    res.on("data", (data) => {
      stravaData += data;
    });

    res.on("end", () => {
      stravaData = JSON.parse(stravaData);
      const jwt = makeJwt(stravaData);

      const response = {
        statusCode: 302,
        headers: { "Location": applicationURL + "?jwt=" + jwt },
        body: ""
      };

      callback(null, response);
    });

    res.on("error", (error) => {
      console.log("Failed to do token exchange with Strava: " + error);

      const response = {
        statusCode: 302,
        headers: { "Location": applicationURL + "?error=unauthorized" },
        body: ""
      };

      callback(null, response);
    });
  });

  req.write(postData);
  req.end
};
