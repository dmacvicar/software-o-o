require 'test_helper'

class AppdataTest < ActiveSupport::TestCase
  test 'Factory Appdata can be parsed' do
    appdata = Appdata.get('factory')
    pkg_list = appdata[:apps].map { |p| p[:pkgname] }.uniq

    assert_equal 2, pkg_list.size
    assert_equal ['0ad', '4pane'], pkg_list
  end
end
