function handler(event) {
  var host =
    (event.request.headers.host &&
      event.request.headers.host.value) ||
    '';

  if (host.indexOf('www.') !== 0) {
    return event.request;
  }

  var queryString = Object.keys(event.request.querystring)
    .map(key => key + '=' + event.request.querystring[key].value)
    .join('&');

  return {
    statusCode: 302,
    statusDescription: 'Found',
    headers: {
      location: {
        value:
          'https://' +
          host.substr(4) +
          event.request.uri +
          (queryString.length > 0 ? '?' + queryString : ''),
      },
    },
  };
}
