# steady
**SDET challenge for Steady**

## Requirements
Firefox
Ruby 2.5
bundler gem:
- `gem install bundler`
Mozilla geckodriver:
- https://github.com/mozilla/geckodriver/releases
- *Must be in $PATH*

## Setup
1. Run `bundle install --deployment`

## Known Issues
Tests do not pass with phantomjs/poltergeist ("Find a Hotel" dropdown doesn't appear)

## Future
- Select location via autocomplete dropdown rather than filling in text
- Overload `find_all` with a Boolean yield condition with regard to date picker