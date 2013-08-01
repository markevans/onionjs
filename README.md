# Onion JS. Brings tears to your eyes.

## Usage in rails

1. Add requirejs-rails to your project - see instructions at [https://github.com/jwhitley/requirejs-rails]

2. Add onionjs

    gem 'onionjs'

3. In your view file, add an app

    <%= onionjs_app :calendar %>

4. Start making controllers - see usage with

    rails generate onionjs:module

## Tests

    make test

