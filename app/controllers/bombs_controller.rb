class BombsController < ApplicationController
  # GET /bombs
  # GET /bombs.xml
  def index
    @bombs = Bomb.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @bombs }
    end
  end

  # GET /bombs/1
  # GET /bombs/1.xml
  def show
    @bomb = Bomb.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @bomb }
    end
  end
end
