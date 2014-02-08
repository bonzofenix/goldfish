Goldfish
========

Simplest blog engine develop with sinatra and bootstrap.

Developed for [my personal web site](http://bonzofenix.com).

Play with the [example](goldfish.cfapps.io)(username: admin ,password: admin).

## Features:

- CRUL for posts.
- Markdown editor with Preview.
- Tags.
- Disquss.
- Coderay.


##Setting it up.

```bash
  cp config/application.example.ymp config/application.yml
  vi config/application.yml #set your personal configurations.

  #push it to your favourite cloud!
```

## Running it locally to test your configurations:

```
bundle install
shotgun
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

