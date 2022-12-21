require 'ostruct'
require_relative './utils/log'
require_relative './utils/show_help'

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

# Our first function
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

ShowHelp.call "\n\n# GenerateUserSignature use cases:"
ShowHelp.call "## With valid user_id & address_id -> GenerateUserSignature.call(user_id: 1, address_id: 1)\n"
ShowHelp.call ""
ShowHelp.call GenerateUserSignature.call(user_id: 1, address_id: 3)
ShowHelp.call ""
ShowHelp.call "## With valid user_id & invalid address_id -> GenerateUserSignature.call(user_id: 1, address_id: 99)"
ShowHelp.call ""
ShowHelp.call GenerateUserSignature.call(user_id: 1, address_id: 99)
ShowHelp.call ""
ShowHelp.call "## With invalid user_id & valid address_id -> GenerateUserSignature.call(user_id: 99, address_id: 3)"
ShowHelp.call ""
ShowHelp.call GenerateUserSignature.call(user_id: 99, address_id: 1)
ShowHelp.call ""
ShowHelp.call "## when DB errors -> GenerateUserSignature.call(user_ids: 1, address_id: :db_will_fail)"
ShowHelp.call ""
ShowHelp.call GenerateUserSignature.call(user_id: 1, address_id: :db_will_fail)

class PrintSignature
  class << self
    def call(user_id:, address_id:)
      default = 'not_signed'

      user_signature = begin
        GenerateUserSignature.call(user_id: user_id, address_id: address_id) || default
      rescue
        default
      end

      puts ''
      puts '<Signature>'
      puts user_signature.to_s
      puts '</Signature>'
      puts ''
    end
  end
end

ShowHelp.call "\n\n# PrintSignature use cases:"
ShowHelp.call "## With valid user_id & address_id -> PrintSignature.call(user_id: 1, address_id: 1)\n"
ShowHelp.call ""
ShowHelp.call PrintSignature.call(user_id: 1, address_id: 3)
ShowHelp.call ""
ShowHelp.call "## With valid user_id & invalid address_id -> PrintSignature.call(user_id: 1, address_id: 99)"
ShowHelp.call ""
ShowHelp.call PrintSignature.call(user_id: 1, address_id: 99)
ShowHelp.call ""
ShowHelp.call "## With invalid user_id & valid address_id -> PrintSignature.call(user_id: 99, address_id: 3)"
ShowHelp.call ""
ShowHelp.call PrintSignature.call(user_id: 99, address_id: 1)
ShowHelp.call ""
ShowHelp.call "## when DB errors -> PrintSignature.call(user_ids: 1, address_id: :db_will_fail)"
ShowHelp.call ""
ShowHelp.call PrintSignature.call(user_id: 1, address_id: :db_will_fail)

class ValidateSignature
  class << self
    def call(user_id:, address_id:)
      user_signature = GenerateUserSignature.call(user_id: user_id, address_id: address_id)

      if user_signature
        puts 'valid!'
      else
        Log.([
          "ValidationFail(",
          "user_id: #{user_id}, ",
          "address_id: #{address_id}, ",
          "failure: Either User or Address is nil)"
        ].join)
      end

    rescue => e
      Log.([
        "ValidationFail(",
        "user_id: #{user_id}, ",
        "address_id: #{address_id}, ",
        "failure: #{e.message})"
      ].join)
    end
  end
end

ShowHelp.call "\n\n# ValidateSignature use cases:"
ShowHelp.call "## With valid user_id & address_id -> ValidateSignature.call(user_id: 1, address_id: 1)\n"
ShowHelp.call ""
ShowHelp.call ValidateSignature.call(user_id: 1, address_id: 3)
ShowHelp.call ""
ShowHelp.call "## With valid user_id & invalid address_id -> ValidateSignature.call(user_id: 1, address_id: 99)"
ShowHelp.call ""
ShowHelp.call ValidateSignature.call(user_id: 1, address_id: 99)
ShowHelp.call ""
ShowHelp.call "## With invalid user_id & valid address_id -> ValidateSignature.call(user_id: 99, address_id: 3)"
ShowHelp.call ""
ShowHelp.call ValidateSignature.call(user_id: 99, address_id: 1)
ShowHelp.call ""
ShowHelp.call "## when DB errors -> ValidateSignature.call(user_ids: 1, address_id: :db_will_fail)"
ShowHelp.call ""
ShowHelp.call ValidateSignature.call(user_id: 1, address_id: :db_will_fail)

class PrintFamilySignature
  class << self
    def call(user_ids:, address_id:)
      users_signatures = user_ids.map { |user_id|
        GenerateUserSignature.call(user_id: user_id, address_id: address_id)
      }

      if users_signatures.all? { |signature| signature != nil }
        puts ''
        puts '<Family>'
        puts users_signatures
        puts '</Family>'
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

ShowHelp.call "\n\n# PrintFamilySignature use cases:"
ShowHelp.call "## With valid user_ids & address_id -> PrintFamilySignature.call(user_ids: [1,2], address_id: 1)\n"
ShowHelp.call ""
ShowHelp.call PrintFamilySignature.call(user_ids: [1,2], address_id: 3)
ShowHelp.call ""
ShowHelp.call "## With valid user_id & invalid address_id -> PrintFamilySignature.call(user_ids: [1, 2], address_id: 99)"
ShowHelp.call ""
ShowHelp.call PrintFamilySignature.call(user_ids: [1,2], address_id: 99)
ShowHelp.call ""
ShowHelp.call "## With invalid user_id & valid address_id -> PrintFamilySignature.call(user_ids: [99, 2], address_id: 99)"
ShowHelp.call ""
ShowHelp.call PrintFamilySignature.call(user_ids: [99,2], address_id: 3)
ShowHelp.call ""
ShowHelp.call "## when DB errors -> PrintFamilySignature.call(user_ids: [1, :db_will_fail], address_id: 3)"
ShowHelp.call ""
ShowHelp.call PrintFamilySignature.call(user_ids: [1,:db_will_fail], address_id: 3)
