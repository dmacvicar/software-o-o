require 'test_helper'

class OBSTest < ActiveSupport::TestCase
  test 'search binaries data structure' do
    result = OBS.search_published_binary('vcpkg', baseproject: 'openSUSE:Factory')
    assert_equal [:binary, :matches], result.keys

    assert_kind_of OBS::Collection, result
    assert_equal 2, result.matches
    assert_equal 4, result.binaries.size
  end

end
