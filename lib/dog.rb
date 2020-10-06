class Dog 
  attr_accessor :name, :breed
  attr_reader :id
  
  def initialize(name:, breed:, id: nil)
    @name = name
    @breed = breed
    @id = id
  end

  def self.create_table
    sql =  <<-SQL 
      CREATE TABLE IF NOT EXISTS dogs (
        id INTEGER PRIMARY KEY, 
        name TEXT, 
        breed TEXT
        )
        SQL
    DB[:conn].execute(sql) 
  end
  
  def self.drop_table
    sql = <<-SQL
      DROP TABLE IF EXISTS dogs
      SQL
      
    DB[:conn].execute(sql)
  end

  def save
  sql = <<-SQL
    INSERT INTO dogs (name, breed) 
    VALUES (?,?)
    SQL
    
  DB[:conn].execute(sql, self.name, self.breed)
    
  @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
  self
  end
  
  def self.create(name:, breed:)
    dog = Dog.new(name: name, breed: breed)
    dog.save
    dog
  end
  
  def self.new_from_db(row)
    id = row[0]
    name = row[1]
    breed = row[2]
    new_dog = self.new(name: name, breed: breed, id: id)
  end
  
  def self.find_by_id(id)
    sql = <<-SQL
    SELECT *
    FROM dogs
    WHERE id = ?
    LIMIT 1
  SQL
    
    DB[:conn].execute(sql, id).map{|row| self.new_from_db(row)}.first 
  end
  
  def self.find_or_create_by(name:, breed:)
    dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?", name, breed)
    if dog
      new_dog = self.new_from_db(dog)
    else
      new_dog = self.create(name: name, breed: breed, id: id)
    end
    new_dog
  binding.pry
  end
  
end