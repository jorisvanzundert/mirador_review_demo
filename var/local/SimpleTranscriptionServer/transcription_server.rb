require 'sinatra'
require 'nokogiri'
require 'logger'
require 'sinatra/reloader'

  ::Logger.class_eval { alias :write :'<<' }
  access_log = ::File.join(::File.dirname(::File.expand_path(__FILE__)),'log','access.log')
  access_logger = ::Logger.new(access_log)
  error_logger = ::File.new(::File.join(::File.dirname(::File.expand_path(__FILE__)),'log','error.log'),"a+")
  error_logger.sync = true

  configure do
    use ::Rack::CommonLogger, access_logger
    enable :reloader
    set :public_folder, '/var/local/SimpleTranscriptionServer/public'
  end

  before {
    env["rack.errors"] =  error_logger
  }

  get '/' do
    'Success. Sinatra running at your convenience.'
  end

  get '/reynaert' do
    headers 'Access-Control-Allow-Origin' => '*'
    erb :reynaert
  end

  get '/reynaert/xml' do
    headers 'Access-Control-Allow-Origin' => '*'
    content_type 'text/xml'
    File.read( '/var/local/SimpleTranscriptionServer/public/reynaert_transcription_20170704_1529.xml' )
  end

  get '/reynaert/xml_as_html' do
    headers 'Access-Control-Allow-Origin' => '*'
    content_type 'text/html'
    xml = File.open( '/var/local/SimpleTranscriptionServer/public/reynaert_transcription_20170704_1529.xml', 'r:UTF-8' ).read
    xml = xml.gsub( /\</, '&lt;' )
    xml = xml.gsub( /\>/, '&gt;' )
    "<textarea>" << xml << "</textarea>"
  end

  get '/reynaert/diplomatic' do
    headers 'Access-Control-Allow-Origin' => '*'
    content_type 'text/html'
    document = Nokogiri::XML( File.open( '/var/local/SimpleTranscriptionServer/public/reynaert_transcription_20170704_1529.xml', 'r:UTF-8' ).read() )
    template = Nokogiri::XSLT( File.open( '/var/local/SimpleTranscriptionServer/public/template_diplomatic.xslt', 'r:UTF-8' ).read() )
    template.transform( document ).to_s
  end

  get '/reynaert/critical' do
    headers 'Access-Control-Allow-Origin' => '*'
    content_type 'text/html'
    document = Nokogiri::XML( File.open( '/var/local/SimpleTranscriptionServer/public/reynaert_transcription_20170704_1529.xml', 'r:UTF-8' ).read() )
    template = Nokogiri::XSLT( File.open( '/var/local/SimpleTranscriptionServer/public/template_critical.xslt', 'r:UTF-8' ).read() )
    template.transform( document ).to_s
  end

  get '/reynaert/diplomatic/folio/:folio_number' do
    headers 'Access-Control-Allow-Origin' => '*'
    content_type 'text/html'
    document = Nokogiri::XML( File.open( '/var/local/SimpleTranscriptionServer/public/reynaert_transcription_20170704_1529.xml', 'r:UTF-8' ).read() )
    template = Nokogiri::XSLT( File.open( '/var/local/SimpleTranscriptionServer/public/template_diplomatic.xslt', 'r:UTF-8' ).read() )
    folio = template.transform( document ).at_css( "div[folio='#{params['folio_number']}']" )
    inline_style = File.open( '/var/local/SimpleTranscriptionServer/public/folio.css', 'r:UTF-8' ).read()
    folio.at_css( '.column_text' ).add_previous_sibling( "<style>#{inline_style}</style>" )
    folio.to_s
  end

  get '/reynaert/critical/folio/:folio_number' do
    headers 'Access-Control-Allow-Origin' => '*'
    content_type 'text/html'
    document = Nokogiri::XML( File.open( '/var/local/SimpleTranscriptionServer/public/reynaert_transcription_20170704_1529.xml', 'r:UTF-8' ).read() )
    template = Nokogiri::XSLT( File.open( '/var/local/SimpleTranscriptionServer/public/template_critical.xslt', 'r:UTF-8' ).read() )
    folio = template.transform( document ).at_css( "div[folio='#{params['folio_number']}']" )
    inline_style = File.open( '/var/local/SimpleTranscriptionServer/public/folio.css', 'r:UTF-8' ).read()
    folio.at_css( '.column_text' ).add_previous_sibling( "<style>#{inline_style}</style>" )
    folio.to_s
  end
