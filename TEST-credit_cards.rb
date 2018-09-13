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

puts 'TEST START: Validate credit cards and APRs'
visit '/en/index.html'

puts 'Waiting for all AJAX requests to complete'
wait_for_ajax

puts 'Validating Points page'
click_link('Points')
expect(page).to have_content('EARN & USE POINTS')
save_screenshot('./credit-cards_points.png')

puts 'Validating at least 5 credit card offers'
click_link('Credit Cards', match: :first)
offers = find_all('div[class="accordion_element"]')
expect(offers.size).to be >= DSL::MINOFFERS
save_screenshot('./credit-cards_offers.png')

puts 'Validate APR page'
new_window = window_opened_by { click_link('Rates and Fees', match: :first) }
within_window new_window do
	expect(page).to have_content('APR for')
  save_screenshot('./credit-cards_apr.png')
end

puts 'PASS'
