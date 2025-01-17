require 'spec_helper'
require 'rspec-puppet/facter_impl'

describe RSpec::Puppet::FacterTestImpl do
  subject(:facter_impl) { RSpec::Puppet::FacterTestImpl.new }
  let(:fact_hash) do
    {
      'string_fact' => 'string_value',
      'hash_fact' => { 'key' => 'value' },
      'int_fact' => 3,
      'true_fact' => true,
      'false_fact' => false,
    }
  end

  before do
    facter_impl.add(:string_fact) { setcode { 'string_value' } }
    facter_impl.add(:hash_fact) { setcode { { 'key' => 'value' } } }
    facter_impl.add(:int_fact) { setcode { 3 } }
    facter_impl.add(:true_fact) { setcode { true } }
    facter_impl.add(:false_fact) { setcode { false } }
  end

  describe 'noop methods' do
    [:debugging, :reset, :search, :setup_logging].each do |method|
      it "implements ##{method}" do
        expect(facter_impl).to respond_to(method)
      end
    end
  end

  describe '#value' do
    it 'retrieves a fact of type String' do
      expect(facter_impl.value(:string_fact)).to eq('string_value')
    end

    it 'retrieves a fact of type Hash' do
      expect(facter_impl.value(:hash_fact)).to eq({ 'key' => 'value' })
    end

    it 'retrieves a fact of type Integer' do
      expect(facter_impl.value(:int_fact)).to eq(3)
    end

    it 'retrieves a fact of type TrueClass' do
      expect(facter_impl.value(:true_fact)).to eq(true)
    end

    it 'retrieves a fact of type FalseClass' do
      expect(facter_impl.value(:false_fact)).to eq(false)
    end
  end

  describe '#to_hash' do
    it 'returns a hash with all added facts' do
      expect(facter_impl.to_hash).to eq(fact_hash)
    end
  end

  describe '#clear' do
    it 'clears the fact hash' do
      facter_impl.clear
      expect(facter_impl.to_hash).to be_empty
    end
  end

  describe '#add' do
    before { facter_impl.clear }

    it 'adds a fact with a setcode block' do
      facter_impl.add(:setcode_block) { setcode { 'value' } }
      expect(facter_impl.value(:setcode_block)).to eq('value')
    end

    it 'adds a fact with a setcode string' do
      facter_impl.add(:setcode_string) { setcode 'value' }
      expect(facter_impl.value(:setcode_string)).to eq('value')
    end

    it 'fails when not given a block' do
      expect { facter_impl.add(:something) }.to raise_error(RuntimeError, 'Facter.add expects a block')
    end
  end
end
