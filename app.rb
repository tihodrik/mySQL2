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
