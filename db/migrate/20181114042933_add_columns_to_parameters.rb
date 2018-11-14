class AddColumnsToParameters < ActiveRecord::Migration[5.2]
  def change
    add_column :parameters, :uid, :text, :null => false
    add_column :parameters, :tyc, :integer, default: 0
    add_column :parameters, :reason, :text, :null => false
    add_column :parameters, :password, :text, :null => false
  end
end
