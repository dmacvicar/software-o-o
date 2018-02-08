

# ActiveXML

## Warning

This documentation has been writen by reading the code and observing its usage.

## Introduction

ActiveXML is a library to access REST resources in a Rails model-like interface.

## Setup

* Setup the transport in eg. `config/initializers/active.xml`

```ruby
api = URI('https://api.myhost.com')
map = ActiveXML::setup_transport(api.scheme, api.hostname, api.port)
```

`setup_transport` creates a new transport object, and sets it as the global transport in the `ActiveXML` class.
The transport is returned so that it can be configured, and mappings can be created.

The following connect statement would connect the model `Published` to do a REST call on the `/published` path, passing the rest of the parameters as parameters to ind`.

```ruby
map.connect :published, 'rest:///published/:project/:repository/:arch/:name?:view'
```

Would be used as:

```ruby
pat = ::Published.find('file.txt', project: 'myproject, repository: 'myrepo', view: 'myfileinfo')
```
You can set login information:

```ruby
map.set_additional_header( "X-Username", config.api_username)
```

or authentication

```ruby
map.login config.api_username, config.api_password
```

