class ApplicationController < ActionController::Base

  # サインイン後のリダイレクトループ解消用
  def after_sign_in_path_for(resource)
    '/transactions'
  end

end
