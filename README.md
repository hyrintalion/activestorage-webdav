[![Build Status](https://travis-ci.org/hyrintalion/activestorage-webdav.svg?branch=master)](https://travis-ci.org/hyrintalion/activestorage-webdav)

# ActiveStorageWebDAV

WebDAV service for ActiveStorage.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'activestorage_webdav'
```

And then execute:

    $ bundle

Set up webdav storage service in config/storage.yml:

```yml
webdav:
  service: WebDAV
  url: "http://path_to_your/webdav_server/"
```

## Usage

To use the WebDAV service in the development environment, you would add the following to config/environments/your_environment.rb:

```ruby.
config.active_storage.service = :webdav
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/hyrintalion/activestorage_webdav. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Activestorage::Webdav project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/activestorage_webdav/blob/master/CODE_OF_CONDUCT.md).


<a href="https://funbox.ru">
  <img src="https://funbox.ru/badges/sponsored_by_funbox.svg" alt="Sponsored by FunBox" width=250 />
</a>
