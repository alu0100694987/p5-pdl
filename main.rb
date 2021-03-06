require 'sinatra'
require 'slim'
require 'sass'
require 'v8'
require 'coffee-script'

before do
  set_title
end

helpers do
  def css(*stylesheets)
    stylesheets.map do |stylesheet| 
      %Q{
        <link href="/#{stylesheet}.css" 
              media="screen, projection" 
              rel="stylesheet" 
        />
      }
    end.join
  end
  
  def current?(path='/')
    (request.path==path || request.path==path+'/') ? "current" : nil
  end
  
  def set_title
    @title ||= "Analizador Sint&aacute;ctico Descendente Predictivo Recursivo"
  end
end

get('/styles.css'){ scss :styles }
get('/javascripts/main.js'){ coffee :main }

get '/' do
  slim :home
end

get '/gramatica' do
  slim :gramatica
end

get '/tests' do
  slim :tests
end

not_found do
  slim :not_found
end

