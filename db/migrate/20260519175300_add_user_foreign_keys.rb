class AddUserForeignKeys < ActiveRecord::Migration[8.1]
  def change
    add_foreign_key :oauth_applications,  :users, column: :created_by_id
    add_foreign_key :oauth_applications,  :users, column: :discarded_by_id
    add_foreign_key :oauth_access_tokens, :users, column: :resource_owner_id
    add_foreign_key :users,               :users, column: :discarded_by_id
  end
end
