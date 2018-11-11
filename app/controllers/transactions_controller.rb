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
end
