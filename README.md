# steady
**SDET challenge for Steady**

## Requirements
Linux

Firefox

Ruby 2.5

bundler gem:
- `gem install bundler`

Mozilla geckodriver:
- https://github.com/mozilla/geckodriver/releases
- *Must be in $PATH*

## Setup
1. Run `bundle install --deployment`
2. Run `run_tests.sh`

## Known Issues
Tests do not pass with phantomjs/poltergeist ("Find a Hotel" dropdown doesn't appear)

## Motivation
Per the SDET challenge, it makes sense to separate both requests into specific test cases.

I have experience with 'baseline' testing, where the output of a test case is validated against a known good state, so I adapted that to these cases.

Using the DSL module greatly helped configuration and the DRY principle.

## Future
- Select location via autocomplete dropdown rather than filling in text
- Overload `find_all` with a Boolean yield condition with regard to date picker
- Protect against no results in dropdown during hotel search
- Adapt tests into application specific robust testing framework (Harness with or without Baseline)