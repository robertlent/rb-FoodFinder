require 'restaurant'
require 'support/string_extend'

class Guide
  class Config
    @@actions = ['list', 'find', 'add', 'quit']
    def self.actions
      @@actions
    end
  end

  def initialize(path = nil)
    Restaurant.filepath = path

    if Restaurant.file_usable?
      system('clear')
      puts 'Found restaurant file.'
    elsif Restaurant.create_file
      system('clear')
      puts 'Restaurant file not found. Created new restaurant file.'
      puts "Add new restaurants now.\n\n"
    else
      puts "Exiting.\n\n"
      exit!
    end
  end

  def launch!
    intro
    result = nil
    until result == :quit
      action, args = get_action
      result = do_action(action, args)
    end
    conclusion
  end

  def get_action
    action = nil
    until Guide::Config.actions.include?(action)
      puts 'Actions: ' + Guide::Config.actions.join(', ') if action
      print '> '
      args = gets.chomp.downcase.strip.split(' ')
      action = args.shift
    end
    [action, args]
  end
  end

def do_action(action, args = [])
  case action
  when 'list'
    list(args)
  when 'find'
    keyword = args.shift
    find(keyword)
  when 'add'
    add
  when 'quit'
    :quit
  else
    puts "\nI don't understand that command.\n"
  end
end

def list(args = [])
  sort_order = args.shift
  sort_order = args.shift if sort_order == 'by'
  sort_order = 'name' unless ['name', 'cuisine', 'price'].include?(sort_order)

  output_action_header('Listing Restaurants')

  restaurants = Restaurant.saved_restaurants
  restaurants.sort! do |restaurant1, restaurant2|
    case sort_order
    when 'name'
      restaurant1.name.downcase <=> restaurant2.name.downcase
    when 'cuisine'
      restaurant1.cuisine.downcase <=> restaurant2.cuisine.downcase
    when 'price'
      restaurant1.price.to_i <=> restaurant2.price.to_i
    end
  end
  output_restaurant_table(restaurants)
  puts "Sort using: 'list cuisine' or 'list by cuisine'\n\n"
end

def find(keyword = '')
  output_action_header('Find a restaurant')
  if keyword
    restaurants = Restaurant.saved_restaurants
    found = restaurants.select do |restaurant|
      restaurant.name.downcase.include?(keyword.downcase) || restaurant.cuisine.downcase.include?(keyword.downcase) || restaurant.price.to_i <= keyword.to_i
    end
    output_restaurant_table(found)
  else
    puts 'Find using a key phrase to search the restaurant list.'
    puts "Examples: 'find pizza', 'find fast'\n\n"
  end
end

def add
  output_action_header('Add a restaurant')
  restaurant = Restaurant.build_from_questions

  if restaurant.save
    puts "\nRestaurant Added\n\n"
  else
    puts "\nSave Error: Restaurant not added\n\n"
  end
end

def intro
  puts "<<< Welcome to the Food Finder >>>\n\n"
  puts "This is an interactive guide to help you find the food you crave.\n"
  puts "Type 'help' to see a list of commands\n\n"
end

def conclusion
  puts "\n<<< Goodbye! >>>\n\n\n"
end

  private

def output_action_header(text)
  puts "\n#{text.upcase.center(60)}\n\n"
end

def output_restaurant_table(restaurants = [])
  print ' ' + 'Name'.ljust(30)
  print ' ' + 'Cuisine'.ljust(20)
  print ' ' + 'Price'.rjust(6) + "\n"
  puts '-' * 60
  restaurants.each do |restaurant|
    line = ' ' << restaurant.name.titleize.ljust(30)
    line << ' ' + restaurant.cuisine.titleize.ljust(20)
    line << ' ' + restaurant.formatted_price.rjust(6)
    puts line
  end
  puts 'No listings found' if restaurants.empty?
  puts '-' * 60
end
