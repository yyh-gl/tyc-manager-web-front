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
    @target_uids.delete(current_user[:uid])

    @possession_tyc = Transaction.where(uid: current_user[:uid]).sum(:tyc)
  end

  def create
    possession_tyc = Transaction.where(uid: current_user[:uid]).sum(:tyc)

    ActiveRecord::Base.transaction do
      params[:form][:parameters_attributes].each do |parameter|
        next if parameter[1][:_destroy].present?

        tyc = parameter[1][:tyc].to_i
        raise("取引額には 1 〜 #{possession_tyc} の間の数値を入力してください。") unless tyc.positive? && tyc <= possession_tyc

        # 送信主の取引履歴を追加
        new_from_transaction = Transaction.new(uid: current_user[:uid],
                                               tyc: -tyc,
                                               reason: parameter[1][:reason])
        new_from_transaction.save!

        # 送信先の取引履歴を追加
        new_to_transaction = Transaction.new(uid: parameter[1][:uid],
                                             tyc: tyc,
                                             reason: parameter[1][:reason])
        new_to_transaction.save!
      end
    end

    # 取引ログをCSVに出力
    params[:form][:parameters_attributes].each do |parameter|
      next if parameter[1][:_destroy].present?

      unless Rails.env == 'development'
        # Development環境以外ではSlackで通知する（取引内容）
        # TransactionMailer.notice(request.headers[:uid], request.headers[:target], tyc).deliver_later
        send_slack_message(parameter[1][:uid], parameter[1][:tyc], parameter[1][:reason]) if ENV['NOTIFICATION'] == 'on'
      end

      make_transaction_backup(current_user[:uid],
                              parameter[1][:uid],
                              parameter[1][:tyc].to_i,
                              parameter[1][:reason])
    end

    unless Rails.env == 'development'
      # Development環境以外ではSlackで通知する（総流通量）
      check_tyc_distribution_amount
    end

    session[:success_message] = '取引が正常に完了しました。'
    redirect_to action: :index

  rescue => error
    puts '----------------'
    puts error
    puts '----------------'

    session[:error] = '取引が完了しませんでした。以下のエラーログを参考に入力項目を修正してください。'
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

  # TODO: メッセージ部分を分離したい
  def send_slack_message(target_uid, tyc, reason)
    if current_user[:uid] == ENV['PROF_MIKI']
      from = '三木先生'
    elsif current_user[:uid] == ENV['LADY_MASAKI']
      from = '正木さん'
    else
      from = User.find_by_email(current_user[:uid]).name
    end

    if target_uid == ENV['PROF_MIKI']
      to = '三木先生'
    elsif target_uid == ENV['LADY_MASAKI']
      to = '正木さん'
    else
      to = User.find_by_email(target_uid).name
    end

    message = <<"MESSAGE"
研究室の皆様

TYC管理秘書のF.R.I.D.A.Yです。

下記のTYC取引が行われたことをお知らせ致します。

-----
[取引内容]
送り主： #{from}
送り先： #{to}
金額　： #{tyc} TYC
理由　： #{reason}
-----

以上です。
MESSAGE
    slack_notifier = Slack::Notifier.new(ENV['SLACK_WEBHOOK_URL'])
    slack_notifier.ping(message)
  end

  # 取引が行われるたびに取引および取引後の"全員分"の残TYCをCSVに出力
  # -> CSVファイル： /log/transaction_log.csv
  def make_transaction_backup(from, to, tyc, reason)
    transactions = [Time.now]
    transactions << Transaction.group(:uid).sum(:tyc).sort_by { |a| a[1] }.reverse
    CSV.open(TRANSACTION_LOG_PATH, 'a', encoding: 'Shift_JIS:UTF-8') do |file|
      file << transactions.flatten
      file << ['', 'FROM', from, 'TO', to, 'TYC', tyc, 'REASON', reason]
    end
  end

  # 取引が行われるたびに取引および流通量に変動がないか確認
  def check_tyc_distribution_amount
    if Transaction.sum(:tyc) != TYC_DISTRIBUTION_AMOUNT
      message = <<"MESSAGE"
研究室の皆様

TYC管理秘書のF.R.I.D.A.Yです。

TYCの流通量に変動があったことをお知らせ致します。

以上です。
MESSAGE
      slack_notifier = Slack::Notifier.new(ENV['SLACK_WEBHOOK_URL'])
      slack_notifier.ping(message)
    end
  end

end
