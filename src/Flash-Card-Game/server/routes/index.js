/*
following tutorial for auth0 router setup
*/

const { auth } = require('express-openid-connect');
const { requiresAuth } = require('express-openid-connect');

const config = {
  authRequired: false,
  auth0Logout: true,
  // "You can generate a suitable string for secret using openssl rand -hex 32 on the command line."
  secret: 'c36515ddb892ea9e8ce1acd6533c871caa8f595c944ed53c5f40af80eeb46485',
  // this is where someone gets directed to on logout, currently set as the homepage
  baseURL: 'http://localhost:4001',
  clientID: 'v3ma3OxeK5UqDvKbFjESL6xwOAmywwzf',
  issuerBaseURL: 'https://dev-5pscksgz.us.auth0.com',
};

App.use(auth(config)); // "auth router attaches login, /logout, and /callback routes to the baseURL"

/*
Their example:

app.get('/profile', requiresAuth(), (req, res) => {
  res.send(JSON.stringify(req.oidc.user));
});
*/
