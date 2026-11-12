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
  test "企業のページから、企業名を入れた状態でES作成の画面へ移れる" do
    sign_in users(:user)

    get company_url(companies(:tech))

    assert_select "a[href=?]", new_es_generation_path(company_name: "サンプルソフト")
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

  test "管理者は、勤務地も含めて企業の情報を更新できる" do
    sign_in users(:admin)

    patch company_url(companies(:tech)), params: { company: { work_location: "本社：横浜" } }

    assert_redirected_to company_url(companies(:tech))
    assert_equal "本社：横浜", companies(:tech).reload.work_location
  end

  test "登録の画面では、業界を8つの中から選ぶ" do
    sign_in users(:admin)

    get new_company_url

    assert_select "select#company_industry option", 9
  end

  test "管理者が企業を消しても、利用者が保存した ES は残る" do
    sign_in users(:admin)

    assert_no_difference -> { EsDraft.count } do
      delete company_url(companies(:tech))
    end
    assert_redirected_to companies_url
  end
end
