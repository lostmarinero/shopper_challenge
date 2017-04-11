class AddApplicantCreatedAtIndex < ActiveRecord::Migration
  def change
    add_index :applicants, :created_at
  end
end
