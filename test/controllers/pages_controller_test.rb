require "test_helper"

class PagesControllerTest < ActionDispatch::IntegrationTest
  test "トップページは、ログインしなくても見られる" do
    get root_url

    assert_response :success
  end

  test "プライバシーポリシーは、ログインしなくても見られる" do
    get privacy_url

    assert_response :success
  end
end