module V1
  class RecurringFrequencyAPI < Grape::API
    version 'v1', using: :path, vendor: 'osb'
    format :json
    #prefix :api


    resource :recurring_frequencies do

      before {current_user}


      desc 'Return all Recurring Frequencies',
           headers: {
               "Access-Token" => {
                   description: "Validates your identity",
                   required: true
               }
           }
      get do
        RecurringFrequency.all
      end

    end
  end
end



