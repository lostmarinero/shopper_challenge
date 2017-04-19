# app/helpers/applicants_helper.rb
module ApplicantsHelper
  def why_join_reasons
    [
      { icon: 'glyphicon glyphicon-time',
        title: 'Be Independent',
        content: 'Schedule work around your own life.' },
      { icon: 'glyphicon glyphicon-road',
        title: 'No Driving Required!',
        content: 'We have many positions available, no car needed!' },
      { icon: 'glyphicon glyphicon-headphones',
        title: 'Be Cool Without Saying It',
        content: 'Work for a company that doesn\'t call you a Ninja - Those
        other companies try too hard!' },
      { icon: 'glyphicon glyphicon-tint',
        title: 'Conserve Water',
        content: 'This has nothing to do with this job,
        but its good practice. We just got out of a drought!' },
      { icon: 'glyphicon glyphicon-signal',
        title: 'Earn extra income',
        content: 'Get paid weekly. Work Sundays to maximize your hours
        and pay.' }
    ]
  end

  def role_descriptions_array
    [
      {
        title: 'Shopper',
        car_required: false,
        designation: 'Part-time Employee',
        description: 'Shop for grocery orders in local stores.',
        responsibilities: ['Shopping only', 'No vehicle required',
                           'Flexible schedule', 'Work up to 29 hrs/wk']
      },
      {
        title: 'Cashier',
        car_required: false,
        designation: 'Part-Time Employee',
        description: 'Work the cash register to check out orders',
        responsibilities: ['Check-out only', 'No vehicle required',
                           'Flexible schedule', 'Work up to 29 hrs/wk']
      },
      {
        title: 'Driver',
        car_required: true,
        designation: 'Independent Contractor',
        description: 'Deliver groceries from local stores to customers.',
        responsibilities: ['Delivery only', 'Vehicle required',
                           'Flexible schedule', 'Work unlimited hours']
      },
      {
        title: 'Driver + Shopper',
        car_required: true,
        designation: 'Independent Contractor',
        description: 'Shop for groceries and deliver them to customers',
        responsibilities: ['Delivery and shopping', 'Vehicle required',
                           'Flexible schedule', 'Work unlimited hours']
      }
    ]
  end
end
