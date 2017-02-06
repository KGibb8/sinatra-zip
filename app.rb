require 'rubygems'
require 'sinatra'
require 'sinatra/reloader'
require 'sinatra/flash'
require 'zip'
require 'erb'
require 'pry'

Dir["./config/initializers/*.rb"].each { |file| require file }
Dir["./lib/errors/*.rb"].each {|file| require file }

require './lib/unzip'

set :run, false

class Application < Sinatra::Base
  register Sinatra::Flash
  enable :sessions

  set :views, 'views'
  set :public_dir, "public"
  set :uploads, "public/uploads"
  set :root, File.dirname(__FILE__)

  configure do
    set :server, :puma
  end

  get('/') do
    erb :index
  end

  get('/upload') do
    erb :upload
  end

  get('/uploaded_files') do
    @files = Dir["#{Application.uploads}/*"].inject([]) { |arr, file| arr << File.open(file) }
    erb :uploaded_files
  end

  post('/upload') do
    if params[:file]
      unzip = Unzip.new(params[:file], Application.uploads)
      if unzip.valid?
        redirect to('/uploaded_files')
      else
        flash[:notice] = "Upload invalid. Please select a valid zip file for upload"
        redirect to('/upload')
      end
    else
      flash[:notice] = "Please select a file for upload"
      redirect to('/upload')
    end
  end

end

