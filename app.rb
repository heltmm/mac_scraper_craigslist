require("bundler/setup")
require 'open-uri'
require 'pry'


Bundler.require(:default)
Dir[File.dirname(__FILE__) + '/lib/*.rb'].each { |file| require file }

parse_file = Nokogiri::HTML(open('https://portland.craigslist.org/search/sya?query=macbook+pro'))
search_links = parse_file.xpath("//a[@class='result-title hdrlnk']/@href")

keywords = ['broken', 'damaged', 'parts', 'cracked', 'crack', 'not working', 'damage', 'fix']
macs = []

search_links.each do |link|
  page = Nokogiri::HTML(open(link).read)

  link = link.text
  condition = page.xpath("//p[@class='attrgroup']/span[1]/b").text
  manufacturer = page.xpath("//p[@class='attrgroup']/span[2]/b").text
  model = page.xpath("//p[@class='attrgroup']/span[3]/b").text
  title = page.xpath("//span[@id='titletextonly']").text

  if price = page.xpath("//span[@class='price']").text
    price = price.gsub("$", "")
  end
  description = page.xpath("//section[@id='postingbody']").text
  if location = page.xpath("//span[@class='postingtitletext']/small").text
    if location != ''
      location = location.chop!.gsub(' ','')[1..-1]
    end
  end

  keywords.each do |word|
    if !title.match(word) and !description.match(word)
      macs.push({:link => link, :model => model, :manufacturer => manufacturer, :title => title, :price => price, :condition => condition, :description => description, :location => location})
    end
  end
end
binding.pry
