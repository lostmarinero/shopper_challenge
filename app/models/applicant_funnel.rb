class ApplicantFunnel
  attr_reader :start_date, :end_date

  def initialize(args)
    @start_date = convert_to_date(args.fetch(:start_date, ''))
    @end_date   = convert_to_date(args.fetch(:end_date, ''))

    @start_date = default_date(@start_date, @end_date, '-')
    @end_date   = default_date(@end_date, @start_date, '+')
  end

  def valid?
    return false if !@start_date.is_a?(Date) || !@end_date.is_a?(Date)
    @start_date <= @end_date
  end

  def data_counts_by_week
    Applicant.workflow_states_by_week(@start_date.to_s,
                                      @end_date.to_s)
  end

  private

  def convert_to_date(string_date)
    return string_date if string_date.is_a?(Date)
    begin
      Date.parse(string_date)
    rescue ArgumentError
      string_date
    end
  end

  def default_date(target_date, other_date, operator)
    return target_date if target_date.is_a? Date
    return_date = if other_date.is_a? Date
                    other_date.send(operator, 4.weeks)
                  else
                    Date.today.send(operator, 4.weeks)
                  end
    [Date.today, return_date].min
  end
end
