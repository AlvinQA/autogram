def configure_driver(browser="firefox")
	puts "Driver: #{browser}"
	if browser == 'chrome'
		driver = Selenium::WebDriver.for :chrome
	elsif browser == 'safari'
		driver = Selenium::WebDriver.for :safari
	elsif browser == 'firefox'
		driver = Selenium::WebDriver.for :firefox,:profile => configure_firefox_profile
	elsif browser == 'sauce'
		driver = Selenium::WebDriver.for :remote, :url => get_saucelabs_endpoint, :desired_capabilities => configure_saucelabs_profile
	end
	return driver
end

def set_explicit_wait(wait_time)
	puts "Setting WebDriver explicit wait for #{wait_time} seconds"
	return Selenium::WebDriver::Wait.new(:timeout => wait_time)
end

def configure_firefox_profile
	profile = Selenium::WebDriver::Firefox::Profile.new
	profile['browser.download.dir'] = "Downloads"
	profile['browser.download.folderList'] = 2
	profile['browser.helperApps.neverAsk.saveToDisk'] = "application/pdf"
	profile['pdfjs.disabled'] = true
	return profile
end

def configure_saucelabs_profile
	return {:platform => "Mac OS X 10.9", :browserName => "Firefox", :name => name()}
end

def get_saucelabs_endpoint
	return "http://mmeling:4320aa06-d65d-4786-8947-73f6bdabd77d@ondemand.saucelabs.com:80/wd/hub"
end

def go_to_url(driver, url)
	driver.get url
end

def email_randomizer
	return "qa" + Time.now.to_s.gsub(/[^0-9A-Za-z]/, '') + "@thecontrolgroup.com"
end

def random_letter
	return (('A'..'P').to_a + ('R'..'W').to_a).sample
end

def random_wait_length
	return Random.rand(5)
end

def compare_hash(hash1, hash2)
	puts hash1.select{|k,_| hash2.has_key? k}
	puts hash2.select{|k,_| hash1.has_key? k}
	return hash1.select{|k,_| hash2.has_key? k} == hash2.select{|k,_| hash1.has_key? k}
end

def wait_until_visible(driver, type, path, wait_length=15)
	wait = Selenium::WebDriver::Wait.new(:timeout => wait_length)
	puts "Waiting up to " + wait_length.to_s + " seconds for " + path + " to be visible  "
	beginning_time = Time.now
	#show_wait_spinner{
		wait.until { driver.find_element(type, path).displayed? }
	#}
	puts "Actually took #{humanize_time(Time.now - beginning_time)} to run"
end

def wait_until_not_visible(driver, type, path, wait_length=15)
	wait = Selenium::WebDriver::Wait.new(:timeout => wait_length)
	puts "Waiting up to " + wait_length.to_s + " seconds for " + path + " to no longer be visible"
	beginning_time = Time.now
	#show_wait_spinner{
		wait.until { driver.find_elements(type, path).size == 0 }
	#}
	puts "Actually took #{humanize_time(Time.now - beginning_time)} to run"
end

def wait_for_element(driver, type, path, wait_length=15)
	wait = Selenium::WebDriver::Wait.new(:timeout => wait_length)
	puts "Waiting up to " + wait_length.to_s + " seconds for " + path + " to be in DOM"
	beginning_time = Time.now
	#show_wait_spinner{
		wait.until { driver.find_element(type, path) }
	#}
	puts "Actually took #{humanize_time(Time.now - beginning_time)} to run"
end

def wait_for_element_to_disappear(driver, type, path, wait_length=15)
	wait = Selenium::WebDriver::Wait.new(:timeout => wait_length)
	puts "Waiting up to " + wait_length.to_s + " seconds for " + path + " to no longer be in DOM"
	beginning_time = Time.now
	#show_wait_spinner{
		wait.until { driver.find_elements(type, path).empty? }
	#}
	puts "Actually took #{humanize_time(Time.now - beginning_time)} to run"
end

def get_current_url(driver)
	return driver.current_url
end

def show_wait_spinner() # stolen from http://stackoverflow.com/a/10263337, and viciously butchered
	loader = [["  \\o/\n   |\n  / \\\nW\n","   /o/\n   /\n  //\n A\n","    _\n  =-o\n    ¯\n  I\n",
		"  \\ \\\n    \\\n    \\o\\\n   T\n","  | |\n   |\n  |o|\n    I\n","    / /\n    /\n  /o/\n     N\n",
		"  _\n  o-=\n  ¯\n      G\n","  \\o\\\n    \\\n    \\\\\n       !\n","  \\o/\n   |\n  / \\\n        !\n",
		"  _o_\n   |\n  / \\\n         !\n","   o\n  /|\\\n  / \\\nWAITING!!!\n","  _o_\n   |\n  / \\\nWAITING!!!"],
		[">))'>","    >))'>","        >))'>","    <'((<","<'((<"],
		["        /\\\n       /__\\_{)\n     W|IT!!)__\\\n       \\  /  (\n        \\/   )\n            /|\n            \\ \\\n            ~ ~",
		"         /|   \\\n        /_|_{)/\nAIT!!   | |  )\n        \\ |  (\n         \\|  )\n            /|\n            \\ \\\n            ~ ~",
		"              \\\n          /|{)/\nAIT!!    WA|T)\n          \\| (\n             )\n            /|\n            \\ \\\n            ~ ~"],
		["    /\\O\n     /\\/\n    /\\\n   /  \\\n WAI  NG!","     _O\n   //|_\n    |\n   /|\n   TING",
		"      O\n     /_\n     |\\\n    / |\n  ITING"]]
	iter = 0
	colorizer = Lolize::Colorizer.new
	spinner = Thread.new do
		rand_loader = Random.new.rand(loader.length)
		while iter do
			colorizer.write loader[rand_loader].rotate!.first
			sleep 0.15
			print ("\e[A"*loader[rand_loader].first.count("\n")) + "\r\e[J"
		end
	end
	yield.tap{
		iter = false
		spinner.join
	}
end

def get_matts_attention()
	iter = 0
	colorizer = Lolize::Colorizer.new
	spinner = Thread.new do
		while iter do
			colorizer.write "PAY ATTENTION DUMMY PAY ATTENTION DUMMY PAY ATTENTION DUMMY"
			sleep 0.15
      		print "\b"
		end
	end
	yield.tap{
		iter = false
		spinner.join
	}
end

def humanize_time seconds # stolen from http://stackoverflow.com/a/4136485
  [[60, :seconds], [60, :minutes], [24, :hours], [1000, :days]].map{ |count, name|
    if seconds > 0
      seconds, n = seconds.divmod(count)
      "#{n.to_i} #{name}"
    end
  }.compact.reverse.join(' ')
end