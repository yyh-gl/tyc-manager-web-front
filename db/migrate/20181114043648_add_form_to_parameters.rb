class AddFormToParameters < ActiveRecord::Migration[5.2]
  def change
    add_column :parameters, :form_id, :integer, :null => false
  end
end
