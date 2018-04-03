module Services
  class ImportPaymentService

    def import_data(options)

      page, per_page, total, counter = 0, 25, 50, 0

      while(per_page* page < total)
        payments = options[:freshbooks].payment.list per_page: per_page, page: page+1
        return payments if payments.keys.include?('error')
        fb_payments = payments['payments']
        total = fb_payments['total'].to_i
        page+=1
        unless fb_payments['payment'].blank?

          fb_payments['payment'].each do |payment|
            payment = fb_payments['payment'] if total.eql?(1)
            unless ::Payment.find_by_provider_id(payment['payment_id'].to_i)

              hash = { created_at: payment['updated'], updated_at: payment['updated'], provider: 'Freshbooks',
                       provider_id: payment['payment_id'].to_i, payment_amount: payment['amount'],
                       payment_method: payment['type'], company_id: options[:current_company_id],
                       notes: payment['notes'], payment_date: payment['date']
                     }

              fb_payment = ::Payment.new(hash)
              fb_payment.client =  ::Client.find_by_provider_id(payment['client_id'].to_i) if payment['client_id'].present?
              fb_payment.invoice =  ::Invoice.find_by_provider_id(payment['invoice_id'].to_i) if payment['invoice_id'].present?
              fb_payment.save
              counter+=1
            end
          end
        end
      end
      "Payment #{counter} record(s) successfully imported."
    end

  end
end
