# config/initializers/wicked_pdf.rb
WickedPdf.configure do |config|
  config.page_size = 'Letter'
  config.orientation = 'Portrait'
  config.encoding = 'UTF-8'
  config.margin = {
    top: '12mm',
    bottom: '12mm',
    left: '12mm',
    right: '12mm'
  }
  config.print_media_type = true
end
