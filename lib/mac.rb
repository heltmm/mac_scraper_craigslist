class Mac < ActiveRecord::Base
  def self.scrape_craigslsit(url, city)

    parse_file = Nokogiri::HTML(open(url))
    # select every macbook link
    mac_links = parse_file.xpath("//a[@class='result-title hdrlnk']/@href")
    # keywords to sort broken or damaged
    keywords = ['broken', 'damaged', 'parts', 'cracked', 'not working', 'repair']

    # parse each macbook page
    mac_links.each do |link|
      page = Nokogiri::HTML(open(link).read)

      link = link.text
      condition = page.xpath("//p[@class='attrgroup']/span[1]/b").text
      if condition == ''
        condition = "not provided"
      end
      date_posted = page.xpath("//time").text.split(' ')[0]
      # manufacture should always be apple but can scrape if needed
      # manufacturer = page.xpath("//p[@class='attrgroup']/span[2]/b").text
      model = page.xpath("//p[@class='attrgroup']/span[3]/b").text
      if model == ''
        model = 'not provided'
      end
      title = page.xpath("//span[@id='titletextonly']").text
      # remove extra characters and spaces that were selected along with information
      if price = page.xpath("//span[@class='price']").text
        price = price.gsub("$", "").to_i
      end
      description = page.xpath("//section[@id='postingbody']").text.gsub("\n        \n            QR Code Link to This Post\n            \n        \n", '')
      if location = page.xpath("//span[@class='postingtitletext']/small").text
        if location != ''
          location = location.chop![2..-1]
        else
          location = "not provided"
        end
      end

      mac = {:link => link, :model => model, :title => title, :price => price, :condition => condition, :description => description, :address => location, :date_posted => date_posted, :city => city, :normal => false}

      # block duplicates
      if Mac.exists?({:title => title, :price => price}) == false
        if keywords.any? {|word| title.downcase.match?(word) || description.downcase.match?(word)} || price < 100 || title.downcase.match("wanted")
          Mac.create(mac)
        else
          mac[:normal] = true
          Mac.create(mac)
        end
      end
    end
  end

  def self.remove_old
    current_macs = Mac.all
    # current date converted to julian
    today = Date.today.julian.strftime("%j").to_i
    current_macs.each do |mac|
      if !mac.date_posted
        mac.delete
      end
      if check = mac.date_posted.julian.strftime("%j").to_i
        if (today - check) > 30
          mac.delete
        end
      end
    end
  end
end
