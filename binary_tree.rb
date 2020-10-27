require 'pry'

class Node
  attr_accessor :value, :right, :left
  include Comparable
  def initialize(value)
    @value = value
    @left = nil
    @right = nil
  end

  def <=>(other)
    @value <=> other.value
  end

  def print_node
    puts '-----------'
    puts "|         |"
    puts "|     #{value}   |"
    puts "|         |"
    puts '-----------'
  end

end

class Tree
  def initialize(array)
    @root = build_tree(array)
  end

  def build_tree(array)
    array = array.sort.uniq
    mid = array.length/2
    root = Node.new(array[mid])
    return root if mid == 0

    root.left = build_tree(array[0..mid - 1])
    root.right = build_tree(array[mid + 1..-1]) if mid != 1
    root
  end

  def is_leaf?(node)
    if node.right.nil? && node.left.nil?
      return true
    else
      return false
    end
  end

  def insert(value, current_node = @root)
    if @root.nil?
      @root = Node.new(value)
      return nil
    end
    if value == current_node.value
      return nil
    elsif value < current_node.value
      if current_node.left.nil?
        current_node.left = Node.new(value)
      else
        insert(value, current_node.left)
      end
    else # its bigger
      if current_node.right.nil?
        current_node.right = Node.new(value)
      else
        insert(value, current_node.right)
      end
    end
  end

  def delete(value, current_node = @root, previous_node = @root)
    current_node.print_node
    if value == current_node.value # achou o valor que precisa ser deletado
      puts "achei o que precisoo deletar"
      if current_node.left.nil? && current_node.right.nil? # sem filhos
        if previous_node.left == current_node # veio da direita ou esquerda
          previous_node.left = nil
        else
          previous_node.right = nil
        end
      elsif current_node.right.nil? # tem  apenas filho na esquerda
        if previous_node.left == current_node 
          previous_node.left = current_node.left
        else
          previous_node.right = current_node.left
        end
      elsif current_node.left.nil? # tem apenas filho na direta
        if previous_node.left == current_node
          previous_node.left = current_node.right
        else
          previous_node.right = current_node.right
        end
      else # tem dois filhos 
        most_left_node = current_node.right
        most_right_node = most_left_node
        until most_left_node.left.nil?
          most_left_node = most_left_node.left
        end
        if previous_node.left == current_node
          previous_node.left = most_left_node
          most_right_node.left = most_left_node.right
          most_left_node.left = current_node.left
          most_left_node.right = current_node.right
          delete(most_left_node.value, current_node, current_node)
        else
          previous_node.right = most_left_node
          most_right_node.left = most_left_node.right
          most_left_node.left = current_node.left
          most_left_node.right = current_node.right
          delete(most_left_node.value, current_node, current_node)
        end
      end
    else
      if value < current_node.value # recursao para a direita
        if current_node.left.nil?
          return nil
        else
          delete(value, current_node.left, current_node)
        end
      else # recursao para a esquerda
        if current_node.right.nil?
          return nil
        else
          delete(value, current_node.right, current_node)
        end
      end
    end
  end

  def find(value, current_node = @root)
    return nil if current_node.nil?
    return current_node if value == current_node.value
    if value < current_node.value
      find(value, current_node.left)
    elsif value > current_node.value
      find(value, current_node.right)
    else
      return nil
    end
  end

  def level_order_iterative
    return nil if @root.nil?

    queue = [@root]
    result_array = []
    until queue.empty?
      current_node = queue.pop
      result_array.push(current_node.value)
      if current_node.left
        queue.unshift(current_node.left)
      end
      if current_node.right
        queue.unshift(current_node.right)
      end
    end
    return result_array
  end

  def inorder(current_node = @root, result_array = [])
    return nil if current_node.nil?

    inorder(current_node.left, result_array)
    result_array.push(current_node.value)
    inorder(current_node.right, result_array)
    return result_array
  end

  def preorder(current_node = @root, result_array = [])
    return nil if current_node.nil?

    result_array.push(current_node.value)
    preorder(current_node.left, result_array)
    preorder(current_node.right, result_array)
    return result_array
  end

  def postorder(current_node = @root, result_array = [])
    return nil if current_node.nil?

    postorder(current_node.left, result_array)
    postorder(current_node.right, result_array)
    result_array.push(current_node.value)
    return result_array
  end

  def height(node)
    return 0 if node.nil?

    max_height = []
    max_height << height(node.left)
    max_height << height(node.right)
    max_height = max_height.max + 1
  end

  def depth(node)
    return 0 if node.nil?

    return 1 if node.left.nil? && node.right.nil?
    max_depth = []
    max_depth.push(depth(node.left))
    max_depth.push(depth(node.right))
    max_depth = 1 + max_depth.max
  end

  def balanced?(node = @root)
    return true if node.nil?

    if balanced?(node.left) && balanced?(node.right)
      left_height = height(node.left)
      right_height = height(node.right)
      (left_height - right_height).abs < 2
    else
      return false
    end
  end

  def rebalance
    return Tree is already balanced! if balanced?(@root)

    ordered_elements = level_order_iterative
    @root = build_tree(ordered_elements)
  end




  def pretty_print(node = @root, prefix = '', is_left = true)
    pretty_print(node.right, "#{prefix}#{is_left ? '│   ' : '    '}", false) if node.right
    puts "#{prefix}#{is_left ? '└── ' : '┌── '}#{node.value}"
    pretty_print(node.left, "#{prefix}#{is_left ? '    ' : '│   '}", true) if node.left
  end
end

test_tree = Tree.new(Array.new(15) { rand(1..100) }) # cria uma árvore com elementos aleatórios
test_tree.pretty_print
test_tree.balanced?

15.times { test_tree.insert(rand(100..200)) }
test_tree.pretty_print
test_tree.balanced?
test_tree.rebalance
test_tree.balanced?

test_tree.pretty_print

binding.pry
