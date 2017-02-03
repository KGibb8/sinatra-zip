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
  set :public_dir, 'public'
  set :root, File.dirname(__FILE__)

  get('/') do
    erb :index
  end

  get('/upload') do
    erb :upload
  end

  post('/upload') do
    binding.pry
    return unless params[:file]
    @file = Unzip.new(params[:file])
  end

end

