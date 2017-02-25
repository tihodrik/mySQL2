Bundler.require(:development)
require 'yaml'

Hash.use_dot_syntax = true

@config = YAML.load_file('config.yml')
DB = Sequel.connect(
  :adapter => 'mysql2',
  :host => @config.host,
  :database => @config.name,
  :user => @config.user,
  :password => @config.password
)

DB.drop_table? :students
DB.drop_table? :cities

DB.create_table :cities do
  primary_key :id
  String  :city, :null => false
  String  :country, :null => false
end

DB.create_table :students do
  primary_key :student_id
  String  :first_name, :null => false
  String  :middle_name
  String  :last_name, :null => false
  Integer :course, :fixed => true, :size => 1, :null => false
  String  :gender, :fixed => true, :size => 1, :null => false
  foreign_key :city_id, :cities, :null => false
end

DB[:cities].import(
  [:city, :country],
  [
    ['Erfurt', 'Germany'],
    ['San-Francisco', 'USA'],
    ['Capetown', 'RSA'],
    ['Beijing', 'China'],
    ['Essen', 'Germany'],
    ['Hamburg', 'Germany'],
    ['Athlanta', 'USA']
  ]
)

DB[:students].import(
  [:first_name, :last_name, :course, :gender, :city_id],
  [
    ['Mark',    'Schmidt',  '3', 'm', '1'],
    ['Helen',   'Hunt',     '2', 'f', '2'],
    ['Matumba', 'Zuko',     '4', 'm', '3'],
    ['Rin',     'Kupo',     '4', 'f', '3'],
  	['Peter',   'Zimmer',   '3', 'm', '5'],
    ['Hanz',    'Mueller',  '4', 'm', '6'],
    ['Alisa',   'Kepler',   '4', 'f', '1'],
    ['Anna',    'Madavie',  '2', 'f', '7']
  ]
)

DB[:students].insert(
  [:first_name, :middle_name, :last_name, :course, :gender, :city_id],
  ['Zhen','Chi','Bao','2','m','4']
)

students = DB[:students]
cities = DB[:cities]

puts "Сколько всего студентов приехало к нам учиться?"
puts "#{students.count(:student_id)}\n\n"

puts "Сколько студенток-девочек приехало учиться и на каких они курсах?"
students.where(:gender => 'f').each do |girl|
  puts "#{girl[:first_name]} #{girl[:last_name]}, #{girl[:course]} course\n"
end
puts "\nВсего девочек: #{students.where(:gender => 'f').count()}\n\n"

puts "Сколько студентов приехало учиться из Германии?"
puts "#{students.where(:city_id => (cities.where(:country => 'Germany').select(:id))).count()}\n\n"

puts "Сколько студентов младше четвертого курса у нас обучаются (не включая сам 4 курс)?"
puts "#{students.where('course < 4').count()}\n\n"

puts "Необходимо перевести Анну со 2 на 3 курс, а Питера за неуспеваемость на второй курс"
students.where(:first_name=>'Anna').update(:course => '3')
students.where(:first_name=>'Anna').each do |anna|
  puts "#{anna[:first_name]} #{anna[:last_name]} переведена на #{anna[:course]} курс"
end
students.where(:first_name=>'Peter').update(:course => '2')
students.where(:first_name=>'Peter').each do |peter|
  puts "#{peter[:first_name]} #{peter[:last_name]} переведен на #{peter[:course]} курс\n\n"
end

puts "Необходимо удалить записи обо всех студентках-девушках из Германии, т.к. им не дали разрешение на обучение у нас"
puts "Deleted #{students.where(:gender => 'f', :city_id => cities.where(:country => "Germany").select(:id)).delete()} records\n"
puts "\nFinal list:"
students.each do |student|
  puts "#{student[:student_id]} #{student[:first_name]} #{student[:last_name]}, #{student[:course]} course, #{cities.where(:id => student[:city_id]).first()[:country]}"
end
