require("bundler/setup")
require 'open-uri'
require 'date'
require 'pry'


Bundler.require(:default)
Dir[File.dirname(__FILE__) + '/lib/*.rb'].each { |file| require file }

get '/' do
  @type = "Normal"
  @search_macs = Mac.where("normal = true")
  erb(:index)
end

get '/update' do
  erb(:search)
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
post '/' do
  # default link
  search_link = 'https://portland.craigslist.org/search/sss?query=+macbook+pro&sort=rel'
  city = "Portland"
  # if user inputs link chang default link
  if params['link'] != ''
    search_link = params['link']
  end

  macs = Mac.scrape_craigslsit(search_link, city)

  macs.each do |mac|
    Mac.create(mac)
  end
  @search_macs = Mac.where("normal = true")
  @type = "Normal"
  erb(:index)
end
