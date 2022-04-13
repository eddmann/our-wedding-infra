/**
 * Ensure that the client is requesting the website from our desired canonical domain.
 * If this is not the case redirect them to this domain.
 */
function handler(event) {
  var host =
    (event.request.headers.host && event.request.headers.host.value) || '';

  if (host.indexOf('${DOMAIN}') === 0) {
    return event.request;
  }

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
