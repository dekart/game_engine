# An object for managing a roll of dice.
class Dice
	
	# 
	# Creates a new Dice object, rolling the indicated _count_ of the
	# indicated _sided_ dice.  The sides on a die need not be realistic,
	# so this object can also be used to manage a coin toss (a two-sided
	# die).
	#
	# :call-seq:
	#   Dice.new(count, sides)    -> count_d_sides_roll
	#   Dice.new(sides)           -> one_d_sides_roll
	#   Dice.new()                -> one_d_six_roll
	# 
	def initialize( *args )
		@dice, @sides = if args.size == 2
			args
		elsif args.size == 1
			[1, args.first]
		else
			[1, 6]
		end
		
		@roll = Array.new(@dice) { rand(@sides) + 1 }
	end

  def roll
    @roll
  end
  
	# Fetch the die at the provided _index_.
	def []( index )
		@roll[index]
	end
	
	# 
	# Returns a count of all dice in the roll matching the provided
	# _pips_.
	# 
	def count( pips )
		@roll.inject(0) do |total, die|
			if die == pips then total + 1 else total end
		end
	end
	
	include Enumerable
	
	# Iterate over each die in the roll.
	def each( &block )
		@roll.each(&block)
	end
	
	# 
	# Count the number of "failure" dice in this roll.  A die is
	# a failure if it is less than or equal to the provided _maximum_.
	# 
	def fail( maximum )
		@roll.inject(0) do |total, die|
			if die <= maximum then total + 1 else total end
		end
	end

	# 
	# A call to matches?() allows _pattern_ matching for dice rolls.  A
	# _pattern_ may contain single-letter Strings and/or Integers.  
	# 
	# Strings are used to locate recurring die patterns.  For example, 
	# one could check for a full house with 
	# <tt>dice.matches?(*w{x x x y y})</tt>.
	# 
	# Integers can be used to locate sequences of dice.  For example,
	# one could check for a small straight with
	# <tt>dice.matches?(*(1..4).to_a)</tt>.
	# 
	def matches?( *pattern )
		digits, letters = pattern.partition { |e| e.is_a?(Integer) }
		matches_digits?(digits) and matches_letters?(letters)
	end

	# 
	# A call to this method will reroll the indicated dice.  Dice can be
	# selected by block or _indices_.
	# 
	# :call-seq:
	#   reroll(*indices)          -> dice
	#   reroll() { |die| ... }    -> dice
	# 
	def reroll( *indices )
		if block_given?
			@roll.each_with_index do |die, i|
				@roll[i] = rand(6) + 1 if yield(die)
			end
		elsif indices.empty?
			@roll = Array.new(@dice) { rand(@sides) + 1 }
		else
			indices.each { |i| @roll[i] = rand(6) + 1 }
		end
		
		self
	end
	
	# 
	# Count the number of "success" dice in this roll.  A die is
	# a success if it is greater than or equal to the provided 
	# _minimum_.
	# 
	def success( minimum )
		@roll.inject(0) do |total, die|
			if die >= minimum then total + 1 else total end
		end
	end
	
	# 
	# Returns a total sum of all dice in the roll matching the provided
	# _pips_.  If _pips_ is +nil+ (the default), all dice are totaled.
	# 
	def sum( pips = nil )
		if pips
			@roll.inject(0) do |total, die|
				if die == pips then total + die else total end
			end
		else
			@roll.inject(0) { |total, die| total + die }
		end
	end
	
	# Add the sum() of this roll to an Integer.
	def +( other ) sum + other end
	# Subtract the sum() of this roll from an Integer.
	def -( other ) sum - other end
	# Multiply the sum() of this roll to an Integer.
	def *( other ) sum * other end
	# Divide the sum() of this roll by an Integer.
	def /( other ) sum / other end
	
	# 
	# Support for using Dice objects in ordinary Ruby math.  Rolls are
	# added to an Integer or Float by sum().
	# 
	def coerce( other )
		if other.is_a? Integer
			[other, self.sum]
		else
			[Float(other), Float(self.sum)]
		end
	end

  def add_items(*items)
    @roll << items
    @roll.flatten!.compact!
  end
  
  alias_method :<<, :add_items
  
  def to_a
    return @roll
  end
  
	private
	
	# The "number pattern" half of matches?().
	def matches_digits?( digits )
		return true if digits.size < 2

		digits.sort!
		test = @roll.uniq.sort
		loop do
			(0..(@roll.length - digits.length)).each do |index|
				return true if test[index, digits.length] == digits
			end

			digits.collect! { |d| d + 1 }
			break if digits.last > 6	
		end

		false
	end

	# The "letter pattern" half of matches?().
	def matches_letters?( letters )
		return true if letters.size < 2

		counts = Hash.new(0)
		letters.each { |l| counts[l] += 1 }
		counts = counts.values.sort.reverse

		pips = @roll.uniq
		counts.each do |c|
			return false unless match = pips.find { |p| count(p) >= c }
			pips.delete(match)
		end

		true
	end
end

class Integer
	# 
	# A shortcut for rolling dice in a program.  For example:
	# 
	#   str = 3.d(6) + 2
	# 
	def d( sides )
		Dice.new(self, sides)
	end
end

class Array
  def summarize
    self.inject(0) do |sum, value|
      sum + value
    end
  end
end