class ApplicationController < ActionController::Base

  # TYC総流通量
  TYC_DISTRIBUTION_AMOUNT = 5_000_000

  # ホワイトリスト
  PROFESSOR = ENV['PROFESSOR'][1..-2].split(', ')
  STUDENT = ENV['M2'][1..-2].split(', ') + ENV['M1'][1..-2].split(', ') + ENV['U4'][1..-2].split(', ')
  LAB_MEMBER = (PROFESSOR + STUDENT).freeze

  # 取引データのログ
  TRANSACTION_LOG_PATH = ENV['TRANSACTION_LOG']

  # ユーザ登録時のemailに使用可能な文字
  VALID_ADDRESS = %r{\A[a-zA-Z0-9_\#!$%&`'*+\-{|}~^\/=?\.]+@[a-zA-Z0-9][a-zA-Z0-9\.-]+\z}
  # ユーザ登録時のパスワードに使用可能な文字
  VALID_PASSWORD = %r{\A[a-zA-Z\d]+\z}

  # サインイン後のリダイレクトループ解消用
  def after_sign_in_path_for(resource)
    '/forms'
  end

end
