require File.expand_path(File.dirname(__FILE__) + '/pdf_extract.rb')
test_schema = {
	file_path: "test_files/dream-may.pdf",
	options: {
		remove_protection: false,
		password: nil,
		extract_all_text: true,
		extract_text: []
	},
	pages: {
		match: "page_num",
		page: 1,
		items: [
			{
				kind: 'ocr', #alternative is kind table
				dimensions:  {
					x: "1",
					y: "34",
					height: "59",
					width: "281"
				}
			}
		]
	}
}
describe "test remote pdf " do
  it "downloads a pdf" do
  #	extractor = PDFextract.new({
  #		file_url: "https://www.dropbox.com/s/x02bhp2xy8me2hg/dream-may.pdf"
  #		})
  #	extractor.file_path.should eq("temp-file.pdf")
  end
end
describe "pdf extraction" do 
	before(:each) do
	    @extractor = PDFextract.new(test_schema)
	end

  it "opens a pdf from a path" do 
 		puts @extractor.file_path
	end
  it "extracts texts from pdf files" do
  	@extractor.extract_all_text.values[0] == "Brightbox 250 5th Avenue,Suite 503 New York, NY, 10001\n\nBrightbox Report for Dream Hotel Downtown\nMay 1, 2013 - May 30, 2013\n\nVenue Summary\n15.0\n\nUses by day\n12.5 10.0\n\nUses Revenue\n\n99 $286.15\n\nUnits\nLocation Default Unit ID 122 Uses 99 Revenue $286.15\n\n7.5 5.0 2.5 0.0 May 3 May 6 May 9 May 12 May 15 May 18 May 21 May 24 May 27 May 30\n\nUsage Heatmap\nM 04:00–08:00 08:00–12:00 12:00–16:00 16:00–20:00 20:00–00:00 00:00–04:00 2 0 0 0 3 1 T 4 1 1 2 2 3 W 0 1 2 0 5 4 T 1 1 1 3 9 5 F 0 0 0 2 1 11 S 1 0 3 0 17 4 S 3\n10.0 15.0 12.5\n\nUnit Uses by day\nunit 122\n\n1\n7.5\n\n1\n5.0\n\n2\n2.5\n\n2\n0.0\n\n3\n\nMay 3 May 6 May 9\n\nMay 12\n\nMay 15\n\nMay 18\n\nMay 21\n\nMay 24\n\nMay 27\n\nMay 30\n\n\f"
  end
  it "generates image files " do
  	@extractor.pdf_to_image_files
  end
  


end
