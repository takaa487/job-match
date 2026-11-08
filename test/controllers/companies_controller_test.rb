require "test_helper"

class CompaniesControllerTest < ActionDispatch::IntegrationTest
  test "ログインしていないと、ログインの画面に移動する" do
    get companies_url

    assert_redirected_to new_user_session_url
  end

  test "企業名か業界の言葉で検索できる" do
    sign_in users(:user)

    get companies_url, params: { search: "金融" }

    assert_response :success
    assert_includes response.body, companies(:bank).name
    assert_not_includes response.body, companies(:tech).name
  end

  test "業界で絞り込める" do
    sign_in users(:user)

    get filter_companies_url, params: { industries: [ "金融" ] }

    assert_includes response.body, companies(:bank).name
    assert_not_includes response.body, companies(:tech).name
  end

  test "初任給で絞り込める" do
    sign_in users(:user)

    get filter_companies_url, params: { min_salary: 280_000 }

    assert_includes response.body, companies(:tech).name
    assert_not_includes response.body, companies(:bank).name
  end

  test "勤務地で絞り込める" do
    sign_in users(:user)

    get filter_companies_url, params: { areas: [ "関東" ] }

    assert_includes response.body, companies(:tech).name
    assert_not_includes response.body, companies(:bank).name
  end

  test "管理者でなければ、企業を登録できない" do
    sign_in users(:user)

    assert_no_difference -> { Company.count } do
      post companies_url, params: { company: { name: "新しい会社", industry: "金融" } }
    end
    assert_redirected_to companies_url
    assert_equal "権限がありません", flash[:alert]
  end

  test "管理者は、企業を登録できる" do
    sign_in users(:admin)

    assert_difference -> { Company.count }, 1 do
      post companies_url, params: { company: { name: "新しい会社", industry: "金融" } }
    end
    assert_redirected_to company_url(Company.find_by!(name: "新しい会社"))
  end
end
