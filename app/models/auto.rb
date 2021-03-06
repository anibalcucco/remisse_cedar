class Auto < ActiveRecord::Base
  attr_accessible :nombre, :oblea

  has_many :trabajos, :dependent => :destroy
  
  def pagados
    Trabajo.find(:all, :conditions => ["auto_id = ? AND pagado = true", self.id])
  end

  def no_pagados
    Trabajo.find(:all, :conditions => ["auto_id = ? AND pagado = false", self.id])
  end
  
  def debe
    return "No debe nada" if no_pagados.empty?
    "Debe: #{no_pagados.join(", ")}"
  end 

  def nombre_completo
    "#{oblea} - #{nombre}"
  end

  # The header line lists the attribute names.  ID is quoted to work
  # around an issue with Excel and CSV files that start with "ID".
  def self.csv_header
    "Remisse,Debe"
  end

  # Emit our attribute values as a line of CSVs
  def to_csv
    nombre_completo << " - " << debe
  end
  
  def to_s
    nombre_completo
  end

end
