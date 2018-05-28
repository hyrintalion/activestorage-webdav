# ActiveStorageWebDAV

WebDAV сервис для ActiveStorage.

[![Build Status](https://travis-ci.org/hyrintalion/activestorage-webdav)](https://travis-ci.org/d-unseductable/ruru)

## Installation

Добавьте эту строку в Gemfile вашего приложения:

```ruby
gem 'activestorage_webdav'
```

Запустите:

    $ bundle

Объявите webdav сервис в файле config/storage.yml с нужными параметрами:

```yml
webdav:
  service: WebDAV
  url: "http://path_to_your/webdav_server/"
```

##  Использование

Чтобы использовать сервис WebDAV в среде разработки, нужно добавить следующее в config/environments/нужная_среда.rb:

```ruby.
config.active_storage.service = :webdav
```

## Сотрудничество

Сообщения об ошибках и pull requests принимаются здесь: https://github.com/[USERNAME]/activestorage_webdav. Для более продуктивного сотрудничества, придерживатесь кодекс поведения для проектов с открытым исходным кодом [Contributor Covenant] (http://contributor-covenant.org).

## Лицензия

Данный гем опубликован на условиях лицензии [MIT License](https://opensource.org/licenses/MIT).

## Этические правила поведения

Все, кто использует код проекта ActiveStorageWebDAV, обязуются соблюдать
[правила поведения](https://github.com/[USERNAME]/activestorage_webdav/blob/master/CODE_OF_CONDUCT.md).

