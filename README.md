# MailyHerald Web UI

Web interface for Ruby on Rails email marketing solution - [MailyHerald](https://github.com/Sology/maily_herald).

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

## More Information

* [Home Page](http://www.mailyherald.org)
* [API Docs](http://www.rubydoc.info/gems/maily_herald)
* Showcase (_coming soon_)
* [Sample application](https://github.com/Sology/maily_testapp)

For bug reports or feature requests see the [issues on Github](https://github.com/Sology/maily_herald-webui/issues).  

## License

LGPLv3 License. Copyright 2013-2015 Sology. http://www.sology.eu
