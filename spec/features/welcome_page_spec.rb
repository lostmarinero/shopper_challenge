require 'rails_helper'

feature 'Welcome page' do
  scenario 'the applicant clicks on apply now' do
    visit root_path
    expect(page).to have_content 'Apply now to join our team!'
  end
end
