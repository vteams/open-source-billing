require 'rails_helper'

describe Category do
  let(:category) do
    Category.new(category:'valid Category')
  end

  it '# has valid category name' do
    expect(category.category).to eq('valid Category')
  end
end