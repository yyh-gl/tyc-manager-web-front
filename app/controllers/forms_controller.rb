class FormsController < ApplicationController

  def index
    @form = Form.new
    @form.parameters.build if @form.parameters.none?
    @target_uids = User.all.map { |user| user[:uid] }
    if current_user
      @username = current_user.name
    else
      @username = 'hoge'
    end
  end

  def create
    puts '----------'
    puts '----------'
    puts '----------'
  end

  # deviseのコントローラいじるのがめんどかったのでtransactionsコントローラにパスワード忘れたときようの処理を追加
  def forget
  end

  def form_params
    params.require(:form).permit(
      parameters_attributes: [:id, :form_id, :uid, :tyc, :reason, :password, :_destroy]
    )
  end

end
