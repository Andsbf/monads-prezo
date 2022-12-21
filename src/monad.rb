require 'dry/monads'
require "ostruct"
require_relative './utils/log'
require_relative './utils/show_help'

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

# Our first function
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
ShowHelp.call GenerateUserSignature.call(user_id: 1, address_id: 3)

# Another function
class PrintSignature
  extend Dry::Monads[:result]

  class << self
    def call(user_id:, address_id:)
      puts ''
      puts '<Signature>'
      puts GenerateUserSignature.call(user_id: user_id, address_id: address_id).value_or('not_signed')
      puts '</Signature>'
      puts ''

      Success(:printed)
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
ShowHelp.call PrintSignature.call(user_id: 1, address_id: 3)

class ValidateSignature
  extend Dry::Monads[:result]

  class << self
    def call(user_id:, address_id:)
      GenerateUserSignature.call(user_id: user_id, address_id: address_id)
        .either(
          -> _{
            Success(:valid)
          },
          -> failure {
            Log.([
              "ValidationFail(",
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
ShowHelp.call ValidateSignature.call(user_id: 1, address_id: 3)

class PrintFamilySignature
  extend Dry::Monads[:do, :result]

  class << self
    def call(user_ids:, address_id:)
      print(user_ids: user_ids, address_id: address_id)
        .or { |failure|
          Log.([
            "PrintFamilySignatureFail(",
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
      puts '<Family>'
      puts users_signatures
      puts '</Family>'
      puts ''

      Success(:printed)
    end
  end
end

ShowHelp.call "\n\n# PrintFamilySignature use cases:"
ShowHelp.call "## With valid user_ids & address_id -> PrintFamilySignature.call(user_ids: [1,2], address_id: 1)\n"
ShowHelp.call ""
ShowHelp.call PrintFamilySignature.call(user_ids: [1,2], address_id: 3)
ShowHelp.call ""
ShowHelp.call "## With valid user_id & invalid address_id -> PrintFamilySignature.call(user_id: 1, address_id: 99)"
ShowHelp.call ""
ShowHelp.call PrintFamilySignature.call(user_ids: [1,2], address_id: 99)
ShowHelp.call ""
ShowHelp.call "## With invalid user_id & valid address_id -> PrintFamilySignature.call(user_id: 1, address_id: 99)"
ShowHelp.call ""
ShowHelp.call PrintFamilySignature.call(user_ids: [99,2], address_id: 3)
ShowHelp.call ""
ShowHelp.call "## when DB errors -> PrintFamilySignature.call(user_ids: 1, address_id: :db_will_fail)"
ShowHelp.call ""
ShowHelp.call PrintFamilySignature.call(user_ids: [1,:db_will_fail], address_id: 3)
