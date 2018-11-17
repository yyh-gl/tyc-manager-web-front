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

    render template: 'forms/hoge'
  end

  def create
    ActiveRecord::Base.transaction do
      params[:form][:parameters_attributes].each do |parameter|
        next if parameter[1][:_destroy].present?

        # 送信主の取引履歴を追加
        new_from_transaction = Transaction.new(uid: current_user[:uid],
                                               tyc: -parameter[1][:tyc].to_i,
                                               reason: parameter[1][:reason])
        new_from_transaction.save!

        # 送信先の取引履歴を追加
        new_to_transaction = Transaction.new(uid: parameter[1][:uid],
                                             tyc: parameter[1][:tyc].to_i,
                                             reason: parameter[1][:reason])
        new_to_transaction.save!
      end
    end

    session[:notice] = '取引が正常に完了しました。'
    redirect_to action: :index

  rescue => error
    puts '----------------'
    puts error
    puts '----------------'

    session[:error] = '取引が完了しませんでした。以下のエラーを参考に入力項目を修正してください。'
    session[:error_detail] = error
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
