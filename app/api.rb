require 'grape'
require 'grape_entity'

class API < Grape::API
  get :hello do
    {hello: "world"}
  end
end
