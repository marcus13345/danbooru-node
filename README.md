# danbooru-node
danbooru api wrapper

[![NPM](https://nodei.co/npm/danbooru.png?mini=true)](https://nodei.co/npm/danbooru/)
[![Build Status](https://travis-ci.org/stawberri/danbooru-node.svg?branch=master)](https://travis-ci.org/stawberri/danbooru-node)

This package is an api wrapper intended to make [Danbooru's api](https://danbooru.donmai.us/wiki_pages/43568) even easier to work with.

```js
const Danbooru = require('danbooru')

let booru = new Danbooru()
booru.posts('1girl cat_ears').then(async posts => {
  let file = posts[0].file
  let data = await file.download()
  require('fs').writeFile(file.name, data))
})
```

This module has been updated to require Node.js 7. You can still install version 1 with `npm install danbooru@1` and [read its documentation on Github](https://github.com/stawberri/danbooru-node/tree/v1.4.8).


## Danbooru class
This module exposes the `Danbooru` class. Instantiating it with no arguments creates an unauthenticated session, while passing it parameters allows you to log in. You can also specify an alternate base url. Your `api_key` is not your password, and you can find it on your profile page.

```js
// Unauthenticated session
let booru = new Danbooru()

// Login to your account with your username and api_key
let booru = new Danbooru('login', 'api_key')

// Optionally provide a base url to use a different server
let booru = new Danbooru({
  login: 'login',
  api_key: 'api_key',
  base: 'http://sonohara.donmai.us'
})

// Specify all three in one string
let booru = new Danbooru(`http://login:api_key@sonohara.donmai.us`)
```

### Safebooru subclass

A `Safebooru` subclass is available that locks the base url to `https://safebooru.donmai.us`. This alternate server only serves "safe" images. Please refer to [Danbooru's definition of safe](https://danbooru.donmai.us/wiki_pages/10920), and remember that ratings for most posts can be changed by anyone.

```js
// Unauthenticated safe images session
let booru = new Danbooru.Safebooru()

// Login, but still only see safe posts
let booru = new Danbooru.Safebooru('login', 'api_key')
```


## Image posts
Images on Danbooru come with a bunch of tags and other metadata. These are bundled into packages called posts. There are two functions available to you to find them.

### Searching for posts
You can search for a tag string, or choose to use the full set of post listing parameters Danbooru makes available through its api. You may wish to refer to [Danbooru's search cheat sheet](https://danbooru.donmai.us/wiki_pages/43049) to decide on your search query.

This function returns a promise that resolves to an array of posts.

```js
// Perform a simple search for a tag string or array of tags
let postArray = await booru.posts('fox_ears maid')
let postArray = await booru.posts(['fox_ears', 'maid'])

// Specify parameters
let postArray = await booru.posts({
  limit: 100,
  page: 1,
  tags: 'fox_ears maid',
  random: true
})
```

### Fetching a post
If you know the numerical ID of a post, you can fetch it directly. This function returns a promise that resolves to a single post.

```js
// Fetch a single post
let post = await booru.post(2596801)
```


### Post object
This module parses posts and restructures them into an instance of `Post`.

```js
// Get the id of a post as an integer or a string
let id = post.id
let id = +post.id
let id = String(post.id)

// Get a post's raw data, as received from the server
let data = post.raw

// Look up a post's tags
let tags = post.tags
// Break up a post's tags into categories
let artists = post.tags.artist
let characters = post.tags.character
let copyrights = post.tags.copyright
let otherTags = post.tags.general

// Get a post's rating as a boolean
let isSafe = post.rating.s
let isSafe = post.rating.safe
let isQuestionable = post.rating.q
let isQuestionable = post.rating.questionable
let isExplicit = post.rating.e
let isExplicit = post.rating.explicit
// Or get it as a string
String(post.rating) === 's'
```

### Download object
Posts have a download object meant to make downloading files easier. You can access it with `post.file`.

Note that you may occasionally encounter posts that have been deleted or marked as unavailable due to their tags. In this case, `post.file` will still return an object, but it will be missing most of its properties.

```js
// Fetch a post's file object
let file = post.file
// Check if it's actually available first
if(!('request' in file)) return

// Get some details about the file
let filename = file.name
let fileExtension = file.ext
let width = file.width
let height = file.height
let md5 = file.md5
let size = file.size

// Start a http request for the file
let httpResponse = file.request()
// Or just get its data in a promise!
let dataPromise = file.download()
// Keep track of its download progress
dataPromise.data((bytesDownloaded, bytesTotal) => {
  let percent = 100 * bytesDownloaded/bytesTotal
  console.log(`Currently downloaded ${percent}%`)
})
// then() or await the promise to get a buffer of your image
let dataBuffer = await dataPromise
// You can also cancel a download
// dataPromise.abort()
```

Posts also have a `preview` thumbnail image, and a `large` preview image that is used on post pages if the actual image is too large.

```js
// Get thumbnail image
let preview = post.file.preview
// Preview images have less data associated with them
let name = preview.name
let extension = preview.ext
let data = preview.download()
// Note that you should not call request() if you plan to call download().
//   This is only for reference.
let response = preview.request()

// Large preview images do not always exist, so check if they exist first.
if('large' in post.file) {
  let largePreview = post.file.large
  let largeBuffer = await file.download()
}
```
