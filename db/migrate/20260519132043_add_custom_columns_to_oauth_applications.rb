class AddCustomColumnsToOauthApplications < ActiveRecord::Migration[8.1]
  def change
    add_column :oauth_applications, :owner_type,      :string
    add_column :oauth_applications, :owner_id,        :bigint
    add_column :oauth_applications, :created_by_id,   :bigint
    add_column :oauth_applications, :calls_count,     :integer,  default: 0, null: false
    add_column :oauth_applications, :last_used_at,    :datetime
    add_column :oauth_applications, :discarded_at,    :datetime
    add_column :oauth_applications, :discarded_by_id, :bigint

    add_index :oauth_applications, [ :owner_type, :owner_id ], unique: true
    add_index :oauth_applications, :created_by_id
    add_index :oauth_applications, :discarded_at
    add_index :oauth_applications, :discarded_by_id

    # FK constraints to `users` are deferred to ticket 09 (User model migration).
    # add_foreign_key :oauth_applications, :users, column: :created_by_id
    # add_foreign_key :oauth_applications, :users, column: :discarded_by_id
  end
end
