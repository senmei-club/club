#encoding: utf-8
class SysConfigsController < ApplicationController
  layout "common"
  
  load_and_authorize_resource
  # GET /sys_configs
  # GET /sys_configs.json
  def index
    @sys_configs = SysConfig.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @sys_configs }
    end
  end

  # GET /sys_configs/1
  # GET /sys_configs/1.json
  def show
    @sys_config = SysConfig.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @sys_config }
    end
  end

  # GET /sys_configs/new
  # GET /sys_configs/new.json
  def new
    @sys_config = SysConfig.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @sys_config }
    end
  end

  # GET /sys_configs/1/edit
  def edit
    @sys_config = SysConfig.find(params[:id])
  end

  # POST /sys_configs
  # POST /sys_configs.json
  def create
    @sys_config = SysConfig.new(params[:sys_config])

    respond_to do |format|
      if @sys_config.save
        format.html { redirect_to @sys_config, notice: '系統變數建立成功.' }
        format.json { render json: @sys_config, status: :created, location: @sys_config }
      else
        format.html { render action: "new" }
        format.json { render json: @sys_config.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /sys_configs/1
  # PUT /sys_configs/1.json
  def update
    @sys_config = SysConfig.find(params[:id])

    respond_to do |format|
      if @sys_config.update_attributes(params[:sys_config])
        format.html { redirect_to @sys_config, notice: '系統變數更新成功.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @sys_config.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /sys_configs/1
  # DELETE /sys_configs/1.json
  def destroy
    @sys_config = SysConfig.find(params[:id])
    @sys_config.destroy

    respond_to do |format|
      format.html { redirect_to sys_configs_url }
      format.json { head :no_content }
    end
  end
end
