require 'rails_helper'

feature 'New applicant applies' do
  def valid_sign_up_credentials
    fill_in 'First name', with: 'Roger'
    fill_in 'Last name', with: 'Rabbit'
    fill_in 'Email', with: 'rrabbit@example.com'
    fill_in 'Phone', with: '555-555-5555'
    page.select('iPhone 6/6 Plus', from: 'Phone type')
    page.select('San Francisco Bay Area', from: 'Region')
  end

  scenario 'with valid input it renders background check confirmation' do
    visit new_applicant_path

    fill_in 'First name', with: 'Roger'
    fill_in 'Last name', with: 'Rabbit'
    fill_in 'Email', with: 'rrabbit@example.com'
    fill_in 'Phone', with: '555-555-5555'
    page.select('iPhone 6/6 Plus', from: 'Phone type')
    page.select('San Francisco Bay Area', from: 'Region')
    click_button 'Continue'

    expect(page).to have_content 'Please confirm a background check'
    expect(Applicant.first.first_name).to eq('Roger')
  end

  scenario 'with valid background-check confirm it renders congratulations' do
    visit new_applicant_path

    fill_in 'First name', with: 'Roger'
    fill_in 'Last name', with: 'Rabbit'
    fill_in 'Email', with: 'rrabbit@example.com'
    fill_in 'Phone', with: '555-555-5555'
    # fill_in 'Region', with:
    click_button 'Continue'

    check 'Background checkbox'
    click_button 'Continue'

    expect(page).to have_content 'Congratulations!'
  end

  scenario 'with invalid first_name input' do
    visit new_applicant_path

    fill_in 'First name', with: ''
    fill_in 'Last name', with: 'Rabbit'
    fill_in 'Email', with: 'rrabbit@example.com'
    fill_in 'Phone', with: '555-555-5555'
    page.select('iPhone 6/6 Plus', from: 'Phone type')
    page.select('San Francisco Bay Area', from: 'Region')
    click_button 'Continue'

    help_block = page.find('.applicant_first_name').find('.help-block')
    expect(help_block).to have_content 'can\'t be blank'
  end
  scenario 'with invalid email format' do
    visit new_applicant_path
    valid_sign_up_credentials

    fill_in 'Email', with: 'example.com'
    click_button 'Continue'

    help_block = page.find('.applicant_email').find('.help-block')
    expect(help_block).to have_content (
      'invalid format. please ensure the email address includes an @'
    )
  end
  scenario 'with invalid phone format' do
    visit new_applicant_path
    valid_sign_up_credentials

    fill_in 'Phone', with: '555555555555'
    click_button 'Continue'
    help_block = page.find('.applicant_phone').find('.help-block')
    expect(help_block).to have_content(
      'invalid format. please ensure the telephone number is formated' \
      ' as 555-555-5555'
    )
  end
end
