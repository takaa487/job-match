class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  # :recoverable（メールでパスワードを再設定する機能）は、メール送信の設定をしていないので外している
  devise :database_authenticatable, :registerable,
         :rememberable, :validatable
  has_many :es_drafts, dependent: :destroy
end