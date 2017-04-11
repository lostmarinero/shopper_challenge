class Applicant < ActiveRecord::Base
  PHONE_TYPES = ['iPhone 6/6 Plus', 'iPhone 6s/6s Plus', 'iPhone 5/5S', 'iPhone 4/4S', 'iPhone 3G/3GS', 'Android 4.0+ (less than 2 years old)', 'Android 2.2/2.3 (over 2 years old)', 'Windows Phone', 'Blackberry', 'Other']
  REGIONS = ['San Francisco Bay Area', 'Chicago', 'Boston', 'NYC', 'Toronto', 'Berlin', 'Delhi']
  WORKFLOW_STATES = ['applied', 'quiz_started', 'quiz_completed', 'onboarding_requested', 'onboarding_completed', 'hired', 'rejected']

  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :email, presence: true, uniqueness: true,
                    format: {
                      with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/,
                      message: 'invalid format. please ensure the email' \
                               ' address includes an @'
                    }
  validates :phone, presence: true, uniqueness: true,
                    format: {
                      with: /\d{3}-\d{3}-\d{4}/,
                      message: 'invalid format. please ensure the telephone' \
                               ' number is formated as 555-555-5555'
                    }
  validates :phone_type, presence: true
  validates :workflow_state, presence: true
  validates :region, presence: true

  def self.count_by_workflow_state(start_date, end_date, workflow_state)
    self.where(created_at: start_date..(end_date + 1),
               workflow_state: workflow_state).count
  end

  def self.get_week_data(start_date, end_date)
    return_hash = {}
    [
      'applied', 'quiz_started', 'quiz_completed', 'onboarding_requested',
      'onboarding_completed', 'hired', 'rejected'
    ].each do |workflow_state|
      return_hash[workflow_state] =
        self.count_by_workflow_state(start_date, end_date, workflow_state)
    end
    return_hash
  end
end
