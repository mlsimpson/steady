#!/usr/bin/env ruby

require 'date'
require 'rspec'
require 'capybara'
require 'capybara/dsl'

module DSL
  # Suppress global scope warning for Capybara::DSL
  include Capybara::DSL

  # Since the Hilton site is using jQuery, the following is useful:
  # https://robots.thoughtbot.com/automatically-wait-for-ajax-with-capybara
  def wait_for_ajax
    Timeout.timeout(Capybara.default_max_wait_time) do
      loop until finished_all_ajax_requests?
    end
  end

  def finished_all_ajax_requests?
    page.evaluate_script('jQuery.active').zero?
  end
end

include RSpec::Matchers
include DSL

Capybara.current_driver = :selenium
Capybara.run_server = false
Capybara.app_host = 'http://hiltonhonors3.hilton.com'
page = Capybara.page

visit '/en/index.html'
puts 'Waiting for all AJAX requests to complete'
wait_for_ajax

fill_in('hotelSearchOneBox', :with => 'Paris')

# Wait for dropdown to load
expect(page).to have_css('ul[class="jq-ui-autocomplete"]')
save_screenshot('./1-Paris_dropdown.png')

firstlocation = page.find('ul[class="jq-ui-autocomplete"]').find('li[id="location0"]').text

find('ul.jq-ui-autocomplete').should have_content(firstlocation)
puts "First location: #{firstlocation}"

fill_in('hotelSearchOneBox', :with => firstlocation)
save_screenshot('./2-Paris_completion.png')

click_button('Open calendar', match: :first)

# Method 1: Enter text in Arrival & Departure inputs
# Future-proof dates instead of hardcoding
tomorrow = (Date.today + 1).strftime('%d %b %Y')
nextweek = (Date.today + 8).strftime('%d %b %Y')

fill_in('checkin', :with => tomorrow)
fill_in('checkout', :with => nextweek)
save_screenshot('./3-Arrival_Departure.png')

#expect(page).to have_css('ui-datepicker-div', visible: false)
