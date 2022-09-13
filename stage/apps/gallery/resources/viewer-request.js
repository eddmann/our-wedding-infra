/**
 * Ensure that the client is requesting the website from our desired canonical domain.
 * If this is not the case redirect them to this domain.
 *
 * This also ensures that authenticated requests using HTTP Basic Authentication are premitted.
 */
function handler(event) {
  var host = (event.request.headers.host && event.request.headers.host.value) || '';

  if (!host.startsWith('${DOMAIN}')) {
    var queryString = Object.keys(event.request.querystring)
      .map(key => key + '=' + event.request.querystring[key].value)
      .join('&');

    return {
      statusCode: 301,
      statusDescription: 'Moved Permanently',
      headers: {
        location: {
          value:
            'https://${DOMAIN}' +
            event.request.uri +
            (queryString.length > 0 ? '?' + queryString : ''),
        },
      },
    };
  }

  var authorization =
    (event.request.headers.authorization && event.request.headers.authorization.value) || '';

  if (authorization !== '${AUTHORIZATION}') {
    return {
      statusCode: 401,
      statusDescription: 'Unauthorized',
      headers: {
        'www-authenticate': {
          value: 'Basic realm="Enter gallery credentials"',
        },
      },
    };
  }

  return event.request;
}
