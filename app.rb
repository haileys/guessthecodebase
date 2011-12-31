require "bundler/setup"
require "sinatra"
require "sass"
require "active_record"
require "erubis"
require "coderay"

ActiveRecord::Base.establish_connection adapter: "mysql2", host: "localhost", user: "root", database: "guessthecodebase"
set :erb, escape_html: true

class ActiveRecord::Base
  def self.random(n = 1)
    find rand(count) + 1
  end
end

class Codebase < ActiveRecord::Base
end

class Snippet < ActiveRecord::Base
  belongs_to :codebase
  def formatted_code
    indentation = code.match(/\A\s*/)[0]
    CodeRay.scan(code.gsub(/^#{indentation}/,""), language).div
  end
end

get "/" do
  @snippet = Snippet.random
  @choices = Codebase.all.shuffle.take 4
  @choices[rand 4] = @snippet.codebase unless @choices.include? @snippet.codebase
  erb :index
end

get "/style.scss" do
  scss :style
end