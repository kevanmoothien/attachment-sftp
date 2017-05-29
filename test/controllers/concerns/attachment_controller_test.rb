require 'test_helper'

class Concerns::AttachmentControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get concerns_attachment_index_url
    assert_response :success
  end

end
