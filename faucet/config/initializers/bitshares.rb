require Rails.root.join('lib/BitShares/bitshares_api.rb').to_s

BitShares::API.init(Rails.application.config.bitshares.pls_rpc_host,
                    Rails.application.config.bitshares.pls_rpc_port,
                    Rails.application.config.bitshares.pls_rpc_user,
                    Rails.application.config.bitshares.pls_rpc_password,
                    logger: Rails.logger)