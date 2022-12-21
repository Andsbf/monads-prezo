require 'dry/monads'
require "ostruct"
require_relative './utils/log'

class User
  extend Dry::Monads[:result]

  def self.find(id)
    case id
    when 1..10
      Success(OpenStruct.new(name: "Ben #{id}"))

    when Symbol
      Failure(:user_db_error)

    else
      Failure(:user_not_found)
    end
  end
end

class Address
  extend Dry::Monads[:result]

  def self.find(id)
    case id
    when 1..10
      Success(OpenStruct.new(state: 'NSW'))

    when Symbol
      Failure(:address_db_error)

    else
      Failure(:address_not_found)
    end
  end
end

class GenerateUserSignature
  extend Dry::Monads[:do, :result]

  class << self
    def call(user_id:, address_id:)
      user = yield User.find(user_id)
      address = yield Address.find(address_id)

      Success("#{user.name} - #{address.state}")
    end
  end
end


class PrintSignature
  class << self
    def call(user_id:, address_id:)
      puts ''
      puts '########'
      puts '<FORM>'
      puts GenerateUserSignature.call(user_id: user_id, address_id: address_id).value_or('not_signed')
      puts '</FORM>'
      puts '########'
      puts ''
    end
  end
end

# PrintSignature.call(user_id: 99, address_id: 1)

class ValidateSignature
  class << self
    def call(user_id:, address_id:)
      GenerateUserSignature.call(user_id: user_id, address_id: address_id)
        .either(
          -> user_signature {
            Success(:valid)
          },
          -> failure {
            Log.([
              "NoPrintForReport(",
              "user_id: #{user_id}, ",
              "address_id: #{address_id}, ",
              "failure: #{failure})"
            ].join)

            Failure(:not_valid)
          }
        )
    end
  end
end

# ValidateSignature.call(user_id: 99, address_id: 1)

class PrintFamilySignature
  extend Dry::Monads[:do, :result]

  class << self
    def call(user_ids:, address_id:)
      print(user_ids: user_ids, address_id: address_id)
        .or { |failure|
          Log.([
            "NoPrintForParternsReport(",
            "user_ids: #{user_ids}, ",
            "address_id: #{address_id}, ",
            "failure: #{failure}"
          ].join)

          Failure(:not_printed)
        }
    end

    def print(user_ids:, address_id:)
      users_signatures = user_ids.map { |user_id|
        yield GenerateUserSignature.call(user_id: user_id, address_id: address_id)
      }

      puts ''
      puts '########'
      puts '<Family>'
      puts users_signatures
      puts '</Family>'
      puts '########'
      puts ''

      Success(:printed)
    end
  end
end

# PrintFamilySignature.call(user_ids: [1, :a], address_id: 1)
