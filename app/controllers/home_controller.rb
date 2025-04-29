class HomeController < ApplicationController
  def index
    @friends = Friend.all
  end
end
