module ActiveMerchant #:nodoc:
  module Billing #:nodoc
    class InvalidCardAccessResponseError < ActiveMerchantError
    end
    
    class CardAccessResponse < Billing::Response
      attr_reader :audit, :code, :status
      
      FAILURE_RESPONSES = ['01', '04', '05', '07', '14', '15', '19', '23', '31', '33', '34', '35', '36', '37', '38', '39', '40', '41', '42', '43', '44', '51', '52', '53', '54', '55', '57', '58', '59', '60', '61', '62', '64', '65', '66', '67', '75', '91', '92', '93', '98']
      
      MESSAGES = {
        '00' => 'Approved or completed successfully',
        '01' => 'Refer to card issuer',
        '02' => 'Refer to card issuers special conditions',
        '03' => 'Invalid merchant',
        '04' => 'Pick-up card',
        '05' => 'Do not honour',
        '06' => 'Error',
        '07' => 'Pick - up card, special condition',
        '08' => 'Honour with identification',
        '09' => 'Request in progress',
        '10' => 'Approved for partial amount',
        '11' => 'Approved VIP',
        '12' => 'Invalid transaction',
        '13' => 'Invalid amount',
        '14' => 'Invalid card number (no such number)',
        '15' => 'No such issuer',
        '16' => 'Approved, update Track 3',
        '17' => 'Customer cancellation',
        '18' => 'Customer dispute',
        '19' => 'Re - enter transaction',
        '20' => 'Invalid response',
        '21' => 'No action taken',
        '22' => 'Suspected malfunction',
        '23' => 'Unacceptable transaction fee',
        '24' => 'File update not supported by receiver',
        '25' => 'Unable to locate record on file',
        '26' => 'Duplicate file update record, old record replaced',
        '27' => 'File update field edit error',
        '28' => 'File update file locked out',
        '29' => 'File update not successful, contact acquirer',
        '30' => 'Format error',
        '31' => 'Bank not supported by switch',
        '32' => 'Completed partially',
        '33' => 'Expired card',
        '34' => 'Suspected fraud',
        '35' => 'Card acceptor contact acquirer',
        '36' => 'Restricted card',
        '37' => 'Card acceptor call acquirer security',
        '38' => 'Allowable PIN tries exceeded',
        '39' => 'No credit account',
        '40' => 'Request function not supported',
        '41' => 'Lost card',
        '42' => 'No universal account',
        '43' => 'Stolen card, pick up',
        '44' => 'No investment account',
        '45' => 'Reserved for ISO use',
        '46' => 'Reserved for ISO use',
        '47' => 'Reserved for ISO use',
        '48' => 'Reserved for ISO use',
        '49' => 'Reserved for ISO use',
        '50' => 'Reserved for ISO use',
        '51' => 'Not sufficient funds',
        '52' => 'No cheque account',
        '53' => 'No savings account',
        '54' => 'Expired card',
        '55' => 'Incorrect PIN',
        '56' => 'No card record',
        '57' => 'Transaction not permitted to cardholder',
        '58' => 'Transaction not permitted to terminal',
        '59' => 'Suspected fraud',
        '60' => 'Card acceptor contact acquirer',
        '61' => 'Exceeds withdrawal amount limits',
        '62' => 'Restricted card',
        '63' => 'Security violation',
        '64' => 'Original amount incorrect',
        '65' => 'Exceeds withdrawal frequency limit',
        '66' => 'Card acceptor call acquirer\'s security department',
        '67' => 'Hard capture (requires that card be picked up at ATM)',
        '68' => 'Response received too late',
        '69' => 'Reserved for ISO use',
        '70' => 'Reserved for ISO use',
        '71' => 'Reserved for ISO use',
        '72' => 'Reserved for ISO use',
        '73' => 'Reserved for ISO use',
        '74' => 'Reserved for ISO use',
        '75' => 'Allowable number of PIN tries exceeded',
        '76' => 'Reserved for private use',
        '77' => 'NB: ANZ merchants only',
        '78' => 'Reserved or private use',
        '79' => 'Reserved or private use',
        '80' => 'Reserved or private use',
        '81' => 'Reserved or private use',
        '82' => 'Reserved or private use',
        '83' => 'Reserved or private use',
        '84' => 'Reserved or private use',
        '85' => 'Reserved or private use',
        '86' => 'Reserved or private use',
        '87' => 'Reserved or private use',
        '88' => 'Reserved or private use',
        '89' => 'Reserved or private use',
        '90' => 'Cut - off is in process (Switch ending a day\'s business and starting the next. The transaction can be sent again in a few minutes)',
        '91' => 'Issuer or switch is inoperative',
        '92' => 'Financial institution or intermediate network facility cannot be found for routing',
        '93' => 'Transaction cannot be completed. Violation of law',
        '94' => 'Duplicate transmission',
        '95' => 'Reconcile error',
        '96' => 'System malfunction',
        '97' => 'Advises that reconciliation totals have been reset',
        '98' => 'MAC error',
        '99' => 'Reserved for national use',
        'A1' => 'Recursive Call',
        'A2' => 'General Failure',
        'A4' => 'Invalid Merchant',
        'A5' => 'Pinpad Offline',
        'A6' => 'Server Busy',
        'A7' => 'Internal Buffer',
        'A8' => 'Invalid Amount',
        'A9' => 'Invalid Card Number',
        'AA' => 'Invalid Account',
        'AB' => 'Invalid Expiry',
        'AC' => 'Card Expired',
        'AD' => 'Account Error',
        'AE' => 'Timeout',
        'AF' => 'Record Not Found',
        'B1' => 'Invalid RQ Type',
        'B2' => 'Unsupported Operation',
        'B3' => 'Client Offline',
        'B4' => 'Internal Buffer',
        'B5' => 'Invalid Amount',
        'B6' => 'Invalid Dialog',
        'B7' => 'Invalid TXNTYPE',
        'B8' => 'Invalid TXNREF',
        'BY' => 'Pinpad Busy',
        'D0' => 'Invalid AuthCode',
        'E2' => 'NO Previous TXN',
        'IN' => 'Initialised',
        'IP' => 'In progress',
        'P3' => 'System Error P3',
        'P6' => 'System Error P6',
        'P8' => 'System Error P8',
        'PF' => 'Pinpad Offline',
        'T1' => 'Card Unsupported',
        'T4' => 'System Error',
        'T5' => 'Over ceiling limit',
        'T6' => 'Account Error',
        'TF' => 'Init Required',
        'TG' => 'Display Error',
        'TH' => 'Printer Error',
        'TI' => 'Operator Timeout',
        'TJ' => 'System Error',
        'TL' => 'Signature Error',
        'U9' => 'No Response',
        'V9' => 'TXN Not Active',
        'W6' => 'Not Supported',
        'X0' => 'No Response',
        'X1' => 'Link Fail',
        'X2' => 'Error 09',
        'X3' => 'Error 01',
        'X4' => 'System Error',
        'X7' => 'Mac Error',
        'X8' => 'System Error',
        'X9' => 'System Error',
        'XA' => 'System Error',
        'XB' => 'System Error',
        'XC' => 'System Error',
        'Y3' => 'Unable to process',
        'Z0' => 'Modem Error',
        'Z1' => 'No Line',
        'Z2' => 'No Answer',
        'Z3' => 'Number Busy',
        'Z4' => 'Host No Invalid',
        'Z5' => 'Power Fail',
        'Z6' => 'No Carrier',
        'Z7' => 'Link Error',
        'ZZ' => 'Not processed',
        '77' => 'Reserved for private use',
        '' => 'The transaction had not yet proceeded to a point where the bank response code was available'
      }
      
      SUCCESS_RESPONSES = ['00', '08', '10', '11', '16', '77']
      
      def initialize(action, params = {}, options = {})
        super(nil, nil, params, options)
        
        @action = action
        @params = params.stringify_keys!
        @status = params['DE048'] || {}
        
        @amount = options[:amount]
        @merchant_id = options[:merchant_id]
        @original_audit = options[:original_audit]
        
        @audit = status['CAS.RESPONSE.AUDIT1'] || status['CAS.AUDIT'] # first response is CAS.RESPONSE.AUDIT1 all others are CAS.AUDIT
        @authorization = params['DE038']
        @code = status['CAS.RESPONSE.STATUSCODE']
        @message = [ MESSAGES[params['DE039']].presence, status['CAS.RESPONSE.MSG'].presence ].compact
        
        # Not supported by Australian banks, if the CVC is incorrect the response will be 'Declined'
        # @avs_result = AVSResult.new(options[:avs_result]).to_hash
        # @cvv_result = CVVResult.new(status['CAS.CARD.CVC']).to_hash
      end
      
      def success?
        params['DE042'] == @merchant_id &&
        if @action == :audit
          params['DE001'] == '0810' &&
          status['CAS.RESPONSE.AUDIT1'].present?
        else
          SUCCESS_RESPONSES.include?(params['DE039']) &&
          status['CAS.RESPONSE.STATUSCODE'] == '0' &&
          status['CAS.AUDIT'] == @original_audit &&
          params['DE004'] == @amount &&
          case @action
          when :authorize
            params['DE001'] == '0110'
          when :capture
            params['DE001'] == '0230'
          when :purchase
            params['DE001'] == '0210' && params['DE003'] == '003000'
          when :refund
            params['DE001'] == '0210' && params['DE003'] == '200030'
          end
        end
      end
    end
    
    class CardAccessGateway < Gateway
      
      TEST_URL = 'https://etx.cardaccess.com.au/casmtp/testcasmtp.php'
      LIVE_URL = 'https://etx.cardaccess.com.au/casmtp/casmtp.php'

      # The countries the gateway supports merchants from as 2 digit ISO country codes
      self.supported_countries = ['AU']

      # The card types supported by the payment gateway
      self.supported_cardtypes = [:american_express, :diners_club, :jcd, :master, :visa]

      # The homepage URL of the gateway
      self.homepage_url = 'http://cardaccess.com.au'

      # The name of the gateway
      self.display_name = 'CardAccessServices'

      self.money_format = :cents
      self.default_currency = 'AUD'

      def initialize(options = {})
        requires!(options, :merchant_id, :password)
        @merchant_id = options[:merchant_id] = options[:merchant_id].rjust(15, '0')
        @password = options[:password]
        @options = options
        super
      end

      def audit(money, options = {})
        post = {}
        add_headers(post, options)
        add_audit(post, options)
        add_security(post, options)

        commit(:audit, post)
      end
      
      def authorize(money, creditcard, options = {})
        response = audit(money, options)
        return response unless response.success?
        @audit = response.audit
        
        post = {}
        add_headers(post, options)
        add_authorize(post, money, creditcard, response)
        add_cas(post, response, creditcard)
        add_creditcard(post, creditcard)
        add_security(post, options)

        commit(:authorize, post)
      end

      def capture(money, creditcard, authorization, options = {})
        response = audit(money, options)
        return response unless response.success?
        @audit = response.audit
        
        post = {}
        add_headers(post, options)
        add_capture(post, money, creditcard, authorization, response)
        add_cas(post, response, creditcard)
        add_creditcard(post, creditcard)
        add_security(post, options)

        commit(:capture, post)
      end

      def purchase(money, creditcard, options = {})
        response = audit(money, options)
        return response unless response.success?
        @audit = response.audit
        
        post = {}
        add_headers(post, options)
        add_cas(post, response, creditcard)
        add_creditcard(post, creditcard)
        add_purchase(post, money, creditcard, response)
        add_security(post, options)

        commit(:purchase, post)
      end

      def refund(money, creditcard, original_audit, options = {})
        response = audit(money, options)
        return response unless response.success?
        @audit = response.audit
        
        post = {}
        add_headers(post, options)
        add_cas(post, response, creditcard, original_audit)
        add_creditcard(post, creditcard)
        add_refund(post, money, response)
        add_security(post, options)

        commit(:refund, post)
      end

      def test?
        @options[:test] || super
      end

    private
      
      def add_audit(post, options)
        post['DE001'] = '0800'
        post['DE048'] = { 'CAS.REQUEST.AUDIT' => '1' }
      end
      
      def add_authorize(post, amount, creditcard, response)
    		post['DE001'] = '0100'
    		post['DE004'] = @amount = amount.to_s
      end

      def add_capture(post, amount, creditcard, authorization, response)
    		post['DE001'] = '0220'
    		post['DE004'] = @amount = amount.to_s
    		post['DE038'] = authorization
      end

      def add_cas(post, response, creditcard = nil, original_audit = nil)
        cas = { 'CAS.AUDIT' => response.audit }
        cas['CAS.CARD.CVC'] = creditcard.verification_value if creditcard.present? && creditcard.verification_value.present?
        cas['CAS.REFUND.AUDIT'] = original_audit if original_audit.present?
        post['DE048'] = cas
      end
    
      def add_creditcard(post, creditcard)
    		post['DE002'] = creditcard.number
    		post['DE014'] = expiry_date(creditcard)
      end
      
      def add_headers(post, options)
        post['dataformat'] = 'HTTP_AS2805'
        post['DE042'] = @merchant_id
      end

      def add_purchase(post, amount, creditcard, response)
    		post['DE001'] = '0200'
    		post['DE003'] = '003000'
    		post['DE004'] = @amount = amount.to_s
      end
      
      def add_refund(post, amount, response)
    		post['DE001'] = '0200'
    		post['DE003'] = '200030'
    		post['DE004'] = @amount = amount.to_s
      end
      
      def add_security(post, options)
    		post["CAS_SECURITY_TIMESTAMP"] = Time.now.utc.strftime("%Y/%m/%d %H:%M:%S")

    		secure_post = post.clone
    		secure_de048 = secure_post["DE048"] || {}
    		secure_post["DE048"] = secure_de048.map { |k,v| "#{k}#{CGI.escape("=")}#{Base64.encode64(v || '').chomp}" }.join(CGI.escape("&"))
    		secure_post = secure_post.sort.map { |k,v| "#{k}=#{v}" }.join("&")
    		secure_post = OpenSSL::HMAC.hexdigest 'sha256', @password, secure_post
    		
    		post["CAS_SECURITY_VALUE"] = secure_post
    		post["CAS_SECURITY_TYPE"] = "hash"
      end

      def commit(action, parameters)
        url = test? ? TEST_URL : LIVE_URL
        response = parse(ssl_post(url, post_data(parameters)))
        
        CardAccessResponse.new(action, response,
          :amount => @amount,
          :merchant_id => @merchant_id,
          :original_audit => @audit,
          :test => test?
        )
      end
      
      def expiry_date(creditcard)
        format(creditcard.year, :two_digits) + format(creditcard.month, :two_digits)
      end

      def parse(data)
        response = data.split("\n")
        unless response.first.to_s + response.last.to_s == 'DESTARTDESTOP'
          raise(ActiveMerchant::Billing::InvalidCardAccessResponseError, 'Invalid response' + "\n" + data)
        end
        
        response = Hash[*data.scan(/([^\n=]*)=(.*)/).flatten]
        response['DE048'] ||= ''
        response['DE048'] = Hash[*response['DE048'].split("&").map { |x| x.scan(/([^\n=]*)=(.*)/).flatten }.flatten]
    		response['DE048'] = response['DE048'].each { |k,v| response['DE048'][k] = Base64.decode64(v).chomp }
    		response
      end

      def post_data(params)
        params.map do |key, value|
          next if value.blank?
          value = value.map { |k, v| "#{k}=#{Base64.encode64(v || '').chomp}" }.join("&") if value.is_a?(Hash)
          "#{key}=#{CGI.escape(value.to_s)}"
        end.compact.join("&")
      end
    end
  end
end
