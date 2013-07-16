require 'java'
require 'json'
require './settings.rb'
json = '{"x1":0,"x2":265.73044864101234,"y1":184.9483922541446,"y2":233.8427948040909,"page":1,"use_lines":false }'
parameters = JSON.parse(json)

def get_table(file,p)


#	extractor = Tabula::Extraction::CharacterExtractor.new(File.expand_path(file, File.dirname(__FILE__)))
#	characters = extractor.extract.next.get_text([p["x1"],p["x2"],p["y1"],p["y2"]])
#	table = lines_to_array Tabula.make_table(characters)
	dimensions = [p["y1"],p["x1"],p["y2"],p["x2"]].join(", ")
	puts table = `tabula --area='#{dimensions}' #{file}`
	return table

end
puts parameters["x2"].class

file = "temp-file.pdf"
puts get_table(file,parameters)

