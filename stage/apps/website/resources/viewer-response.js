/**
 * Ensure that Basic HTTP Authentication required by the application is returned to the client.
 * This gets remapped when using Lambda Function Urls.
 */
function handler(event) {
  var response = event.response;

  if (response.headers['x-amzn-remapped-www-authenticate']) {
    response.headers['www-authenticate'] =
      response.headers['x-amzn-remapped-www-authenticate'];
  }

  return response;
}
