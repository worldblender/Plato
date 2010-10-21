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

  # GET /bombs/new
  # GET /bombs/new.xml
  def new
    @bomb = Bomb.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @bomb }
    end
  end

  # GET /bombs/1/edit
  def edit
    @bomb = Bomb.find(params[:id])
  end

  # POST /bombs
  # POST /bombs.xml
  def create
    @bomb = Bomb.new(params[:bomb])

    respond_to do |format|
      if @bomb.save
        format.html { redirect_to(@bomb, :notice => 'Bomb was successfully created.') }
        format.xml  { render :xml => @bomb, :status => :created, :location => @bomb }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @bomb.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /bombs/1
  # PUT /bombs/1.xml
  def update
    @bomb = Bomb.find(params[:id])

    respond_to do |format|
      if @bomb.update_attributes(params[:bomb])
        format.html { redirect_to(@bomb, :notice => 'Bomb was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @bomb.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /bombs/1
  # DELETE /bombs/1.xml
  def destroy
    @bomb = Bomb.find(params[:id])
    @bomb.destroy

    respond_to do |format|
      format.html { redirect_to(bombs_url) }
      format.xml  { head :ok }
    end
  end
end
