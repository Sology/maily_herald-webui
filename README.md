# MailyHerald Web UI

Web interface for [MailyHerald](https://github.com/Sology/maily_herald) - Ruby on Rails email marketing solution.

## Requirements

Both Ruby on Rails 3.2 and 4 are supported. 

## Installation

Simply just

    gem install maily_herald-webui

or put in your Gemfile

    gem "maily_herald-webui"

## Usage

Mount WebUI in your application:

```ruby
# config/routes.rb
mount MailyHerald::Webui::Engine => "/maily_webui"
```

## Customizing

### Restricting access

The simplest way to restrict access to Maily WebUI is to use Rails routing constraints:

```ruby
# config/routes.rb
mount MailyHerald::Webui::Engine => "/maily_webui", :constraints => MailyAccessConstraint.new
```

Sample `MailyAccessConstraint` implementation might look like this:

```ruby
class MailyAccessConstraint
  def matches?(request)
    return false unless request.session[:user_id]
    user = User.find request.session[:user_id]
    return user && user.admin?
  end
end
```

## Conflict between will_paginate and kaminari
will_paginate is known to cause problem when used with kaminari, to which maily_herald-webui has dependency. To work around this issue, create config/initializers/will_paginate.rb with following content:

```ruby
# config/initializers/will_paginate.rb
if defined?(WillPaginate)
  module WillPaginate
    module ActiveRecord
      module RelationMethods
        alias_method :per, :per_page
        alias_method :num_pages, :total_pages
      end
    end
  end
end
```

## More Information

* [Home Page](http://mailyherald.org)
* [API Docs](http://www.rubydoc.info/gems/maily_herald)
* [Showcase](http://showcase.sology.eu/maily_herald)
* [Sample application](https://github.com/Sology/maily_testapp)

For bug reports or feature requests see the [issues on Github](https://github.com/Sology/maily_herald-webui/issues).  

## License

LGPLv3 License. Copyright 2013-2015 Sology. http://www.sology.eu
