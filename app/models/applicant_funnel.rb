class ApplicantFunnel
  attr_reader :start_date, :end_date

  def initialize(args)
    @start_date = convert_to_date(args.fetch(:start_date, ''))
    @end_date   = convert_to_date(args.fetch(:end_date, ''))

    @start_date = default_date(@start_date, @end_date, '-')
    @end_date   = default_date(@end_date, @start_date, '+')

    @all_weeks  = valid? ? break_into_weeks(@start_date, @end_date) : []
  end

  def valid?
    return false if !@start_date.is_a?(Date) || !@end_date.is_a?(Date)
    @start_date <= @end_date
  end

  def data_counts_by_week
    return_hash = {}
    @all_weeks.each do |week_array|
      start_date = week_array[0]
      end_date = week_array[1]
      data_count = Applicant.get_week_data(start_date, end_date)
      unless data_count.values.reduce(:+).zero?
        return_hash[dates_to_key(start_date, end_date)] =
          data_count
      end
    end
    return_hash
  end

  private

  def break_into_weeks(start_date, end_date)
    all_mondays = (start_date..end_date).select(&:monday?)
    return [[start_date, end_date]] if all_mondays == []
    return_elements = []
    all_mondays.each.with_index do |monday, index|
      if index.zero? && start_date != monday
        return_elements.unshift([start_date, (monday - 1)])
      end
      return_elements << if (monday + 6) < end_date
                           [monday, (monday + 6)]
                         else
                           [monday, end_date]
                         end
    end
    return_elements
  end

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

  def dates_to_key(start_date, end_date)
    "#{start_date}-#{end_date}"
  end
end
