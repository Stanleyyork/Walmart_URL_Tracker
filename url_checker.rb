require 'rubygems'
require 'readit'
require 'open-uri'
require 'nokogiri'
# note, if you're going to run on your machine you may need to 'gem install'
# each of the items above


#################################################################################
################### Only Change The (Three) Variables Below #####################

# url_find is the variable that determines which link you're looking for
# please enter without the host domain (e.g. without "http://www.walmart.com/")
url_find = "browse/household-essentials/bath-tissue/1115193_1073264_1149384"

# print_only_pages_with_url establishes whether you want to print only the pages
# that contain the url_find link above. leave as 'yes' if this is the case.
print_only_pages_with_url = "yes" #options "yes" or "no"

# show_percent_complete shows you your progerss
show_percent_complete = "no" #options "yes" or "no"

#################################################################################
#################################################################################






# currently using the "All Departments" page on Walmart.com as a source for
# all the links to search through
root_url = "http://www.walmart.com/cp/All-Departments/121828"

# retrieve content from 'All Departments' page
root_content = Nokogiri::HTML(open(root_url))

# retrieve all links from content on 'All Departments page'
url_array = []
(root_content.css("a")).each do |x| 
                url_array << x['href']
end

# adding the host domain (walmart.com) to links that don't contain the domain
url_array_new = []
url_array.each do |x|
        if (x.to_s)[0..3] != "http"
                url_array_new << "http://www.walmart.com#{x}"
        else
                url_array_new << x
        end
end

# removing any links from the url array that contains 'https'
url_array_no_https = []
url_array_new.each do |y|
        if y[0..4] == "https"
                y
        else
                url_array_no_https << y
        end
end

# scanning through every url in array to see the page contains the 'url_find'
total_url_count = 0
total_page_count = 0
x=0
print "Number of pages to check: "
puts url_array_no_https.count
while x < url_array_no_https.count

        begin
                content = Net::HTTP.get(URI.parse(url_array_no_https[x]))
                        if content.include? url_find
                                puts "-----"
                                puts url_array_no_https[x]
                            print "Yes: "
                            puts content.scan(url_find).count
                            total_page_count = total_page_count + 1
                            total_url_count = total_url_count + (content.scan(url_find).count)
                            puts "-----"
                        else
                                if print_only_pages_with_url == "yes"
                                        if show_percent_complete == "yes"
                                                print ((((x.to_f)/((url_array_no_https.count).to_f))*100)).round(2)
                                                puts "%"
                                        end
                                else
                                        puts url_array_no_https[x]
                                        puts "No URL on this page"
                                        puts "-----"
                                end
                        end
        rescue URI::Error => e
                puts "error with #{url_array_no_https[x]}, moving on to next URL"
        end
        x = x + 1
end

puts "Found #{total_url_count} URLs on #{total_page_count} pages."