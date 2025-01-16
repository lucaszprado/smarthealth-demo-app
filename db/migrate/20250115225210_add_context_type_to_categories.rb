class AddContextTypeToCategories < ActiveRecord::Migration[7.1]

  # This migration involves both schema and data changes
  # When rollback is (down) done no action action is required regarding the data
  def up
    add_column :categories, :context_type, :string
    Category.update_all(context_type: 'vendor_ornament')
  end

  def down
    remove_column :categories, :context_type
  end

end
