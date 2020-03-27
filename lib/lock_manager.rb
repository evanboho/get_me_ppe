module LockManager
  class LockAcquisitionTimeoutError < StandardError
  end

  def self.with_lock(str, timeout: nil)
    Rails.logger.info "Acquiring lock for #{str}"
    start_time = Time.now
    number = str.to_i(36)
    while !(lock = get_lock(number)) do
      if timeout.nil? || (Time.now - start_time > timeout)
        Rails.logger.info("Could not acquire lock for #{str}. Aborting.")
        raise LockAcquisitionTimeoutError
      end
      sleep 0.1
    end

    begin
      yield
    ensure
      conn.execute "select pg_advisory_unlock(#{number});"
    end
  end

  def self.get_lock(number)
    conn.select_value("select pg_try_advisory_lock(#{number});")
  end

  def self.conn
    ActiveRecord::Base.connection
  end
end

