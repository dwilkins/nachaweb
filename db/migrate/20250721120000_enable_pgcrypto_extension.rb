# Enables the pgcrypto extension for UUID generation.
class EnablePgcryptoExtension < ActiveRecord::Migration[8.0]
  def change
    enable_extension 'pgcrypto' unless extension_enabled?('pgcrypto')
  end
end
