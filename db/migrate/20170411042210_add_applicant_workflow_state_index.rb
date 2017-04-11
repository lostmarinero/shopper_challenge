class AddApplicantWorkflowStateIndex < ActiveRecord::Migration
  def change
    add_index :applicants, :workflow_state
  end
end
