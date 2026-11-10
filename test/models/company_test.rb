require "test_helper"

class CompanyTest < ActiveSupport::TestCase
  test "企業名か業界に、その言葉が入っている企業を探す" do
    assert_equal [ companies(:bank) ], Company.search("銀行").to_a
    assert_equal [ companies(:tech) ], Company.search("ソフトウェア").to_a
  end

  test "探す言葉が空なら、全部の企業を返す" do
    assert_equal Company.count, Company.search("").count
  end

  test "% は「何にでも当てはまる記号」ではなく、ただの文字として探す" do
    company = Company.create!(name: "満足度100%商事", industry: "商社")

    assert_equal [ company ], Company.search("%").to_a
  end

  test "業界で絞り込む" do
    assert_equal [ companies(:bank) ], Company.in_industries([ "金融" ]).to_a
  end

  test "初任給が、指定した額ちょうどの企業も含めて絞り込む" do
    assert_equal [ companies(:tech) ], Company.with_salary_at_least("300000").to_a
  end

  test "勤務地の地方で絞り込み、2つの地方に当てはまる企業も1回だけ数える" do
    assert_equal [ companies(:tech) ], Company.in_areas([ "関東" ]).to_a
    assert_equal 2, Company.in_areas([ "関東", "近畿" ]).count
  end

  test "条件をいくつか組み合わせて絞り込む" do
    companies = Company.in_industries([ "金融", "ソフトウェア・通信" ]).with_salary_at_least("280000").in_areas([ "近畿" ])

    assert_equal [ companies(:tech) ], companies.to_a
  end

  test "条件が空なら、絞り込まない" do
    assert_equal Company.count, Company.in_industries(nil).with_salary_at_least("").in_areas([]).count
  end
end
