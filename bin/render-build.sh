#!/usr/bin/env bash
# Render が公開のたび（デプロイのたび）に動かす準備の手順
# エラーが出たら、そこで止める
set -o errexit

# 使う部品（gem）を入れる
bundle install

# CSS などを本番用にまとめる
bin/rails assets:precompile
bin/rails assets:clean

# データベースの準備（無料プランは pre-deploy が使えないので、ここでやる）
# db:prepare … 初めてなら表を作る、2回目からは新しいマイグレーションだけ流す
bin/rails db:prepare
# db:seed … 企業データ・地方・勤務地を入れる（何回やっても同じ結果になる作り）
bin/rails db:seed