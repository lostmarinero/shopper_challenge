module FunnelHelper
  def convert_form_params_to_date(form_args)
    start_date_year = form_args[:'start_date(1i)']
    start_date_month = format('%02d', form_args[:'start_date(2i)'])
    start_date_day = form_args[:'start_date(3i)']
    end_date_year = form_args[:'end_date(1i)']
    end_date_month = format('%02d', form_args[:'end_date(2i)'])
    end_date_day = form_args[:'end_date(3i)']
    {
      start_date: "#{start_date_year}-#{start_date_month}-#{start_date_day}",
      end_date: "#{end_date_year}-#{end_date_month}-#{end_date_day}"
    }
  end
end
