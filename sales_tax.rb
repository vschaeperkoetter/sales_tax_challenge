# minitest gem might need to be manually installed via gem install minitest in terminal.
gem 'minitest'
require 'minitest/autorun'

class Basket
  attr_accessor :list, :items, :prices, :line_items, :non_taxed_items

  def initialize(file)
    @list = File.open(file, 'r').to_a.map!(&:chomp)

    # This block of code converts @list to a new array @output, removing "at" from each
    # element in @list. Only quanity&name ("1 book", "2 CDs", etc) and price will
    # be used from now on
    @output = []
    @list.each do |i|
      new_line = i.split(' at ')
      @output << new_line
    end

    # Items and Prices are seperated into seperate arrays here.
    @items = []
    @prices = []
    @output.each do |item|
      item.each do |line|
        if item.index(line).even?
          items << line
        else
          prices << line
        end
      end
    end

    # Method located on line 61. Builds line_item hashes that will print info to console.
    build_line_items
  end

  def total
    totals = []
    @line_items.each do |item|
      totals << item[:total]
    end
    format('%.2f', totals.inject(:+))
  end

  def sales_tax
    taxes = []
    @line_items.each do |item|
      taxes << item[:tax]
    end
    format('%.2f', taxes.inject(:+))
  end

  def print_receipt
    items.each do |item|
      puts "#{item}: #{format('%.2f', line_items[items.index(item)][:total])}"
    end
    puts "Sales Taxes: #{sales_tax}"
    puts "Total: #{total}"
  end

  def build_line_items
    @line_items = []

    @non_taxed_items = %w(book books chocolate chocolates pills medicine food)

    @items.each do |i|
      line_item = {}
      line_item[:quantity] = items[items.index(i)].scan(/\d/).join.to_i
      line_item[:item] = items[items.index(i)].scan(/\D/).pop(items[items.index(i)].scan(/\D/).length - 1).join
      line_item[:price] = prices[items.index(i)].to_f
      line_item[:subtotal] = line_item[:quantity] * line_item[:price]
      line_item[:tax] = format('%.2f', line_item[:quantity] *
                        line_item[:price] * 0.10).to_f

      @non_taxed_items.each { |p| line_item[:tax] = 0 if line_item[:item].include?(p) }

      line_item[:tax] += format('%.2f', line_item[:quantity] *
      line_item[:price] * 0.05).to_f if line_item[:item].include?('imported')

      line_item[:tax] = line_item[:tax].round_up_tax if line_item[:tax] != 0

      @line_items << line_item

      line_item[:total] = format('%.2f', line_item[:quantity] *
                          line_item[:price] + line_item[:tax]).to_f
    end
  end
end

# Rounds up sales tax up to the nearest $0.05
class Float
  def round_up_tax
    remainder = (self * 100) - (((self * 100).to_i) / 5 * 5)
    if remainder > 0
      return ((((self * 100).to_i) / 5 + 1) * 5) / 100.to_f
    else
      return self
    end
  end
end

# Testing done through minitest gem
class TestBasket < Minitest::Test
  def setup
    @basket = Basket.new('input1.txt')
  end

  def test_textfile_parse
    assert_equal ['1 book at 12.49', '1 music CD at 14.99', '1 chocolate bar at 0.85'],
                 @basket.list
  end

  def test_line_item
    assert_equal '1 music CD', @basket.items[1]
  end

  def test_line_item_price
    assert_equal 14.99, @basket.line_items[1][:price]
  end

  def test_line_item_subtotal
    assert_equal 14.99, @basket.line_items[1][:subtotal]
  end

  def test_line_item_tax
    assert_equal 1.5, @basket.line_items[1][:tax]
  end

  def test_line_item_total
    assert_equal 16.49, @basket.line_items[1][:total]
  end
end

puts '*' * 50
shopping_list1 = Basket.new('input1.txt')
puts shopping_list1.print_receipt
puts '*' * 50
shopping_list2 = Basket.new('input2.txt')
shopping_list2.print_receipt
puts '*' * 50
shopping_list3 = Basket.new('input3.txt')
shopping_list3.print_receipt
