class CreateNote < ActiveRecord::Migration
  def change
    create_table :notes do |t|
      t.column :content, :string, :limit => 200
      t.column :completed, :integer, :default => 0
      t.timestamps
    end
  end
end
