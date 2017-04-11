require 'rails_helper'

feature 'Welcome page' do
  scenario 'the applicant clicks on apply now' do
    visit root_path
    click_link 'Shopper Apply Now'

    expect(page).to have_content 'Apply now to join our team!'
  end
  scenario 'the instacart employee clicks on funnel analytics' do
    visit root_path
    click_link 'Go To Funnel Analytics'

    expect(page.find_by_id('funnel-chart')).to have_content ''
  end
end
