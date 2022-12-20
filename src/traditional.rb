require 'ostruct'
require_relative './utils/log'

class User
  class DbError < StandardError; end

  def self.find(id)
    case id
    when 1..10
      OpenStruct.new(name: "Rowdy #{id}")

    when Symbol
      raise DbError

    else
      nil
    end
  end
end

class Address
  class DbError < StandardError; end

  def self.find(id)
    case id
    when 1..10
      OpenStruct.new(state: 'QLD')

    when Symbol
      raise DbError

    else
      nil
    end
  end
end

class GenerateUserSignature
  class << self
    def call(user_id:, address_id:)
      user = User.find(user_id)
      address = Address.find(address_id)

      if user && address
        "#{user.name} - #{address.state}"
      else
        nil
      end
    end
  end
end

class PrintForm
  class << self
    def call(user_id:, address_id:)
      user_signature = begin
        GenerateUserSignature.call(user_id: user_id, address_id: address_id) || 'not_signed'
      rescue
        'not_signed'
      end

      puts ''
      puts '########'
      puts '<FORM>'
      puts user_signature.to_s
      puts '</FORM>'
      puts '########'
      puts ''
    end
  end
end

# PrintForm.call(user_id: 99, address_id: 1)

class PrintReport
  class << self
    def call(user_id:, address_id:)
      user_signature = GenerateUserSignature.call(user_id: user_id, address_id: address_id)

      if user_signature
        puts ''
        puts '########'
        puts '<FORM>'
        puts user_signature
        puts '</FORM>'
        puts '########'
        puts ''
      else
        Log.([
          "NoPrintForReport(",
          "user_id: #{user_id}, ",
          "address_id: #{address_id}, ",
          "failure: Either User or Address is nil)"
        ].join)
      end

    rescue => e
      Log.([
        "NoPrintForReport(",
        "user_id: #{user_id}, ",
        "address_id: #{address_id}, ",
        "failure: #{e.message})"
      ].join)
    end
  end
end

# PrintReport.call(user_id: 1, address_id: 99)

class PrintParternsReport
  class << self
    def call(user_ids:, address_id:)
      users_signatures = user_ids.map { |user_id|
        GenerateUserSignature.call(user_id: user_id, address_id: address_id)
      }

      if users_signatures.all? { |signature| signature != nil }
        puts ''
        puts '########'
        puts '<FORM>'
        puts users_signatures
        puts '</FORM>'
        puts '########'
        puts ''
      else
        Log.([
          "NoPrintForParternsReport(",
          "user_ids: #{user_ids}, ",
          "address_id: #{address_id}, ",
          "failure: Either one ofthe Users or Address is nil"
        ].join)
      end

    rescue => e
      Log.([
        "NoPrintForParternsReport(",
        "user_ids: #{user_ids}, ",
        "address_id: #{address_id}, ",
        "failure: #{e.message}"
      ].join)
    end
  end
end

# PrintParternsReport.call(user_ids: [1,:a], address_id: 1)
