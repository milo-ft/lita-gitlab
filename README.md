# lita-gitlab

 [![Build Status](https://travis-ci.org/milo-ft/lita-gitlab.png)](https://travis-ci.org/milo-ft/lita-gitlab)
 [![Code Climate](https://codeclimate.com/github/milo-ft/lita-gitlab.png)](https://codeclimate.com/github/milo-ft/lita-gitlab)
 [![Coverage Status](https://coveralls.io/repos/milo-ft/lita-gitlab/badge.png)](https://coveralls.io/r/milo-ft/lita-gitlab)

**lita-gitlab** is a [Lita](https://github.com/jimmycuadra/lita) that will display [GitLab](https://www.gitlab.com/gitlab-ce/) messages in the channel.

## Installation

Add **lita-gitlab** to your Lita instance's Gemfile:

``` ruby
gem "lita-gitlab"
```

## Configuration

### Required attributes

* `default_room` (String) - A channel idenitifier.
ie: `#general`.

### Example

``` ruby
Lita.configure do |config|
  config.handlers.gitlab.default_room = '#general'
end
```

## Usage

* `targets` Channel(s) separated by commas.
You will need to add a GitLab Webhook url that points to: `http://address.of./lita/gitlab?targets=<targets>`

## License

[MIT](http://opensource.org/licenses/MIT)
