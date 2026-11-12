require "test_helper"

# チェックすると見えるようになる動きはブラウザの中の JavaScript なので、ここでは画面の部品が JavaScript とつながっているかを確かめる
class PasswordVisibilityTest < ActionDispatch::IntegrationTest
  test "新規登録では、パスワード欄2つを「パスワードを表示する」で切りかえられる" do
    get new_user_registration_url

    assert_select "[data-controller=password-visibility]" do
      assert_select "input[type=password][data-password-visibility-target=field]", 2
      assert_select "input[type=checkbox][data-action=?]", "change->password-visibility#toggle"
    end
  end

  test "ログインでも、パスワード欄を「パスワードを表示する」で切りかえられる" do
    get new_user_session_url

    assert_select "[data-controller=password-visibility]" do
      assert_select "input[type=password][data-password-visibility-target=field]", 1
      assert_select "input[type=checkbox][data-action=?]", "change->password-visibility#toggle"
    end
  end
end
