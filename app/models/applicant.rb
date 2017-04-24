class Applicant < ActiveRecord::Base
  before_validation :format_phone

  PHONE_TYPES = ['iPhone 6/6 Plus', 'iPhone 6s/6s Plus', 'iPhone 5/5S', 'iPhone 4/4S', 'iPhone 3G/3GS', 'Android 4.0+ (less than 2 years old)', 'Android 2.2/2.3 (over 2 years old)', 'Windows Phone', 'Blackberry', 'Other']
  REGIONS = ['San Francisco Bay Area', 'Chicago', 'Boston', 'NYC', 'Toronto', 'Berlin', 'Delhi']
  WORKFLOW_STATES = ['applied', 'quiz_started', 'quiz_completed', 'onboarding_requested', 'onboarding_completed', 'hired', 'rejected']

  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :email, presence: true, uniqueness: true,
                    format: {
                      with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/,
                      message: 'invalid format. please ensure the ' \
                               'email address includes an @'
                    }
  validates :phone, presence: true, uniqueness: true,
                    format: {
                      with:
                        /\A\d?\-?\(?\d{3}(\-|\.|\))\s?\d{3}(\-|\.)?\d{4}(\s?x\d{3,4})?\z/,
                      message: 'invalid format. please ensure the ' \
                               'telephone number is formated as 555-555-5555'
                    }
  validates :phone_type, presence: true
  validates :workflow_state, presence: true
  validates :region, presence: true

  def format_phone
    phone = self.phone
    unless phone.include?('x')
      phone = self.phone.gsub(/[^\d]/, '')
      self.phone = if phone.length > 6 && phone.length <= 10
                     phone.insert(3, '-').insert(7, '-')
                   elsif phone.length >= 11
                     phone.insert(1, '-').insert(5, '-').insert(9, '-')
                   else
                     phone
                   end
    end
  end

  def self.workflow_states_by_week(start_date, end_date)
    response = workflow_state_counts_by_dates(start_date, end_date)
    reorder_workflow_state_counts(response, start_date, end_date)
  end

  def self.workflow_state_counts_by_dates(start_date, end_date)
    query = <<-SQL
      SELECT
        SUM(CASE WHEN workflow_state='applied' THEN 1 ELSE 0 END)
          as applied,
        SUM(CASE WHEN workflow_state='quiz_started' THEN 1 ELSE 0 END)
          as quiz_started,
        SUM(CASE WHEN workflow_state='quiz_completed' THEN 1 ELSE 0 END)
          as quiz_completed,
        SUM(CASE WHEN workflow_state='onboarding_requested' THEN 1 ELSE 0 END)
          as onboarding_requested,
        SUM(CASE WHEN workflow_state='onboarding_completed' THEN 1 ELSE 0 END)
          as onboarding_completed,
        SUM(CASE WHEN workflow_state='hired' THEN 1 ELSE 0 END)
          as hired,
        SUM(CASE WHEN workflow_state='rejected' THEN 1 ELSE 0 END)
          as rejected,
        date(SUBSTR(created_at,1,10), '-6 days', 'weekday 1') as monday_date,
        date(SUBSTR(created_at,1,10), 'weekday 0') as sunday_date,
        strftime('%W',substr(created_at,1,10)) as week
    FROM applicants
    WHERE (applicants.created_at BETWEEN ? AND date(?, '+1 days'))
    GROUP BY week
    ORDER BY date(monday_date)
  SQL
    query = self.sanitize_sql_array([query, start_date, end_date])
    self.connection.execute(query)
  end

  def self.reorder_workflow_state_counts(sql_response,
                                         start_date_string,
                                         end_date_string)
    response_hash = {}
    last_index = sql_response.length - 1
    return response_hash if last_index == -1

    start_date = Date.parse(start_date_string)
    end_date   = Date.parse(end_date_string)

    sql_response.each.with_index do |week_data, index|
      week_hash = {}
      key_start_date = if index.zero? &&
                          Date.parse(week_data['monday_date']) < start_date &&
                          start_date < Date.parse(week_data['sunday_date'])
                         start_date_string
                       else
                         week_data['monday_date']
                       end
      key_end_date = if index == last_index &&
                        Date.parse(week_data['monday_date']) < end_date &&
                        end_date < Date.parse(week_data['sunday_date'])
                       end_date_string
                     else
                       week_data['sunday_date']
                     end

      week_key = key_start_date + '-' + key_end_date

      ['applied', 'quiz_started', 'quiz_completed', 'onboarding_requested',
       'onboarding_completed', 'hired', 'rejected'].each do |value_key|
        week_hash[value_key] = week_data[value_key]
      end
      response_hash[week_key] = week_hash
    end
    response_hash
  end
end
