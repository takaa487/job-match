class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes

  # 画面（ビュー）からも ai_available? を使えるようにする
  helper_method :ai_available?

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
end
