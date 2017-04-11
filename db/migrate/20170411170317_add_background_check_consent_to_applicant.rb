class AddBackgroundCheckConsentToApplicant < ActiveRecord::Migration
  def change
    add_column :applicants, :background_check_consent, :boolean, default: false
  end
end
