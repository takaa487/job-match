ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"

# .env の APIキーを消して、テストで本物のAIを呼ばない（お金がかからず、CI と同じ条件になる）ようにするため
ENV.delete("ANTHROPIC_API_KEY")

module ActiveSupport
  class TestCase
    parallelize(workers: :number_of_processors)
    fixtures :all
  end
end

module ActionDispatch
  class IntegrationTest
    # テストの中で sign_in users(:user) と書くだけで、ログインした状態にできるようにするため
    include Devise::Test::IntegrationHelpers
  end
end
