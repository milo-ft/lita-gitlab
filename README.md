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

* `url` (String) - The Gitlab repository location.
ie: `http://gitlab.mycompany.com/`.

* `group_name` (String) - Your group identifier.
ie: `my_team`.

### Example

``` ruby
Lita.configure do |config|
  config.handlers.gitlab.default_room = '#general'
  config.handlers.gitlab.url = 'http://example.gitlab/'
  config.handlers.gitlab.group = 'group_name'
end
```

## Usage

* `targets` Channel(s) separated by commas.
* `project` The name of the specific project (only needed for webhooks).

You will need to add a GitLab Webhook url that points to: `http://address.of./lita/gitlab?targets=<targets>&project=<project>`

## License

[MIT](http://opensource.org/licenses/MIT)
