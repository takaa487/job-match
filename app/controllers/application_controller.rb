class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes

  AI_FAILED_MESSAGE = "AIの呼び出しに失敗しました。時間をおいてもう一度試してください".freeze

  # 画面（ビュー）からも ai_available? を使えるようにする
  helper_method :ai_available?

  # AI の通信や API が失敗しても、エラー画面にせず、元の画面に戻してメッセージを出す
  rescue_from Claude::Error, with: :ai_failed

  private

  # AIを使えるか（APIキーが入っているか）。キーを入れていない所（公開先など）では false
  def ai_available?
    ENV["ANTHROPIC_API_KEY"].present?
  end

  # AIを呼ぶ処理の前に使う。AIが使えなければ、AIを呼ばずに元のページへ戻す
  def require_ai
    return if ai_available?

    redirect_back fallback_location: root_path, alert: "AIの機能は準備中です"
  end

  def ai_failed(error)
    log_ai_failure(error)
    redirect_back fallback_location: root_path, alert: AI_FAILED_MESSAGE
  end

  # 失敗の原因（API の返事の番号や、通信のエラー）を、あとでログから調べられるようにする
  def log_ai_failure(error)
    Rails.logger.warn("AIの呼び出しに失敗しました: #{error.message}")
  end
end
