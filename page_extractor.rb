require 'java'
require 'tesseract'
require 'image_voodoo'
require 'docsplit'
class PageExtractor
	attr_accessor :page, :results, :items, :image_path, :pdf_path, :results
	def initialize(page)
		@image_path = page[:image_path]
		@pdf_path = page[:pdf_path]
		@items = page[:items]
		@page_num = 
		@results = {}
	end

	def process
		items.each do |item|
			case item[:kind]
			when 'ocr' then extract_ocr(item)
			when 'table' then extract_table(item)
			end
		end

	end

	def extract_ocr(item)
		dimensions = item[:dimensions]
		@results[item[:name]] = ocr_text(crop_image(dimensions))	
	end

	def crop_image(d)
		new_image_name = "CR.png"
		ImageVoodoo.with_image(image_path) do |img|
			x1 = d[:x1]	
			x2 = d[:x2]
			y1 = d[:y1]
			y2 = d[:y2]
			img.with_crop(x1,y1,x2,y2) { |img2| img2.save new_image_name }
		end
		return new_image_name
	end

	def extract_table(item)
		table = run_tabula(item[:dimensions])
		@results[item[:name]] = lines_to_array(table)
	end

	def run_tabula(d)
	area = [d[:y1],d[:x1],d[:y2],d[:x2]].join(", ")
	table = `tabula --area='#{area}' #{pdf_path}`
	return table
	end
	
	def lines_to_array(table)
	  table.lines.map(&:chomp).map { |l|
	    l.split(",")
	  }
	end

	def ocr_text(image_path,blacklist='|',language=:eng)
		e = Tesseract::Engine.new {|e|
		  e.language  = language
		  e.blacklist = blacklist
		}
		return e.text_for(image_path).strip
	end
end

page = {
	pdf_path: 'temp-file.pdf',
	image_path: 'temp-file_1.png',
	items: [
		{
			name: "title",
			kind: 'ocr', #alternative is kind table
			dimensions:  {
				x1: 10,
				x2: 282,
				y1: 50,
				y2: 100
			}
		},
		{
			name: "unit table",
			kind: 'table',
			dimensions: {
				x1: 0,
				x2: 265.73,
				y1: 184.94,
				y2: 233.84
			}
		}
] 
}
#test = PageExtractor.new(page)
#test.process
#puts test.results.inspect
