require("bundler/setup")
require 'open-uri'
require 'pry'
Bundler.require(:default)
Dir[File.dirname(__FILE__) + '/lib/*.rb'].each { |file| require file }

get '/' do
  @macs = []
  @damaged_macs = []
  erb(:index)
end

post '/' do
  # default link
  search_link = 'https://portland.craigslist.org/search/sss?query=+macbook+pro&sort=rel'
  # if user inputs link chang default link
  if params['link'] != ''
    search_link = params['link']
  end
  #parse local craiglist macbook search
  parse_file = Nokogiri::HTML(open(search_link))
  # select every macbook link
  mac_links = parse_file.xpath("//a[@class='result-title hdrlnk']/@href")
  # keywords to sort broken or damaged
  keywords = ['broken', 'damaged', 'parts', 'cracked', 'crack', 'not working', 'damage', 'fix']

  @macs = []
  @damaged_macs = []
  # parse each macbook page
  mac_links.each do |link|
    page = Nokogiri::HTML(open(link).read)

    link = link.text
    condition = page.xpath("//p[@class='attrgroup']/span[1]/b").text
    manufacturer = page.xpath("//p[@class='attrgroup']/span[2]/b").text
    model = page.xpath("//p[@class='attrgroup']/span[3]/b").text
    title = page.xpath("//span[@id='titletextonly']").text
    # remove extra characters and spaces that were selected along with information
    if price = page.xpath("//span[@class='price']").text
      price = price.gsub("$", "")
    end
    description = page.xpath("//section[@id='postingbody']").text.gsub("\n        \n            QR Code Link to This Post\n            \n        \n", '')
    if location = page.xpath("//span[@class='postingtitletext']/small").text
      if location != ''
        location = location.chop!.gsub(' ','')[1..-1]
      end
    end

    if keywords.any? {|word| title.match(word) || description.match(word)}
      @damaged_macs.push({:link => link, :model => model, :manufacturer => manufacturer, :title => title, :price => price, :condition => condition, :description => description, :location => location})
    else
      @macs.push({:link => link, :model => model, :manufacturer => manufacturer, :title => title, :price => price, :condition => condition, :description => description, :location => location})
    end
  end
  binding.pry
  erb(:index)
end
