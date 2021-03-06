class TrabajosController < ApplicationController

  before_filter :authenticate_user!
  before_filter :find_auto, :only => [ :bulk, :update ]

  def new
    @autos = Auto.find(:all, :order => 'oblea ASC')
  end

  def edit
    @trabajo = Trabajo.find(params[:id])
  end
  
  def bulk
    @trabajos = @auto.no_pagados
  end

  def create
    unless params[:fecha].blank?
      params[:trabajos].each do |auto_id|
        trabajo = Trabajo.find(:first, :conditions => ['fecha = ? AND auto_id = ?', params[:fecha].to_date, auto_id])
        if trabajo
          trabajo.update_attribute(:pagado, pagado?(auto_id))
        elsif !pagado?(auto_id)
          Trabajo.create(:fecha => params[:fecha], :auto_id => auto_id, :pagado => false)
        end  
      end if params[:trabajos]  
      flash[:notice] = 'La carga fue exitosa'
      redirect_to :controller => 'autos'
    else
      flash[:notice] = 'Por favor seleccione una fecha antes de cargar'    
      @autos = Auto.find(:all)
      render :action => 'new'
    end  
  end

  def update
    if params[:pagos]
      params[:pagos].each do |trabajo_id|
        trabajo = Trabajo.find(trabajo_id)
        trabajo.update_attribute(:pagado, true)
      end
      no_pagados = @auto.no_pagados
      flash[:notice] = "#{params[:pagos].size} dia(s) fueron marcados como pagados. "
      if no_pagados.empty?
        flash[:notice] << "El remisse '#{@auto.nombre_completo}' no debe mas nada"
      else
        flash[:notice] << "El remisse '#{@auto.nombre_completo}' sigue debiendo #{no_pagados.size} dia(s)"
      end
    else
      flash[:notice] = "No se seleccionaron dias pagados"
    end
    redirect_to :controller => 'autos'
  end

  private

  def pagado?(auto_id)
    return false unless params[:pagos]
    params[:pagos].include?(auto_id)
  end
  
  def find_auto
    @auto = Auto.find(params[:auto_id])
  end

end
