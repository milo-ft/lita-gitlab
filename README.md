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

* `repos` (Hash) - A map of repositories to allow notifications for and the chat rooms to post them in.
The keys should be strings in the format "gitlab_username/repository_name" and the values should be either a string room name or an array of string room names.
Default: `{}`.

### Example

``` ruby
Lita.configure do |config|
  config.handlers.gitlab.repos = {
    "username/repo1" => "#someroom",
    "username/repo2" => ["#someroom", "#someotherroom"]
  }
end
```

## Usage

You will need to add a GitLab Webhook url that points to: `http://address.of.lita/gitlab`

## License

[MIT](http://opensource.org/licenses/MIT)
