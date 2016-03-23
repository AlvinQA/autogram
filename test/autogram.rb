require_relative "test_helper"
require_relative "helpers/base_test"
require_relative "helpers/navigation_helpers"
require_relative "helpers/login_helpers"
require_relative "helpers/dashboard_helpers"

BROWSER = "firefox"

class Autogram < Minitest::Test
  def setup
    @test_beginning_time = Time.now
    puts "Running Setup"
    @properties = YAML.load_file("test/config/properties.yml")
    @uris = YAML.load_file("test/config/uris.yml")
    @driver = configure_driver(BROWSER)
    @domain = "http://www.instagram.com"
    @wait = set_explicit_wait(20)
  end

  def test_login
    puts "Login Test:"
    navigate_to_login(@driver, @domain, @uris)

    puts "Logging in with valid email and password"
    username = @properties["test_account"]["username"]
    password = @properties["test_account"]["password"]
    login(@driver, username, password)
    username_path = "//*[contains(.,'#{username}')]"
    assert(@driver.find_elements(:xpath => username_path).size > 0,
      "FAILURE: Username not appearing on page")
    # @driver.navigate.refresh if seed_followers?(@driver, @pending)
    # load_more(@driver)
    # load_more(@driver)
    # load_more(@driver)
    # load_more(@driver)
  end

  def teardown
    save_last_run(@properties)
    puts "Test took #{humanize_time(Time.now - @test_beginning_time)} to run"
    @driver.quit
  end
end