require! <[https request deep-extend args-js ./search ./util]>

module.exports = class exports
  :: <<< search

  (params = {}, key) ~>
    if typeof params is \string
      @default-parameters = login: params
      @default-parameters.api_key = key if key? and typeof key is \string
    else
      @default-parameters = deep-extend {} params

  danbooru-errors =
    204: '204 No Content: Request was successful'
    403: '403 Forbidden: Access denied'
    404: '404 Not Found: Not found'
    420: '420 Invalid Record: Record could not be saved'
    421: '421 User Throttled: User is throttled, try again later'
    422: '422 Locked: The resource is locked and cannot be modified'
    423: '423 Already Exists: Resource already exists'
    424: '424 Invalid Parameters: The given parameters were invalid'
    500: '500 Internal Server Error: Some unknown error occurred on the server'
    503: '503 Service Unavailable: Server cannot currently handle the request, try again later'

  parse-path = -> "https://danbooru.donmai.us/#{(it is /^\/?(.*?)(?:\.(?:json|xml)|)$/).1}.json"
  do-request = (self, method, body, path, params, callback) !->
    stacktrace = util.stacktrace do-request

    let @ = self
      data = deep-extend {}, @default-parameters, params
      data-name = if body then \form else \qs
      uri = parse-path path

      request do
        {uri, method, (data-name): data, +json}
        (e, response, body) ->
          try
            throw e if e?
            throw new Error danbooru-errors[response.status-code] unless response.status-code is 200
            callback void body
          catch
            e.stack = stacktrace
            callback e, body
  optional-args = ->
    stacktrace = util.stacktrace optional-args

    try
      {path, params, callback} = args-js [
        * path: args-js.STRING .|. args-js.Optional
          _default: ''
        * params: args-js.OBJECT .|. args-js.Optional
          _default: {}
        * callback: args-js.FUNCTION .|. args-js.Optional
          _default: ->
      ], &
      [path, params, callback]
    catch
      e.stack = stacktrace
      throw e

  get: (path, params, callback) -> do-request @, \GET, false, ...optional-args ...
  post: (path, params, callback) -> do-request @, \POST, true, ...optional-args ...
  put: (path, params, callback) -> do-request @, \PUT, true, ...optional-args ...
  delete: (path, params, callback) -> do-request @, \DELETE, true, ...optional-args ...
|> -> it <<<< it!
