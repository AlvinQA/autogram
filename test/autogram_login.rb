require 'rubygems'
require 'selenium-webdriver'
require 'minitest/autorun'
require 'yaml'

require_relative 'helpers/base_test'
require_relative 'autogram_page_login'

BROWSER = 'firefox'

class Autogram < Minitest::Test
    def setup
        @test_beginning_time = Time.now
        puts "Running Setup"
        @properties = YAML.load_file("config/properties.yml")
        @driver = configure_driver(BROWSER)
        @wait = set_explicit_wait(20)
    end

    def test_login
        puts "Login Test:"
        navigate_login(@driver, @domain)

        puts "Logging in with valid email and password"
        login(@driver, @properties['test_account']['username'], @properties['test_account']['password'])

        assert(@driver.find_elements(:xpath => '//*[contains(.,"' + @properties['test_account']['username'] + '")]'), "FAILURE: Username not appearing on page")
    end

    def teardown
        puts "Test took #{humanize_time(Time.now - @test_beginning_time)} to run"
        @driver.quit
    end
end