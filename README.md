# ActiveStorageWebDAV

WebDAV service for ActiveStorage.

[![Build Status]()]()

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

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/activestorage_webdav. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Activestorage::Webdav project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/activestorage_webdav/blob/master/CODE_OF_CONDUCT.md).
