require 'rubygems'
require 'sinatra'
require 'sinatra/reloader'
require 'zip'
require 'erb'
require 'pry'

Dir["./config/initializers/*.rb"].each { |file| require file }
Dir["./lib/errors/*.rb"].each {|file| require file }

require './lib/unzip'

set :run, false

class Application < Sinatra::Base

  set :views, 'views'
  set :public_dir, "#{Application.root}/public"
  set :uploads, "#{Application.public_dir}/uploads"
  set :root, File.dirname(__FILE__)

  get('/') do
    erb :index
  end

  get('/upload') do
    erb :upload
  end

  get('/uploaded_files') do
    @files = Dir["#{Application.uploads}/*"].inject([]) { |arr, file| arr << File.open(file) }
    binding.pry
    erb :uploaded_files
  end

  post('/upload') do
    return unless params[:file]
    Unzip.new(params[:file], Application.uploads)
    redirect to('/uploaded_files')
  end

end

