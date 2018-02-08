require File.expand_path('../../test_helper', __FILE__)

api = URI.parse('https://fooapi.org')
map = ActiveXML::setup_transport(api.scheme, api.hostname, api.port)
map.connect :foobar, 'rest:///foobar/:attr1/?attr2=:attr2'

class Foobar < ActiveXML::Node
end
  
class NodeTest < ActiveSupport::TestCase
  test 'generates xpath correctly' do
    ::Foobar.find :foo, :attr1 => 'attr1', :attr2 => 'attr2'
  end
end
