define( function () {
  // http://stackoverflow.com/questions/3446170/escape-string-for-use-in-javascript-regex
  return function (string) {
    return string.replace(/[\-\[\]\/\{\}\(\)\*\+\?\.\\\^\$\|]/g, "\\$&")
  }
})

