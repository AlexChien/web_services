require Rails.root.join('lib/BitShares/bitshares_api.rb').to_s

def init_bitshares_api(network)
  BitShares::API.init(Rails.application.secrets["#{network}_rpc_host"],
                      Rails.application.secrets["#{network}_rpc_port"],
                      Rails.application.secrets["#{network}_rpc_user"],
                      Rails.application.secrets["#{network}_rpc_password"],
                      logger: Rails.logger)
end

init_bitshares_api 'pls'
