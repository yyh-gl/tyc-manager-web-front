class FormsController < ApplicationController

  def index
    if current_user
      @username = current_user.name
    else
      @username = 'ゲスト'
    end

    @form = Form.new
    @form.parameters.build

    @target_uids = User.all.map { |user| user[:uid] }
  end

  def create
    session[:notice] = params[:form][:parameters_attributes]
    @transactions = params[:form][:parameters_attributes]
    params[:form][:parameters_attributes].each do |parameters|
      puts '----------'
      pp parameters
    end
    puts '----------'

    redirect_to action: :index
  end

  # deviseのコントローラいじるのがめんどかったのでtransactionsコントローラにパスワード忘れたときようの処理を追加
  def forget
  end

  private

  def form_params
    params.require(:form).permit(
      parameters_attributes: [:id, :form_id, :uid, :tyc, :reason, :password, :_destroy]
    )
  end

end
