class TransactionsController < ApplicationController

  def index
    if current_user
      @username = current_user.name
    else
      @username = 'hoge'
    end
  end

  def create
    new_transaction = Transaction.new(transaction_params)
    new_transaction.save
  end

  # deviseのコントローラいじるのがめんどかったのでtransactionsコントローラにパスワード忘れたときようの処理を追加
  def forget
  end

  private

  def transaction_params
    params.permit(:uid, :tyc, :reason)
  end

end
