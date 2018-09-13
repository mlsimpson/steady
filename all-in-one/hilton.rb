#!/usr/bin/env ruby

require 'awesome_print'
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

  def datepicker(calendar)
    # Get all calendar buttons
    calendars = find_all('button[class="ui-datepicker-trigger btn-reset hide-text"]')
    if calendar == 'arrival'
      month = Date.today.month - 1
      day = Date.today.day + 1
      index = 0
    elsif calendar == 'departure'
      # Kind of nasty, but necessary to parse correct month/day
      month = Date.parse((Date.today + 8).to_s).month - 1
      day = Date.parse((Date.today + 8).to_s).day
      index = 1
    else
      puts "Invalid calendar"
    end
    calendars[index].click
    expect(page).to have_css('#ui-datepicker-div', visible: true)
    rows = find_all("td[data-month=\"#{month}\"]")
    ids = rows.map{ |row| row['id'] }
    idmatch = ids.select{ |i| i =~ /.*-#{day}$/ }.join

    find("td[id=\"#{idmatch}\"]").click
    save_screenshot("./4-#{index}-calendar.png")
  end
end

include RSpec::Matchers
include DSL

#def start_webdriver
#	useragent = 'Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:62.0) Gecko/20100101 Firefox/62.0'
#	Capybara.register_driver :custom do |app|
#		require 'selenium-webdriver'
#		profile = Selenium::WebDriver::Firefox::Profile.new
#		#profile["network.proxy.type"] = 1
#		#profile["network.proxy.http"] = "localhost"
#		#profile["network.proxy.http_port"] = 3128
#		profile['general.useragent.override'] = useragent
#		Capybara::Selenium::Driver.new(app, {:browser => :firefox, :profile =>  profile})
#	end
#	#Capybara.register_driver :chrome do |app|
#	#	Capybara::Selenium::Driver.new(app, browser: :chrome)
#	#end
#
#	Capybara.run_server = false
#	Capybara.default_driver = :custom
#	Capybara.current_driver = :custom
#	Capybara.javascript_driver = :custom
#	Capybara.app_host = 'http://hiltonhonors3.hilton.com'
#	Capybara::Session.new :custom
#	page = Capybara.page
#	return page
#end

Capybara.current_driver = :selenium
Capybara.run_server = false
Capybara.app_host = 'http://hiltonhonors3.hilton.com'
page = Capybara.page

#page = start_webdriver

visit '/en/index.html'
#visit 'http://hiltonhonors3.hilton.com/en_US/hh/search/findhotels/index.htm'
#sleep 6000
puts 'Waiting for all AJAX requests to complete'
wait_for_ajax

puts "Arbitrarily choosing Paris"
fill_in('hotelSearchOneBox', :with => 'Paris')

# Wait for dropdown to load
expect(page).to have_css('ul[class="jq-ui-autocomplete"]')
save_screenshot('./1-Paris_dropdown.png')

#firstlocation = page.find('ul[class="jq-ui-autocomplete"]').find('li[id="location0"]').text
firstlocation = find('ul[class="jq-ui-autocomplete"]').find('li[id="location0"]').text

find('ul.jq-ui-autocomplete').should have_content(firstlocation)
puts "Specific location: #{firstlocation}"

find('input[id="hotelSearchOneBox"]').click

fill_in('hotelSearchOneBox', :with => firstlocation)
save_screenshot('./2-Paris_completion.png')

# Future-proof dates instead of hardcoding
# Set departure date to tomorrow and arrival date 7 days from tomorrow

# Method 1 (the easy way): Enter text in Arrival & Departure inputs
tomorrow = (Date.today + 1).strftime('%d %b %Y')
nextweek = (Date.today + 8).strftime('%d %b %Y')

fill_in('checkin', :with => tomorrow)
fill_in('checkout', :with => nextweek)

save_screenshot('./3-easy-calendar.png')

# Method 2 (the hard way): Click on dates in calendar widgets
# Months on the Hilton calendar widget are 0-indexed

datepicker('arrival')
datepicker('departure')

find('a[title="Find it"]').click
sleep 10
