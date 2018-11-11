class TransactionsController < ApplicationController
  def index
    if current_user
      @username = current_user.name
    else
      @username = 'hoge'
    end

  end

  def show
  end

  def create
  end

  # deviseのコントローラいじるのがめんどかったのでtransactionsコントローラにパスワード忘れたときようの処理を追加
  def forget
  end
end
