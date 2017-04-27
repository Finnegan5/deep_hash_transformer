require 'deep_hash_transformer/version'

class DeepHashTransformer
  attr_reader :hash

  OPS = {
    dasherize:  ->(val) { val.to_s.tr('_'.freeze, '-'.freeze) },
    identity:   ->(val) { val },
    stringify:  ->(val) { val.to_s },
    symbolize:  ->(val) { val.to_sym },
    underscore: ->(val) { val.to_s.tr('-'.freeze, '_'.freeze) }
  }.freeze

  def initialize(hash)
    @hash = hash
  end

  def tr(*ops)
    transform_value(hash, ops)
  end

  OPS.keys.each do |operation|
    define_method(operation) { tr(operation) }
  end

  private

  attr_reader :hash

  def transform_value(value, ops)
    case value
    when Array
      value.map { |e| transform_value(e, ops) }
    when Hash
      value.map { |k, v| [transform_key(k, ops), transform_value(v, ops)] }.to_h
    else
      value
    end
  end

  def transform_key(key, ops)
    return key unless [String, Symbol].include?(key.class)

    ops.inject(key) { |k, op| OPS.fetch(op).call(k) }
  end
end