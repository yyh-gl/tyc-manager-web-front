class TransactionsController < ApplicationController

  def index
    @uids = User.all.map { |user| user[:uid] }
    if current_user
      @username = current_user.name
    else
      @username = 'hoge'
    end
  end

  def create
    ActiveRecord::Base.transaction do
      # 送信主の取引履歴を追加
      new_from_transaction = Transaction.new(uid: current_user[:uid], tyc: -params[:tyc].to_i, reason: params[:reason])
      # 送信先の取引履歴を追加
      new_to_transaction = Transaction.new(transaction_params)

      if new_from_transaction.save && new_to_transaction.save
        session[:notice] = 'TYC譲渡が完了しました'
        redirect_to action: :index
      else
        session[:alert] = 'TYC譲渡に失敗しました'
        redirect_to action: :index
      end
    end
  end

  # deviseのコントローラいじるのがめんどかったのでtransactionsコントローラにパスワード忘れたときようの処理を追加
  def forget
  end

  private

  def transaction_params
    params.permit(:uid, :tyc, :reason)
  end

end
