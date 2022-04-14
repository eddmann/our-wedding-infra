/**
 * Ensure that Basic HTTP Authentication required by the application is returned to the client.
 * This gets remapped when using Lambda Function Urls.
 */
exports.handler = async event => {
  const response = event.Records[0].cf.response;
  const headers = response.headers;

  if (headers['x-amzn-remapped-www-authenticate']) {
    headers['www-authenticate'] = [
      {
        key: 'WWW-Authenticate',
        value: headers['x-amzn-remapped-www-authenticate'][0].value,
      },
    ];
    delete headers['x-amzn-remapped-www-authenticate'];
  }

  return response;
};
