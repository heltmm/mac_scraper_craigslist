require("bundler/setup")
require 'open-uri'
require 'date'

Bundler.require(:default)
Dir[File.dirname(__FILE__) + '/lib/*.rb'].each { |file| require file }

Dynopoker.configure do |config|
	config.address = 'https://macbook-tracker.herokuapp.com/update'
end

get '/' do
  @type = "Normal"
  @search_macs = Mac.where("normal = true")
  @macs = Mac.all
  erb(:index)
end


post ('/search') do

  if params['type'] != "all"
    params['type'] == "true" ? @type = "Normal" : @type = "Damaged/Unusual"
    search_type = "normal = #{params['type']}"
  else
    @type = "All"
  end

  if params['min_price'] != ''
    search_min_price = "price >= #{params['min_price']}"
  end

  if params['max_price'] != ''
    search_max_price = "price <= #{params['max_price']}"
  end

  if search_type
    combined_search = search_type
  end
  if search_min_price && combined_search
    combined_search += " and " + search_min_price
  elsif search_min_price
    combined_search = search_min_price
  end
  if search_max_price && combined_search
    combined_search += " and " + search_max_price
  elsif search_max_price
    combined_search = search_max_price
  end
  if !combined_search
    combined_search = ''
  end

  @search_macs = Mac.where(combined_search).order(params['sort'])
  @macs = Mac.all
  erb(:index)
end
get '/update' do
  #remove old macbooks
  Mac.remove_old
  # default link and city
  search_link = 'https://portland.craigslist.org/search/sss?excats=5-15-22-2-24-1-4-19-1-1-1-2-1-3-6-10-1-1-1-2-2-8-1-1-1-1-1-4-1-3-1-3-1-1-1-1-7-1-1-1-1-1-3-1-1-1-1-1-1-1-1-1-1-1-1-1-1-1-1-1-1-1-1-1-1-1-1-1-1-1-1-1-1-3-1-1-1-1-1&query=macbook&sort=rel'
  city = "Portland"
  # if user inputs link chang default link
  # if params['link'] != ''
  #   search_link = params['link']
  # end

  macs = Mac.scrape_craigslsit(search_link, city)

  macs.each do |mac|
    Mac.create(mac)
  end
  redirect '/'
end

