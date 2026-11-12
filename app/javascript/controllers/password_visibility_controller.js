import { Controller } from "@hotwired/stimulus"

// 「パスワードを表示する」にチェックを入れている間だけ、パスワード欄を普通の文字で見せる
export default class extends Controller {
  static targets = [ "field" ]

  toggle(event) {
    const type = event.target.checked ? "text" : "password"
    this.fieldTargets.forEach((field) => { field.type = type })
  }
}
