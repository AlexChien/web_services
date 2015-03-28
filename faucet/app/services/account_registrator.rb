class AccountRegistrator
  def initialize(user, logger)
    @user = user
    @logger = logger
  end

  def register(account_name, account_key, owner_key, referrer)
    @account = @user.pls_accounts.where(name: account_name).first
    @result = {account_name: account_name}

    if @account
      @result[:error] = "Account '#{account_name}' is already registered"
      return @result
    end

    if @user.pls_accounts.count >= Rails.application.secrets.registrations_limit
      @result[:error] = 'Account cannot be registered. You are running out of your limit of free account registrations.'
      return @result
    end

    begin
      account_created = case account_key.upcase.first(3)
        when 'PLS'
        register_pls(account_name, account_key, owner_key)
        @user.pls_accounts.create(name: account_name, key: account_key, referrer: referrer)
      when 'BTS'
        register_bts(account_name, account_key, owner_key)
        @user.bts_accounts.create(name: account_name, key: account_key, referrer: referrer)
      when 'DVS'
        register_dvs(account_name, account_key, owner_key)
        @user.dvs_accounts.create(name: account_name, key: account_key, referrer: referrer)
      end

      if account_created.nil? || !account_created.persisted? || !account_created.errors.empty?
        error_msg = account_created.try(:errors).try(:full_messages)
        @result[:error] = error_msg
        @logger.error("!!! Error. Cannot register account #{account_name} - #{error_msg}")
      end
      # account_key.start_with?('DVS') ? register_dvs(account_name, account_key, owner_key) : register_bts(account_name, account_key, owner_key)
      # @user.bts_accounts.create(name: account_name, key: account_key, referrer: referrer)
    rescue BitShares::API::Rpc::Error => ex
      @result[:error] = ex.to_s
      @logger.error("!!! Error. Cannot register account #{account_name} - #{ex.to_s}")
    rescue Errno::ECONNREFUSED => e
      @logger.error("!!! Error. No rpc connection to BitShares toolkit - (#{ex.to_s})")
      if Rails.env.development?
        @user.pls_accounts.create(name: account_name, key: account_key, owner_key: owner_key, referrer: referrer)
      else
        @result[:error] = "No rpc connection to BitShares toolkit"
      end
    end
    @result
  end

  private

  def register_pls(account_name, account_key, owner_key)
    return false if account_name.length < 7
    BitShares::API.rpc.request('request_register_account_with_key', [account_name, account_key])
  end

  def register_bts(account_name, account_key, owner_key)
    bts_rpc_instance = BitShares::API::Rpc.new(
      Rails.application.secrets.bitshares.bts_rpc_port,
      Rails.application.secrets.bts_rpc_user,
      Rails.application.secrets.bts_rpc_password,
      logger: Rails.logger, instance_name: 'btsrpc')

    bts_rpc_instance.request('wallet_add_contact_account', [account_name, account_key])
    account = dvs_rpc_instance.request('wallet_get_account', [account_name])
    account['owner_key'] = owner_key if owner_key
    account['meta_data'] = {'type' => 'public_account', 'data' => ''}
    dvs_rpc_instance.request('request_register_account', [account])
  end

  def register_dvs(account_name, account_key, owner_key)
    dvs_rpc_instance = BitShares::API::Rpc.new(
      Rails.application.secrets.dvs_rpc_port,
      Rails.application.secrets.dvs_rpc_user,
      Rails.application.secrets.dvs_rpc_password,
      logger: Rails.logger, instance_name: 'dvsrpc')

    dvs_rpc_instance.request('wallet_add_contact_account', [account_name, account_key])
    account = dvs_rpc_instance.request('wallet_get_account', [account_name])
    account['owner_key'] = owner_key if owner_key
    account['meta_data'] = {'type' => 'public_account', 'data' => ''}
    dvs_rpc_instance.request('request_register_account', [account])
  end

end
