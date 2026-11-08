class PagesController < ApplicationController
  def home
    @questions_count = Diagnosis::QUESTIONS.size
    @sample_types = Diagnosis::TYPES.values.first(6)
    @other_types_count = Diagnosis::TYPES.size - @sample_types.size
  end

  # プライバシーポリシー（だれでも見られる）
  def privacy
  end
end
