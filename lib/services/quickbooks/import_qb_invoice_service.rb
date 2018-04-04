module Services
  class ImportQbInvoiceService
    include ItemsHelper
    include TaxesHelper

    def import_data(options)
      counter = 0

      qbo_api = QboApi.new(access_token: options[:token], realm_id: options[:realm_id])
      if qbo_api.all(:invoices).count > 0
        qbo_api.all(:invoices) do |invoice|
          begin
            if invoice.present?
            unless ::Invoice.find_by_provider_id(invoice['Id'].to_i)
              if invoice['Line'].last['DetailType'].eql?('DiscountLineDetail')
                discount_line_detail = invoice['Line'].last['DiscountLineDetail']
                discount_per =  discount_line_detail['DiscountPercent'] if discount_line_detail['PercentBased']
                discount_amount = invoice['Line'].last['Amount']
                discount_type = discount_line_detail['PercentBased'] ? '%' : invoice['CurrencyRef']['value']
              end
              invoice_attributes_hash = {
                                              terms:               nil,
                                              po_number:           nil,
                                              provider:            'Quickbooks',
                                              provider_id:         invoice['Id'].to_i,
                                              discount_type:       discount_type,
                                              notes:               invoice['PrivateNote'],
                                              discount_amount:     discount_amount,
                                              discount_percentage: discount_per,
                                              invoice_number:      invoice['DocNumber'],
                                              invoice_total:       invoice['TotalAmt'].to_f,
                                              company_id:          options[:current_company_id],
                                              invoice_date:        (invoice['ShipDate'] || invoice['MetaData']['CreateTime']).to_date,
                                              status:              invoice['EmailStatus'] == 'NotSet' ? 'Draft' : 'Sent',
                                        }
              osb_invoice=  ::Invoice.new(invoice_attributes_hash)
              qb_client = invoice['CustomerRef']['value']
              qb_currency = invoice['CurrencyRef']['value']
              osb_invoice.currency = ::Currency.find_by_unit(qb_currency) if invoice['CurrencyRef'].present? && qb_currency.present?
              osb_invoice.client = ::Client.find_by_provider_id(qb_client.to_i) if invoice['CustomerRef'].present? && qb_client.present?
              osb_invoice.save
              counter+=1
              amount = 0
              invoice['Line'].each do |item|
                if qb_item_name?(item['SalesItemLineDetail'])
                  amount += item['Amount'].to_f
                  qb_tax_id = invoice['TxnTaxDetail']['TaxLine'][0]['TaxLineDetail']['TaxRateRef']['value'] if qb_tax_rate?(invoice['TxnTaxDetail'])
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
                                item_quantity:    item['SalesItemLineDetail']['Qty'].to_i, tax_1: tax_1
                              }
                  osb_item = osb_invoice.invoice_line_items.new(item_hash)
                  osb_item.save
                end
              end
              osb_invoice.create_line_item_taxes
              osb_invoice.update_attributes(sub_total: amount)
            end
            end
          rescue Exception => e
            p e.inspect
          end
        end
      end
      data_import_result_message = "#{counter} record(s) successfully imported."
      module_name = 'Invoices'
      ::UserMailer.delay.qb_import_data_result(data_import_result_message, module_name, options[:user])
    end
  end
end
