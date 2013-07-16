require 'java'
require 'tesseract'
require 'docsplit'
require 'json'
require 'open-uri'
require './settings.rb'
require './page_extractor.rb'
class Hash
	def symbolize_keys!
	  keys.each do |key|
	    self[(key.to_sym rescue key) || key] = delete(key)
	  end
	  self
	end
end

class PDFextract
	attr_accessor :file_path, :results
	attr_accessor :options,:text_dir,:base_dir
	attr_accessor :image_dir, :output_dir, :pages

	def initialize(schema)
		schema.symbolize_keys!

		@base_dir = Time.now.to_i.to_s
		setup_folders(@base_dir)
		@text_dir = @base_dir+'/text_files'
		@image_dir = @base_dir+'/image_files'
		@output_dir = @base_dir+'/output'
		if schema[:file_url]
			@file_path = get_file_from_url(schema[:file_url])
		else
			@file_path = get_file_from_path(schema[:file_path])
			puts @file_path
		end
		@options = schema[:options] if schema[:options]
		@pages = schema[:pages] if schema[:options]
		@results = {}

	end
	def setup_folders(folder_name)
			`rm -r #{folder_name}` if Dir.exists? folder_name
			`mkdir #{folder_name}`
			`mkdir #{text_dir}`
			`mkdir #{output_dir}`
	end

	def get_file_from_url(file_url)
		file_data = open(file_url).read
		temp_file = open(@base_dir+"/temp-file.pdf","w")
		temp_file.write file_data
		temp_file.close
		return temp_file.path
	end
	def get_file_from_path(path)
		new_path = @base_dir+"/temp-file.pdf"
		`cp #{path} #{new_path}` 
		return new_path
	end

	def process
		remove_protection if options[:remove_protection] == true 
		results[:images] = pdf_to_image_files("all")
		results[:text] = convert_to_text if options[:extract_all_text] == true 
		process_pages
		cleanup
	end
	def cleanup
		`rm -r #{base_dir}`
	end
	def remove_protection
		#todo

	end
	
	def process_pages
		pages.each do |page|
			if page[:match] == "page_num"
				page_num = page[:page]
				page[:image_path] = image_dir+"/temp-file_#{page_num}.png"
				page[:pdf_path] = file_path
								
			end
			page_extractor = PageExtractor.new(page)
			page_extractor.process
			results[page_num] = page_extractor.results
		end

	end


	def convert_to_text(pages = "all")
		pdf_to_text_files(pages)
		text = {}
		#take the text from the pdf pages and load em into this shit
		Dir.glob(text_dir+"/*.txt").each do |file|  
			page_num = file.split("_")[-1].split(".")[0]
			text[page_num] = File.open(file).read 
		end
		puts text
		return text
	end
	def convert_to_image(pages = "all")
		pdf_to_image_files(pages)
		images = []
		Dir.glob(image_dir+"/*.png").each do |file|  
			images << file 
		end
	end

	def pdf_to_image_files(pages)
		Docsplit.extract_images(file_path,:output => image_dir, :format => [:png], size: '560x')
	end

	def pdf_to_text_files(pages)
	    Docsplit.extract_text(file_path, :output => text_dir,:pages => pages)
	end
	def extract_with_ocr(page_path,dimensions)
		engine = Tesseract::Engine.new(language: :eng)
		engine.image = page_path
		engine.select 1,34,59,281
		text = engine.text.strip
		dimensions[:result] = text 
		return text
	end


	def self.example_schema 
		{
			file_path: "test_files/dream-may.pdf",
			options: {
				remove_protection: false,
				password: nil,
				extract_all_text: true,
				extract_text: []
			},
			pages: [{
				match: "page_num",
				page: 1,
				items: [
					{
						name: 'title',
						kind: 'ocr', #alternative is kind table
						dimensions:  {
							x1: 10,
							x2: 282,
							y1: 50,
							y2: 100
						}
					},
					{
						name: 'units_table'
						kind: 'table',
						dimensions: {
							x1: 0,
							x2: 265.73,
							y1: 184.94,
							y2: 233.84
						}
					}
				]
			}]
		}
	end

end


schema = PDFextract.example_schema

extractor = PDFextract.new(schema)
extractor.process
puts extractor.results