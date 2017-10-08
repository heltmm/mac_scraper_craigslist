require("bundler/setup")
require 'open-uri'
require 'pry'

Bundler.require(:default)
Dir[File.dirname(__FILE__) + '/lib/*.rb'].each { |file| require file }

get '/' do
  @macs = Mac.where("normal = true")
  erb(:index)
end

post '/' do
  # default link
  search_link = 'https://portland.craigslist.org/search/sss?query=+macbook+pro&sort=rel'
  # if user inputs link chang default link
  if params['link'] != ''
    search_link = params['link']
  end

  macs = Mac.scrape_craigslsit(search_link)
  
  macs.each do |mac|
    Mac.create(mac)
  end
  @macs = Mac.where("normal = true")
  erb(:index)
end
