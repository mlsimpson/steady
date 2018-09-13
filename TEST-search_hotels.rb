#!/usr/bin/env ruby

require 'awesome_print'
require 'date'
require 'rspec'
require 'capybara'
require 'capybara/dsl'
require_relative 'dsl.rb'

include RSpec::Matchers
include DSL

Capybara.current_driver = :selenium
Capybara.run_server = false
Capybara.app_host = 'http://hiltonhonors3.hilton.com'
page = Capybara.page

puts 'TEST START: Validating hotel search, with a 7 day stay'
visit '/en/index.html'

puts 'Waiting for all AJAX requests to complete'
wait_for_ajax

puts "Arbitrarily choosing Paris"
fill_in('hotelSearchOneBox', :with => 'Paris')

# Wait for dropdown to load
expect(page).to have_css('ul[class="jq-ui-autocomplete"]')
save_screenshot('./search-hotels_Paris_dropdown.png')

#firstlocation = page.find('ul[class="jq-ui-autocomplete"]').find('li[id="location0"]').text
firstlocation = find('ul[class="jq-ui-autocomplete"]').find('li[id="location0"]').text

find('ul.jq-ui-autocomplete').should have_content(firstlocation)
puts "Specific location: #{firstlocation}"

find('input[id="hotelSearchOneBox"]').click

fill_in('hotelSearchOneBox', :with => firstlocation)
save_screenshot('./search-hotels_Paris_completion.png')

# Future-proof dates instead of hardcoding
# Set departure date to tomorrow and arrival date 7 days from tomorrow

# Method 1 (the easy way): Enter text in Arrival & Departure inputs
tomorrow = (Date.today + 1).strftime('%d %b %Y')
nextweek = (Date.today + 8).strftime('%d %b %Y')

fill_in('checkin', :with => tomorrow)
fill_in('checkout', :with => nextweek)

save_screenshot('./search-hotels_easy-calendar.png')

# Method 2 (the hard way): Click on dates in calendar widgets
# Months on the Hilton calendar widget are 0-indexed

datepicker('arrival')
datepicker('departure')

puts 'Finding hotels'
find('a[title="Find it"]').click

puts 'Validating search results page'
expect(page).to have_content('matching hotels')
expect(page).to have_css('a[data-quicklookdefaultimagepath]')
expect(page).to have_css('a[id$="hotelName"]')

save_screenshot('./search-hotels_success.png')

puts 'PASS'
