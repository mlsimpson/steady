module DSL
  # Suppress global scope warning for Capybara::DSL
  include Capybara::DSL

  MINOFFERS = 5

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
    save_screenshot("./#{index}-calendar.png")
  end

	## TODO: fix me!
	## https://stackoverflow.com/questions/7612038/with-capybara-how-do-i-switch-to-the-new-window-for-links-with-blank-targets
	#def apr(cardoffers)
	#       puts cardoffers.size
	#       (cardoffers.size).times do |i|
	#               root_window = current_window
	#               new_window = window_opened_by { cardoffers[i].click_link('*Rates and Fees') }
	#               within_window new_window do
	#                       expect(page).to have_content('Annual Percentage Rate (APR) for Purchases')
	#               end
	#               new_window.close
	#               switch_to_window root_window
	#       end
	#       return true
	#end
end

