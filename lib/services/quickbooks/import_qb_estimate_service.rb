module Services
  class ImportQbEstimateService
    include ItemsHelper
    include TaxesHelper

    def import_data(options)
      counter = 0

      qbo_api = QboApi.new(access_token: options[:token], realm_id: options[:realm_id])
      qbo_api.all(:estimates).each do |estimate|
        begin
          if estimate.present?
          unless ::Estimate.find_by_provider_id(estimate['Id'].to_i)
            if estimate['Line'].last['DetailType'].eql?('DiscountLineDetail')
              discount_per =  estimate['Line'].last['DiscountLineDetail']['DiscountPercent'] if estimate['Line'].last['DiscountLineDetail']['PercentBased']
              discount_amount = estimate['Line'].last['Amount']
              discount_type = estimate['Line'].last['DiscountLineDetail']['PercentBased'] ? '%' : estimate['CurrencyRef']['value']
            end
            estimate_hash = {
                               terms: nil,
                               po_number: nil,
                               provider: 'Quickbooks',
                               discount_type: discount_type,
                               notes: estimate['PrivateNote'],
                               discount_amount: discount_amount,
                               provider_id: estimate['Id'].to_i,
                               discount_percentage: discount_per,
                               estimate_number: estimate['DocNumber'],
                               company_id: options[:current_company_id],
                               estimate_total: estimate['TotalAmt'].to_f,
                               status: estimate['EmailStatus'] == 'NotSet' ? 'Draft' : 'Sent',
                               estimate_date: (estimate['ShipDate'] || estimate['MetaData']['CreateTime']).to_date,
                            }
            osb_estimate =  ::Estimate.new(estimate_hash)
            qb_currency = estimate['CurrencyRef']
            qb_client = estimate['CustomerRef']
            osb_estimate.currency = ::Currency.find_by_unit(qb_currency['value']) if qb_currency.present? && qb_currency['value'].present?
            osb_estimate.client = ::Client.find_by_provider_id(qb_client['value'].to_i) if qb_client.present? && qb_client['value'].present?
            osb_estimate.save
            counter+=1
            amount = 0
            estimate['Line'].each do |item|
              if qb_item_name?(item['SalesItemLineDetail'])
                amount += item['Amount'].to_f
                qb_tax_id = estimate['TxnTaxDetail']['TaxLine'][0]['TaxLineDetail']['TaxRateRef']['value'] if qb_tax_rate?(estimate['TxnTaxDetail'])
                if qb_tax_id.present?
                  qb_tax = qbo_api.query(%{SELECT * FROM TaxRate  WHERE Id = '#{qb_tax_id.to_i}'}).first
                  osb_tax = ::Tax.find_by_name_and_percentage(qb_tax['Name'], qb_tax['RateValue'].to_f)
                  if osb_tax.present?
                    tax_1 = osb_tax.id
                  else
                    new_tax = ::Tax.create(name: qb_tax['Name'], percentage: qb_tax['RateValue'].to_f)
                    tax_1 = new_tax.id
                  end
                end
                item_hash = {
                              item_name:        item['SalesItemLineDetail']['ItemRef']['name'],
                              item_description: item['Description'],
                              item_unit_cost:   item['SalesItemLineDetail']['UnitPrice'].to_f,
                              item_quantity:    item['SalesItemLineDetail']['Qty'].to_i,
                              tax_1:            tax_1
                            }
                osb_item = osb_estimate.estimate_line_items.new(item_hash)
                osb_item.save
              end
            end
            osb_estimate.create_line_item_taxes
            osb_estimate.update_attributes(sub_total: amount)
          end
        end
        rescue Exception => e
          p e.inspect
        end
      end
      data_import_result_message = "#{counter} record(s) successfully imported."
      module_name = 'Estimates'
      ::UserMailer.delay.qb_import_data_result(data_import_result_message, module_name, options[:user])
    end
  end
end
